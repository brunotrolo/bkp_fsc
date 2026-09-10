/**
 * @description Testes de HoldingService: lista informativa, vazio e falha
 * parcial sem bloquear (Cen 8, Cen 22).
 */
@IsTest
private class HoldingServiceTest {

    private class OkMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse resp = new HttpResponse();
            resp.setStatusCode(200);
            resp.setBody('{'
                + '"holding":['
                + '{"nome":"Seguro Auto","detalhe":"Apolice vigente","icone":"utility:truck"},'
                + '{"nome":"Plano de Saude","detalhe":"Titular + 2 dependentes","icone":"utility:co_insurance"}'
                + ']}');
            return resp;
        }
    }

    private class FailMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse resp = new HttpResponse();
            resp.setStatusCode(500);
            resp.setBody('erro');
            return resp;
        }
    }

    @IsTest
    static void holdingInformativo() {
        Test.setMock(HttpCalloutMock.class, new OkMock());
        HoldingService.HoldingResult r = HoldingService.fetch('12345678900');
        System.assertEquals(null, r.fault);
        System.assertEquals(2, r.items.size());
        System.assertEquals('Seguro Auto', r.items[0].nome);
    }

    @IsTest
    static void falhaParcialNaoLancaExcecao() {
        Test.setMock(HttpCalloutMock.class, new FailMock());
        HoldingService.HoldingResult r = HoldingService.fetch('12345678900');
        System.assertEquals('HTTP_500', r.fault.code);
        System.assertEquals(true, r.items.isEmpty());
    }
}
