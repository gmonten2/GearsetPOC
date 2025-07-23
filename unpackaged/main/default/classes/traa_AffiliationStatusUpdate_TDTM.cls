/**
* @description TDTM class for Opportunity trigger
*
* @author      Traction on Demand (Traction TRAA Package)
* @date        2020-02-13
*/
global without sharing class traa_AffiliationStatusUpdate_TDTM extends hed.TDTM_Runnable {
    // the main entry point for TDTM to invoke our trigger handlers.
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        hed.TDTM_Runnable.DmlWrapper dmlWrapper = new hed.TDTM_Runnable.DmlWrapper();
        if (triggerAction == hed.TDTM_Runnable.Action.AfterUpdate) {
            Map<Id, Opportunity> oldOppMap = new Map<Id, Opportunity>((List<Opportunity>) oldList);

            Set<String> fieldsToCheck = new Set<String>();

            List<traa_Status_Processor_Rule__mdt> statusProcessorRules = [SELECT Id, traa_Source_SObject_Type__c, traa_Source_Field__c FROM traa_Status_Processor_Rule__mdt WHERE traa_Source_SObject_Type__c = 'Opportunity'];

            for (traa_Status_Processor_Rule__mdt statusProcessorRule : statusProcessorRules) {
                fieldsToCheck.add(statusProcessorRule.traa_Source_Field__c);
            }

            for (Opportunity oppObject : (List<Opportunity>) newList) {
                //When Stage is changed and it is not enrolled, update the related affiliation Status
                Boolean runStatusProcessor = false;
                for (String fieldToCheck : fieldsToCheck) {
                    if (oldOppMap.get(oppObject.Id).get(fieldToCheck) != oppObject.get(fieldToCheck)) {
                        runStatusProcessor = true;
                        break;
                    }
                }

                if (runStatusProcessor) {
                    traa_StatusProcessor.execute(newList, oldOppMap);
                }
            }
        }

        return dmlWrapper;
    }
}