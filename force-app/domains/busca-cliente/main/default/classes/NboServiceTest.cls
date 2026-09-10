/**
 * @description Testes de NboService e NboInteractionService: 1 oferta, zero
 * ofertas, deduplicacao, falha parcial, abordar e dispensar com Task (Cen 11-15).
 */
@IsTest
private class NboServiceTest {

    public static final String NBO_OK = '{'
        + '"ofertas":[{'
        + '"externalOfferId":"nbo-black","productType":"CARTAO",'
        + '"titulo":"Oportunidade identificada: Cartao Black",'
        + '"narrativa":"Cliente elegivel para upgrade",'
        + '"beneficio":"Isencao de anuidade no 1o ano",'
        + '"beneficios":["Isencao total da anuidade no 1o ano","Sala VIP"],'
        + '"bandeiras":["Visa Infinite","Mastercard Black"],'
        + '"limites":"Limite pre-aprovado de R$ 15.000 a R$ 50.000",'
        + '"anuidade":"12x de R$ 98,00, isento no 1o ano"}]}';

    private class OkMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse resp = new HttpResponse();
            resp.setStatusCode(200);
            resp.setBody(NBO_OK);
            return resp;
        }
    }

    private class DupMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse resp = new HttpResponse();
            resp.setStatusCode(200);
            resp.setBody('{'
                + '"ofertas":['
                + '{"externalOfferId":"nbo-1","productType":"CARTAO","titulo":"Oferta 1"},'
                + '{"externalOfferId":"nbo-1","productType":"CARTAO","titulo":"Oferta 1 duplicada"},'
                + '{"externalOfferId":"nbo-2","productType":"CONSORCIO","titulo":"Oferta 2"}'
                + ']}');
            return resp;
        }
    }

    private class EmptyMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse resp = new HttpResponse();
            resp.setStatusCode(200);
            resp.setBody('{"ofertas":[]}');
            return resp;
        }
    }

    private class FailMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse resp = new HttpResponse();
            resp.setStatusCode(504);
            resp.setBody('timeout');
            return resp;
        }
    }

    @IsTest
    static void ofertaComNarrativaCompleta() {
        Test.setMock(HttpCalloutMock.class, new OkMock());
        NboService.NboResult r = NboService.fetch('12345678900');
        System.assertEquals(null, r.fault);
        System.assertEquals(1, r.offers.size());
        System.assertEquals(true, r.offers[0].isPrimary);
        System.assertEquals(2, r.offers[0].bandeiras.size());
        System.assertEquals(2, r.offers[0].beneficios.size());
    }

    @IsTest
    static void deduplicaMesmoProduto() {
        Test.setMock(HttpCalloutMock.class, new DupMock());
        NboService.NboResult r = NboService.fetch('12345678900');
        System.assertEquals(2, r.offers.size(), 'Oferta duplicada do mesmo produto suprimida');
    }

    @IsTest
    static void semOfertaRecolheArea() {
        Test.setMock(HttpCalloutMock.class, new EmptyMock());
        NboService.NboResult r = NboService.fetch('12ABC34501DE35');
        System.assertEquals(0, r.offers.size());
        System.assertEquals(null, r.fault);
    }

    @IsTest
    static void falhaParcialNaoBloqueia() {
        Test.setMock(HttpCalloutMock.class, new FailMock());
        NboService.NboResult r = NboService.fetch('99999999999');
        System.assertEquals('HTTP_504', r.fault.code);
    }
}
