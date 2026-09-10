/**
 * @description Testes de AssetTriggerHandler e TriggerBypass: bypass ativo por
 * padrao (handler inerte) e VR de formato Last4 agindo na DML (T-A07, T-C10).
 */
@IsTest
private class AssetTriggerHandlerTest {

    private static Account novaConta() {
        return new Account(Name = 'Conta Bypass');
    }

    @IsTest
    static void bypassAtivoPorPadrao() {
        System.assertEquals(true, TriggerBypass.isBypassed('Asset'));
        System.assertEquals(true, TriggerBypass.isBypassed('Opportunity'));
        System.assertEquals(true, TriggerBypass.isBypassed('QualquerCoisa'));
    }

    @IsTest
    static void linhaOrgDesligaBypass() {
        insert new TriggerBypass__c(
            SetupOwnerId = UserInfo.getOrganizationId(), Asset__c = false);
        System.assertEquals(false, TriggerBypass.isBypassed('Asset'));
        System.assertEquals(true, TriggerBypass.isBypassed('Opportunity'));
    }

    @IsTest
    static void handlerInerteComBypass() {
        Test.startTest();
        AssetTriggerHandler.handleBefore(new List<Asset>{
            new Asset(Name = 'Via', Last4__c = 'ZZ')
        });
        Test.stopTest();
        System.assertEquals(0, [SELECT COUNT() FROM Asset], 'Handler nao faz DML');
    }

    @IsTest
    static void validationRuleBloqueiaLast4Invalido() {
        Account acc = novaConta();
        insert acc;
        Boolean threw = false;
        Test.startTest();
        try {
            insert new Asset(Name = 'Via', AccountId = acc.Id, Last4__c = 'ZZ');
        } catch (DmlException e) {
            threw = true;
        }
        Test.stopTest();
        System.assertEquals(true, threw, 'Asset_Last4_Format deve bloquear Last4 fora do padrao');
    }

    @IsTest
    static void semBypassValidaFormato() {
        insert new TriggerBypass__c(
            SetupOwnerId = UserInfo.getOrganizationId(), Asset__c = false);
        Account acc = novaConta();
        insert acc;
        Boolean threw = false;
        Test.startTest();
        try {
            insert new Asset(Name = 'Via', AccountId = acc.Id, Last4__c = 'ZZ');
        } catch (DmlException e) {
            threw = true;
        }
        insert new Asset(Name = 'Via Boa', AccountId = acc.Id, Last4__c = '4321');
        Test.stopTest();
        System.assertEquals(true, threw, 'Sem bypass o handler valida formato');
        System.assertEquals(1, [SELECT COUNT() FROM Asset WHERE Last4__c = '4321']);
    }
}
