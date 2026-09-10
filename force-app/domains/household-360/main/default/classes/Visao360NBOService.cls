/**
 * @description Ofertas NBO da Visao 360 (T-C04, estatico RN-17): callout ao
 * motor na carga da raiz devolve o top 3 imediato (sem spinner) e a
 * persistencia idempotente por safra roda em Visao360SyncQueueable em segundo
 * plano (chave {doc}_{cod}_{periodo}, RN-06). Recusa 1-clique otimista +
 * Visao360RejectQueueable. Mock-first: com a flag ligada, sem callout e sem
 * DML (UI remove na hora; nada persiste fixture como dado real).
 */
public with sharing class Visao360NBOService {

    public static final String NC_NBO = 'NC_Visao360_Nbo';
    public static final Integer TIMEOUT_MS = 3000;
    public static final Integer TOP_N = 3;

    /**
     * @description Top 3 ofertas da safra vigente + disparo do sync em 2o plano.
     * @param accountId Id da Account raiz.
     * @param retry true apos o operador acionar Tentar Novamente (Carlos/EL-03).
     */
    public static Visao360DTOs.NboResult getOffersAndSync(Id accountId, Boolean retry) {
        Visao360DTOs.NboResult result = new Visao360DTOs.NboResult();
        if (accountId == null) {
            result.fault = new Visao360DTOs.ApiFaultDTO('VISAO360', 'INVALID_INPUT', 'Conta raiz não informada.');
            return result;
        }
        String doc = docDaConta(accountId);
        if (String.isBlank(doc)) {
            result.fault = new Visao360DTOs.ApiFaultDTO('VISAO360', 'NOT_FOUND', 'Conta raiz sem documento.');
            return result;
        }
        if (Visao360Mock.isEnabled()) {
            return Visao360Mock.mockOffers(doc, retry);
        }
        Visao360HttpService.CallResult callout = Visao360HttpService.get(
            NC_NBO, EncodingUtil.urlEncode(doc, 'UTF-8'), TIMEOUT_MS);
        if (!callout.isSuccess) {
            // RN-12: motor fora mostra SOMENTE banner + retry, sem ultimo estado.
            result.fault = callout.fault;
            return result;
        }
        parse(callout.response.getBody(), result);
        enqueueSync(accountId, result);
        return result;
    }

    /**
     * @description Recusa em 1 clique com motivo rapido. UI remove na hora;
     * aqui só enfileira (real) ou ignora (mock, sem DML).
     */
    public static void rejectOffer(String externalOfferId, String reason) {
        if (String.isBlank(externalOfferId)) {
            throw new Visao360Exception('Oferta não informada.');
        }
        if (Visao360Mock.isEnabled()) {
            return;
        }
        if (Limits.getQueueableJobs() >= Limits.getLimitQueueableJobs()) {
            throw new Visao360Exception('Fila de processamento cheia; tente novamente.');
        }
        System.enqueueJob(new Visao360RejectQueueable(externalOfferId, reason));
    }

    /**
     * @description Aceite marca negociacao (Stage Negotiation/Review) e devolve
     * o contexto de saida para a futura jornada de venda. RN-14: sem jornada
     * pronta, exibe "Oferta reservada, contratação em breve" e mantem a tela.
     */
    public static Visao360DTOs.NBOOfferDTO acceptOffer(String externalOfferId) {
        if (String.isBlank(externalOfferId)) {
            throw new Visao360Exception('Oferta não informada.');
        }
        if (Visao360Mock.isEnabled()) {
            Visao360DTOs.NBOOfferDTO mock = new Visao360DTOs.NBOOfferDTO();
            mock.externalOfferId = externalOfferId;
            mock.estado = 'negociacao';
            return mock;
        }
        List<Opportunity> opps = [
            SELECT Id, StageName FROM Opportunity
            WHERE ExternalOfferId__c = :externalOfferId
            WITH USER_MODE LIMIT 1
        ];
        if (opps.isEmpty()) {
            throw new Visao360Exception('Oferta não encontrada na safra vigente.');
        }
        opps[0].StageName = 'Negotiation/Review';
        update opps[0];
        Visao360DTOs.NBOOfferDTO dto = new Visao360DTOs.NBOOfferDTO();
        dto.externalOfferId = externalOfferId;
        dto.estado = 'negociacao';
        return dto;
    }

    /** Payload esperado: {modelo, safra, geradoEm, ofertas:[{externalOfferId, productCode, productName, category, priority, propensityScore, headline, elegibilidade, confianca, motivos[], validade, chaveSafra, omniScriptKey}]}. */
    public static void parse(String body, Visao360DTOs.NboResult result) {
        if (String.isBlank(body)) {
            return;
        }
        Map<String, Object> root;
        try {
            root = (Map<String, Object>) JSON.deserializeUntyped(body);
        } catch (JSONException e) {
            result.fault = new Visao360DTOs.ApiFaultDTO(NC_NBO, 'INVALID_JSON', 'Ofertas em formato inesperado.');
            return;
        }
        Visao360DTOs.MotorInfoDTO motor = new Visao360DTOs.MotorInfoDTO();
        motor.modelo = valueOf(root, 'modelo');
        motor.safra = valueOf(root, 'safra');
        motor.geradoEm = valueOf(root, 'geradoEm');
        result.motor = motor;
        if (!(root.get('ofertas') instanceof List<Object>)) {
            return;
        }
        List<Visao360DTOs.NBOOfferDTO> todas = new List<Visao360DTOs.NBOOfferDTO>();
        Set<String> seen = new Set<String>();
        for (Object item : (List<Object>) root.get('ofertas')) {
            if (!(item instanceof Map<String, Object>)) {
                continue;
            }
            Map<String, Object> m = (Map<String, Object>) item;
            String externalId = valueOf(m, 'externalOfferId');
            if (String.isBlank(externalId)) {
                externalId = valueOf(m, 'chaveSafra');
            }
            if (String.isBlank(externalId) || seen.contains(externalId)) {
                continue;
            }
            seen.add(externalId);
            Visao360DTOs.NBOOfferDTO o = new Visao360DTOs.NBOOfferDTO();
            o.offerId = valueOf(m, 'offerId');
            o.externalOfferId = externalId;
            o.chaveSafra = valueOf(m, 'chaveSafra');
            o.productCode = valueOf(m, 'productCode');
            o.productName = valueOf(m, 'productName');
            o.category = valueOf(m, 'category');
            o.priority = toInteger(m.get('priority'));
            o.propensityScore = toDecimal(m.get('propensityScore'));
            o.headline = valueOf(m, 'headline');
            o.elegibilidade = valueOf(m, 'elegibilidade');
            o.confianca = valueOf(m, 'confianca');
            o.motivos = stringsOf(m, 'motivos');
            o.validade = valueOf(m, 'validade');
            o.omniScriptKey = valueOf(m, 'omniScriptKey');
            o.estado = 'elegivel';
            todas.add(o);
        }
        todas.sort();
        Integer limite = Math.min(TOP_N, todas.size());
        for (Integer i = 0; i < limite; i++) {
            result.offers.add(todas[i]);
        }
    }

    // =================================================================
    // Privados
    // =================================================================

    private static void enqueueSync(Id accountId, Visao360DTOs.NboResult result) {
        if (result.offers.isEmpty()) {
            return;
        }
        if (Limits.getQueueableJobs() >= Limits.getLimitQueueableJobs()) {
            return;
        }
        String safra = result.motor != null ? result.motor.safra : null;
        System.enqueueJob(new Visao360SyncQueueable(accountId, safra, result.offers));
    }

    private static String docDaConta(Id accountId) {
        List<Account> contas = [
            SELECT Document__c FROM Account WHERE Id = :accountId WITH USER_MODE LIMIT 1
        ];
        if (contas.isEmpty()) {
            return null;
        }
        return Visao360Mock.normalizeDoc(contas[0].Document__c);
    }

    private static String valueOf(Map<String, Object> m, String key) {
        Object v = m.get(key);
        return v == null ? '' : String.valueOf(v);
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

    private static Integer toInteger(Object v) {
        if (v instanceof Integer) {
            return (Integer) v;
        }
        if (v instanceof Decimal) {
            return ((Decimal) v).intValue();
        }
        return 0;
    }

    private static Decimal toDecimal(Object v) {
        if (v instanceof Decimal) {
            return (Decimal) v;
        }
        if (v instanceof Integer) {
            return Decimal.valueOf((Integer) v);
        }
        return 0;
    }

    public class Visao360Exception extends Exception {}
}
