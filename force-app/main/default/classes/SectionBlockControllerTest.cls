/**
 * @description Testes da SectionBlockController (secoes, blocos, dynamic links).
 */
@isTest
private class SectionBlockControllerTest {

    private static Id detailRtId() {
        return [SELECT Id FROM RecordType WHERE SobjectType = 'Section__c' AND DeveloperName = 'Detail' LIMIT 1].Id;
    }

    private static Page__c seedPage(String tipo) {
        Page__c p = new Page__c(Type__c = tipo, Active__c = true);
        insert p;
        return p;
    }

    private static Block__c seedBlock(String name, String actionId) {
        Block__c b = new Block__c(Name = name, Active__c = true, Header__c = name, Action__c = actionId);
        insert b;
        return b;
    }

    private static Section__c seedSection(Id pageId) {
        Section__c s = new Section__c(
            RecordTypeId = detailRtId(), Active__c = true, Page__c = pageId, Header__c = 'Secao'
        );
        insert s;
        return s;
    }

    private static DynamicLink__c seedLink(String identity) {
        DynamicLink__c l = new DynamicLink__c(Identity__c = identity);
        insert l;
        return l;
    }

    private static void seedJunction(Id sectionId, Id blockId, Integer seq) {
        insert new SectionBlock__c(Section__c = sectionId, Block__c = blockId, Order_Sequence__c = seq);
    }

    @isTest
    static void shouldReturnSections_WhenTypeAndPageExist() {
        // Given
        Page__c p = seedPage('Home');
        Section__c s = seedSection(p.Id);
        seedJunction(s.Id, seedBlock('B1', null).Id, 1);

        // When
        Test.startTest();
        List<Section__c> result = SectionBlockController.getSectionsByType('Detail', 'Home');
        Test.stopTest();

        // Then
        Assert.areEqual(1, result.size(), 'Deve retornar 1 secao.');
        Assert.areEqual(1, result[0].SectionBlocks__r.size(), 'Deve trazer 1 bloco ativo.');
    }

    @isTest
    static void shouldThrowAura_WhenTypeGuardsEmpty() {
        // When/Then
        Test.startTest();
        try {
            SectionBlockController.getSectionsByType('', 'Home');
            Assert.fail('Deveria lancar (sectionType vazio).');
        } catch (AuraHandledException e) {
            Assert.isInstanceOfType(e, AuraHandledException.class, 'Tipo deve ser AuraHandled.');
        }
        try {
            SectionBlockController.getSectionsByType('Detail', '');
            Assert.fail('Deveria lancar (pageType vazio).');
        } catch (AuraHandledException e) {
            Assert.isInstanceOfType(e, AuraHandledException.class, 'Tipo deve ser AuraHandled.');
        }
        Test.stopTest();
    }

    @isTest
    static void shouldThrowAura_WhenPageTypeMissing() {
        // When/Then
        Test.startTest();
        try {
            SectionBlockController.getSectionsByType('Detail', 'TipoInexistenteXYZ');
            Assert.fail('Deveria lancar No Page.');
        } catch (AuraHandledException e) {
            Assert.isInstanceOfType(e, AuraHandledException.class, 'Tipo deve ser AuraHandled.');
        }
        Test.stopTest();
    }

    @isTest
    static void shouldReturnSections_WhenPageIdGiven() {
        // Given
        Page__c p = seedPage('Home');
        Section__c s = seedSection(p.Id);
        seedJunction(s.Id, seedBlock('B2', null).Id, 1);

        // When
        Test.startTest();
        List<Section__c> result = SectionBlockController.getSectionsByPageId('Detail', p.Id);
        Test.stopTest();

        // Then
        Assert.areEqual(1, result.size(), 'Deve retornar 1 secao por pageId.');
    }

    @isTest
    static void shouldThrowAura_WhenPageIdGuardsEmpty() {
        // When/Then
        Test.startTest();
        try {
            SectionBlockController.getSectionsByPageId('', 'x');
            Assert.fail('Deveria lancar (sectionType vazio).');
        } catch (AuraHandledException e) {
            Assert.isInstanceOfType(e, AuraHandledException.class, 'Tipo deve ser AuraHandled.');
        }
        try {
            SectionBlockController.getSectionsByPageId('Detail', '');
            Assert.fail('Deveria lancar (pageId vazio).');
        } catch (AuraHandledException e) {
            Assert.isInstanceOfType(e, AuraHandledException.class, 'Tipo deve ser AuraHandled.');
        }
        Test.stopTest();
    }

