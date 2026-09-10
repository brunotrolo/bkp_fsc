/**
 * @description Testes de InteractionContextService: contexto cliente+produto
 * e cliente+produto+item (P7/P8, RN-09). Roda como operador com o PS da
 * jornada: mesmo enforcement USER_MODE da producao.
 */
@IsTest
private class InteractionContextServiceTest {

    private static void seed() {
        Account acc = new Account(Name = 'Joao da Silva', Document__c = '52998224725', DocumentType__c = 'CPF');
        insert acc;
        insert new Asset(AccountId = acc.Id, Name = 'Cartao de Credito',
            ExternalContractId__c = 'CTR-1', ProductType__c = 'CARTAO', ViaStatus__c = 'Ativo');
    }

    @IsTest
    static void contextoDiretoContaDigital() {
        User agente = BuscaClienteTestFactory.novoAgente();
        System.runAs(agente) {
            seed();
            Test.startTest();
            BuscaClienteDTOs.InteractionContextDTO ctx =
                InteractionContextService.build('52998224725', 'CONTA_DIGITAL', null);
            Test.stopTest();
            System.assertNotEquals(null, ctx.accountId);
            System.assertEquals('CONTA_DIGITAL', ctx.productType);
            System.assertEquals(null, ctx.itemAssetId);
            System.assertNotEquals(null, ctx.resumo);
        }
    }

    @IsTest
    static void contextoComViaSelecionada() {
        User agente = BuscaClienteTestFactory.novoAgente();
        System.runAs(agente) {
            seed();
            Test.startTest();
            BuscaClienteDTOs.InteractionContextDTO ctx =
                InteractionContextService.build('52998224725', 'CARTAO', 'CTR-1');
            Test.stopTest();
            System.assertNotEquals(null, ctx.itemAssetId);
            System.assertEquals(ctx.itemAssetId, ctx.assetId);
        }
    }

    @IsTest
    static void documentoSemConsolidacao() {
        User agente = BuscaClienteTestFactory.novoAgente();
        System.runAs(agente) {
            Test.startTest();
            BuscaClienteDTOs.InteractionContextDTO ctx =
                InteractionContextService.build('00000000000', 'CARTAO', null);
            Test.stopTest();
            System.assertEquals(null, ctx.accountId);
        }
    }
}
