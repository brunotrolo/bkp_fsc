/**
 * @description Testes do NBO estatico: top 3 ordenado, dedup de safra,
 * retry do Carlos, recusa/aceite sem DML em mock e com DML no real.
 * Cen 10-13, 25, RN-06, RN-12, RN-14, RN-17.
 * Padrao MIXED_DML: setup (agente) fora, todo DML nao-setup dentro do runAs.
 */
@IsTest
private class Visao360NBOServiceTest {

    private class NboOkMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse resp = new HttpResponse();
            resp.setStatusCode(200);
            resp.setBody('{'
                + '"modelo":"Propensão Porto v3.2","safra":"2026-09","geradoEm":"06/09/2026 às 08:00",'
                + '"ofertas":['
                + '{"externalOfferId":"DOC_CDB_2026-09","productCode":"CDB","productName":"CDB 102%","category":"Investimentos","priority":3,"propensityScore":74,"headline":"Aplicação mínima","elegibilidade":"Saldo parado","confianca":"Média","motivos":["m1"],"validade":"15/10/2026","chaveSafra":"DOC_CDB_2026-09","omniScriptKey":"osSaleInvestimento"},'
                + '{"externalOfferId":"DOC_BLACK_2026-09","productCode":"BLACK","productName":"Cartão Black","category":"Cartão de Crédito","priority":1,"propensityScore":92,"headline":"Isenção 1º ano","elegibilidade":"Sem Black","confianca":"Alta","motivos":["m1","m2"],"validade":"30/09/2026","chaveSafra":"DOC_BLACK_2026-09","omniScriptKey":"osSaleCreditCard"},'
                + '{"externalOfferId":"DOC_BLACK_2026-09","productCode":"BLACK","productName":"Cartão Black DUPLICADO","category":"Cartão","priority":1,"propensityScore":99,"headline":"dup","elegibilidade":"dup","confianca":"Alta","motivos":[],"validade":"30/09/2026","chaveSafra":"DOC_BLACK_2026-09","omniScriptKey":"x"},'
                + '{"externalOfferId":"DOC_CONS_2026-09","productCode":"CONSORCIO","productName":"Consórcio Imóvel","category":"Consórcio","priority":2,"propensityScore":81,"headline":"Lance embutido","elegibilidade":"Sem consórcio","confianca":"Alta","motivos":["m1"],"validade":"30/09/2026","chaveSafra":"DOC_CONS_2026-09","omniScriptKey":"osSaleConsorcio"},'
                + '{"externalOfferId":"DOC_EXTRA_2026-09","productCode":"EXTRA","productName":"Extra","category":"Outros","priority":4,"propensityScore":10,"headline":"extra","elegibilidade":"x","confianca":"Baixa","motivos":[],"validade":"30/09/2026","chaveSafra":"DOC_EXTRA_2026-09","omniScriptKey":"x"}'
                + ']}');
            return resp;
        }
    }

    @IsTest
    static void shouldReturnFault_WhenNullAccount() {
        Visao360DTOs.NboResult result = Visao360NBOService.getOffersAndSync(null, false);

        Assert.isNotNull(result.fault, 'Conta nula vira fault');
    }

    @IsTest
    static void shouldReturnMockTop3_WhenFlagOn() {
        User agente = Visao360TestFactory.novoAgente();
        System.runAs(agente) {
            Visao360TestFactory.ligarMock();
            Account acc = Visao360TestFactory.novaConta('João da Silva', Visao360Mock.DOC_JOAO, 'CPF');
            Test.startTest();
            Visao360DTOs.NboResult result = Visao360NBOService.getOffersAndSync(acc.Id, false);
            Test.stopTest();

            Assert.areEqual(3, result.offers.size(), 'Top 3 do Joao');
            Assert.areEqual('BLACK', result.offers[0].productCode, 'Maior score primeiro (92)');
        }
    }

    @IsTest
    static void shouldSortDedupAndLimit_WhenRealPayload() {
        Test.setMock(HttpCalloutMock.class, new NboOkMock());
        User agente = Visao360TestFactory.novoAgente();
        System.runAs(agente) {
            Account acc = Visao360TestFactory.novaConta('Cliente Real', '55566677788', 'CPF');
            Test.startTest();
            Visao360DTOs.NboResult result = Visao360NBOService.getOffersAndSync(acc.Id, false);
            Test.stopTest();

            Assert.areEqual(3, result.offers.size(), 'Limita ao top 3 (Cen 10)');
            Assert.areEqual('BLACK', result.offers[0].productCode, 'Ordena por score desc');
            Assert.areEqual('CONSORCIO', result.offers[1].productCode, 'Segundo maior score');
            Assert.areEqual('CDB', result.offers[2].productCode, 'Terceiro maior score');
            Assert.areEqual('2026-09', result.motor.safra, 'Safra do motor');
            Integer opps = [SELECT COUNT() FROM Opportunity WHERE AccountId = :acc.Id];
            Assert.areEqual(3, opps, 'Sync em 2o plano persiste sem duplicar a safra (Cen 11)');
        }
    }

    @IsTest
    static void shouldSkipDml_WhenMockRejectAndAccept() {
        User agente = Visao360TestFactory.novoAgente();
        System.runAs(agente) {
            Visao360TestFactory.ligarMock();
            Account acc = Visao360TestFactory.novaConta('João da Silva', Visao360Mock.DOC_JOAO, 'CPF');
            Test.startTest();
            Visao360NBOService.rejectOffer('12345678900_BLACK_2026-09', 'SEM_INTERESSE');
            Visao360DTOs.NBOOfferDTO aceite = Visao360NBOService.acceptOffer('12345678900_BLACK_2026-09');
            Test.stopTest();

            Assert.areEqual('negociacao', aceite.estado, 'Aceite mock marca negociacao (RN-14)');
        }
        Integer opps = [SELECT COUNT() FROM Opportunity];
        Assert.areEqual(0, opps, 'Mock nunca persiste fixture como dado real');
    }

    @IsTest
    static void shouldThrow_WhenBlankOfferReject() {
        try {
            Visao360NBOService.rejectOffer('', 'SEM_INTERESSE');
            Assert.fail('Recusa sem oferta deve falhar');
        } catch (Visao360NBOService.Visao360Exception e) {
            Assert.isTrue(e.getMessage().contains('não informada'), 'Mensagem orienta o operador');
        }
    }

    @IsTest
    static void shouldMarkNegotiation_WhenRealAccept() {
        User agente = Visao360TestFactory.novoAgente();
        System.runAs(agente) {
            Account acc = Visao360TestFactory.novaConta('Cliente Real', '77788899900', 'CPF');
            Visao360TestFactory.novaOferta(acc.Id, 'DOC_BLACK_2026-09', 'Prospecting');
            Test.startTest();
            Visao360DTOs.NBOOfferDTO aceite = Visao360NBOService.acceptOffer('DOC_BLACK_2026-09');
            Test.stopTest();

            Assert.areEqual('negociacao', aceite.estado, 'Estado de saida para a jornada futura');
        }
        Opportunity atual = [SELECT StageName FROM Opportunity WHERE ExternalOfferId__c = 'DOC_BLACK_2026-09' LIMIT 1];
        Assert.areEqual('Negotiation/Review', atual.StageName, 'Aceite marca negociacao');
    }
}
