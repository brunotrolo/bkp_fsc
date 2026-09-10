/**
 * @description Esqueleto do handler de Asset, preparado mas inativo (T-C10, A39).
 * Com bypass ativo (padrao), apenas valida formato de Last4__c quando
 * informado. Sem callout e sem DML em cadeia, nunca prendendo a tela.
 */
public with sharing class AssetTriggerHandler {

    public static void handleBefore(List<Asset> newRecords) {
        if (newRecords == null || newRecords.isEmpty()) {
            return;
        }
        if (TriggerBypass.isBypassed('Asset')) {
            return;
        }
        for (Asset a : newRecords) {
            if (!String.isBlank(a.Last4__c)
                && !Pattern.matches('[0-9]{4}', a.Last4__c)) {
                a.addError('O final do cartao deve conter exatamente 4 digitos.');
            }
        }
    }
}
