/*
* @author          Traction on Demand (Traction TRAA Package)
* @description     Scheduler class used to schedule the Applications object when decision type of academic program is selcted as Update on Publish date
*/
global class traa_ApplicationDecisionDatePassed implements Schedulable  {
    global void execute(SchedulableContext ctx) {
        
        Date todayDate = System.today();
        
        List<hed__Application__c> applicationsToBeUpdated =[SELECT Id, Name, traa_Applicant_Facing_Status__c, hed__Application_Status__c, RecordTypeId FROM hed__Application__c
                                               WHERE hed__Applying_To__r.Decision_Type__c = :traa_Constants.ACCOUNT_DECISION_STAGE_UPDATE_ON_PUBLISH_DATE and hed__Application_Status__c != null AND traa_Publish_Decision_Date__c = : todayDate];
        traa_StatusProcessor.execute(applicationsToBeUpdated);
      
    }
}