/**
 * @description Posicoes de investimento, chamada lazy (I03c, T-C07).
 * GET NC_Investimentos/{doc}, timeout 3.0s, LIMIT 50.
 */
public with sharing class InvestimentoService {

    public static final String NAMED_CREDENTIAL = 'NC_Investimentos';
    public static final Integer TIMEOUT_MS = 3000;
    public static final Integer QUERY_LIMIT = 50;

    public class InvestimentoResult {
        public List<BuscaClienteDTOs.InvestimentoPosicaoDTO> posicoes;
        public BuscaClienteDTOs.ApiFaultDTO fault;
        public InvestimentoResult() {
            this.posicoes = new List<BuscaClienteDTOs.InvestimentoPosicaoDTO>();
        }
    }

    public static InvestimentoResult fetchPosicoes(String normalizedDoc) {
        InvestimentoResult result = new InvestimentoResult();
        if (BuscaClienteMock.isEnabled()) {
            return BuscaClienteMock.mockPosicoes();
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

    /** Payload esperado: {posicoes:[{externalContractId,classe,produto,valor,rentabilidade,vencimento,risco}]}. */
    public static void parse(String body, InvestimentoResult result) {
        if (String.isBlank(body)) {
            return;
        }
        Map<String, Object> root;
        try {
            root = (Map<String, Object>) JSON.deserializeUntyped(body);
        } catch (JSONException e) {
            result.fault = new BuscaClienteDTOs.ApiFaultDTO(NAMED_CREDENTIAL, 'INVALID_JSON', 'Posicoes em formato inesperado.');
            return;
        }
        if (!(root.get('posicoes') instanceof List<Object>)) {
            return;
        }
        Integer added = 0;
        for (Object item : (List<Object>) root.get('posicoes')) {
            if (added >= QUERY_LIMIT) {
                break;
            }
            if (!(item instanceof Map<String, Object>)) {
                continue;
            }
            Map<String, Object> m = (Map<String, Object>) item;
            BuscaClienteDTOs.InvestimentoPosicaoDTO pos = new BuscaClienteDTOs.InvestimentoPosicaoDTO();
            pos.externalContractId = valueOf(m, 'externalContractId');
            pos.classe = valueOf(m, 'classe');
            pos.produto = valueOf(m, 'produto');
            pos.valor = valueOf(m, 'valor');
            pos.rentabilidade = valueOf(m, 'rentabilidade');
            pos.vencimento = valueOf(m, 'vencimento');
            pos.risco = valueOf(m, 'risco');
            result.posicoes.add(pos);
            added++;
        }
    }

    private static String valueOf(Map<String, Object> m, String key) {
        Object v = m.get(key);
        return v == null ? '' : String.valueOf(v);
    }
}
