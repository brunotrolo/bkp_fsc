/**
 * @description Fachada AuraEnabled da Visao 360, sem logica de negocio.
 * Orquestra Customer/Asset/NBO e enfileira o sync progressivo sem DML
 * sincrono. O LWC chama getVisao, getAssets e getOffers em paralelo para o
 * carregamento progressivo por area (Cen 15); detalhe volatil e NBO tem
 * retry explicito (Cen 9, EL-03). Falha parcial vira fault no DTO, nunca
 * excecao — excecao e so para entrada invalida.
 */
public with sharing class Visao360Controller {

    /** Resolve a raiz pelo documento (troca de raiz vinda da arvore, RN-11). */
    @AuraEnabled
    public static Id resolveAccount(String document) {
        String doc = Visao360Mock.normalizeDoc(document);
        if (String.isBlank(doc)) {
            throw new AuraHandledException('Informe o documento para trocar de raiz.');
        }
        List<Account> contas = [
            SELECT Id FROM Account WHERE Document__c = :doc WITH USER_MODE LIMIT 1
        ];
        if (contas.isEmpty()) {
            throw new AuraHandledException('Cliente não localizado para o documento.');
        }
        return contas[0].Id;
    }

    /** Visao consolidada nao-volatil da raiz (header + rico + arc + casos). */
    @AuraEnabled
    public static Visao360DTOs.VisaoResult getVisao(Id accountId) {
        exigirRaiz(accountId);
        return Visao360CustomerService.getVisao(accountId);
    }

    /** Inventario por familia (ativos + inativos). */
    @AuraEnabled
    public static Visao360DTOs.AssetsResult getAssets(Id accountId) {
        exigirRaiz(accountId);
        return Visao360AssetService.getCustomerAssets(accountId);
    }

    /** Detalhe volatil sob demanda; retry=true apos Tentar Novamente. */
    @AuraEnabled
    public static Visao360DTOs.RealtimeResult getRealtime(String contractNumber, String family, Boolean retry) {
        if (String.isBlank(contractNumber)) {
            throw new AuraHandledException('Contrato não informado.');
        }
        return Visao360AssetService.fetchRealtimeData(contractNumber, family, retry);
    }

    /** Top 3 NBO estatico da safra + sync em 2o plano; retry=true no retry. */
    @AuraEnabled
    public static Visao360DTOs.NboResult getOffers(Id accountId, Boolean retry) {
        exigirRaiz(accountId);
        return Visao360NBOService.getOffersAndSync(accountId, retry);
    }

    /** Recusa otimista em 1 clique com motivo rapido (Cen 12). */
    @AuraEnabled
    public static void rejectOffer(String externalOfferId, String reason) {
        if (String.isBlank(externalOfferId)) {
            throw new AuraHandledException('Oferta não informada.');
        }
        try {
            Visao360NBOService.rejectOffer(externalOfferId, reason);
        } catch (Visao360NBOService.Visao360Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /** Aceite marca negociacao; sem jornada pronta, mantem na tela (RN-14). */
    @AuraEnabled
    public static Visao360DTOs.NBOOfferDTO acceptOffer(String externalOfferId) {
        if (String.isBlank(externalOfferId)) {
            throw new AuraHandledException('Oferta não informada.');
        }
        try {
            return Visao360NBOService.acceptOffer(externalOfferId);
        } catch (Visao360NBOService.Visao360Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static void exigirRaiz(Id accountId) {
        if (accountId == null) {
            throw new AuraHandledException('Conta raiz não informada.');
        }
    }
}
