/**
 * @description Registra abordagem ou dispensa de oferta NBO (T-C06, Cen 14/15).
 * Update sincrono leve por ExternalOfferId__c + Task de auditoria. Supressao de
 * reexibicao na sessao e client-side; NboSuppressedUntil__c permanece para a
 * janela futura (premissa 05).
 */
public with sharing class NboInteractionService {

    /** Aborda uma ou mais ofertas: status Abordada + Task de auditoria. */
    public static void approach(List<String> externalOfferIds) {
        applyStatus(externalOfferIds, 'Abordada', 'NBO Abordada', null);
    }

    /** Dispensa uma ou mais ofertas: status Dispensada + Task de auditoria. */
    public static void dismiss(List<String> externalOfferIds) {
        dismissWithReason(externalOfferIds, null);
    }

    /** Dispensa com motivo opcional (placeholder da premissa 05). */
    public static void dismissWithReason(List<String> externalOfferIds, String reason) {
        applyStatus(externalOfferIds, 'Dispensada', 'NBO Dispensada', reason);
    }

    private static void applyStatus(List<String> externalOfferIds, String status, String taskSubject, String reason) {
        // Mock: sem Opportunity real para atualizar — registra nada, libera o hub.
        if (BuscaClienteMock.isEnabled()) {
            return;
        }
        if (externalOfferIds == null || externalOfferIds.isEmpty()) {
            return;
        }
        Set<String> ids = new Set<String>(externalOfferIds);
        ids.remove(null);
        ids.remove('');
        if (ids.isEmpty()) {
            return;
        }
        List<Opportunity> offers = [
            SELECT Id, NboStatus__c
            FROM Opportunity
            WHERE ExternalOfferId__c IN :ids
            WITH USER_MODE
            LIMIT 500
        ];
        if (offers.isEmpty()) {
            return;
        }
        Datetime now = Datetime.now();
        Id currentUser = UserInfo.getUserId();
        for (Opportunity o : offers) {
            o.NboStatus__c = status;
            o.ApproachTimestamp__c = now;
            o.LastNboInteractionBy__c = currentUser;
            if (!String.isBlank(reason)) {
                o.DismissalReason__c = reason.left(255);
            }
        }
        Database.update(offers, false, AccessLevel.USER_MODE);
        List<Task> audits = new List<Task>();
        for (Opportunity o : offers) {
            audits.add(new Task(
                WhatId = o.Id,
                Subject = taskSubject,
                Status = 'Completed',
                ActivityDate = Date.today()
            ));
        }
        Database.insert(audits, false, AccessLevel.USER_MODE);
    }
}
