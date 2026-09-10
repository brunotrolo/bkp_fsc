/**
 * @description Testes de ProductCatalogService (PT): leitura ordenada do CMDT
 * sem SOQL; filtro de tipos transacionais.
 */
@IsTest
private class ProductCatalogServiceTest {

    @IsTest
    static void catalogoAcessivelESemFalha() {
        Test.startTest();
        List<BuscaClienteDTOs.CatalogItemDTO> items = ProductCatalogService.getCatalog();
        Test.stopTest();
        System.assertNotEquals(null, items, 'Leitura do CMDT nao pode falhar');
        for (BuscaClienteDTOs.CatalogItemDTO item : items) {
            System.assertEquals(true, item.isActive);
        }
    }

    @IsTest
    static void tiposTransacionaisExcluemHolding() {
        List<BuscaClienteDTOs.CatalogItemDTO> items = ProductCatalogService.getTransationalTypes();
        System.assertNotEquals(null, items);
        for (BuscaClienteDTOs.CatalogItemDTO item : items) {
            System.assertEquals(false, item.holdingInformative, 'Holding nao e transacional');
        }
    }
}
