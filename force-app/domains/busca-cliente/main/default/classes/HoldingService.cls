/**
 * @description Carteira Holding informativa, somente leitura (I04, T-C05, RN-06).
 * GET NC_CadastroCorporativo/{doc}/holding, timeout 2.5s. Nunca transacional:
 * nenhum item daqui gera PRODUCT_SELECTED.
 */
public with sharing class HoldingService {

    public static final String NAMED_CREDENTIAL = 'NC_CadastroCorporativo';
    public static final Integer TIMEOUT_MS = 2500;

    public class HoldingResult {
        public List<BuscaClienteDTOs.HoldingDTO> items;
        public BuscaClienteDTOs.ApiFaultDTO fault;
        public HoldingResult() {
            this.items = new List<BuscaClienteDTOs.HoldingDTO>();
        }
    }

    public static HoldingResult fetch(String normalizedDoc) {
        HoldingResult result = new HoldingResult();
        if (BuscaClienteMock.isEnabled()) {
            return BuscaClienteMock.mockHolding(normalizedDoc);
        }
        HttpCalloutService.CallResult callout =
            HttpCalloutService.get(NAMED_CREDENTIAL, normalizedDoc + '/holding', TIMEOUT_MS);
        if (!callout.isSuccess) {
            result.fault = callout.fault;
            return result;
        }
        parse(callout.response.getBody(), result);
        return result;
    }

    /** Payload esperado: {holding:[{nome,detalhe,icone}]}. */
    public static void parse(String body, HoldingResult result) {
        if (String.isBlank(body)) {
            return;
        }
        Map<String, Object> root;
        try {
            root = (Map<String, Object>) JSON.deserializeUntyped(body);
        } catch (JSONException e) {
            result.fault = new BuscaClienteDTOs.ApiFaultDTO(NAMED_CREDENTIAL, 'INVALID_JSON', 'Holding em formato inesperado.');
            return;
        }
        if (!(root.get('holding') instanceof List<Object>)) {
            return;
        }
        for (Object item : (List<Object>) root.get('holding')) {
            if (!(item instanceof Map<String, Object>)) {
                continue;
            }
            Map<String, Object> m = (Map<String, Object>) item;
            BuscaClienteDTOs.HoldingDTO h = new BuscaClienteDTOs.HoldingDTO();
            h.nome = valueOf(m, 'nome');
            h.detalhe = valueOf(m, 'detalhe');
            h.icone = valueOf(m, 'icone');
            if (!String.isBlank(h.nome)) {
                result.items.add(h);
            }
        }
    }

    private static String valueOf(Map<String, Object> m, String key) {
        Object v = m.get(key);
        return v == null ? '' : String.valueOf(v);
    }
}
