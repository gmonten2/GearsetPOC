/*
* @author          Traction on Demand (Traction TRAA Package)
* @description     Class to update  the child opportunities close dates, When the Enrollment Deadline is updated on academic program.
*/
global without sharing class traa_UpdateChildOpportunities_TDTM extends hed.TDTM_Runnable {
    // the main entry point for TDTM to invoke our trigger handlers.
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        
        hed.TDTM_Runnable.DmlWrapper dmlWrapper = new hed.TDTM_Runnable.DmlWrapper();
        
        if (triggerAction == hed.TDTM_Runnable.Action.AfterUpdate) {
            Map<Id,Account> newAccountMap = new Map<Id,Account>((List<Account>) newList);
            List<Opportunity> opportunitiesToBeUpdated = new List<Opportunity>();
            Map<Id,Account> oldAccountMap = new Map<Id,Account>((List<Account>) oldList);
            
            //Get Academic Program Record Type of Account
            Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Academic_Program').getRecordTypeId();
            
            for(Account account : [SELECT Id, traa_Enrollment_Deadline__c, (SELECT Id, CloseDate FROM traa_Opportunities__r) FROM Account WHERE Id IN : newAccountMap.keySet() AND RecordTypeId = :recordTypeId]){
                //If Academic Program's Enrollment Deadline is updated, then update all child opportunities Close Dates
                if(account.traa_Opportunities__r.size()>0 && account.traa_Enrollment_Deadline__c != null && isEnrollmentDeadlineChanged(account, oldAccountMap)){
                    for(Opportunity opp : account.traa_Opportunities__r){
                        opp.CloseDate = account.traa_Enrollment_Deadline__c;
                        opportunitiesToBeUpdated.add(opp);
                    }
                }
            }
            if(!opportunitiesToBeUpdated.isEmpty()){
                dmlWrapper.objectsToUpdate.addAll((List<SObject>) opportunitiesToBeUpdated);
            }
        }
        return dmlWrapper;
    }

    public Boolean isEnrollmentDeadlineChanged(Account account, Map<Id, Account> oldMap) {
        return (oldMap != null && account.traa_Enrollment_Deadline__c != oldMap.get(account.Id).traa_Enrollment_Deadline__c);
    }
}