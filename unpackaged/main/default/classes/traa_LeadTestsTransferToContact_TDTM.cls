/*
* @author          Traction on Demand (Traction TRAA Package)
* @description     On Lead conversion any Test child records on lead should be transfer to the new or existing contact. 
For Duplicate Tests based on Test Type transfer Test Scores.
*/
global without sharing class traa_LeadTestsTransferToContact_TDTM extends hed.TDTM_Runnable {
    // the main entry point for TDTM to invoke our trigger handlers.
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        
        hed.TDTM_Runnable.DmlWrapper dmlWrapper = new hed.TDTM_Runnable.DmlWrapper();
        Map<Id,Lead> newLeadMap = new Map<Id,Lead>((List<Lead>) newList);
        Map<Id, List<hed__Test__c>> leadIdToTestsMap = new Map<Id, List<hed__Test__c>>();
        Map<Id, Id> leadIdToContactIdMap = new Map<Id, Id>();
        List<hed__Test__c> testsToBeUpdated = new List<hed__Test__c>();

        if (triggerAction == hed.TDTM_Runnable.Action.AfterUpdate) {
            Map<Id, Lead> oldLeadMap = new Map<Id, Lead>((List<Lead>)oldList);
            
            for(Lead lead : [SELECT Id, convertedContactId, (SELECT Id, Name, hed__Test_Type__c, hed__Contact__c FROM traa_Tests__r) FROM Lead WHERE Id IN : newLeadMap.keySet()]){
                if (oldLeadMap.containsKey(lead.Id) && newLeadMap.containsKey(lead.Id)) {
                    //Check if the Lead is Converted
                    if (isLeadConverted(newLeadMap.get(lead.Id), oldLeadMap)) {
                        if(lead.traa_Tests__r.size()>0){
                            //Collect Lead Id and Related Test Records
                            for(hed__Test__c test : lead.traa_Tests__r){
                                if(!leadIdToTestsMap.containsKey(lead.Id)){
                                    leadIdToTestsMap.put(lead.Id, new List<hed__Test__c>());
                                }
                                leadIdToTestsMap.get(lead.Id).add(test);
                            }
                            //Collect Lead Id and Converted Contact Id
                            leadIdToContactIdMap.put(lead.Id, lead.ConvertedContactId);
                        }
                    }
                }
            }
            
            for(Id leadId : leadIdToTestsMap.keySet()){
                List<hed__Test__c> leadTests= leadIdToTestsMap.get(leadId);
                for(hed__Test__c leadTest : leadTests){
                    leadTest.hed__Contact__c = leadIdToContactIdMap.get(leadId);
                    testsToBeUpdated.add(leadTest);
                }
                
            }
            
        }
        if(testsToBeUpdated.size()>0){
            dmlWrapper.objectsToUpdate.addAll((List<SObject>) testsToBeUpdated);
        }
        
        return dmlWrapper;
        
    }

    private Boolean isLeadConverted(Lead lead, Map<Id, Lead> oldMap) {
        return(oldMap != null && lead.Status != oldMap.get(lead.Id).Status && lead.IsConverted);
    }
}