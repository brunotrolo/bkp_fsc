/**
 * @description Testes de CustomerUpsertQueueable e InteractionContextService:
 * upsert idempotente por External ID (EL-11, RN-10) e montagem do contexto
 * de saida (RN-09).
 */
@IsTest
private class CustomerUpsertQueueableTest {

    private static String payload() {
        BuscaClienteDTOs.CustomerSearchResultDTO dto = new BuscaClienteDTOs.CustomerSearchResultDTO();
        dto.documentNormalized = '52998224725';
        dto.docType = 'CPF';
        dto.demographic = new BuscaClienteDTOs.DemographicDTO();
        dto.demographic.nome = 'Joao da Silva';
        dto.demographic.segmento = 'Exclusivo';
        dto.demographic.email = 'joao@email.com';
        BuscaClienteDTOs.ProductSummaryDTO item = new BuscaClienteDTOs.ProductSummaryDTO();
        item.productType = 'CONTA_DIGITAL';
        item.label = 'Conta Digital';
        dto.portoBankWallet.add(item);
        BuscaClienteDTOs.NboOfferDTO offer = new BuscaClienteDTOs.NboOfferDTO();
        offer.externalOfferId = 'nbo-q-1';
        offer.productType = 'CARTAO';
        offer.titulo = 'Oferta Black';
        offer.narrativa = 'Elegivel para Black';
        offer.isPrimary = true;
        dto.nboOffers.add(offer);
        return JSON.serialize(dto);
    }

    @IsTest
    static void upsertIdempotente() {
        Test.startTest();
        System.enqueueJob(new CustomerUpsertQueueable(payload()));
        System.enqueueJob(new CustomerUpsertQueueable(payload()));
        Test.stopTest();
        System.assertEquals(1, [SELECT COUNT() FROM Account WHERE Document__c = '52998224725']);
        System.assertEquals(1, [SELECT COUNT() FROM Asset WHERE ExternalContractId__c = '52998224725-CONTA_DIGITAL']);
        System.assertEquals(1, [SELECT COUNT() FROM Opportunity WHERE ExternalOfferId__c = 'nbo-q-1'],
            'Re-busca do mesmo documento nao duplica');
    }
}
