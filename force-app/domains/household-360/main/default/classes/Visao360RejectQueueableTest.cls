/**
 * @description Testes da recusa em 2o plano: Closed Lost + motivo rapido,
 * feedback melhor-esforco ao motor, mock sem DML. Cen 12, RN-05.
 * Padrao MIXED_DML: setup (agente) fora, todo DML nao-setup dentro do runAs.
 */
@IsTest
private class Visao360RejectQueueableTest {

    private class FeedbackOkMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse resp = new HttpResponse();
            resp.setStatusCode(200);
            resp.setBody('{"ok":true}');
            return resp;
        }
    }

    @IsTest
    static void shouldCloseLost_WhenRealReject() {
        Test.setMock(HttpCalloutMock.class, new FeedbackOkMock());
        User agente = Visao360TestFactory.novoAgente();
        System.runAs(agente) {
            Account acc = Visao360TestFactory.novaConta('Cliente Recusa', '33344455566', 'CPF');
            Visao360TestFactory.novaOferta(acc.Id, 'DOCC_BLACK_2026-09', 'Prospecting');
            Test.startTest();
            System.enqueueJob(new Visao360RejectQueueable('DOCC_BLACK_2026-09', 'SEM_INTERESSE'));
            Test.stopTest();

            Opportunity recusada = [
                SELECT StageName, Loss_Reason__c FROM Opportunity
                WHERE ExternalOfferId__c = 'DOCC_BLACK_2026-09' LIMIT 1
            ];
            Assert.areEqual('Closed Lost', recusada.StageName, 'Recusa encerra a oferta');
            Assert.areEqual('SEM_INTERESSE', recusada.Loss_Reason__c, 'Motivo rapido registrado');
        }
    }

    @IsTest
    static void shouldTolerateMissing_WhenOfferGone() {
        Test.setMock(HttpCalloutMock.class, new FeedbackOkMock());
        User agente = Visao360TestFactory.novoAgente();
        System.runAs(agente) {
            Test.startTest();
            System.enqueueJob(new Visao360RejectQueueable('INEXISTENTE_2026-09', 'JA_POSSUI'));
            Test.stopTest();

            // Sem excecao: UI otimista prevalece, job nunca quebra a tela.
            Assert.isTrue(true, 'Oferta ausente tolerada sem erro');
        }
    }

    @IsTest
    static void shouldSkipDml_WhenMockEnabled() {
        User agente = Visao360TestFactory.novoAgente();
        System.runAs(agente) {
            Visao360TestFactory.ligarMock();
            Account acc = Visao360TestFactory.novaConta('João da Silva', Visao360Mock.DOC_JOAO, 'CPF');
            Opportunity opp = Visao360TestFactory.novaOferta(acc.Id, '12345678900_BLACK_2026-09', 'Prospecting');
            Test.startTest();
            System.enqueueJob(new Visao360RejectQueueable('12345678900_BLACK_2026-09', 'SEM_INTERESSE'));
            Test.stopTest();

            Opportunity intacta = [SELECT StageName FROM Opportunity WHERE Id = :opp.Id];
            Assert.areEqual('Prospecting', intacta.StageName, 'Mock nao altera dado real');
        }
    }
}
