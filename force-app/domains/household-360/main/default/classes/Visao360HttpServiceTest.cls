/**
 * @description Testes do wrapper de callout: ok/timeout/5xx + POST.
 * Cen 9, 15 (falha parcial vira fault, nunca excecao para a UI).
 */
@IsTest
private class Visao360HttpServiceTest {

    private class OkMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse resp = new HttpResponse();
            resp.setStatusCode(200);
            resp.setBody('{"ok":true}');
            return resp;
        }
    }

    private class Erro500Mock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse resp = new HttpResponse();
            resp.setStatusCode(500);
            resp.setBody('erro');
            return resp;
        }
    }

    private class TimeoutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            throw new CalloutException('timeout simulado');
        }
    }

    @IsTest
    static void shouldReturnResponse_WhenStatus200() {
        Test.setMock(HttpCalloutMock.class, new OkMock());

        Test.startTest();
        Visao360HttpService.CallResult result =
            Visao360HttpService.get('NC_Visao360_Nbo', '123', 3000);
        Test.stopTest();

        Assert.isTrue(result.isSuccess, 'GET 200 deve ser sucesso');
        Assert.areEqual('{"ok":true}', result.response.getBody(), 'Corpo deve passar adiante');
        Assert.isNull(result.fault, 'Sem fault no sucesso');
    }

    @IsTest
    static void shouldReturnFault_WhenStatus500() {
        Test.setMock(HttpCalloutMock.class, new Erro500Mock());

        Test.startTest();
        Visao360HttpService.CallResult result =
            Visao360HttpService.get('NC_Visao360_Core', 'X/realtime', 3000);
        Test.stopTest();

        Assert.isFalse(result.isSuccess, 'GET 500 nao e sucesso');
        Assert.isNotNull(result.fault, 'Falha 500 vira fault');
        Assert.areEqual('HTTP_500', result.fault.code, 'Codigo tipado para banner');
    }

    @IsTest
    static void shouldReturnFault_WhenTimeout() {
        Test.setMock(HttpCalloutMock.class, new TimeoutMock());

        Test.startTest();
        Visao360HttpService.CallResult result =
            Visao360HttpService.get('NC_Visao360_Core', 'X/realtime', 3000);
        Test.stopTest();

        Assert.isFalse(result.isSuccess, 'Timeout nao e sucesso');
        Assert.areEqual('CALLOUT_ERROR', result.fault.code, 'Timeout vira fault para retry');
    }

    @IsTest
    static void shouldPost_WhenFeedbackRecusa() {
        Test.setMock(HttpCalloutMock.class, new OkMock());

        Test.startTest();
        Visao360HttpService.CallResult result = Visao360HttpService.post(
            'NC_Visao360_Nbo', 'feedback', '{"offerId":"X"}', 3000);
        Test.stopTest();

        Assert.isTrue(result.isSuccess, 'POST 200 deve ser sucesso');
    }

    @IsTest
    static void shouldTolerateNulls_WhenOptionalParams() {
        Test.setMock(HttpCalloutMock.class, new OkMock());

        Test.startTest();
        Visao360HttpService.CallResult result =
            Visao360HttpService.get('NC_Visao360_Nbo', null, null);
        Test.stopTest();

        Assert.isTrue(result.isSuccess, 'Nulos opcionais nao quebram o GET');
    }
}
