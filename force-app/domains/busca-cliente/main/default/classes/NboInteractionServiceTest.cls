/**
 * @description Testes de NboInteractionService: abordar e dispensar atualizam
 * status, operador, timestamp e criam Task de auditoria (Cen 14/15).
 * Roda como operador com o PS da jornada: mesmo enforcement USER_MODE da
 * producao; registros criados pelo proprio operador (OWD Private).
 */
@IsTest
private class NboInteractionServiceTest {

    private static Opportunity newOffer(String externalId) {
        return new Opportunity(
            Name = 'Oferta Black',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            ExternalOfferId__c = externalId,
            NboProductType__c = 'CARTAO',
            NboStatus__c = 'Elegivel'
        );
    }

    @IsTest
    static void abordarRegistraEAudita() {
        User agente = BuscaClienteTestFactory.novoAgente();
        Opportunity created;
        System.runAs(agente) {
            created = newOffer('nbo-t-1');
            insert created;
            Test.startTest();
            NboInteractionService.approach(new List<String>{ 'nbo-t-1' });
            Test.stopTest();
        }
        Opportunity o = [SELECT NboStatus__c, ApproachTimestamp__c, LastNboInteractionBy__c
                         FROM Opportunity WHERE Id = :created.Id LIMIT 1];
        System.assertEquals('Abordada', o.NboStatus__c);
        System.assertNotEquals(null, o.ApproachTimestamp__c);
        System.assertEquals(agente.Id, o.LastNboInteractionBy__c);
        System.assertEquals(1, [SELECT COUNT() FROM Task WHERE WhatId = :o.Id AND Subject = 'NBO Abordada']);
    }

    @IsTest
    static void dispensarRegistraEAudita() {
        User agente = BuscaClienteTestFactory.novoAgente();
        Opportunity created;
        System.runAs(agente) {
            created = newOffer('nbo-t-2');
            insert created;
            Test.startTest();
            NboInteractionService.dismissWithReason(new List<String>{ 'nbo-t-2' }, 'Cliente sem interesse');
            Test.stopTest();
        }
        Opportunity o = [SELECT NboStatus__c, DismissalReason__c
                         FROM Opportunity WHERE Id = :created.Id LIMIT 1];
        System.assertEquals('Dispensada', o.NboStatus__c);
        System.assertEquals('Cliente sem interesse', o.DismissalReason__c);
        System.assertEquals(1, [SELECT COUNT() FROM Task WHERE WhatId = :o.Id AND Subject = 'NBO Dispensada']);
    }

    @IsTest
    static void listaVaziaNaoFalha() {
        User agente = BuscaClienteTestFactory.novoAgente();
        System.runAs(agente) {
            Test.startTest();
            NboInteractionService.approach(new List<String>());
            NboInteractionService.dismiss(null);
            Test.stopTest();
        }
        System.assertEquals(0, [SELECT COUNT() FROM Opportunity]);
    }
}
