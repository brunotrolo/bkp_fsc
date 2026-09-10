/**
 * @description Monta o contexto de interacao, saida formal da jornada (RN-09).
 * Somente leitura de Account/Asset/Opportunity pelos ids externos; nenhum DML.
 * Dominios consumidores futuros leem via SOQL/API, nunca via LMS cross-domain.
 */
public with sharing class InteractionContextService {

    public static BuscaClienteDTOs.InteractionContextDTO build(
        String normalizedDoc, String productType, String itemExternalId
    ) {
        BuscaClienteDTOs.InteractionContextDTO ctx = new BuscaClienteDTOs.InteractionContextDTO();
        ctx.productType = productType;
        if (String.isBlank(normalizedDoc)) {
            ctx.resumo = 'Documento nao informado.';
            return ctx;
        }
        // Mock: sem banco consolidado — compõe o resumo dos fixtures (ids ficam nulos).
        if (BuscaClienteMock.isEnabled()) {
            ctx.resumo = BuscaClienteMock.mockContextResumo(normalizedDoc, productType, itemExternalId);
            return ctx;
        }
        List<Account> accounts = [
            SELECT Id, Name, Document__c
            FROM Account
            WHERE Document__c = :normalizedDoc
            WITH USER_MODE
            LIMIT 1
        ];
        if (accounts.isEmpty()) {
            ctx.resumo = 'Cliente ainda nao consolidado para o documento informado.';
            return ctx;
        }
        Account acc = accounts[0];
        ctx.accountId = acc.Id;
        List<Contact> contacts = [
            SELECT Id FROM Contact WHERE AccountId = :acc.Id WITH USER_MODE LIMIT 1
        ];
        if (!contacts.isEmpty()) {
            ctx.contactId = contacts[0].Id;
        }
        if (!String.isBlank(itemExternalId)) {
            List<Asset> items = [
                SELECT Id, ProductType__c FROM Asset
                WHERE ExternalContractId__c = :itemExternalId WITH USER_MODE LIMIT 1
            ];
            if (!items.isEmpty()) {
                ctx.itemAssetId = items[0].Id;
                ctx.assetId = items[0].Id;
            }
        }
        List<Opportunity> primary = [
            SELECT Id FROM Opportunity
            WHERE AccountId = :acc.Id AND IsPrimaryNbo__c = TRUE
            WITH USER_MODE
            ORDER BY CreatedDate DESC LIMIT 1
        ];
        if (!primary.isEmpty()) {
            ctx.opportunityId = primary[0].Id;
        }
        ctx.resumo = acc.Name + ' + ' + productType
            + (String.isBlank(itemExternalId) ? '' : ' + item ' + itemExternalId);
        return ctx;
    }
}
