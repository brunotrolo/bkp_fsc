/**
 * @description Wrapper unico de callout da Visao 360 via Named Credential com
 * timeout por servico e retorno de falha tipada em vez de excecao (T-C02).
 * Copia o padrao HttpCalloutService da busca para arquivos NOVOS deste
 * dominio (sem importar a classe da busca). Timeout e falha parcial viram
 * ApiFaultDTO; o LWC decide por area sem bloquear as demais (Cen 9, 15).
 */
public with sharing class Visao360HttpService {

    /** Resposta ou falha: exatamente um dos dois esta preenchido. */
    public class CallResult {
        public HttpResponse response;
        public Visao360DTOs.ApiFaultDTO fault;
        public Boolean isSuccess {
            get { return this.response != null; }
        }
    }

    /**
     * @description GET via Named Credential com timeout dedicado.
     * @param namedCredential Nome da credencial (ex.: NC_Visao360_Nbo).
     * @param pathSuffix Sufixo do path apos a URL base (documento ja codificado).
     * @param timeoutMs Timeout em milissegundos (3000 motor e core).
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
                result.fault = new Visao360DTOs.ApiFaultDTO(
                    namedCredential, 'HTTP_' + status,
                    'Fonte temporariamente indisponivel. E possivel seguir com as demais areas.'
                );
            }
        } catch (CalloutException e) {
            result.fault = new Visao360DTOs.ApiFaultDTO(
                namedCredential, 'CALLOUT_ERROR',
                'Fonte temporariamente indisponivel. E possivel seguir com as demais areas.'
            );
        }
        return result;
    }

    /**
     * @description POST JSON via Named Credential (feedback de recusa ao motor).
     * @param namedCredential Nome da credencial.
     * @param pathSuffix Sufixo do path apos a URL base.
     * @param jsonBody Corpo JSON (sem segredos, sem PII alem do necessario).
     * @param timeoutMs Timeout em milissegundos.
     */
    public static CallResult post(String namedCredential, String pathSuffix, String jsonBody, Integer timeoutMs) {
        CallResult result = new CallResult();
        String suffix = String.isBlank(pathSuffix) ? '' : pathSuffix;
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('callout:' + namedCredential + '/' + suffix);
        req.setTimeout(timeoutMs == null ? 3000 : timeoutMs);
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(String.isBlank(jsonBody) ? '{}' : jsonBody);
        try {
            HttpResponse resp = new Http().send(req);
            Integer status = resp.getStatusCode();
            if (status >= 200 && status < 300) {
                result.response = resp;
            } else {
                result.fault = new Visao360DTOs.ApiFaultDTO(
                    namedCredential, 'HTTP_' + status,
                    'Feedback ao motor nao confirmado.'
                );
            }
        } catch (CalloutException e) {
            result.fault = new Visao360DTOs.ApiFaultDTO(
                namedCredential, 'CALLOUT_ERROR',
                'Feedback ao motor nao confirmado.'
            );
        }
        return result;
    }
}
