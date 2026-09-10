/**
 * @description Trigger de Asset: delega ao esqueleto AssetTriggerHandler,
 * inerte por padrao via TriggerBypass__c (T-C10, A39). Sem callout, sem DML.
 */
trigger AssetTrigger on Asset (before insert, before update) {
    AssetTriggerHandler.handleBefore(Trigger.new);
}
