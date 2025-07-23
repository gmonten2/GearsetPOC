/**
* @description TDTM class for Opportunity trigger
*
*
* @author      Traction on Demand (Traction TRAA Package)
* @date        2020-02-13
*/

global without sharing class traa_EnrollmentDateUpdate_TDTM extends hed.TDTM_Runnable {
    // the main entry point for TDTM to invoke our trigger handlers.
    
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        
        hed.TDTM_Runnable.DmlWrapper dmlWrapper = new hed.TDTM_Runnable.DmlWrapper();
        
        if (triggerAction == hed.TDTM_Runnable.Action.BeforeUpdate) {
            Set<String> stageNames = new Set<String>();
            Map<Id, Opportunity> oldOppMap = new Map<Id, Opportunity>((List<Opportunity>) oldList);
            //Get Stage Name of Opportunity from Metadata Table
            for (traa_Opportunity_Stage__mdt metadataRules : [ SELECT Id, Opp_Stage_Name__c, traa_Count_as_Enrolled__c FROM traa_Opportunity_Stage__mdt WHERE traa_Count_as_Enrolled__c =: true]) {
                stageNames.add(metadataRules.Opp_Stage_Name__c);
            }
            //Update Opportunity Enrollment Date
            if(!stageNames.isEmpty()){
                for (Opportunity oppObject : (List<Opportunity>) newList) {
                    if (String.isNotBlank(oppObject.StageName) && stageNames.contains(oppObject.StageName) &&  oldOppMap.get(oppObject.Id).StageName != oppObject.StageName) {
                        oppObject.traa_Enrollment_Date__c = System.today();
                    }
                }
            }
        }
        return dmlWrapper;
    } 
}