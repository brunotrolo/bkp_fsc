/**
 * @description Classe abstrata base para todas as integracoes de API.
 *              Implementa Template Method: execute() define o fluxo,
 *              cada Connector implementa buildHttpRequest() e processResponse().
 *              Configuracao vem da Lookup Table (APIConfigDAO).
 *              Token OAuth gerenciado automaticamente pelo Named Credential
 *              (generateAuthorizationHeader=true) — zero codigo de token aqui.
 */
public abstract with sharing class APIConnector {

    protected final String apiName;
    protected final String correlationId;
    protected String currentEnvironment;
    protected APIConfigDAO.APIConfig config;

    protected APIConnector(String apiName) {
        if (String.isBlank(apiName)) {
            throw APIException.create('INVALID_CONFIG', 'apiName nao pode ser vazio.');
        }
        this.apiName = apiName;
        this.currentEnvironment = APIConfigDAO.getCurrentEnvironment();
        this.correlationId = generateCorrelationId();
    }

    /**
     * @description Template Method: preProcess -> build -> send -> process -> log.
     */
    public Object execute(String operacao, Map<String, Object> params) {
        if (String.isBlank(operacao)) {
            throw APIException.create('INVALID_OPERATION', 'Operacao nao pode ser vazia.');
        }
        if (params == null) {
            params = new Map<String, Object>();
        }

        this.config = APIConfigDAO.getConfig(apiName, currentEnvironment, operacao);
        Datetime startTime = Datetime.now();
        HttpResponse httpResponse;

        try {
            preProcess(operacao, params);
            HttpRequest httpRequest = buildHttpRequest(operacao, params);
            httpResponse = sendRequest(httpRequest, config);
            Object result = processResponse(operacao, httpResponse);
            logIntegration(config, operacao, params, httpResponse, startTime, null);
            return result;
        } catch (APIException e) {
            logIntegration(config, operacao, params, httpResponse, startTime, e);
            throw e;
        } catch (Exception e) {
            APIException wrapped = APIException.create(
                'UNEXPECTED_ERROR',
                'Erro inesperado na operacao ' + operacao + ': ' + e.getMessage()
            );
            logIntegration(config, operacao, params, httpResponse, startTime, wrapped);
            throw wrapped;
        }
    }

    // =================================================================
    // ABSTRATOS - todo Connector implementa
    // =================================================================

    protected abstract HttpRequest buildHttpRequest(String operacao, Map<String, Object> params);

    protected abstract Object processResponse(String operacao, HttpResponse httpResponse);

    // =================================================================
    // VIRTUAL - sobrescrever somente se precisar
    // =================================================================

    protected virtual void preProcess(String operacao, Map<String, Object> params) {
    }

    // =================================================================
    // CONCRETOS - comportamento padrao da base
    // =================================================================

    private HttpResponse sendRequest(HttpRequest httpRequest, APIConfigDAO.APIConfig cfg) {
        Integer attempts = 1 + (cfg.retryEnabled ? Math.max(0, cfg.retryCount) : 0);
        Http http = new Http();
        HttpResponse httpResponse;

        for (Integer i = 0; i < attempts; i++) {
            try {
                httpResponse = http.send(httpRequest);
            } catch (CalloutException e) {
                if (i == attempts - 1) {
                    throw APIException.create('CALLOUT_ERROR', 'Erro na chamada HTTP: ' + e.getMessage());
                }
                continue;
            }
            Integer status = httpResponse.getStatusCode();
            if (status >= 200 && status < 300) {
                return httpResponse;
            }
            // Para erros que nao sejam 401, ou na ultima tentativa, retorna imediatamente
            if (status != 401 || i == attempts - 1) {
                return httpResponse;
            }
            // 401 com tentativas restantes: o NC vai renovar o token automaticamente
            // na proxima iteracao (comportamento nativo do Salesforce OAuth Named Credential)
        }
        return httpResponse;
    }

    private void logIntegration(
        APIConfigDAO.APIConfig cfg,
        String operacao,
        Map<String, Object> params,
        HttpResponse response,
        Datetime startTime,
        Exception error
    ) {
        if (cfg == null || cfg.logEnabled != true) {
            return;
        }
        Long elapsedMs = Datetime.now().getTime() - startTime.getTime();
        System.debug(
            LoggingLevel.INFO,
            'INTEGRATION correlationId=' + correlationId +
            ' api=' + cfg.apiName +
            ' env=' + cfg.environment +
            ' operacao=' + operacao +
            ' endpoint=' + cfg.endpoint +
            ' method=' + cfg.method +
            ' status=' + (response != null ? String.valueOf(response.getStatusCode()) : 'N/A') +
            ' elapsedMs=' + elapsedMs +
            (error != null ? ' error=' + error.getMessage() : '')
        );
    }

    private String generateCorrelationId() {
        return UserInfo.getUserId() + '_' + Datetime.now().getTime() + '_' + Crypto.getRandomInteger();
    }
}