/**
 * @description Leitura do catalogo configuravel ProductCatalog__mdt (PT, RN-12).
 * Unico ponto de leitura do CMDT: c-product-hub consome via controller, nunca
 * direto. Via Custom Metadata getAll (sem SOQL), ordenado por DisplayOrder__c.
 */
public with sharing class ProductCatalogService {

    public static List<BuscaClienteDTOs.CatalogItemDTO> getCatalog() {
        List<BuscaClienteDTOs.CatalogItemDTO> items = new List<BuscaClienteDTOs.CatalogItemDTO>();
        for (ProductCatalog__mdt row : ProductCatalog__mdt.getAll().values()) {
            if (row.IsActive__c != true) {
                continue;
            }
            BuscaClienteDTOs.CatalogItemDTO item = new BuscaClienteDTOs.CatalogItemDTO();
            item.productType = row.ProductType__c;
            item.label = row.Label__c;
            item.iconName = row.IconName__c;
            item.requiresViaSelection = row.RequiresViaSelection__c == true;
            item.displayOrder = row.DisplayOrder__c;
            item.isActive = true;
            item.holdingInformative = row.HoldingInformative__c == true;
            items.add(item);
        }
        items.sort(new DisplayOrderComparator());
        return items;
    }

    /** Tipos ativos nao informativos: os cartoes selecionaveis do hub. */
    public static List<BuscaClienteDTOs.CatalogItemDTO> getTransationalTypes() {
        List<BuscaClienteDTOs.CatalogItemDTO> out = new List<BuscaClienteDTOs.CatalogItemDTO>();
        for (BuscaClienteDTOs.CatalogItemDTO item : getCatalog()) {
            if (item.holdingInformative != true && !String.isBlank(item.productType)) {
                out.add(item);
            }
        }
        return out;
    }

    private class DisplayOrderComparator implements Comparator<BuscaClienteDTOs.CatalogItemDTO> {
        public Integer compare(BuscaClienteDTOs.CatalogItemDTO a, BuscaClienteDTOs.CatalogItemDTO b) {
            Decimal oa = a.displayOrder == null ? 9999 : a.displayOrder;
            Decimal ob = b.displayOrder == null ? 9999 : b.displayOrder;
            if (oa == ob) {
                return 0;
            }
            return oa < ob ? -1 : 1;
        }
    }
}
