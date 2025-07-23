/**
 * @description: Updates all child Application's recordtype based on Account picklist field traa_Application_Record_Types__c update
 *
 * @author Pranshu Sharma, Traction on Demand
 * @date   2021-05-07
 */

global inherited sharing class traa_UpdatingChildApplicationRT_TDTM extends hed.TDTM_Runnable{

    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        hed.TDTM_Runnable.DmlWrapper dmlWrapper = new hed.TDTM_Runnable.DmlWrapper();
        if (triggerAction == hed.TDTM_Runnable.Action.AfterUpdate) {
            Map<Id, Account> oldAccountByIdsMap = new Map<Id, Account>((List<Account>) oldList);
            Map<Id, Account> accountsApplicationNeedsToBeUpdated = new Map<Id, Account>();
            Map<String, Schema.RecordTypeInfo> applicationRecordTypeMap = Schema.SObjectType.hed__Application__c.getRecordTypeInfosByName();
            List<hed__Application__c> applicationsToUpdate = new List<hed__Application__c>();

            for(Account account : (List<Account>) newList){
                if(account.traa_Application_Record_Types__c != oldAccountByIdsMap.get(account.Id).traa_Application_Record_Types__c){
                    accountsApplicationNeedsToBeUpdated.put(account.Id,account);
                }
            }

            for(hed__Application__c application : [SELECT Id, RecordTypeId,hed__Applying_To__c, hed__Applying_To__r.traa_Application_Record_Types__c
                FROM hed__Application__c WHERE hed__Applying_To__c IN :accountsApplicationNeedsToBeUpdated.keySet()]){
                if(applicationRecordTypeMap.containsKey(application.hed__Applying_To__r?.traa_Application_Record_Types__c)){
                    application.RecordTypeId = applicationRecordTypeMap.get(application.hed__Applying_To__r?.traa_Application_Record_Types__c).getRecordTypeId();
                    applicationsToUpdate.add(application);
                }
            }
            dmlWrapper.objectsToUpdate.addAll((List<SObject>) applicationsToUpdate);
        }
        return dmlWrapper;
    }
}