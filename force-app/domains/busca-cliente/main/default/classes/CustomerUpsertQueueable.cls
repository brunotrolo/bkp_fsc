/**
 * @description Upsert progressivo e idempotente para a visao 360 futura (T-C09,
 * T-E01, RN-10/11, EL-11). Fire-and-forget: nao retem a navegacao. Recebe o
 * DTO serializado, faz upsert por External ID com allOrNone=false e publica
 * Customer360Upserted__e para household-360. Retry unico em UNABLE_TO_LOCK_ROW.
 */
public with sharing class CustomerUpsertQueueable implements Queueable {

    private String payloadJson;
    private Integer attempt;

    public CustomerUpsertQueueable(String payloadJson) {
        this(payloadJson, 1);
    }

    private CustomerUpsertQueueable(String payloadJson, Integer attempt) {
        this.payloadJson = payloadJson;
        this.attempt = attempt == null ? 1 : attempt;
    }

    public void execute(QueueableContext context) {
        if (String.isBlank(payloadJson)) {
            return;
        }
        BuscaClienteDTOs.CustomerSearchResultDTO dto;
        try {
            dto = (BuscaClienteDTOs.CustomerSearchResultDTO)
                JSON.deserialize(payloadJson, BuscaClienteDTOs.CustomerSearchResultDTO.class);
        } catch (JSONException e) {
            return;
        }
        try {
            upsertAll(dto);
        } catch (DmlException e) {
            if (isRowLock(e) && attempt < 2 && Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()) {
                System.enqueueJob(new CustomerUpsertQueueable(payloadJson, attempt + 1));
            }
        }
    }

    private static void upsertAll(BuscaClienteDTOs.CustomerSearchResultDTO dto) {
        if (dto == null || String.isBlank(dto.documentNormalized) || dto.demographic == null) {
            return;
        }
        Account acc = new Account(
            Name = fallbackName(dto),
            Document__c = dto.documentNormalized,
            DocumentType__c = dto.docType,
            CustomerSegment__c = mapSegment(dto.demographic.segmento)
        );
        Database.UpsertResult[] accResults =
            Database.upsert(new List<Account>{ acc }, Account.Document__c, false);
        if (!accResults[0].isSuccess()) {
            return;
        }
        Id accountId = accResults[0].getId();
        if (accountId == null) {
            List<Account> existing = [
                SELECT Id FROM Account WHERE Document__c = :dto.documentNormalized LIMIT 1
            ];
            if (existing.isEmpty()) {
                return;
            }
            accountId = existing[0].Id;
        }
        upsertContact(dto, accountId);
        upsertAssets(dto, accountId);
        upsertOffers(dto, accountId);
        EventBus.publish(new Customer360Upserted__e(
            DocumentNormalized__c = dto.documentNormalized,
            AccountId__c = accountId,
            Timestamp__c = Datetime.now()
        ));
    }

    private static String fallbackName(BuscaClienteDTOs.CustomerSearchResultDTO dto) {
        String name = dto.demographic != null ? dto.demographic.nome : null;
        return String.isBlank(name) ? ('Cliente ' + dto.documentNormalized) : name;
    }

    private static String mapSegment(String segmento) {
        if (String.isBlank(segmento)) {
            return 'VAREJO';
        }
        String upper = segmento.toUpperCase();
        if (upper.contains('EXCLUSIVO')) {
            return 'EXCLUSIVO';
        }
        if (upper.contains('ALTA')) {
            return 'ALTA_RENDA';
        }
        if (upper.contains('CORPORATE') || upper.contains('EMPRESARIAL')) {
            return 'CORPORATE';
        }
        return 'VAREJO';
    }

    private static void upsertContact(BuscaClienteDTOs.CustomerSearchResultDTO dto, Id accountId) {
        if (dto.demographic == null || String.isBlank(dto.demographic.nome)) {
            return;
        }
        Contact c = new Contact(
            AccountId = accountId,
            LastName = dto.demographic.nome.left(80),
            Document__c = dto.documentNormalized,
            Email = blankToNull(dto.demographic.email)
        );
        Database.insert(c, false);
    }

    private static void upsertAssets(BuscaClienteDTOs.CustomerSearchResultDTO dto, Id accountId) {
        if (dto.portoBankWallet == null || dto.portoBankWallet.isEmpty()) {
            return;
        }
        List<Asset> assets = new List<Asset>();
        for (BuscaClienteDTOs.ProductSummaryDTO item : dto.portoBankWallet) {
            if (item == null || String.isBlank(item.productType)) {
                continue;
            }
            assets.add(new Asset(
                AccountId = accountId,
                Name = String.isBlank(item.label) ? item.productType : item.label,
                ExternalContractId__c = dto.documentNormalized + '-' + item.productType,
                ProductType__c = item.productType,
                ViaStatus__c = 'Ativo'
            ));
        }
        if (!assets.isEmpty()) {
            Database.upsert(assets, Asset.ExternalContractId__c, false);
        }
    }

    private static void upsertOffers(BuscaClienteDTOs.CustomerSearchResultDTO dto, Id accountId) {
        if (dto.nboOffers == null || dto.nboOffers.isEmpty()) {
            return;
        }
        List<Opportunity> offers = new List<Opportunity>();
        for (BuscaClienteDTOs.NboOfferDTO offer : dto.nboOffers) {
            if (offer == null || String.isBlank(offer.externalOfferId)) {
                continue;
            }
            offers.add(new Opportunity(
                AccountId = accountId,
                Name = String.isBlank(offer.titulo) ? ('Oferta ' + offer.productType) : offer.titulo.left(120),
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(30),
                ExternalOfferId__c = offer.externalOfferId,
                NboProductType__c = offer.productType,
                NboBenefit__c = offer.narrativa,
                NboStatus__c = 'Elegivel',
                IsPrimaryNbo__c = offer.isPrimary == true
            ));
        }
        if (!offers.isEmpty()) {
            Database.upsert(offers, Opportunity.ExternalOfferId__c, false);
        }
    }

    private static Boolean isRowLock(DmlException e) {
        String msg = e.getMessage();
        return !String.isBlank(msg) && msg.contains('UNABLE_TO_LOCK_ROW');
    }

    private static String blankToNull(String value) {
        return String.isBlank(value) ? null : value;
    }
}
