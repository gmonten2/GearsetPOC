/*
* @author          Traction on Demand (Traction TRAA Package)
* @description     Trigger to automatically create the program enrollment on an opportunity stage change to Close Won status.
*/

global without sharing class traa_ProgramEnrollmentCreate_TDTM extends hed.TDTM_Runnable {
    // the main entry point for TDTM to invoke our trigger handlers.

    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        hed.TDTM_Runnable.DmlWrapper dmlWrapper = new hed.TDTM_Runnable.DmlWrapper();

        Map<Id, Opportunity> oppEnrollmentMap = new Map<Id, Opportunity>();

        if (triggerAction == hed.TDTM_Runnable.Action.AfterUpdate) {
            Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>((List<Opportunity>) oldList);
            processOpportunityStageNameUpdate((List<Opportunity>) newList, oldMap);
        }
        return dmlWrapper;
    }
    //Return Program Enrollment list for Opportunities Whose Stage is Closed Won
    private List<hed__Program_Enrollment__c> createProgramEnrollments(List<Opportunity> oppEnrollments) {
        List<hed__Program_Enrollment__c> programEnrollmentList = new List<hed__Program_Enrollment__c>();

        for (Opportunity oppObject : oppEnrollments) {
            //Create Program Enrollment Records for Opportunities Whose Stage is Closed Won
            hed__Program_Enrollment__c programEnrollment = new hed__Program_Enrollment__c();
            programEnrollment.traa_Opportunity__c = oppObject.Id;
            programEnrollment.hed__Account__c = oppObject.traa_Academic_Program__c;
            programEnrollment.hed__Admission_Date__c = System.today();
            programEnrollment.hed__Affiliation__c = oppObject.traa_Primary_Affiliation__c;
            programEnrollment.hed__Enrollment_Status__c = oppObject.StageName;
            programEnrollment.hed__Contact__c = oppObject.traa_Applicant__c;
            programEnrollmentList.add(programEnrollment);
            if (oppObject.traa_Secondary_Affiliation__c != null && oppObject.traa_Dual_Degree_Sec_Academic_Program__c != null) {
                hed__Program_Enrollment__c secondaryProgramEnrollment = programEnrollment.clone();
                secondaryProgramEnrollment.hed__Affiliation__c = oppObject.traa_Secondary_Affiliation__c;
                secondaryProgramEnrollment.hed__Account__c = oppObject.traa_Dual_Degree_Sec_Academic_Program__c;
                programEnrollmentList.add(secondaryProgramEnrollment);
            }
        }
        return programEnrollmentList;
    }

    private void processOpportunityStageNameUpdate(List<Opportunity> opportunities, Map<id, opportunity> oldMap) {
        Set<String> stageNames = new Set<String>(getStages());
        Map<Id, opportunity> opportunityMap = new Map<Id, opportunity>();
        Map<Id, hed__Program_Enrollment__c> programEnrollmentMap = new Map<Id, hed__Program_Enrollment__c>();
        List<hed__Program_Enrollment__c> programEnrollmentList = new List<hed__Program_Enrollment__c>();
        Map<Id, hed__Program_Enrollment__c> affiliationToProgEnrollmentMap = new Map<Id, hed__Program_Enrollment__c>();
        Map<Id, Id> progEnrollmentToOppIdsMap = new Map<Id, Id>();
        if(!stageNames.isEmpty()) {
            for(Opportunity opportunity : opportunities) {
                if(String.isNotBlank(opportunity.StageName) && stageNames.contains(opportunity.StageName) && isStageChanged(opportunity, oldMap)) {
                    opportunityMap.put(opportunity.Id, opportunity);
                }
            }
        }
        if (!opportunityMap.isEmpty()) {
            programEnrollmentList = createProgramEnrollments(opportunityMap.values());
        }
        if (!programEnrollmentList.isEmpty()) {
            insert programEnrollmentList;
        }
        programEnrollmentMap.putAll(programEnrollmentList);
        for (hed__Program_Enrollment__c progEnrollment : programEnrollmentMap.values()) {
            affiliationToProgEnrollmentMap.put(progEnrollment.hed__Affiliation__c, progEnrollment);
            progEnrollmentToOppIdsMap.put(progEnrollment.Id, progEnrollment.traa_Opportunity__c);
        }
        updateProgramEnrollementOnOpportunity(opportunityMap, progEnrollmentToOppIdsMap, programEnrollmentMap);
        updateAffilaitions(affiliationToProgEnrollmentMap);
    }

    private void updateProgramEnrollementOnOpportunity(Map<Id, Opportunity> opportunityMap, Map<Id, Id> progEnrollmentToOppIdsMap, Map<Id, hed__Program_Enrollment__c> programEnrollmentMap) {
        Map<Id, Opportunity> progEnrollmentIdToOppUpdateMap = new Map<Id, Opportunity>();
        for (Id progEnrId : progEnrollmentToOppIdsMap.keySet()) {
            Opportunity opp = progEnrollmentIdToOppUpdateMap.containsKey(progEnrollmentToOppIdsMap.get(progEnrId)) ? progEnrollmentIdToOppUpdateMap.get(progEnrollmentToOppIdsMap.get(progEnrId)) : new Opportunity();
            opp.Id = progEnrollmentToOppIdsMap.get(progEnrId);
            if (opportunityMap.containsKey(opp.Id) && opportunityMap.get(opp.Id).traa_Secondary_Affiliation__c == programEnrollmentMap.get(progEnrId).hed__Affiliation__c) {
                opp.traa_Secondary_Program_Enrollment__c = progEnrId;
            } else {
                opp.traa_Primary_Program_Enrollment__c = progEnrId;
            }
            progEnrollmentIdToOppUpdateMap.put(opp.Id, opp);
        }
        if(!progEnrollmentIdToOppUpdateMap.isEmpty()) {
            update progEnrollmentIdToOppUpdateMap.values();
        }
    }

    private void updateAffilaitions( Map<Id, hed__Program_Enrollment__c> affiliationToProgEnrollmentMap) {
        List<hed__Affiliation__c> affiliationsToUpdate = new List<hed__Affiliation__c>();
        for (hed__Affiliation__c affiliation : [SELECT Id, traa_Primary_at_Recruitment__c, traa_Program_Enrollment__c FROM hed__Affiliation__c WHERE Id IN :affiliationToProgEnrollmentMap.keySet()]) {
            affiliation.traa_Program_Enrollment__c = affiliationToProgEnrollmentMap.get(affiliation.Id).Id;
            affiliation.hed__Primary__c = true;
            affiliationsToUpdate.add(affiliation);
        }
        if(!affiliationsToUpdate.isEmpty()) {
            update affiliationsToUpdate;
        }
    }

    private Boolean isStageChanged(Opportunity opportunity, Map<id, opportunity> oldMap) {
        return (oldMap != null && opportunity.StageName != oldMap.get(opportunity.Id).StageName);
    }

    private Set<String> getStages() {
        Set<String> stageNames = new Set<String>();
        for(traa_Opportunity_Stage__mdt metadataRules : [SELECT Id, Opp_Stage_Name__c, traa_Count_as_Enrolled__c FROM traa_Opportunity_Stage__mdt WHERE traa_Count_as_Enrolled__c = :true]) {
            if(String.isNotBlank(metadataRules.Opp_Stage_Name__c)) {
                stageNames.add(metadataRules.Opp_Stage_Name__c);
            }
        }
        return stageNames;
    }
}