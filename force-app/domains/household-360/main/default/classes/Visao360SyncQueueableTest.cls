/**
 * @description Testes do sync idempotente: mesma safra 2x nao duplica,
 * safra antiga vencida expira, ausente-mas-valida mantida; mock sem DML.
 * Cen 11, RN-06.
 * Padrao MIXED_DML: setup (agente) fora, todo DML nao-setup dentro do runAs.
 */
@IsTest
private class Visao360SyncQueueableTest {

    private static List<Visao360DTOs.NBOOfferDTO> ofertas(String sufixo) {
        Visao360DTOs.NBOOfferDTO a = new Visao360DTOs.NBOOfferDTO();
        a.externalOfferId = 'DOCA_BLACK_2026-09' + sufixo;
        a.chaveSafra = a.externalOfferId;
        a.productName = 'Cartão Black';
        a.propensityScore = 92;
        a.confianca = 'Alta';
        a.omniScriptKey = 'osSaleCreditCard';
        a.validade = '30/09/2026';
        a.estado = 'elegivel';
        Visao360DTOs.NBOOfferDTO b = new Visao360DTOs.NBOOfferDTO();
        b.externalOfferId = 'DOCA_CDB_2026-09' + sufixo;
        b.chaveSafra = b.externalOfferId;
        b.productName = 'CDB 102%';
        b.propensityScore = 74;
        b.confianca = 'Média';
        b.omniScriptKey = 'osSaleInvestimento';
        b.validade = '15/10/2026';
        b.estado = 'elegivel';
        return new List<Visao360DTOs.NBOOfferDTO>{ a, b };
    }

    @IsTest
    static void shouldNotDuplicate_WhenSameSafraTwice() {
        User agente = Visao360TestFactory.novoAgente();
        System.runAs(agente) {
            Account acc = Visao360TestFactory.novaConta('Cliente Sync', '11122233344', 'CPF');
            Test.startTest();
            System.enqueueJob(new Visao360SyncQueueable(acc.Id, '2026-09', ofertas('')));
            Test.stopTest();

            // Segunda passagem executa direto (so o 1o job enfileirado roda em
            // testes): re-sync da mesma safra nao pode duplicar (RN-06).
            new Visao360SyncQueueable(acc.Id, '2026-09', ofertas('')).execute(null);

            Integer opps = [SELECT COUNT() FROM Opportunity WHERE AccountId = :acc.Id];
            Assert.areEqual(2, opps, 'Re-sync da mesma safra nao duplica (RN-06)');
        }
    }

    @IsTest
    static void shouldExpire_WhenPreviousSafraOverdue() {
        User agente = Visao360TestFactory.novoAgente();
        System.runAs(agente) {
            Account acc = Visao360TestFactory.novaConta('Cliente Expira', '22233344455', 'CPF');
            Opportunity antiga = Visao360TestFactory.novaOferta(acc.Id, 'DOCB_OLD_2026-08', 'Prospecting');
            antiga.Offer_Safra__c = '2026-08';
            antiga.ExpirationDate__c = Date.today().addDays(-1);
            update antiga;
            Opportunity valida = Visao360TestFactory.novaOferta(acc.Id, 'DOCB_KEEP_2026-09', 'Prospecting');
            valida.Offer_Safra__c = '2026-09';
            valida.ExpirationDate__c = Date.today().addDays(30);
            update valida;
            Test.startTest();
            // Nova safra sem as antigas: expira a vencida, mantem a valida ausente.
            System.enqueueJob(new Visao360SyncQueueable(acc.Id, '2026-09', ofertas('X')));
            Test.stopTest();

            Opportunity expirada = [SELECT StageName, Loss_Reason__c FROM Opportunity WHERE Id = :antiga.Id];
            Assert.areEqual('Closed Lost', expirada.StageName, 'Vencida encerra com motivo');
            Assert.areEqual('Safra expirada', expirada.Loss_Reason__c, 'Motivo de expiracao');
            Opportunity mantida = [SELECT StageName FROM Opportunity WHERE Id = :valida.Id];
            Assert.areEqual('Prospecting', mantida.StageName, 'Ausente-mas-valida mantida (RN-06)');
        }
    }

    @IsTest
    static void shouldSkipDml_WhenMockEnabled() {
        User agente = Visao360TestFactory.novoAgente();
        System.runAs(agente) {
            Visao360TestFactory.ligarMock();
            Account acc = Visao360TestFactory.novaConta('João da Silva', Visao360Mock.DOC_JOAO, 'CPF');
            Test.startTest();
            System.enqueueJob(new Visao360SyncQueueable(acc.Id, '2026-09', ofertas('')));
            Test.stopTest();

            Integer opps = [SELECT COUNT() FROM Opportunity WHERE AccountId = :acc.Id];
            Assert.areEqual(0, opps, 'Mock nao persiste safra como dado real');
        }
    }

    @IsTest
    static void shouldParseDates_WhenMotorFormats() {
        Assert.areEqual(Date.newInstance(2026, 9, 30), Visao360SyncQueueable.dataDe('30/09/2026'), 'dd/MM/yyyy do motor');
        Assert.areEqual(Date.newInstance(2026, 9, 30), Visao360SyncQueueable.dataDe('2026-09-30'), 'ISO');
        Assert.isNull(Visao360SyncQueueable.dataDe('invalida'), 'Invalida tolerada');
        Assert.isNull(Visao360SyncQueueable.dataDe(null), 'Nula tolerada');
    }
}
