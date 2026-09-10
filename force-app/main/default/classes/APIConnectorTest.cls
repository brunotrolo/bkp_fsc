/**
 * @description Testes da APIConnector (template method, retry, erros) via stub concreto.
 */
@isTest
private class APIConnectorTest {

    private class StubConnector extends APIConnector {
        StubConnector() {
            super('STUB_API');
        }
        StubConnector(String apiName) {
            super(apiName);
        }
        protected override HttpRequest buildHttpRequest(String operacao, Map<String, Object> params) {
            if (operacao == 'boomBuild') {
                throw new DmlException('build explodiu');
            }
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:STUB_NC/path');
            request.setMethod('GET');
            return request;
        }
        protected override Object processResponse(String operacao, HttpResponse response) {
            if (operacao == 'boomApi') {
                throw APIException.create('STUB_ERR', 'erro stub');
            }
            return response.getStatusCode();
        }
    }

    private class OkMock implements HttpCalloutMock {
        private final Integer status;
        OkMock(Integer status) {
            this.status = status;
        }
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(status);
            response.setBody('{}');
            return response;
        }
    }

    private class SeqMock implements HttpCalloutMock {
        private final List<Integer> statuses;
        private Integer calls = 0;
        SeqMock(List<Integer> statuses) {
            this.statuses = statuses;
        }
        public HttpResponse respond(HttpRequest request) {
            Integer idx = Math.min(calls, statuses.size() - 1);
            calls++;
            HttpResponse response = new HttpResponse();
            response.setStatusCode(statuses[idx]);
            response.setBody('{}');
            return response;
        }
    }

    private class ThrowThenOkMock implements HttpCalloutMock {
        private Boolean first = true;
        public HttpResponse respond(HttpRequest request) {
            if (first) {
                first = false;
                throw new CalloutException('timeout simulado');
            }
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('{}');
            return response;
        }
    }

    private class AlwaysThrowMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            throw new CalloutException('falha simulada');
        }
    }

    private static void useMockConfig(Boolean retryEnabled, Integer retryCount, Boolean logEnabled) {
        APIConfigDAO.APIConfig cfg = new APIConfigDAO.APIConfig();
        cfg.apiName = 'STUB_API';
        cfg.environment = APIConfigDAO.getCurrentEnvironment();
        cfg.namedCredential = 'STUB_NC';
        cfg.endpoint = '/path';
        cfg.method = 'GET';
        cfg.timeout = 30000;
        cfg.retryEnabled = retryEnabled;
        cfg.retryCount = retryCount;
        cfg.logEnabled = logEnabled;
        APIConfigDAO.mockConfig = cfg;
    }

    @isTest
    static void shouldThrowInvalidConfig_WhenApiNameBlank() {
        // When/Then
        Test.startTest();
        try {
            new StubConnector('');
            Assert.fail('Deveria lancar INVALID_CONFIG.');
        } catch (APIException e) {
            Assert.areEqual('INVALID_CONFIG', e.getErrorCode(), 'Codigo deve ser INVALID_CONFIG.');
        }
        Test.stopTest();
    }

    @isTest
    static void shouldThrowInvalidOperation_WhenOperacaoBlank() {
        // When/Then: validacao ocorre antes de qualquer config/callout
        Test.startTest();
        try {
            new StubConnector().execute('', null);
            Assert.fail('Deveria lancar INVALID_OPERATION.');
        } catch (APIException e) {
            Assert.areEqual('INVALID_OPERATION', e.getErrorCode(), 'Codigo deve ser INVALID_OPERATION.');
        }
        Test.stopTest();
    }

    @isTest
    static void shouldReturnResult_WhenSuccessWithLog() {
        // Given
        useMockConfig(false, 0, true);
        Test.setMock(HttpCalloutMock.class, new OkMock(200));

        // When (params null → map vazio)
        Test.startTest();
        Object result = new StubConnector().execute('op', null);
        Test.stopTest();

        // Then
        Assert.areEqual(200, result, 'Deve retornar o status 200.');
    }

    @isTest
    static void shouldSkipLogging_WhenLogDisabled() {
        // Given
        useMockConfig(false, 0, false);
        Test.setMock(HttpCalloutMock.class, new OkMock(200));

        // When
        Test.startTest();
        Object result = new StubConnector().execute('op', new Map<String, Object>());
        Test.stopTest();

        // Then
        Assert.areEqual(200, result, 'Deve retornar 200 mesmo sem log.');
    }

    @isTest
    static void shouldRethrowApiException_WhenProcessFails() {
        // Given
        useMockConfig(false, 0, true);
        Test.setMock(HttpCalloutMock.class, new OkMock(200));

        // When/Then
        Test.startTest();
        try {
            new StubConnector().execute('boomApi', new Map<String, Object>());
            Assert.fail('Deveria relancar STUB_ERR.');
        } catch (APIException e) {
            Assert.areEqual('STUB_ERR', e.getErrorCode(), 'Deve relancar a APIException original.');
        }
        Test.stopTest();
    }

    @isTest
    static void shouldWrapUnexpected_WhenBuildFails() {
        // Given
        useMockConfig(false, 0, true);

        // When/Then: sem mock — build estoura antes do callout
        Test.startTest();
        try {
            new StubConnector().execute('boomBuild', new Map<String, Object>());
            Assert.fail('Deveria embrulhar em UNEXPECTED_ERROR.');
        } catch (APIException e) {
            Assert.areEqual('UNEXPECTED_ERROR', e.getErrorCode(), 'Codigo deve ser UNEXPECTED_ERROR.');
            Assert.isTrue(e.getMessage().contains('boomBuild'), 'Mensagem deve citar a operacao.');
        }
        Test.stopTest();
    }

    @isTest
    static void shouldRetryOnce_When401ThenSuccess() {
        // Given
        useMockConfig(true, 1, true);
        Test.setMock(HttpCalloutMock.class, new SeqMock(new List<Integer>{ 401, 200 }));

        // When
        Test.startTest();
        Object result = new StubConnector().execute('op', new Map<String, Object>());
        Test.stopTest();

        // Then
        Assert.areEqual(200, result, '401 com retry deve tentar de novo e retornar 200.');
    }

    @isTest
    static void shouldReturn401_WhenNoRetryLeft() {
        // Given
        useMockConfig(false, 0, true);
        Test.setMock(HttpCalloutMock.class, new SeqMock(new List<Integer>{ 401 }));

        // When
        Test.startTest();
        Object result = new StubConnector().execute('op', new Map<String, Object>());
        Test.stopTest();

        // Then
        Assert.areEqual(401, result, 'Sem retry deve retornar o 401.');
    }

    @isTest
    static void shouldReturnImmediately_WhenServerError() {
        // Given
        useMockConfig(true, 3, true);
        Test.setMock(HttpCalloutMock.class, new OkMock(500));

        // When
        Test.startTest();
        Object result = new StubConnector().execute('op', new Map<String, Object>());
        Test.stopTest();

        // Then
        Assert.areEqual(500, result, '500 deve retornar sem retry.');
    }

    @isTest
    static void shouldThrowCalloutError_WhenAlwaysFailing() {
        // Given
        useMockConfig(true, 1, true);
        Test.setMock(HttpCalloutMock.class, new AlwaysThrowMock());

        // When/Then
        Test.startTest();
        try {
            new StubConnector().execute('op', new Map<String, Object>());
            Assert.fail('Deveria lancar CALLOUT_ERROR.');
        } catch (APIException e) {
            Assert.areEqual('CALLOUT_ERROR', e.getErrorCode(), 'Codigo deve ser CALLOUT_ERROR.');
        }
        Test.stopTest();
    }

    @isTest
    static void shouldSucceedAfterRetry_WhenFirstCallThrows() {
        // Given
        useMockConfig(true, 1, true);
        Test.setMock(HttpCalloutMock.class, new ThrowThenOkMock());

        // When
        Test.startTest();
        Object result = new StubConnector().execute('op', new Map<String, Object>());
        Test.stopTest();

        // Then
        Assert.areEqual(200, result, 'Throw com retry restante deve continuar e retornar 200.');
    }
}
