/**
 * @description Elegibilidade a ofertas NBO (I02, T-C06). GET NC_NboMotor/{doc},
 * timeout 3.0s, paralela a I01. Deduplica por ExternalOfferId; a primeira na
 * ordem do motor e a principal (premissa 04, placeholder neutro).
 */
public with sharing class NboService {

    public static final String NAMED_CREDENTIAL = 'NC_NboMotor';
    public static final Integer TIMEOUT_MS = 3000;

    public class NboResult {
        public List<BuscaClienteDTOs.NboOfferDTO> offers;
        public BuscaClienteDTOs.ApiFaultDTO fault;
        public NboResult() {
            this.offers = new List<BuscaClienteDTOs.NboOfferDTO>();
        }
    }

    public static NboResult fetch(String normalizedDoc) {
        NboResult result = new NboResult();
        if (BuscaClienteMock.isEnabled()) {
            return BuscaClienteMock.mockNbo(normalizedDoc);
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

    /** Payload esperado: {ofertas:[{externalOfferId,productType,titulo,narrativa,beneficio,beneficios[],bandeiras[],limites,anuidade}]}. */
    public static void parse(String body, NboResult result) {
        if (String.isBlank(body)) {
            return;
        }
        Map<String, Object> root;
        try {
            root = (Map<String, Object>) JSON.deserializeUntyped(body);
        } catch (JSONException e) {
            result.fault = new BuscaClienteDTOs.ApiFaultDTO(NAMED_CREDENTIAL, 'INVALID_JSON', 'Ofertas em formato inesperado.');
            return;
        }
        if (!(root.get('ofertas') instanceof List<Object>)) {
            return;
        }
        Set<String> seen = new Set<String>();
        Boolean first = true;
        for (Object item : (List<Object>) root.get('ofertas')) {
            if (!(item instanceof Map<String, Object>)) {
                continue;
            }
            Map<String, Object> m = (Map<String, Object>) item;
            String externalId = valueOf(m, 'externalOfferId');
            if (String.isBlank(externalId) || seen.contains(externalId)) {
                continue;
            }
            seen.add(externalId);
            BuscaClienteDTOs.NboOfferDTO offer = new BuscaClienteDTOs.NboOfferDTO();
            offer.externalOfferId = externalId;
            offer.productType = valueOf(m, 'productType');
            offer.titulo = valueOf(m, 'titulo');
            offer.narrativa = valueOf(m, 'narrativa');
            offer.beneficio = valueOf(m, 'beneficio');
            offer.beneficios = stringsOf(m, 'beneficios');
            offer.bandeiras = stringsOf(m, 'bandeiras');
            offer.limites = valueOf(m, 'limites');
            offer.anuidade = valueOf(m, 'anuidade');
            offer.isPrimary = first;
            offer.stage = 'Elegivel';
            first = false;
            result.offers.add(offer);
        }
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
}
