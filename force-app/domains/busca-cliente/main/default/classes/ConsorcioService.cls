/**
 * @description Cotas de consorcio, chamada lazy (I03b, T-C07).
 * GET NC_Consorcio/{doc}, timeout 3.0s, LIMIT 50. Varias cotas no mesmo grupo
 * sao itens independentes (Cen 17).
 */
public with sharing class ConsorcioService {

    public static final String NAMED_CREDENTIAL = 'NC_Consorcio';
    public static final Integer TIMEOUT_MS = 3000;
    public static final Integer QUERY_LIMIT = 50;

    public class ConsorcioResult {
        public List<BuscaClienteDTOs.ConsorcioCotaDTO> cotas;
        public BuscaClienteDTOs.ApiFaultDTO fault;
        public ConsorcioResult() {
            this.cotas = new List<BuscaClienteDTOs.ConsorcioCotaDTO>();
        }
    }

    public static ConsorcioResult fetchCotas(String normalizedDoc) {
        ConsorcioResult result = new ConsorcioResult();
        if (BuscaClienteMock.isEnabled()) {
            return BuscaClienteMock.mockCotas();
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

    /** Payload esperado: {cotas:[{externalContractId,tipo,grupo,cota,valor,contemplacao,parcela,status}]}. */
    public static void parse(String body, ConsorcioResult result) {
        if (String.isBlank(body)) {
            return;
        }
        Map<String, Object> root;
        try {
            root = (Map<String, Object>) JSON.deserializeUntyped(body);
        } catch (JSONException e) {
            result.fault = new BuscaClienteDTOs.ApiFaultDTO(NAMED_CREDENTIAL, 'INVALID_JSON', 'Cotas em formato inesperado.');
            return;
        }
        if (!(root.get('cotas') instanceof List<Object>)) {
            return;
        }
        Integer added = 0;
        for (Object item : (List<Object>) root.get('cotas')) {
            if (added >= QUERY_LIMIT) {
                break;
            }
            if (!(item instanceof Map<String, Object>)) {
                continue;
            }
            Map<String, Object> m = (Map<String, Object>) item;
            BuscaClienteDTOs.ConsorcioCotaDTO cota = new BuscaClienteDTOs.ConsorcioCotaDTO();
            cota.externalContractId = valueOf(m, 'externalContractId');
            cota.tipo = valueOf(m, 'tipo');
            cota.grupo = valueOf(m, 'grupo');
            cota.cota = valueOf(m, 'cota');
            cota.valor = valueOf(m, 'valor');
            cota.contemplacao = valueOf(m, 'contemplacao');
            cota.parcela = valueOf(m, 'parcela');
            cota.status = valueOf(m, 'status');
            if (String.isBlank(cota.status)) {
                cota.status = 'Ativa';
            }
            result.cotas.add(cota);
            added++;
        }
    }

    private static String valueOf(Map<String, Object> m, String key) {
        Object v = m.get(key);
        return v == null ? '' : String.valueOf(v);
    }
}
