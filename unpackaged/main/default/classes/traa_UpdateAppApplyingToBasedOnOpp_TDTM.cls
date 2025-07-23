/**
 * @description: Updates Application's Applying To And Secondary Applying To based on Opportunity field traa_Academic_Program__c and traa_Dual_Degree_Sec_Academic_Program__c update
 *
 * @author Pranshu Sharma, Traction on Demand
 * @date   2021-05-21
 */

global inherited sharing class traa_UpdateAppApplyingToBasedOnOpp_TDTM extends hed.TDTM_Runnable {
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        hed.TDTM_Runnable.DmlWrapper dmlWrapper = new hed.TDTM_Runnable.DmlWrapper();
        if (triggerAction == hed.TDTM_Runnable.Action.AfterUpdate) {
            Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>((List<Opportunity>) oldList);
            List<hed__Application__c> updatedApplications = new List<hed__Application__c>();
            updatedApplications = updatePrimaryAndSecondaryProgram((List<Opportunity>) newList, oldMap);
            dmlWrapper.objectsToUpdate.addAll((List<SObject>) updatedApplications);
        }
        return dmlWrapper;
    }

    private List<hed__Application__c> updatePrimaryAndSecondaryProgram(List<Opportunity> opportunities, Map<Id, Opportunity> oldMap) {
        Map<Id, Opportunity> opportunitiesAcademicProgramUpdated = new Map<Id, Opportunity>();
        List<hed__Application__c> updatedApplications = new List<hed__Application__c>();
        for (Opportunity opportunity : opportunities) {
            if (String.isNotBlank(opportunity.traa_Primary_Application__c) && ((String.isNotBlank(opportunity.traa_Academic_Program__c) && isAcademicProgramChanged(opportunity, oldMap))
                    || (String.isNotBlank(opportunity.traa_Academic_Program__c) && String.isNotBlank(opportunity.traa_Dual_Degree_Sec_Academic_Program__c) && isDualAcademicProgramChanged(opportunity, oldMap)))) {
                opportunitiesAcademicProgramUpdated.put(opportunity.Id, opportunity);
            }
        }

        if(!opportunitiesAcademicProgramUpdated.isEmpty()) {
            Map<Id, hed__Application__c> applicationsByIds = new Map<Id, hed__Application__c>(getApplications(opportunitiesAcademicProgramUpdated.keySet()));
            for (hed__Application__c application : applicationsByIds.values()) {
                if (opportunitiesAcademicProgramUpdated.containsKey(application.traa_Opportunity__c) && application.Id == opportunitiesAcademicProgramUpdated.get(application.traa_Opportunity__c).traa_Primary_Application__c) {
                    if (application.hed__Applying_To__c != opportunitiesAcademicProgramUpdated.get(application.traa_Opportunity__c).traa_Academic_Program__c) {
                        application.hed__Applying_To__c = opportunitiesAcademicProgramUpdated.get(application.traa_Opportunity__c).traa_Academic_Program__c;
                        updatedApplications.add(application);
                    }
                    if (application.traa_Secondary_Program_Applying_To__c != opportunitiesAcademicProgramUpdated.get(application.traa_Opportunity__c).traa_Dual_Degree_Sec_Academic_Program__c) {
                        application.traa_Secondary_Program_Applying_To__c = opportunitiesAcademicProgramUpdated.get(application.traa_Opportunity__c).traa_Dual_Degree_Sec_Academic_Program__c;
                        updatedApplications.add(application);
                    }
                }
            }
        }
        return updatedApplications;
    }

    private List<hed__Application__c> getApplications(Set<Id> opportunityIds) {
        List<hed__Application__c> applications = new List<hed__Application__c>([SELECT Id, traa_Opportunity__c, hed__Applying_To__c, traa_Secondary_Program_Applying_To__c FROM hed__Application__c WHERE traa_Opportunity__c IN : opportunityIds]);
        return applications;
    }

    private Boolean isAcademicProgramChanged(Opportunity opportunity,  Map<Id, Opportunity> oldMap) {
        return (oldMap != null && opportunity.traa_Academic_Program__c != oldMap.get(opportunity.Id).traa_Academic_Program__c);
    }

    private Boolean isDualAcademicProgramChanged(Opportunity opportunity,  Map<Id, Opportunity> oldMap) {
        return (oldMap != null && opportunity.traa_Dual_Degree_Sec_Academic_Program__c != oldMap.get(opportunity.Id).traa_Dual_Degree_Sec_Academic_Program__c);
    }
}