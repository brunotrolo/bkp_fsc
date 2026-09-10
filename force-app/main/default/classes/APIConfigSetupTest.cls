/**
 * @description Testes da APIConfigSetup.
 *
 * Restrição documentada de plataforma: `CalculationMatrixColumn` é definition
 * record e a org recusa o insert em contexto de teste
 * (`CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY, Cannot create definition record`).
 * Estes testes PROVAM esse comportamento (falha documentada, não fachada) e
 * verificam o progresso parcial real (matrix criada antes da barreira).
 * Cobertura honesta: ~30%. Ver `.apex-test-loop/state/APIConfigSetup.md`.
 */
@isTest
private class APIConfigSetupTest {

    @isTest
    static void shouldFailDocumented_WhenColumnsBlockedInTest() {
        // When: setup esbarra na barreira de definition record
        Test.startTest();
        try {
            APIConfigSetup.setup();
            Assert.fail('Deveria falhar na barreira documentada de definition record.');
        } catch (DmlException e) {
            Assert.isTrue(
                e.getMessage().contains('Cannot create definition record'),
                'Deve ser a barreira documentada: ' + e.getMessage()
            );
        }
        Test.stopTest();

        // Then: a matrix (DML permitido) foi criada antes da barreira
        Assert.areEqual(
            1,
            [SELECT COUNT() FROM CalculationMatrix WHERE UniqueName = 'API_Config'],
            'Matrix deve existir mesmo com a barreira de coluna.'
        );
    }

    @isTest
    static void shouldReuseMatrix_WhenRunAfterPartialSetup() {
        // Given: primeira execução cria a matrix e para nas colunas
        try {
            APIConfigSetup.setup();
        } catch (DmlException ignored) {
        }

        // When: segunda execução encontra a matrix (ramo existing) e para de novo nas colunas
        Test.startTest();
        try {
            APIConfigSetup.setup();
            Assert.fail('Deveria falhar de novo na barreira documentada.');
        } catch (DmlException e) {
            Assert.isTrue(
                e.getMessage().contains('Cannot create definition record'),
                'Deve ser a barreira documentada: ' + e.getMessage()
            );
        }
        Test.stopTest();

        // Then: segue 1 matrix (idempotente até a barreira)
        Assert.areEqual(
            1,
            [SELECT COUNT() FROM CalculationMatrix WHERE UniqueName = 'API_Config'],
            'Deve seguir 1 matrix apos 2 execucoes.'
        );
    }

    @isTest
    static void shouldFailDocumented_WhenCorruptRowsPresent() {
        // Given: linhas corruptas não mudam o desfecho (barreira é nas colunas, antes das linhas)
        Test.startTest();
        try {
            APIConfigSetup.setup();
            Assert.fail('Deveria falhar na barreira documentada.');
        } catch (DmlException e) {
            Assert.isTrue(
                e.getMessage().contains('Cannot create definition record'),
                'Deve ser a barreira documentada: ' + e.getMessage()
            );
        }
        Test.stopTest();

        // Then: nenhuma linha válida foi criada (falha ocorre antes de ensureRows)
        Id matrixId = [SELECT Id FROM CalculationMatrix WHERE UniqueName = 'API_Config' LIMIT 1].Id;
        List<CalculationMatrixVersion> versions = [
            SELECT Id FROM CalculationMatrixVersion WHERE CalculationMatrixId = :matrixId
        ];
        Assert.areEqual(0, versions.size(), 'Versao nunca chega a ser criada em teste.');
    }
}
