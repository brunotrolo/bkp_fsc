/**
 * @description Vias e plasticos de cartao, chamada lazy (I03, T-C07).
 * GET NC_CartoesProcessadora/{doc}, timeout 3.0s, LIMIT 50, ativos primeiro.
 * Todas as situacoes listadas e selecionaveis (EL-03/04/05).
 */
public with sharing class CardService {

    public static final String NAMED_CREDENTIAL = 'NC_CartoesProcessadora';
    public static final Integer TIMEOUT_MS = 3000;
    public static final Integer QUERY_LIMIT = 50;

    public class CardResult {
        public List<BuscaClienteDTOs.CardViaDTO> vias;
        public BuscaClienteDTOs.ApiFaultDTO fault;
        public CardResult() {
            this.vias = new List<BuscaClienteDTOs.CardViaDTO>();
        }
    }

    public static CardResult fetchVias(String normalizedDoc) {
        CardResult result = new CardResult();
        if (BuscaClienteMock.isEnabled()) {
            return BuscaClienteMock.mockVias();
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

    /** Payload esperado: {vias:[{externalContractId,brand,category,last4,holderName,isTitular,limite,anuidade,status}]}. */
    public static void parse(String body, CardResult result) {
        if (String.isBlank(body)) {
            return;
        }
        Map<String, Object> root;
        try {
            root = (Map<String, Object>) JSON.deserializeUntyped(body);
        } catch (JSONException e) {
            result.fault = new BuscaClienteDTOs.ApiFaultDTO(NAMED_CREDENTIAL, 'INVALID_JSON', 'Vias em formato inesperado.');
            return;
        }
        if (!(root.get('vias') instanceof List<Object>)) {
            return;
        }
        List<BuscaClienteDTOs.CardViaDTO> active = new List<BuscaClienteDTOs.CardViaDTO>();
        List<BuscaClienteDTOs.CardViaDTO> others = new List<BuscaClienteDTOs.CardViaDTO>();
        for (Object item : (List<Object>) root.get('vias')) {
            if (!(item instanceof Map<String, Object>)) {
                continue;
            }
            Map<String, Object> m = (Map<String, Object>) item;
            BuscaClienteDTOs.CardViaDTO via = new BuscaClienteDTOs.CardViaDTO();
            via.externalContractId = valueOf(m, 'externalContractId');
            via.brand = valueOf(m, 'brand');
            via.category = valueOf(m, 'category');
            via.last4Masked = maskLast4(valueOf(m, 'last4'));
            via.holderName = valueOf(m, 'holderName');
            via.isTitular = m.get('isTitular') == true;
            via.limite = valueOf(m, 'limite');
            via.anuidade = valueOf(m, 'anuidade');
            via.status = valueOf(m, 'status');
            if (String.isBlank(via.status)) {
                via.status = 'Ativo';
            }
            if (via.status == 'Ativo') {
                active.add(via);
            } else {
                others.add(via);
            }
        }
        active.addAll(others);
        Integer total = Math.min(active.size(), QUERY_LIMIT);
        for (Integer i = 0; i < total; i++) {
            result.vias.add(active[i]);
        }
    }

    private static String maskLast4(String last4) {
        String digits = String.isBlank(last4) ? '' : last4.replaceAll('[^0-9]', '');
        if (digits.length() != 4) {
            return '••••';
        }
        return '•••• ' + digits;
    }

    private static String valueOf(Map<String, Object> m, String key) {
        Object v = m.get(key);
        return v == null ? '' : String.valueOf(v);
    }
}
