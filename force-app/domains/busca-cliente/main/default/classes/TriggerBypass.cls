/**
 * @description Leitura null-safe da chave de bypass TriggerBypass__c (T-A07).
 * Sem linha de padrao org, o bypass e tratado como ATIVO: handlers inertes
 * ate a fundacao ratificar as regras. Usa getOrgDefaults (linha real) em vez
 * de getInstance (instancia virtual que materializa checkbox como false).
 */
public with sharing class TriggerBypass {

    public static Boolean isBypassed(String objectName) {
        TriggerBypass__c setting;
        try {
            setting = TriggerBypass__c.getOrgDefaults();
        } catch (Exception e) {
            return true;
        }
        if (setting == null || setting.Id == null) {
            return true;
        }
        if (objectName == 'Asset') {
            return setting.Asset__c != false;
        }
        if (objectName == 'Opportunity') {
            return setting.Opportunity__c != false;
        }
        return true;
    }
}
