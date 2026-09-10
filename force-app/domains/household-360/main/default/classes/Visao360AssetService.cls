/**
 * @description Inventario e detalhe volatil de ativos da Visao 360 (T-C03).
 * getCustomerAssets: SOQL em Asset + RecordTypes por familia (ativos e
 * inativos, sem SOQL dinamica insegura). fetchRealtimeData: callout ao core
 * por tipo de ativo, somente sob demanda, com retry EXPLICITO via botao
 * (sem loop automatico). Volatil nunca persiste: nenhum DML aqui (RN-04).
 * Mock-first: com Visao360Mock__c ligado, serve fixtures sem callout e sem DML.
 */
public with sharing class Visao360AssetService {

    public static final String NC_CORE = 'NC_Visao360_Core';
    public static final Integer TIMEOUT_MS = 3000;

    public static final String FAM_CARTAO = 'CARTAO';
    public static final String FAM_CONTA = 'CONTA';
    public static final String FAM_CONSORCIO = 'CONSORCIO';
    public static final String FAM_INVEST = 'INVEST';

    private static final Map<String, String> FAMILIA_POR_PRODUCTTYPE = new Map<String, String>{
        'CARTAO' => FAM_CARTAO,
        'CONTA_DIGITAL' => FAM_CONTA,
        'CONSORCIO' => FAM_CONSORCIO,
        'INVESTIMENTOS' => FAM_INVEST
    };

    /**
     * @description Inventario da raiz: ativos e inativos por familia.
     * Familia derivada de ProductType__c (o objeto Asset padrao nao suporta
     * RecordTypes — T-A01 adaptado; ver build-report). Sem SOQL dinamica.
     * @param accountId Id da Account raiz.
     */
    public static Visao360DTOs.AssetsResult getCustomerAssets(Id accountId) {
        Visao360DTOs.AssetsResult result = new Visao360DTOs.AssetsResult();
        if (accountId == null) {
            result.fault = new Visao360DTOs.ApiFaultDTO('VISAO360', 'INVALID_INPUT', 'Conta raiz não informada.');
            return result;
        }
        if (Visao360Mock.isEnabled()) {
            String doc = docDaConta(accountId);
            if (String.isBlank(doc)) {
                result.fault = new Visao360DTOs.ApiFaultDTO('VISAO360', 'NOT_FOUND', 'Conta raiz sem documento.');
                return result;
            }
            result.items = Visao360Mock.mockAssets(doc);
            return result;
        }
        List<Asset> ativos;
        try {
            ativos = [
                SELECT Id, Name, AccountId, Status, ExternalContractId__c,
                    ProductType__c, CardBrand__c, CardCategory__c,
                    Last4__c, HolderName__c, ViaStatus__c, ConsorcioGrupo__c,
                    ConsorcioCota__c, ConsorcioTipo__c, Contemplacao__c,
                    InvestClasse__c, InvestProduto__c, Rentabilidade__c,
                    Vencimento__c, ValorContrato__c
                FROM Asset
                WHERE AccountId = :accountId
                WITH USER_MODE
                ORDER BY Name
            ];
        } catch (QueryException e) {
            result.fault = new Visao360DTOs.ApiFaultDTO('VISAO360', 'QUERY_ERROR', 'Inventário indisponível no momento.');
            return result;
        }
        for (Asset a : ativos) {
            result.items.add(toSummary(a));
        }
        return result;
    }

    /**
     * @description Detalhe volatil sob demanda (limites/fatura, saldo/PIX,
     * assembleia, rentabilidade conforme a familia). Falha vira fault para
     * banner + retry; nunca excecao para a UI (Cen 8, 9, RN-07).
     * @param contractNumber ExternalContractId__c do ativo.
     * @param family CARTAO, CONTA, CONSORCIO ou INVEST.
     * @param retry true quando o operador acionou Tentar Novamente.
     */
    public static Visao360DTOs.RealtimeResult fetchRealtimeData(String contractNumber, String family, Boolean retry) {
        Visao360DTOs.RealtimeResult result = new Visao360DTOs.RealtimeResult();
        if (String.isBlank(contractNumber)) {
            result.fault = new Visao360DTOs.ApiFaultDTO('VISAO360', 'INVALID_INPUT', 'Contrato não informado.');
            return result;
        }
        if (Visao360Mock.isEnabled()) {
            return Visao360Mock.mockRealtime(contractNumber, family, retry);
        }
        Visao360HttpService.CallResult callout = Visao360HttpService.get(
            NC_CORE, EncodingUtil.urlEncode(contractNumber, 'UTF-8') + '/realtime', TIMEOUT_MS);
        if (!callout.isSuccess) {
            result.fault = callout.fault;
            return result;
        }
        parseRealtime(callout.response.getBody(), family, result);
        return result;
    }

    /** Payload esperado: {tipo, limiteTotal, limiteDisponivel, faturaAtual, vencimento, melhorDiaCompra, saldo, agenciaConta, chavesPix[], grupoCota, saldoDevedor, parcela, proximaAssembleia, contemplacao, produto, valorAplicado, rentabilidade, aviso}. */
    public static void parseRealtime(String body, String family, Visao360DTOs.RealtimeResult result) {
        if (String.isBlank(body)) {
            result.fault = new Visao360DTOs.ApiFaultDTO(NC_CORE, 'EMPTY_BODY', 'Core respondeu sem conteúdo.');
            return;
        }
        Map<String, Object> m;
        try {
            m = (Map<String, Object>) JSON.deserializeUntyped(body);
        } catch (JSONException e) {
            result.fault = new Visao360DTOs.ApiFaultDTO(NC_CORE, 'INVALID_JSON', 'Detalhe em formato inesperado.');
            return;
        }
        Visao360DTOs.AssetRealtimeDTO d = new Visao360DTOs.AssetRealtimeDTO();
        d.tipo = String.isBlank(valueOf(m, 'tipo')) ? family : valueOf(m, 'tipo');
        d.limiteTotal = valueOf(m, 'limiteTotal');
        d.limiteDisponivel = valueOf(m, 'limiteDisponivel');
        d.faturaAtual = valueOf(m, 'faturaAtual');
        d.vencimento = valueOf(m, 'vencimento');
        d.melhorDiaCompra = valueOf(m, 'melhorDiaCompra');
        d.saldo = valueOf(m, 'saldo');
        d.agenciaConta = valueOf(m, 'agenciaConta');
        d.chavesPix = maskPixKeys(stringsOf(m, 'chavesPix'));
        d.grupoCota = valueOf(m, 'grupoCota');
        d.saldoDevedor = valueOf(m, 'saldoDevedor');
        d.parcela = valueOf(m, 'parcela');
        d.proximaAssembleia = valueOf(m, 'proximaAssembleia');
        d.contemplacao = valueOf(m, 'contemplacao');
        d.produto = valueOf(m, 'produto');
        d.valorAplicado = valueOf(m, 'valorAplicado');
        d.rentabilidade = valueOf(m, 'rentabilidade');
        d.aviso = valueOf(m, 'aviso');
        d.atualizadoEm = Datetime.now().format('HH:mm:ss');
        result.detail = d;
    }

    // =================================================================
    // Privados
    // =================================================================

    private static String docDaConta(Id accountId) {
        List<Account> contas = [
            SELECT Document__c FROM Account WHERE Id = :accountId WITH USER_MODE LIMIT 1
        ];
        if (contas.isEmpty()) {
            return null;
        }
        return Visao360Mock.normalizeDoc(contas[0].Document__c);
    }

    private static Visao360DTOs.AssetSummaryDTO toSummary(Asset a) {
        Visao360DTOs.AssetSummaryDTO s = new Visao360DTOs.AssetSummaryDTO();
        s.assetId = a.Id;
        s.contractNumber = a.ExternalContractId__c;
        s.recordTypeName = null;
        s.productFamily = FAMILIA_POR_PRODUCTTYPE.containsKey(a.ProductType__c)
            ? FAMILIA_POR_PRODUCTTYPE.get(a.ProductType__c)
            : a.ProductType__c;
        s.label = a.Name;
        s.status = String.isBlank(a.ViaStatus__c)
            ? (String.isBlank(a.Status) ? '—' : a.Status)
            : a.ViaStatus__c;
        s.maskedId = maskedId(a, s.productFamily);
        s.numero = s.maskedId;
        s.valor = valorResumo(a, s.productFamily);
        s.encerramento = String.valueOf(a.get('Vencimento__c') == null ? '—' : a.get('Vencimento__c'));
        s.ultimaMov = '—';
        return s;
    }

    private static String maskedId(Asset a, String family) {
        if (family == FAM_CARTAO) {
            String last4 = String.isBlank(a.Last4__c) ? '••••' : a.Last4__c;
            return 'final ' + last4 + ' • ' + nvl(a.HolderName__c);
        }
        if (family == FAM_CONSORCIO) {
            return 'Grupo ' + nvl(a.ConsorcioGrupo__c) + ' • Cota ' + nvl(a.ConsorcioCota__c);
        }
        return nvl(a.ExternalContractId__c);
    }

    private static String valorResumo(Asset a, String family) {
        if (family == FAM_INVEST) {
            return nvl(a.InvestProduto__c) + ' • ' + nvl(a.Rentabilidade__c);
        }
        if (a.ValorContrato__c != null) {
            return 'R$ ' + a.ValorContrato__c.format();
        }
        return nvl(a.ProductType__c);
    }

    private static String nvl(String v) {
        return String.isBlank(v) ? '—' : v;
    }

    private static String valueOf(Map<String, Object> m, String key) {
        Object v = m.get(key);
        return v == null ? '' : String.valueOf(v);
    }

    /** RN-15: chaves PIX do caminho real com o mesmo mascaramento parcial do mock. */
    private static List<String> maskPixKeys(List<String> keys) {
        List<String> out = new List<String>();
        for (String k : keys) {
            out.add(maskPixKey(k));
        }
        return out;
    }

    private static String maskPixKey(String raw) {
        if (String.isBlank(raw)) {
            return '';
        }
        String v = raw.trim();
        if (v.contains('@')) {
            Integer at = v.indexOf('@');
            return v.substring(0, 1) + '***' + v.substring(at) + ' (e-mail)';
        }
        String digits = v.replaceAll('[^0-9]', '');
        Boolean looksPhone = v.contains('(') || v.contains('-') || v.contains(' ') || v.contains('+');
        if ((digits.length() == 10 || digits.length() == 11) && looksPhone) {
            return '(' + digits.substring(0, 2) + ') *****-' + digits.substring(digits.length() - 4) + ' (celular)';
        }
        if (digits.length() == 11 && !isRepeated(digits)) {
            return '***.***.***-' + digits.substring(9) + ' (CPF)';
        }
        if (digits.length() == 14) {
            return '**.***.***/' + digits.substring(8, 12) + '-' + digits.substring(12) + ' (CNPJ)';
        }
        if ((digits.length() == 12 || digits.length() == 13) && digits.startsWith('55')) {
            String local = digits.substring(digits.length() - 11);
            return '(' + local.substring(0, 2) + ') *****-' + local.substring(7) + ' (celular)';
        }
        if (v.length() <= 4) {
            return '••••';
        }
        return v.substring(0, 2) + '••••' + v.substring(v.length() - 2) + ' (chave)';
    }

    private static Boolean isRepeated(String digits) {
        String first = digits.substring(0, 1);
        for (Integer i = 1; i < digits.length(); i++) {
            if (digits.substring(i, i + 1) != first) {
                return false;
            }
        }
        return true;
    }

    private static List<String> stringsOf(Map<String, Object> m, String key) {
        List<String> out = new List<String>();
        if (m.get(key) instanceof List<Object>) {
            for (Object v : (List<Object>) m.get(key)) {
                if (v != null) {
                    out.add(String.valueOf(v));
                }
            }
        }
        return out;
    }
}
