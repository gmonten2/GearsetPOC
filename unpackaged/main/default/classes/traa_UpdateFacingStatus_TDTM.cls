/**
*******************************************************************************************
* @author, Traction on Demand (Traction TRAA Package)
* @description Contains all the queries related to Application Object
* @date 2020-04-08
*
*******************************************************************************************
*/

global without sharing class traa_UpdateFacingStatus_TDTM extends hed.TDTM_Runnable {
    // the main entry point for TDTM to invoke our trigger handlers.

    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        hed.TDTM_Runnable.DmlWrapper dmlWrapper = new hed.TDTM_Runnable.DmlWrapper();

        //update Applicant Facing Status with Applicaiton Status by calling status processor when
        //traa_Status_Processor_Rule__mdt record has Check_Special_Condition__c flag set as true
        //or Decision Type is selected as Rolling in Academic Program record.

        if (triggerAction == hed.TDTM_Runnable.Action.AfterUpdate) {

            Map<String, traa_Status_Processor_Rule__mdt> statusProcessorRulesByValue = getMetaDataRules();
            List<traa_Status_Processor_Rule__mdt> statusProcessorRules = [SELECT Id, traa_Source_SObject_Type__c, traa_Source_Field__c FROM traa_Status_Processor_Rule__mdt WHERE traa_Source_SObject_Type__c =: traa_Constants.ST_APPLICATIONS];
            Map<Id, hed__Application__c> oldApplicationMap = new Map<Id, hed__Application__c>((List<hed__Application__c>) oldList);
            Map<Id, hed__Application__c> applicationMap = new Map<Id, hed__Application__c>([SELECT Id,hed__Applying_To__r.Decision_Type__c FROM hed__Application__c WHERE Id IN :oldApplicationMap.keySet()]);
            Map<Id, String> decisionTypeMap = new Map<Id, String>();
            for (hed__Application__c application : applicationMap.values()) {
                decisionTypeMap.put(application.Id, application.hed__Applying_To__r.Decision_Type__c);
            }
            Set<String> fieldsToCheck = new Set<String>();
            for (traa_Status_Processor_Rule__mdt statusProcessorRule : statusProcessorRules) {
                fieldsToCheck.add(statusProcessorRule.traa_Source_Field__c);
            }
            for (hed__Application__c application : (List<hed__Application__c>) newList) {

                Boolean runStatusProcessor = false;
                for (String fieldToCheck : fieldsToCheck) {
                    if (oldApplicationMap.get(application.Id).get(fieldToCheck) != application.get(fieldToCheck)) {
                        runStatusProcessor = true;
                        break;
                    }
                }
                if (runStatusProcessor) {

                    if (!statusProcessorRulesByValue.containsKey(application.hed__Application_Status__c)
                            || statusProcessorRulesByValue.get(application.hed__Application_Status__c).traa_Check_Special_Condition__c
                            || decisionTypeMap.get(application.Id) == traa_Constants.ACCOUNT_DECISION_STAGE_ROLLING) {
                        //this will call traa_Status_Processor_Rule__mdt metadata and will assign hed__Application_Status__c to traa_Applicant_Facing_Status__c

                        traa_StatusProcessor.execute(newList, oldApplicationMap);
                    }
                }

            }
        }
        else if (triggerAction == hed.TDTM_Runnable.Action.AfterInsert) {
            List<traa_Status_Processor_Rule__mdt> statusProcessorRules = [SELECT Id, traa_Source_SObject_Type__c, traa_Source_Field__c FROM traa_Status_Processor_Rule__mdt WHERE traa_Source_SObject_Type__c =: traa_Constants.ST_APPLICATIONS];

            Set<String> fieldsToCheck = new Set<String>();
            for (traa_Status_Processor_Rule__mdt statusProcessorRule : statusProcessorRules) {
                fieldsToCheck.add(statusProcessorRule.traa_Source_Field__c);
            }
            for (hed__Application__c application : (List<hed__Application__c>) newList) {

                Boolean runStatusProcessor = false;
                for (String fieldToCheck : fieldsToCheck) {
                    if (application.get(fieldToCheck) != null) {
                        runStatusProcessor = true;
                        break;
                    }
                }
                if (runStatusProcessor) {
                    traa_StatusProcessor.execute(newList, null);
                }

            }

        }

        return dmlWrapper;
    }
    /**
	* @description Queries traa_Status_Processor_Rule__mdt records for hed_Application__c object
	* @return Map<String,Boolean>, map containing Source value and check special Condition field of status processor
	*/
    private Map<String, traa_Status_Processor_Rule__mdt> getMetaDataRules() {
        List<traa_Status_Processor_Rule__mdt> rulesList = [
                SELECT Id,traa_Source_Value__c, traa_Source_Field__c, traa_Check_Special_Condition__c, traa_Target_Reference__c
                FROM traa_Status_Processor_Rule__mdt
                WHERE traa_Source_SObject_Type__c = :traa_Constants.ST_APPLICATIONS
        ];
        Map<String, traa_Status_Processor_Rule__mdt> statusProcessorRules = new Map<String, traa_Status_Processor_Rule__mdt>();
        for (traa_Status_Processor_Rule__mdt rule : rulesList) {
            statusProcessorRules.put(rule.traa_Source_Value__c, rule);
        }
        return statusProcessorRules;
    }
}