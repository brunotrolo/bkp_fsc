/**
 * @description Wrapper unico de callout via Named Credential com timeout por
 * servico e retorno de falha tipada em vez de excecao (T-C02, Cen 21/22).
 * Timeout e falha parcial viram ApiFaultDTO; o LWC decide por area via
 * Promise.allSettled sem bloquear as demais.
 */
public with sharing class HttpCalloutService {

    /** Resposta ou falha: exatamente um dos dois esta preenchido. */
    public class CallResult {
        public HttpResponse response;
        public BuscaClienteDTOs.ApiFaultDTO fault;
        public Boolean isSuccess {
            get { return this.response != null; }
        }
    }

    /**
     * @description GET via Named Credential com timeout dedicado.
     * @param namedCredential Nome da credencial (ex.: NC_CadastroCorporativo).
     * @param pathSuffix Sufixo do path apos a URL base (documento ja codificado).
     * @param timeoutMs Timeout em milissegundos (2500 cadastro, 3000 demais).
     */
    public static CallResult get(String namedCredential, String pathSuffix, Integer timeoutMs) {
        CallResult result = new CallResult();
        String suffix = String.isBlank(pathSuffix) ? '' : pathSuffix;
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint('callout:' + namedCredential + '/' + suffix);
        req.setTimeout(timeoutMs == null ? 3000 : timeoutMs);
        req.setHeader('Accept', 'application/json');
        try {
            HttpResponse resp = new Http().send(req);
            Integer status = resp.getStatusCode();
            if (status >= 200 && status < 300) {
                result.response = resp;
            } else {
                result.fault = new BuscaClienteDTOs.ApiFaultDTO(
                    namedCredential, 'HTTP_' + status,
                    'Fonte temporariamente indisponivel. E possivel seguir com as demais areas.'
                );
            }
        } catch (CalloutException e) {
            result.fault = new BuscaClienteDTOs.ApiFaultDTO(
                namedCredential, 'CALLOUT_ERROR',
                'Fonte temporariamente indisponivel. E possivel seguir com as demais areas.'
            );
        }
        return result;
    }
}
