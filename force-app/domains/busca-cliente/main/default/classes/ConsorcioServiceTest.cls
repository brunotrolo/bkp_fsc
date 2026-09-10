/**
 * @description Testes de ConsorcioService: 6 cotas com 2 no grupo Rural 9012,
 * incluindo cancelada selecionavel.
 */
@IsTest
private class ConsorcioServiceTest {

    private class OkMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse resp = new HttpResponse();
            resp.setStatusCode(200);
            resp.setBody('{'
                + '"cotas":['
                + '{"externalContractId":"cota-1","tipo":"Imovel","grupo":"1234","cota":"045","valor":"R$ 350.000","contemplacao":"Nao contemplada","parcela":"R$ 1.420/mes","status":"Ativa"},'
                + '{"externalContractId":"cota-2","tipo":"Veiculo","grupo":"5678","cota":"012","valor":"R$ 85.000","contemplacao":"Contemplada","parcela":"R$ 680/mes","status":"Ativa"},'
                + '{"externalContractId":"cota-3","tipo":"Rural","grupo":"9012","cota":"007","valor":"R$ 220.000","contemplacao":"Nao contemplada","parcela":"R$ 980/mes","status":"Ativa"},'
                + '{"externalContractId":"cota-4","tipo":"Rural","grupo":"9012","cota":"008","valor":"R$ 220.000","contemplacao":"Nao contemplada","parcela":"R$ 980/mes","status":"Ativa"},'
                + '{"externalContractId":"cota-5","tipo":"Imovel","grupo":"1234","cota":"089","valor":"R$ 500.000","contemplacao":"Contemplada","parcela":"R$ 2.100/mes","status":"Ativa"},'
                + '{"externalContractId":"cota-6","tipo":"Veiculo","grupo":"5678","cota":"034","valor":"R$ 120.000","contemplacao":"-","parcela":"-","status":"Cancelada"}'
                + ']}');
            return resp;
        }
    }

    @IsTest
    static void cotasComMesmoGrupo() {
        Test.setMock(HttpCalloutMock.class, new OkMock());
        ConsorcioService.ConsorcioResult r = ConsorcioService.fetchCotas('12345678900');
        System.assertEquals(null, r.fault);
        System.assertEquals(6, r.cotas.size());
        Integer rural9012 = 0;
        for (BuscaClienteDTOs.ConsorcioCotaDTO c : r.cotas) {
            if (c.tipo == 'Rural' && c.grupo == '9012') {
                rural9012++;
            }
        }
        System.assertEquals(2, rural9012, 'Duas cotas no grupo Rural 9012');
    }
}