    @isTest
    static void shouldHandleDynamicLinks_WhenEmptyAndFilled() {
        // Given
        DynamicLink__c l = seedLink('DL_CTRL_001');

        // When
        Test.startTest();
        List<DynamicLink__c> empty = SectionBlockController.getDynamicLinks(new List<String>());
        List<DynamicLink__c> filled = SectionBlockController.getDynamicLinks(new List<String>{ l.Id });
        Test.stopTest();

        // Then
        Assert.areEqual(0, empty.size(), 'Lista vazia deve retornar vazio.');
        Assert.areEqual(1, filled.size(), 'Deve retornar o link.');
    }

    @isTest
    static void shouldReturnSectionMap_WhenSectionIdGiven() {
        // Given: bloco com Action__c apontando para o link (dynamicLinkIds não vazio)
        Page__c p = seedPage('Home');
        Section__c s = seedSection(p.Id);
        DynamicLink__c l = seedLink('DL_CTRL_002');
        seedJunction(s.Id, seedBlock('B3', l.Id).Id, 1);

        // When
        Test.startTest();
        List<Map<String, Object>> result = SectionBlockController.getSectionWithBlockBySectionId(s.Id);
        Test.stopTest();

        // Then
        Assert.areEqual(1, result.size(), 'Deve retornar 1 mapa.');
        Assert.areEqual('B3', ((Map<String, Object>) result[0].get('block')).get('header'), 'Header deve bater.');
        Assert.areEqual(1, ((List<DynamicLink__c>) result[0].get('dynamicLinks')).size(), 'Deve trazer o dynamic link.');
    }

    @isTest
    static void shouldThrowAura_WhenSectionIdGuardEmpty() {
        // When/Then
        Test.startTest();
        try {
            SectionBlockController.getSectionWithBlockBySectionId('');
            Assert.fail('Deveria lancar (sectionId vazio).');
        } catch (AuraHandledException e) {
            Assert.isInstanceOfType(e, AuraHandledException.class, 'Tipo deve ser AuraHandled.');
        }
        Test.stopTest();
    }

    @isTest
    static void shouldReturnMaps_WhenTypeAndPageGiven() {
        // Given
        Page__c p = seedPage('Home');
        Section__c s = seedSection(p.Id);
        seedJunction(s.Id, seedBlock('B4', null).Id, 1);

        // When
        Test.startTest();
        List<Map<String, Object>> byType = SectionBlockController.getSectionsWithBlocksByType('Detail', 'Home');
        List<Map<String, Object>> byPage = SectionBlockController.getSectionsWithBlocksByPageId('Detail', p.Id);
        Test.stopTest();

        // Then
        Assert.areEqual(1, byType.size(), 'Por tipo deve retornar 1.');
        Assert.areEqual(1, byPage.size(), 'Por page deve retornar 1.');
        Assert.areEqual(1, ((List<Map<String, Object>>) byType[0].get('blocks')).size(), 'Deve ter 1 bloco.');
    }

    @isTest
    static void shouldThrowAura_WhenMapGuardsEmpty() {
        // When/Then
        Test.startTest();
        try {
            SectionBlockController.getSectionsWithBlocksByType('', 'Home');
            Assert.fail('Deveria lancar (tipo vazio).');
        } catch (AuraHandledException e) {
            Assert.isInstanceOfType(e, AuraHandledException.class, 'Tipo deve ser AuraHandled.');
        }
        try {
            SectionBlockController.getSectionsWithBlocksByType('Detail', '');
            Assert.fail('Deveria lancar (page vazio).');
        } catch (AuraHandledException e) {
            Assert.isInstanceOfType(e, AuraHandledException.class, 'Tipo deve ser AuraHandled.');
        }
        try {
            SectionBlockController.getSectionsWithBlocksByPageId('', 'x');
            Assert.fail('Deveria lancar (tipo vazio).');
        } catch (AuraHandledException e) {
            Assert.isInstanceOfType(e, AuraHandledException.class, 'Tipo deve ser AuraHandled.');
        }
        try {
            SectionBlockController.getSectionsWithBlocksByPageId('Detail', '');
            Assert.fail('Deveria lancar (page vazio).');
        } catch (AuraHandledException e) {
            Assert.isInstanceOfType(e, AuraHandledException.class, 'Tipo deve ser AuraHandled.');
        }
        Test.stopTest();
    }
}
