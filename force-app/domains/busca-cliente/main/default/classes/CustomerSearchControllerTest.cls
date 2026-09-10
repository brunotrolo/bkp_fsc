/**
 * @description Testes do CustomerSearchController: documento invalido bloqueia
 * antes de callout (Cen 4), identificacao agrega cadastro+holding com falhas
 * parciais (Cen 21/22) e lazy de vias (P8).
 */
@IsTest
private class CustomerSearchControllerTest {

    private class RouterMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            String endpoint = req.getEndpoint().toLowerCase();
            HttpResponse resp = new HttpResponse();
            resp.setStatusCode(200);
            if (endpoint.contains('/holding')) {
                resp.setBody('{"holding":[{"nome":"Seguro Auto","detalhe":"vigente","icone":"utility:truck"}]}');
            } else if (endpoint.contains('cartoes')) {
                resp.setBody('{"vias":[{"externalContractId":"via-1","brand":"Visa","category":"Gold","last4":"1111","holderName":"T","isTitular":true,"limite":"R$ 1.000","anuidade":"Isento","status":"Ativo"}]}');
            } else if (endpoint.contains('consorcio')) {
                resp.setBody('{"cotas":[{"externalContractId":"cota-1","tipo":"Imovel","grupo":"1234","cota":"001","valor":"R$ 10.000","contemplacao":"Nao","parcela":"R$ 100/mes","status":"Ativa"}]}');
            } else if (endpoint.contains('investimentos')) {
                resp.setBody('{"posicoes":[{"externalContractId":"inv-1","classe":"CDB","produto":"CDB X","valor":"R$ 1.000","rentabilidade":"10%","vencimento":"2027","risco":"Baixo"}]}');
            } else {
                resp.setBody(CadastroServiceTest.CADASTRO_OK);
            }
            return resp;
        }
    }

    private class NboFailMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse resp = new HttpResponse();
            resp.setStatusCode(504);
            resp.setBody('timeout');
            return resp;
        }
    }

    @IsTest
    static void documentoInvalidoNaoAcionaCallout() {
        Test.startTest();
        Boolean threw = false;
        try {
            CustomerSearchController.identifyCadastro('12345678999', 'PF');
        } catch (AuraHandledException e) {
            threw = true;
        }
        Test.stopTest();
        System.assertEquals(true, threw, 'DV invalido deve falhar antes de qualquer callout');
    }

    @IsTest
    static void identificacaoAgregaCadastroEHolding() {
        Test.setMock(HttpCalloutMock.class, new RouterMock());
        Test.startTest();
        BuscaClienteDTOs.CustomerSearchResultDTO dto =
            CustomerSearchController.identifyCadastro('52998224725', 'PF');
        Test.stopTest();
        System.assertEquals('52998224725', dto.documentNormalized);
        System.assertEquals('Joao da Silva', dto.demographic.nome);
        System.assertEquals(4, dto.portoBankWallet.size());
        System.assertEquals(1, dto.holdingWallet.size());
        System.assertEquals(true, dto.partialFaults.isEmpty());
    }

    @IsTest
    static void nboIndisponivelViraErroTratado() {
        Test.setMock(HttpCalloutMock.class, new NboFailMock());
        Test.startTest();
        Boolean threw = false;
        try {
            CustomerSearchController.fetchNboOffers('52998224725');
        } catch (AuraHandledException e) {
            threw = true;
        }
        Test.stopTest();
        System.assertEquals(true, threw, 'Falha de NBO vira AuraHandledException tratavel no LWC');
    }

    @IsTest
    static void lazyDeVias() {
        Test.setMock(HttpCalloutMock.class, new RouterMock());
        Test.startTest();
        List<BuscaClienteDTOs.CardViaDTO> vias =
            CustomerSearchController.fetchVias('52998224725');
        Test.stopTest();
        System.assertEquals(1, vias.size());
        System.assertEquals('•••• 1111', vias[0].last4Masked);
    }

    @IsTest
    static void lazyDeCotasEPosicoes() {
        Test.setMock(HttpCalloutMock.class, new RouterMock());
        Test.startTest();
        List<BuscaClienteDTOs.ConsorcioCotaDTO> cotas =
            CustomerSearchController.fetchCotas('52998224725');
        List<BuscaClienteDTOs.InvestimentoPosicaoDTO> posicoes =
            CustomerSearchController.fetchPosicoes('52998224725');
        Test.stopTest();
        System.assertEquals(1, cotas.size());
        System.assertEquals('1234', cotas[0].grupo);
        System.assertEquals(1, posicoes.size());
        System.assertEquals('Baixo', posicoes[0].risco);
    }

    @IsTest
    static void abordarEDispensarViaController() {
        User agente = BuscaClienteTestFactory.novoAgente();
        System.runAs(agente) {
            insert new Opportunity(
                Name = 'Oferta Black', StageName = 'Prospecting',
                CloseDate = Date.today().addDays(30),
                ExternalOfferId__c = 'nbo-c-1', NboStatus__c = 'Elegivel');
            Test.startTest();
            CustomerSearchController.approachNbo('nbo-c-1');
            CustomerSearchController.dismissNbo('nbo-c-1');
            Test.stopTest();
        }
        Opportunity o = [SELECT NboStatus__c FROM Opportunity WHERE ExternalOfferId__c = 'nbo-c-1' LIMIT 1];
        System.assertEquals('Dispensada', o.NboStatus__c);
        System.assertEquals(2, [SELECT COUNT() FROM Task WHERE WhatId = :o.Id]);
    }

    @IsTest
    static void contextoECatalogo() {
        User agente = BuscaClienteTestFactory.novoAgente();
        System.runAs(agente) {
            Account acc = new Account(Name = 'Joao', Document__c = '52998224725', DocumentType__c = 'CPF');
            insert acc;
            Test.startTest();
            BuscaClienteDTOs.InteractionContextDTO ctx =
                CustomerSearchController.fixInteractionContext('52998224725', 'CONTA_DIGITAL', null);
            List<BuscaClienteDTOs.CatalogItemDTO> catalog = CustomerSearchController.getCatalog();
            Test.stopTest();
            System.assertNotEquals(null, ctx.accountId);
            System.assertNotEquals(null, catalog);
        }
    }

    @IsTest
    static void entradasVaziasRejeitadas() {
        Boolean threw = false;
        Test.startTest();
        try {
            CustomerSearchController.fetchVias('');
        } catch (AuraHandledException e) {
            threw = true;
        }
        try {
            CustomerSearchController.approachNbo('');
        } catch (AuraHandledException e) {
            threw = true;
        }
        Test.stopTest();
        System.assertEquals(true, threw);
    }
}
