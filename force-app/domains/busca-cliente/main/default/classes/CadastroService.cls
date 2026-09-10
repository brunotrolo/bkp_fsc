/**
 * @description Busca cadastral e carteira agregada Porto Bank (I01, T-C05).
 * GET NC_CadastroCorporativo/{doc}, timeout 2.5s. Parse defensivo: payload
 * parcial ainda rende DTO com o que retornou; falha total vira fault.
 */
public with sharing class CadastroService {

    public static final String NAMED_CREDENTIAL = 'NC_CadastroCorporativo';
    public static final Integer TIMEOUT_MS = 2500;

    public class CadastroResult {
        public BuscaClienteDTOs.DemographicDTO demographic;
        public List<BuscaClienteDTOs.ProductSummaryDTO> wallet;
        public BuscaClienteDTOs.ApiFaultDTO fault;
        public CadastroResult() {
            this.wallet = new List<BuscaClienteDTOs.ProductSummaryDTO>();
        }
    }

    public static CadastroResult fetch(String normalizedDoc) {
        CadastroResult result = new CadastroResult();
        if (BuscaClienteMock.isEnabled()) {
            return BuscaClienteMock.mockCadastro(normalizedDoc);
        }
        HttpCalloutService.CallResult callout =
            HttpCalloutService.get(NAMED_CREDENTIAL, normalizedDoc, TIMEOUT_MS);
        if (!callout.isSuccess) {
            result.fault = callout.fault;
            return result;
        }
        parse(callout.response.getBody(), result);
        return result;
    }

    /** Payload esperado: {demografico:{...}, carteira:[{productType,label,quantidade,resumo,icone,exigeSubselecao,holdingInformativo}]}. */
    public static void parse(String body, CadastroResult result) {
        if (String.isBlank(body)) {
            result.fault = new BuscaClienteDTOs.ApiFaultDTO(NAMED_CREDENTIAL, 'EMPTY_BODY', 'Cadastro sem conteudo.');
            return;
        }
        Map<String, Object> root;
        try {
            root = (Map<String, Object>) JSON.deserializeUntyped(body);
        } catch (JSONException e) {
            result.fault = new BuscaClienteDTOs.ApiFaultDTO(NAMED_CREDENTIAL, 'INVALID_JSON', 'Cadastro em formato inesperado.');
            return;
        }
        if (root.containsKey('demografico') && root.get('demografico') instanceof Map<String, Object>) {
            result.demographic = toDemographic((Map<String, Object>) root.get('demografico'));
        }
        if (root.containsKey('carteira') && root.get('carteira') instanceof List<Object>) {
            for (Object item : (List<Object>) root.get('carteira')) {
                if (item instanceof Map<String, Object>) {
                    BuscaClienteDTOs.ProductSummaryDTO summary = toSummary((Map<String, Object>) item);
                    if (summary != null && summary.holdingInformativo != true) {
                        result.wallet.add(summary);
                    }
                }
            }
        }
        if (result.demographic == null && result.wallet.isEmpty()) {
            result.fault = new BuscaClienteDTOs.ApiFaultDTO(NAMED_CREDENTIAL, 'NOT_FOUND', 'Nenhum cadastro localizado para o documento.');
        }
    }

    private static BuscaClienteDTOs.DemographicDTO toDemographic(Map<String, Object> m) {
        BuscaClienteDTOs.DemographicDTO d = new BuscaClienteDTOs.DemographicDTO();
        d.nome = str(m, 'nome');
        d.tipoPessoa = str(m, 'tipoPessoa');
        d.documentoFormatado = str(m, 'documentoFormatado');
        d.segmento = str(m, 'segmento');
        d.email = str(m, 'email');
        d.telefone = str(m, 'telefone');
        d.celular = str(m, 'celular');
        d.nascimento = str(m, 'nascimento');
        d.endereco = str(m, 'endereco');
        d.cep = str(m, 'cep');
        d.renda = str(m, 'renda');
        d.score = str(m, 'score');
        d.agencia = str(m, 'agencia');
        d.conta = str(m, 'conta');
        d.tempoRelacionamento = str(m, 'tempoRelacionamento');
        d.statusCadastro = str(m, 'statusCadastro');
        return d;
    }

    private static BuscaClienteDTOs.ProductSummaryDTO toSummary(Map<String, Object> m) {
        String productType = str(m, 'productType');
        if (String.isBlank(productType)) {
            return null;
        }
        BuscaClienteDTOs.ProductSummaryDTO s = new BuscaClienteDTOs.ProductSummaryDTO();
        s.productType = productType;
        s.label = str(m, 'label');
        s.quantidade = intOf(m, 'quantidade');
        s.resumo = str(m, 'resumo');
        s.iconName = str(m, 'icone');
        s.exigeSubselecao = boolOf(m, 'exigeSubselecao');
        s.holdingInformativo = boolOf(m, 'holdingInformativo');
        return s;
    }

    private static String str(Map<String, Object> m, String key) {
        Object v = m.get(key);
        return v == null ? '' : String.valueOf(v);
    }

    private static Integer intOf(Map<String, Object> m, String key) {
        Object v = m.get(key);
        if (v instanceof Decimal) {
            return ((Decimal) v).intValue();
        }
        return 0;
    }

    private static Boolean boolOf(Map<String, Object> m, String key) {
        return m.get(key) == true;
    }
}
