/*
* @author          Traction on Demand (Traction TRAA Package)
* @description     Trigger to stamp the user who edits the Application Score field
*/
global without sharing class traa_ApplicationReviewerUpdation_TDTM extends hed.TDTM_Runnable{
    // the main entry point for TDTM to invoke our trigger handlers.
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        hed.TDTM_Runnable.DmlWrapper dmlWrapper = new hed.TDTM_Runnable.DmlWrapper();
        List<hed__Application__c> applications = new List<hed__Application__c>();
        List<hed__Application__c> applicationList = new List<hed__Application__c>();
        
        if (triggerAction == hed.TDTM_Runnable.Action.AfterInsert) {
            for (hed__Application__c application : (List<hed__Application__c>) newList) {
                if(application.traa_Score__c != null){
                    //Collect application records
                    applicationList.add(application);                   
                }
               
            }
            
        }
        else{
            if (triggerAction == hed.TDTM_Runnable.Action.AfterUpdate) {
                Map<Id, hed__Application__c> oldApplicationMap = new Map<Id, hed__Application__c>((List<hed__Application__c>) oldList);
                
                for (hed__Application__c application : (List<hed__Application__c>) newList) {
                    if(application.traa_Score__c != null && oldApplicationMap.get(application.Id).traa_Score__c != application.traa_Score__c){
                        //Collect application records
                        applicationList.add(application);
                    }
                   
                }
                
            }
        }
        //Get Applications to update
        if(applicationList.size()>0){
            applications = updateApplications(applicationList);
            dmlWrapper.objectsToUpdate.addAll((List<SObject>) applications);
        }
        return dmlWrapper;
    }
    
    //stamp the user who edits the Application Score field
    private List<hed__Application__c> updateApplications(List<hed__Application__c> applicationList){
        List<hed__Application__c> applicationsToUpdate = new List<hed__Application__c>();
        //Set Application Reviewer who updated Application Score
        for (hed__Application__c application : applicationList){
            hed__Application__c newApplication = new hed__Application__c(Id = application.Id, traa_Application_Reviewer__c = application.LastModifiedById  );
            applicationsToUpdate.add(newApplication);
        }        
        return applicationsToUpdate;
    }
}