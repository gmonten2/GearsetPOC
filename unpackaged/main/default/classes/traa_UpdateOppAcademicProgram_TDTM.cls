/**
 * @description: Updates Opportunity Academic Program And Dual Degree Secondary Academic Program based on Application field hed__Applying_To__c and traa_Secondary_Program_Applying_To__c update
 *
 * @author Pranshu Sharma, Traction on Demand
 * @date   2021-05-21
 */
global inherited sharing class traa_UpdateOppAcademicProgram_TDTM extends hed.TDTM_Runnable {
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        hed.TDTM_Runnable.DmlWrapper dmlWrapper = new hed.TDTM_Runnable.DmlWrapper();
        Map<Id, hed__Application__c> applicationsToUpdated = new Map<Id, hed__Application__c>();
        Map<Id, hed__Application__c> oldApplicationsByIds = new Map<Id, hed__Application__c>();
        if (triggerAction == hed.TDTM_Runnable.Action.AfterInsert || triggerAction == hed.TDTM_Runnable.Action.AfterUpdate) {
            if (oldList != null) {
                oldApplicationsByIds.putAll((List<hed__Application__c>) oldList);
            }
            for (hed__Application__c application : (List<hed__Application__c>) newList) {
                if (String.isNotBlank(application.traa_Opportunity__c) && String.isNotBlank(application.hed__Applying_To__c) && (oldApplicationsByIds.isEmpty() || (isApplyingToChanged(application, oldApplicationsByIds) || isSecondaryProgramToChanged(application, oldApplicationsByIds)))) {
                    applicationsToUpdated.put(application.Id, application);
                }
            }

            if (!applicationsToUpdated.isEmpty()) {
                dmlWrapper.objectsToUpdate.addAll((List<SObject>) populateDualDegreeAndAcademicProgram(applicationsToUpdated));
            }
        }
        return dmlWrapper;
    }

    private List<Opportunity> populateDualDegreeAndAcademicProgram(Map<Id, hed__Application__c> applicationsToUpdated ) {
        Map<Id, Opportunity> opportunitiesByIds = new Map<Id, Opportunity>([SELECT Id, traa_Primary_Application__c,traa_Academic_Program__c, traa_Dual_Degree_Sec_Academic_Program__c FROM Opportunity WHERE traa_Primary_Application__c = :applicationsToUpdated.keySet()]);
        Map<Id, Opportunity> opportunityToUpdatesMap = new Map<Id, Opportunity>();
        for (Opportunity opportunity : opportunitiesByIds.values()) {
            if (applicationsToUpdated.containsKey(opportunity.traa_Primary_Application__c) && opportunity.Id == applicationsToUpdated.get(opportunity.traa_Primary_Application__c).traa_Opportunity__c) {
                if (opportunity.traa_Academic_Program__c != applicationsToUpdated.get(opportunity.traa_Primary_Application__c).hed__Applying_To__c) {
                    opportunity.traa_Academic_Program__c = applicationsToUpdated.get(opportunity.traa_Primary_Application__c).hed__Applying_To__c;
                    opportunityToUpdatesMap.put(opportunity.Id, opportunity);
                }
                if (opportunity.traa_Dual_Degree_Sec_Academic_Program__c != applicationsToUpdated.get(opportunity.traa_Primary_Application__c).traa_Secondary_Program_Applying_To__c) {
                    opportunity.traa_Dual_Degree_Sec_Academic_Program__c = applicationsToUpdated.get(opportunity.traa_Primary_Application__c).traa_Secondary_Program_Applying_To__c;
                    opportunityToUpdatesMap.put(opportunity.Id, opportunity);
                }
            }
        }
        return opportunityToUpdatesMap.values();

    }

    private Boolean isApplyingToChanged(hed__Application__c application, Map<Id, hed__Application__c> oldMap) {
        return (oldMap != null && application.hed__Applying_To__c != oldMap.get(application.Id).hed__Applying_To__c);
    }

    private Boolean isSecondaryProgramToChanged(hed__Application__c application, Map<Id, hed__Application__c> oldMap) {
        return (oldMap != null && application.traa_Secondary_Program_Applying_To__c != oldMap.get(application.Id).traa_Secondary_Program_Applying_To__c);
    }
}