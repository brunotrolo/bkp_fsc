/**
 * @description Testes de HttpCalloutService: sucesso, HTTP 500 e excecao de
 * callout viram fault tipada, nunca excecao para o chamador (Cen 22).
 */
@IsTest
private class HttpCalloutServiceTest {

    private class OkMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse resp = new HttpResponse();
            resp.setStatusCode(200);
            resp.setBody('{"ok":true}');
            return resp;
        }
    }

    private class ErrorMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse resp = new HttpResponse();
            resp.setStatusCode(500);
            resp.setBody('erro');
            return resp;
        }
    }

    private class ThrowMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            throw new CalloutException('Read timed out');
        }
    }

    @IsTest
    static void sucessoRetornaResponse() {
        Test.setMock(HttpCalloutMock.class, new OkMock());
        HttpCalloutService.CallResult r =
            HttpCalloutService.get('NC_CadastroCorporativo', '123', 2500);
        System.assertEquals(true, r.isSuccess);
        System.assertEquals(null, r.fault);
    }

    @IsTest
    static void http500ViraFault() {
        Test.setMock(HttpCalloutMock.class, new ErrorMock());
        HttpCalloutService.CallResult r =
            HttpCalloutService.get('NC_NboMotor', '123', 3000);
        System.assertEquals(false, r.isSuccess);
        System.assertEquals('HTTP_500', r.fault.code);
    }

    @IsTest
    static void excecaoViraFault() {
        Test.setMock(HttpCalloutMock.class, new ThrowMock());
        HttpCalloutService.CallResult r =
            HttpCalloutService.get('NC_NboMotor', '123', 3000);
        System.assertEquals(false, r.isSuccess);
        System.assertEquals('CALLOUT_ERROR', r.fault.code);
    }
}
