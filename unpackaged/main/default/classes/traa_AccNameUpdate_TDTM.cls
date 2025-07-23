/*
* @author          Traction on Demand (Traction TRAA Package)
* @description     Class to Update Name of Account of Academic Program Record Type with "'Parent Academic Program' - 'Term'"
*/

global without sharing class traa_AccNameUpdate_TDTM extends hed.TDTM_Runnable {
    // the main entry point for TDTM to invoke our trigger handlers.
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        hed.TDTM_Runnable.DmlWrapper dmlWrapper = new hed.TDTM_Runnable.DmlWrapper();
        List<Account> newAccounts = new List<Account>((List<Account>) newList);
        if (triggerAction == hed.TDTM_Runnable.Action.BeforeInsert) {
            updateAccountName(newAccounts, null);
        } else if (triggerAction == hed.TDTM_Runnable.Action.BeforeUpdate) {
            Map<Id, Account> oldMap = new Map<Id, Account>((List<Account>) oldList);
            updateAccountName(newAccounts, oldMap);
        }
        return dmlWrapper;
    }

    public static void updateAccountName(List<Account> accounts, Map<Id, Account> oldMap) {
        Id academicProgramRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Academic_Program').getRecordTypeId();
        List<Account> accountsToBeUpdated = new List<Account>();
        Set<Id> parentIds = new Set<Id>();
        Set<Id> termIds = new Set<Id>();
        for(Account acc : accounts) {
            if(acc.RecordTypeId == academicProgramRecordTypeId) {
                if(String.isNotBlank(acc.ParentId) && String.isNotBlank(acc.Starting_Term__c) && (oldMap == null || isTermChanged(acc, oldMap))) {
                    parentIds.add(acc.parentId);
                    termIds.add(acc.Starting_Term__c);
                    accountsToBeUpdated.add(acc);
                }
            }
        }
        if(!parentIds.isEmpty() && !termIds.isEmpty()) {
            Map<Id, Account> mapIdToAccount = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id IN :parentIds]);
            Map<Id, hed__Term__c> mapIdToTerm = new Map<Id, hed__Term__c>([SELECT Id, Name from hed__Term__c WHERE Id IN :termIds]);
            for (Account acc : accountsToBeUpdated) {
                if (String.isNotBlank(mapIdToAccount.get(acc.ParentId).Name) && String.isNotBlank(mapIdToTerm.get(acc.Starting_Term__c).Name)) {
                    acc.Name = mapIdToAccount.get(acc.ParentId).Name + ' - ' + mapIdToTerm.get(acc.Starting_Term__c).Name;
                }
            }
        }
    }

    public static Boolean isTermChanged(Account acc, Map<Id, Account> oldMap) {
        return (oldMap != null && acc.Starting_Term__c != oldMap.get(acc.Id).Starting_Term__c);
    }
}