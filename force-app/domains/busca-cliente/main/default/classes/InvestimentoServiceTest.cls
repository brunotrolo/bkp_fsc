/**
 * @description Testes de InvestimentoService: 5 posicoes com classe, valor,
 * rentabilidade, vencimento e risco.
 */
@IsTest
private class InvestimentoServiceTest {

    private class OkMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse resp = new HttpResponse();
            resp.setStatusCode(200);
            resp.setBody('{'
                + '"posicoes":['
                + '{"externalContractId":"inv-1","classe":"Renda Fixa","produto":"CDB Porto Bank","valor":"R$ 18.000","rentabilidade":"+11,2% a.a.","vencimento":"Vence em 12/2027","risco":"Baixo"},'
                + '{"externalContractId":"inv-2","classe":"Renda Fixa","produto":"Tesouro Selic 2029","valor":"R$ 9.500","rentabilidade":"Selic + 0,1%","vencimento":"Vence em 03/2029","risco":"Baixo"},'
                + '{"externalContractId":"inv-3","classe":"CDB","produto":"CDB Prefixado 2 anos","valor":"R$ 6.000","rentabilidade":"12,4% a.a.","vencimento":"Vence em 06/2027","risco":"Baixo"},'
                + '{"externalContractId":"inv-4","classe":"Renda Variavel","produto":"Fundo Acoes Dividendos","valor":"R$ 5.200","rentabilidade":"+18,3% em 12m","vencimento":"Resgate D+2","risco":"Alto"},'
                + '{"externalContractId":"inv-5","classe":"Fundos","produto":"Fundo Multimercado","valor":"R$ 3.300","rentabilidade":"+9,6% em 12m","vencimento":"Resgate D+1","risco":"Moderado"}'
                + ']}');
            return resp;
        }
    }

    @IsTest
    static void posicoesCompletas() {
        Test.setMock(HttpCalloutMock.class, new OkMock());
        InvestimentoService.InvestimentoResult r = InvestimentoService.fetchPosicoes('12345678900');
        System.assertEquals(null, r.fault);
        System.assertEquals(5, r.posicoes.size());
        System.assertEquals('Alto', r.posicoes[3].risco);
        System.assertEquals('Resgate D+1', r.posicoes[4].vencimento);
    }
}
