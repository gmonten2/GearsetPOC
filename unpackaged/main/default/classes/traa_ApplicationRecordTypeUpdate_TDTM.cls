/**
 * @description: Updates the Application recordtype based on Application Record Types field on the Account on
 * Application creation or change in account on application.
 *
 * @author Pranshu Sharma, Traction on Demand
 * @date   2021-05-05
 */

global with sharing class traa_ApplicationRecordTypeUpdate_TDTM extends hed.TDTM_Runnable{

    // the main entry point for TDTM to invoke our trigger handlers.
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        hed.TDTM_Runnable.DmlWrapper dmlWrapper = new hed.TDTM_Runnable.DmlWrapper();
        Set<Id> relatedAccountIds;
        if (triggerAction == hed.TDTM_Runnable.Action.BeforeInsert) {
            relatedAccountIds = getAccountIdsFromApplication(newList);
            updateApplicationRecordType(newList,relatedAccountIds);
        } else if(triggerAction == hed.TDTM_Runnable.Action.BeforeUpdate){
            Map<Id, hed__Application__c> oldApplicationsByIdsMap = new Map<Id, hed__Application__c>((List<hed__Application__c>) oldList);
            List<hed__Application__c> applicationsAccountUpdated = new List<hed__Application__c>();
            for(hed__Application__c application : (List<hed__Application__c>) newList) {
                if (application.hed__Applying_To__c != oldApplicationsByIdsMap.get(application.Id).hed__Applying_To__c) {
                    applicationsAccountUpdated.add(application);
                }
            }
            relatedAccountIds = getAccountIdsFromApplication(applicationsAccountUpdated);
            updateApplicationRecordType(applicationsAccountUpdated,relatedAccountIds);
        }
        return dmlWrapper;
    }

    private Set<Id> getAccountIdsFromApplication(List<hed__Application__c> listOfApplications){
        Set<Id> accountIdSet = new Set<Id>();
        for(hed__Application__c application : listOfApplications){
            if(String.isNotBlank(application.hed__Applying_To__c)){
                accountIdSet.add(application.hed__Applying_To__c);
            }
        }
        return accountIdSet;
    }

    private void updateApplicationRecordType(List<hed__Application__c> applications, Set<Id> relatedAccountIds){
        if(!relatedAccountIds.isEmpty()) {
            Map<Id, Account> relatedAccountMap = new Map<Id, Account>([SELECT Id, traa_Application_Record_Types__c FROM Account WHERE Id IN :relatedAccountIds]);
            Map<String, Schema.RecordTypeInfo> applicationRecordTypeMap = Schema.SObjectType.hed__Application__c.getRecordTypeInfosByName();
            for(hed__Application__c application : (List<hed__Application__c>) applications){
                if(relatedAccountMap.containsKey(application.hed__Applying_To__c) &&
                    String.isNotBlank(relatedAccountMap.get(application.hed__Applying_To__c).traa_Application_Record_Types__c) &&
                    applicationRecordTypeMap.containsKey(relatedAccountMap.get(application.hed__Applying_To__c).traa_Application_Record_Types__c)){
                    application.RecordTypeId = applicationRecordTypeMap.get(relatedAccountMap.get(application.hed__Applying_To__c).traa_Application_Record_Types__c).getRecordTypeId();
                }
            }
        }
        return;
    }
}