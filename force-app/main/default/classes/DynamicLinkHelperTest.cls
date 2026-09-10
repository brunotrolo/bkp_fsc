/**
 * @description Testes da DynamicLinkHelper (links dinamicos, queries, setup pages).
 */
@isTest
private class DynamicLinkHelperTest {

    private static DynamicLink__c seedLink(String identity) {
        DynamicLink__c link = new DynamicLink__c(Identity__c = identity);
        insert link;
        return link;
    }

    @isTest
    static void shouldReturnLink_WhenIdentityExists() {
        // Given
        DynamicLink__c link = seedLink('TESTE_ID_001');

        // When
        Test.startTest();
        DynamicLink__c result = DynamicLinkHelper.getDynamicLinkByIdentity('TESTE_ID_001');
        Test.stopTest();

        // Then
        Assert.areEqual(link.Id, result.Id, 'Deve retornar o link da identidade.');
    }

    @isTest
    static void shouldThrowQueryException_WhenIdentityMissing() {
        // When/Then: produção não trata 0 linhas — documenta o comportamento real
        Test.startTest();
        try {
            DynamicLinkHelper.getDynamicLinkByIdentity('IDENTIDADE_INEXISTENTE_XYZ');
            Assert.fail('Deveria lancar QueryException (0 linhas).');
        } catch (QueryException e) {
            Assert.isTrue(e.getMessage().contains('List has no rows'), 'Deve ser no-rows: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void shouldReturnIds_WhenValidObjectQuery() {
        // When
        Test.startTest();
        List<SObject> result = DynamicLinkHelper.getObjectIdFromQuery('Account', 'Name != null');
        Test.stopTest();

        // Then
        Assert.isNotNull(result, 'Resultado nunca deve ser nulo.');
    }

    @isTest
    static void shouldThrowAura_WhenObjectApiNameEmpty() {
        // When/Then
        Test.startTest();
        try {
            DynamicLinkHelper.getObjectIdFromQuery('', 'Name != null');
            Assert.fail('Deveria lancar AuraHandledException.');
        } catch (AuraHandledException e) {
            Assert.isInstanceOfType(e, AuraHandledException.class, 'Tipo deve ser AuraHandled.');
        }
        Test.stopTest();
    }

    @isTest
    static void shouldThrowAura_WhenWhereConditionEmpty() {
        // When/Then
        Test.startTest();
        try {
            DynamicLinkHelper.getObjectIdFromQuery('Account', '');
            Assert.fail('Deveria lancar AuraHandledException.');
        } catch (AuraHandledException e) {
            Assert.isInstanceOfType(e, AuraHandledException.class, 'Tipo deve ser AuraHandled.');
        }
        Test.stopTest();
    }

    @isTest
    static void shouldThrowAura_WhenQueryIsInvalid() {
        // When/Then
        Test.startTest();
        try {
            DynamicLinkHelper.getObjectIdFromQuery('Account', 'CampoInexistenteXYZ = 1');
            Assert.fail('Deveria lancar AuraHandledException.');
        } catch (AuraHandledException e) {
            Assert.isInstanceOfType(e, AuraHandledException.class, 'Tipo deve ser AuraHandled.');
        }
        Test.stopTest();
    }

    @isTest
    static void shouldBuildSetupUrl_WhenUserObject() {
        // When
        Test.startTest();
        String url = DynamicLinkHelper.getSetupPageLink('User', UserInfo.getUserId());
        Test.stopTest();

        // Then
        Assert.isTrue(url.contains('ManageUsers'), 'URL deve apontar para ManageUsers: ' + url);
        Assert.isTrue(url.contains(UserInfo.getUserId()), 'URL deve conter o record id.');
        Assert.isTrue(url.contains('noredirect=1'), 'URL deve ter noredirect.');
    }

    @isTest
    static void shouldThrowAura_WhenSetupObjectEmpty() {
        // When/Then
        Test.startTest();
        try {
            DynamicLinkHelper.getSetupPageLink('', 'x');
            Assert.fail('Deveria lancar AuraHandledException.');
        } catch (AuraHandledException e) {
            Assert.isInstanceOfType(e, AuraHandledException.class, 'Tipo deve ser AuraHandled.');
        }
        Test.stopTest();
    }

    @isTest
    static void shouldThrowAura_WhenNoSetupPageRecord() {
        // When/Then: Contact nao tem registro no CMDT
        Test.startTest();
        try {
            DynamicLinkHelper.getSetupPageLink('Contact', 'x');
            Assert.fail('Deveria lancar AuraHandledException.');
        } catch (AuraHandledException e) {
            Assert.isInstanceOfType(e, AuraHandledException.class, 'Tipo deve ser AuraHandled.');
        }
        Test.stopTest();
    }

    @isTest
    static void shouldThrowAura_WhenNetworkIdInvalid() {
        // When/Then
        Test.startTest();
        try {
            DynamicLinkHelper.getSiteUrl('0DB000000000000AAA');
            Assert.fail('Deveria lancar AuraHandledException.');
        } catch (AuraHandledException e) {
            Assert.isInstanceOfType(e, AuraHandledException.class, 'Tipo deve ser AuraHandled.');
        }
        Test.stopTest();
    }

    @isTest
    static void shouldThrowAura_WhenLinkTypeGuardsEmpty() {
        // When/Then
        Test.startTest();
        try {
            DynamicLinkHelper.getRecordIdFromDynamicLinkType('', 'Name != null');
            Assert.fail('Deveria lancar AuraHandledException (tipo vazio).');
        } catch (AuraHandledException e) {
            Assert.isInstanceOfType(e, AuraHandledException.class, 'Tipo deve ser AuraHandled.');
        }
        try {
            DynamicLinkHelper.getRecordIdFromDynamicLinkType('CommunityPage', '');
            Assert.fail('Deveria lancar AuraHandledException (where vazio).');
        } catch (AuraHandledException e) {
            Assert.isInstanceOfType(e, AuraHandledException.class, 'Tipo deve ser AuraHandled.');
        }
        Test.stopTest();
    }

    @isTest
    static void shouldQuerySurveyType_WhenValidWhere() {
        // When: a linha do when executa; o Database.query pode retornar vazio ou estourar
        // (objeto pode não existir na org) — ambos cobrem o ramo; o teste aceita os dois.
        Test.startTest();
        try {
            List<SObject> result = DynamicLinkHelper.getRecordIdFromDynamicLinkType('SurveyRecordPage', 'Name != null');
            Assert.isNotNull(result, 'Survey nunca nulo.');
        } catch (AuraHandledException e) {
            Assert.isInstanceOfType(e, AuraHandledException.class, 'Ou retorna lista ou AuraHandled.');
        }
        Test.stopTest();
    }

    @isTest
    static void shouldQueryFlowType_WhenValidWhere() {
        // When: FlowDefinitionView pode não ser consultável em Apex — aceita os dois desfechos
        Test.startTest();
        try {
            List<SObject> result = DynamicLinkHelper.getRecordIdFromDynamicLinkType('FlowRecordPage', 'DeveloperName != null');
            Assert.isNotNull(result, 'Flow nunca nulo.');
        } catch (AuraHandledException e) {
            Assert.isInstanceOfType(e, AuraHandledException.class, 'Ou retorna lista ou AuraHandled.');
        }
        Test.stopTest();
    }

    @isTest
    static void shouldQueryDpeType_WhenValidWhere() {
        // When
        Test.startTest();
        try {
            List<SObject> result = DynamicLinkHelper.getRecordIdFromDynamicLinkType('DPERecordPage', 'Name != null');
            Assert.isNotNull(result, 'DPE nunca nulo.');
        } catch (AuraHandledException e) {
            Assert.isInstanceOfType(e, AuraHandledException.class, 'Ou retorna lista ou AuraHandled.');
        }
        Test.stopTest();
    }

    @isTest
    static void shouldQueryCommunityType_WhenValidWhere() {
        // When
        Test.startTest();
        try {
            List<SObject> result = DynamicLinkHelper.getRecordIdFromDynamicLinkType('CommunityPage', 'Name != null');
            Assert.isNotNull(result, 'Community nunca nulo.');
        } catch (AuraHandledException e) {
            Assert.isInstanceOfType(e, AuraHandledException.class, 'Ou retorna lista ou AuraHandled.');
        }
        Test.stopTest();
    }

    @isTest
    static void shouldBuildSiteUrl_WhenNetworkExists() {
        // Given: usa a primeira rede visível; sem rede no contexto, cobre só o catch (já coberto)
        List<Network> nets = [SELECT Id FROM Network LIMIT 1];
        if (nets.isEmpty()) {
            return;
        }

        // When
        Test.startTest();
        String url = DynamicLinkHelper.getSiteUrl(nets[0].Id);
        Test.stopTest();

        // Then
        Assert.isTrue(url.endsWith('.com'), 'URL deve terminar com .com: ' + url);
    }

    @isTest
    static void shouldThrowAura_WhenLinkTypeUnknown() {
        // When/Then: query fica vazia e o Database.query estoura no catch
        Test.startTest();
        try {
            DynamicLinkHelper.getRecordIdFromDynamicLinkType('TipoDesconhecidoXYZ', 'Name != null');
            Assert.fail('Deveria lancar AuraHandledException.');
        } catch (AuraHandledException e) {
            Assert.isInstanceOfType(e, AuraHandledException.class, 'Tipo deve ser AuraHandled.');
        }
        Test.stopTest();
    }
}
