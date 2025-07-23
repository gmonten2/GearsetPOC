/*
* @author          Traction on Demand
* @description     Class to check Account - Academic Program Record, When it reaches to its Application Deadline. If so,
                   Then sets its child Opportunities to Closed Lost Stage, if they do not have an application child record.
*/
global without sharing class traa_AccApplicationDeadlinePassed implements Schedulable  {
    global void execute(SchedulableContext ctx) {
        
        Set<Id> opportunityIds = new Set<Id>();
        List<Opportunity> oppToBeUpdated = new List<Opportunity>();
        
        //Get Academic Program Record Type of Account
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Academic_Program').getRecordTypeId();
        
        //Collect related Opportunities when Account's Application Deadline is passed
        Date todayDate = System.today();
        for(Account account : [SELECT Id, (SELECT Id FROM traa_Opportunities__r) FROM Account WHERE traa_Application_Deadline__c <> null AND traa_Application_Deadline__c = : todayDate AND RecordTypeId = :recordTypeId]){
            if(account.traa_Opportunities__r.size() > 0){
                for(Opportunity opp : account.traa_Opportunities__r){
                    opportunityIds.add(opp.id);
                }
            }
        }
        //Update Opportunities which don't have related applications
        if(!opportunityIds.isEmpty()){
            for(Opportunity opportunity : [SELECT Id, (SELECT Id FROM traa_Applications__r) FROM Opportunity WHERE Id IN :opportunityIds]){
                if(opportunity.traa_Applications__r.isEmpty()){
                    opportunity.StageName = traa_Constants.STAGE_NAME_STALE;
                    opportunity.traa_Declined_Reason__c = traa_Constants.DECLINED_REASON_OTHER;
                    opportunity.traa_Decision_Notes__c = traa_Constants.DECLINED_NOTES;
                    oppToBeUpdated.add(opportunity);
                }
            }
            if(!oppToBeUpdated.isEmpty()){
                update oppToBeUpdated;
            }
        }
    }
}