/**
 * @description Testes do APIConfigDAO (mock, ambiente, config ausente).
 */
@isTest
private class APIConfigDAOTest {

    @isTest
    static void shouldReturnMockConfig_WhenRunningTest() {
        // Given
        APIConfigDAO.APIConfig cfg = new APIConfigDAO.APIConfig();
        cfg.apiName = 'BCP_DadosCliente';
        cfg.environment = 'Homologacao';
        cfg.operation = 'getDadosCliente';
        cfg.namedCredential = 'BCP_Homologacao';
        cfg.endpoint = '/x';
        cfg.method = 'GET';
        cfg.timeout = 30000;
        cfg.retryEnabled = false;
        cfg.retryCount = 0;
        cfg.logEnabled = false;
        APIConfigDAO.mockConfig = cfg;

        // When
        Test.startTest();
        APIConfigDAO.APIConfig result = APIConfigDAO.getConfig(
            'BCP_DadosCliente',
            'Homologacao',
            'getDadosCliente'
        );
        Test.stopTest();

        // Then
        Assert.areEqual('BCP_Homologacao', result.namedCredential, 'Deve retornar o mock.');
        APIConfigDAO.mockConfig = null;
        APIConfigDAO.clearCache();
    }

    @isTest
    static void shouldReturnEnvironment_WhenAsked() {
        // When
        Test.startTest();
        String env = APIConfigDAO.getCurrentEnvironment();
        Test.stopTest();

        // Then
        Assert.isTrue(
            env == 'Homologacao' || env == 'Producao',
            'Ambiente deve ser Homologacao ou Producao: ' + env
        );
    }

    @isTest
    static void shouldThrowConfigNotFound_WhenNoLookupTable() {
        // Given: sem mock e sem dados de Lookup Table no teste
        APIConfigDAO.mockConfig = null;
        APIConfigDAO.clearCache();

        // When
        Test.startTest();
        try {
            APIConfigDAO.getConfig('API_INEXISTENTE', 'Homologacao', 'op');
            Assert.fail('Deveria lancar CONFIG_NOT_FOUND.');
        } catch (APIException e) {
            // Then
            Assert.areEqual('CONFIG_NOT_FOUND', e.getErrorCode(), 'Codigo deve ser CONFIG_NOT_FOUND.');
        }
        Test.stopTest();
    }
}