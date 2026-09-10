/**
 * @description Testes de CadastroService e HoldingService com HttpCalloutMock
 * (Cen 6-9, EL-12): carteira 4 Porto Bank + holding filtrado, nao-encontrado e
 * falha parcial.
 */
@IsTest
public class CadastroServiceTest {

    public static final String CADASTRO_OK = '{'
        + '"demografico":{"nome":"Joao da Silva","tipoPessoa":"Pessoa Fisica",'
        + '"documentoFormatado":"123.456.789-00","segmento":"Exclusivo",'
        + '"email":"joao@email.com","telefone":"(11) 99999-1234","renda":"R$ 18.500",'
        + '"agencia":"0001","conta":"12345-6","statusCadastro":"Cadastro atualizado"},'
        + '"carteira":['
        + '{"productType":"CARTAO","label":"Cartao de Credito","quantidade":4,"resumo":"4 plasticos","icone":"utility:card_details","exigeSubselecao":true},'
        + '{"productType":"CONTA_DIGITAL","label":"Conta Digital","quantidade":1,"resumo":"Ativa","icone":"custom:custom16","exigeSubselecao":false},'
        + '{"productType":"CONSORCIO","label":"Consorcio","quantidade":6,"resumo":"6 cotas","icone":"utility:contract_doc","exigeSubselecao":true},'
        + '{"productType":"INVESTIMENTOS","label":"Investimentos","quantidade":5,"resumo":"5 posicoes","icone":"standard:investment_account","exigeSubselecao":true},'
        + '{"productType":"HOLDING_AUTO","label":"Seguro Auto","quantidade":1,"resumo":"vigente","icone":"utility:truck","holdingInformativo":true}'
        + ']}';

    private class OkMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse resp = new HttpResponse();
            resp.setStatusCode(200);
            resp.setBody(CADASTRO_OK);
            return resp;
        }
    }

    private class EmptyMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse resp = new HttpResponse();
            resp.setStatusCode(200);
            resp.setBody('{}');
            return resp;
        }
    }

    private class FailMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse resp = new HttpResponse();
            resp.setStatusCode(503);
            resp.setBody('indisponivel');
            return resp;
        }
    }

    @IsTest
    static void carteiraCompletaSeparaHolding() {
        Test.setMock(HttpCalloutMock.class, new OkMock());
        CadastroService.CadastroResult r = CadastroService.fetch('12345678900');
        System.assertEquals(null, r.fault);
        System.assertEquals('Joao da Silva', r.demographic.nome);
        System.assertEquals(4, r.wallet.size(), 'Holding nao entra na carteira Porto Bank');
        System.assertEquals('CARTAO', r.wallet[0].productType);
        System.assertEquals(true, r.wallet[0].exigeSubselecao);
    }

    @IsTest
    static void vazioViraNaoEncontrado() {
        Test.setMock(HttpCalloutMock.class, new EmptyMock());
        CadastroService.CadastroResult r = CadastroService.fetch('00000000000');
        System.assertEquals('NOT_FOUND', r.fault.code);
    }

    @IsTest
    static void falhaViraFaultSemExcecao() {
        Test.setMock(HttpCalloutMock.class, new FailMock());
        CadastroService.CadastroResult r = CadastroService.fetch('88888888888');
        System.assertEquals('HTTP_503', r.fault.code);
        System.assertEquals(true, r.wallet.isEmpty());
    }
}
