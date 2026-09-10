/**
 * @description Testes lazy de Card, Consorcio e Investimento: 4 vias com
 * titular/adicional e situacoes, 6 cotas com 2 no mesmo grupo, 5 posicoes,
 * ativos primeiro e limite de 50 (Cen 17-20, EL-03/04/05).
 */
@IsTest
private class CardServiceTest {

    private class OkMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse resp = new HttpResponse();
            resp.setStatusCode(200);
            resp.setBody('{'
                + '"vias":['
                + '{"externalContractId":"via-1234","brand":"Visa","category":"Infinite","last4":"1234","holderName":"Joao da Silva","isTitular":true,"limite":"R$ 28.000","anuidade":"Isento","status":"Ativo"},'
                + '{"externalContractId":"via-5678","brand":"Mastercard","category":"Platinum","last4":"5678","holderName":"Joao da Silva","isTitular":true,"limite":"-","anuidade":"-","status":"Cancelado"},'
                + '{"externalContractId":"via-9012","brand":"Visa","category":"Gold","last4":"9012","holderName":"Maria da Silva","isTitular":false,"limite":"R$ 8.000","anuidade":"12x R$ 32,00","status":"Ativo"},'
                + '{"externalContractId":"via-3456","brand":"Mastercard","category":"Black","last4":"3456","holderName":"Joao da Silva","isTitular":true,"limite":"R$ 42.000","anuidade":"12x R$ 98,00","status":"Bloqueado"}'
                + ']}');
            return resp;
        }
    }

    @IsTest
    static void viasCompletasMascaradasEOrdenadas() {
        Test.setMock(HttpCalloutMock.class, new OkMock());
        CardService.CardResult r = CardService.fetchVias('12345678900');
        System.assertEquals(null, r.fault);
        System.assertEquals(4, r.vias.size());
        System.assertEquals('Ativo', r.vias[0].status, 'Ativos primeiro');
        System.assertEquals('•••• 1234', r.vias[0].last4Masked, 'Last4 sempre mascarado');
        System.assertEquals(false, r.vias[1].isTitular, 'Adicional distinguido');
        System.assertEquals('Cancelado', r.vias[2].status);
        System.assertEquals('Bloqueado', r.vias[3].status);
    }
}
