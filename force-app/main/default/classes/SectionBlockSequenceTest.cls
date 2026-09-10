/**
 * @description Testes da SectionBlockSequence (listagem e ordenacao de blocos).
 */
@isTest
private class SectionBlockSequenceTest {

    private static Block__c seedBlock(String name) {
        Block__c b = new Block__c(Name = name, Active__c = true);
        insert b;
        return b;
    }

    private static Section__c seedSection() {
        Section__c s = new Section__c(Active__c = true);
        insert s;
        return s;
    }

    @isTest
    static void shouldReturnAllBlocks_WhenBlocksExist() {
        // Given
        seedBlock('Bloco A');
        seedBlock('Bloco B');

        // When
        Test.startTest();
        List<Block__c> result = SectionBlockSequence.getAllBlocks();
        Test.stopTest();

        // Then
        Assert.isTrue(result.size() >= 2, 'Deve retornar ao menos os 2 blocos: ' + result.size());
    }

    @isTest
    static void shouldReturnOrderedBlocks_WhenSectionHasJunctions() {
        // Given
        Section__c s = seedSection();
        Block__c b1 = seedBlock('Bloco 1');
        Block__c b2 = seedBlock('Bloco 2');
        insert new List<SectionBlock__c>{
            new SectionBlock__c(Section__c = s.Id, Block__c = b2.Id, Order_Sequence__c = 2),
            new SectionBlock__c(Section__c = s.Id, Block__c = b1.Id, Order_Sequence__c = 1)
        };

        // When
        Test.startTest();
        List<SectionBlock__c> result = SectionBlockSequence.getBlocksForSection(s.Id);
        Test.stopTest();

        // Then
        Assert.areEqual(2, result.size(), 'Deve retornar as 2 junções.');
        Assert.areEqual(b1.Id, result[0].Block__c, 'Ordenação deve respeitar Order_Sequence__c.');
    }

    @isTest
    static void shouldThrowAura_WhenSectionIdEmpty() {
        // When/Then
        Test.startTest();
        try {
            SectionBlockSequence.getBlocksForSection('');
            Assert.fail('Deveria lancar AuraHandledException.');
        } catch (AuraHandledException e) {
            Assert.isInstanceOfType(e, AuraHandledException.class, 'Tipo deve ser AuraHandled.');
        }
        Test.stopTest();
    }

    @isTest
    static void shouldCreateJunctions_WhenUpdatingEmptySection() {
        // Given
        Section__c s = seedSection();
        Block__c b1 = seedBlock('Bloco X');
        Block__c b2 = seedBlock('Bloco Y');

        // When
        Test.startTest();
        SectionBlockSequence.updateSectionBlocks(s.Id, new List<String>{ b1.Id, b2.Id });
        Test.stopTest();

        // Then
        List<SectionBlock__c> junctions = [
            SELECT Block__c, Order_Sequence__c FROM SectionBlock__c
            WHERE Section__c = :s.Id ORDER BY Order_Sequence__c ASC
        ];
        Assert.areEqual(2, junctions.size(), 'Deve criar 2 junções.');
        Assert.areEqual(b1.Id, junctions[0].Block__c, 'Ordem deve seguir a lista.');
        Assert.areEqual(2, junctions[1].Order_Sequence__c, 'Sequência deve ser 1-based.');
    }

    @isTest
    static void shouldReplaceJunctions_WhenSectionAlreadyHasBlocks() {
        // Given
        Section__c s = seedSection();
        Block__c keep = seedBlock('Mantido');
        Block__c old = seedBlock('Antigo');
        Block__c fresh = seedBlock('Novo');
        insert new SectionBlock__c(Section__c = s.Id, Block__c = old.Id, Order_Sequence__c = 1);

        // When
        Test.startTest();
        SectionBlockSequence.updateSectionBlocks(s.Id, new List<String>{ keep.Id, fresh.Id });
        Test.stopTest();

        // Then
        List<SectionBlock__c> junctions = [
            SELECT Block__c FROM SectionBlock__c WHERE Section__c = :s.Id
        ];
        Assert.areEqual(2, junctions.size(), 'Antiga deve ser deletada e 2 novas criadas.');
    }

    @isTest
    static void shouldThrowAura_WhenSectionIdInvalid() {
        // When/Then: insert com lookup inválido estoura no catch
        Test.startTest();
        try {
            Block__c b = seedBlock('Bloco Z');
            SectionBlockSequence.updateSectionBlocks('a0X000000000000AAA', new List<String>{ b.Id });
            Assert.fail('Deveria lancar AuraHandledException.');
        } catch (AuraHandledException e) {
            Assert.isInstanceOfType(e, AuraHandledException.class, 'Tipo deve ser AuraHandled.');
        }
        Test.stopTest();
    }
}
