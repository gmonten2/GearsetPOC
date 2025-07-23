/**
* @description TDTM class for ProgramEnrollment trigger
*
*
* @author      Traction on Demand (Traction TRAA Package)
* @date        2020-02-19
*/
global without sharing class traa_StatusUpdate_TDTM extends hed.TDTM_Runnable{
    // the main entry point for TDTM to invoke our trigger handlers.
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        
        hed.TDTM_Runnable.DmlWrapper dmlWrapper = new hed.TDTM_Runnable.DmlWrapper();
       
        if (triggerAction == hed.TDTM_Runnable.Action.AfterUpdate) {
            Map<Id, hed__Program_Enrollment__c> oldMap = new Map<Id, hed__Program_Enrollment__c>((List<hed__Program_Enrollment__c>) oldList);
            updateStatus((List<hed__Program_Enrollment__c>) newList, oldMap);
        }
        
        return dmlWrapper;
    }

    private void updateStatus(List<hed__Program_Enrollment__c> ProgramEnrollments, Map<Id, hed__Program_Enrollment__c> oldMap) {
        Set<String> fieldsToCheck = new Set<String>(getStatusProcessor());
        for(hed__Program_Enrollment__c progEnrollment : ProgramEnrollments){
            //Update related objets on update of Enrollment Status as defined in trac_Status_Processor metadata records
            Boolean runStatusProcessor = false;
            for (String fieldToCheck : fieldsToCheck) {
                if (oldMap.get(progEnrollment.Id).get(fieldToCheck) != progEnrollment.get(fieldToCheck)) {
                    runStatusProcessor = true;
                    break;
                }
            }
            if (runStatusProcessor) {
                traa_StatusProcessor.execute(ProgramEnrollments, oldMap);
            }
        }
    }

    private Set<String> getStatusProcessor() {
        Set<String> fieldsToCheck = new Set<String>();
        for (traa_Status_Processor_Rule__mdt statusProcessorRule : [SELECT Id, traa_Source_SObject_Type__c, traa_Source_Field__c FROM traa_Status_Processor_Rule__mdt WHERE traa_Source_SObject_Type__c = 'hed__Program_Enrollment__c']) {
            if(String.isNotBlank(statusProcessorRule.traa_Source_Field__c)) {
                fieldsToCheck.add(statusProcessorRule.traa_Source_Field__c);
            }
        }
        return fieldsToCheck;
    }
}