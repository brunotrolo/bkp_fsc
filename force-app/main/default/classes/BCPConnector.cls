/**
 * @description Connector da API BCP (dados do cliente e da conta).
 *              TUDO junto em 1 classe: operacoes publicas estaticas
 *              (chamaveis de FlexCard, OmniScript e Execute Anonymous),
 *              montagem do request e interpretacao da resposta.
 *              Auth OAuth2 client_credentials via Named Credential;
 *              URL e timeout via Lookup Table API_Config.
 */
public with sharing class BCPConnector extends APIConnector {

    private static final String API_NAME = 'BCP_DadosCliente';
    private static final String OP_DADOS_CLIENTE = 'getDadosCliente';

    public BCPConnector() {
        super(API_NAME);
    }

    // =================================================================
    // OPERACOES - chamadas diretas, sem Service/Controller
    // =================================================================

    @AuraEnabled
    public static Object getDadosCliente(String cpf) {
        try {
            BCPConnector connector = new BCPConnector();
            return connector.execute(OP_DADOS_CLIENTE, paramsFor(cpf));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Override de ambiente para Execute Anonymous.
     *              Permite testar HML e PRD da mesma janela.
     *              Usage: new BCPConnector().call('getDadosCliente', params, 'Producao')
     */
    public Object call(String operacao, Map<String, Object> params, String environment) {
        this.currentEnvironment = environment;
        return this.execute(operacao, params);
    }

    // =================================================================
    // TEMPLATE METHOD - implementacao BCP
    // =================================================================

    protected override HttpRequest buildHttpRequest(String operacao, Map<String, Object> params) {
        if (operacao != OP_DADOS_CLIENTE) {
            throw APIException.create('INVALID_OPERATION', 'Operacao desconhecida: ' + operacao);
        }

        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:' + config.namedCredential + config.endpoint);
        request.setMethod(config.method == null ? 'GET' : config.method.toUpperCase());
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('X-Correlation-ID', correlationId);

        String cpf = (String) params.get('cpf');
        if (String.isBlank(cpf)) {
            throw APIException.create('INVALID_PARAM', 'CPF (legalData) e obrigatorio.');
        }
        request.setHeader('legalData', cpf.trim());
        request.setTimeout(config.timeout);

        return request;
    }

    protected override Object processResponse(String operacao, HttpResponse response) {
        Integer status = response.getStatusCode();
        String body = response.getBody();

        if (status >= 200 && status < 300) {
            if (String.isBlank(body)) {
                return null;
            }
            return JSON.deserializeUntyped(body);
        }

        String detail = 'HTTP ' + status;
        try {
            Map<String, Object> errorMap = (Map<String, Object>) JSON.deserializeUntyped(body);
            if (errorMap.containsKey('message') && errorMap.get('message') != null) {
                detail = String.valueOf(errorMap.get('message'));
            }
        } catch (Exception ignoreException) {
        }
        throw APIException.create('BCP_ERROR', 'Erro na operacao ' + operacao + ': ' + detail, status);
    }

    private static Map<String, Object> paramsFor(String cpf) {
        return new Map<String, Object>{ 'cpf' => cpf };
    }
}