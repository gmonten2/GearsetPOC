/*
* @author          Traction on Demand (Traction TRAA Package)
* @description     Trigger to Create Affiliations and update traa_Is_Enrollment_Type__c checkbox on Opportunity
*/
global without sharing class traa_AffiliationCreate_TDTM extends hed.TDTM_Runnable {

    // the main entry point for TDTM to invoke our trigger handlers
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        hed.TDTM_Runnable.DmlWrapper dmlWrapper = new hed.TDTM_Runnable.DmlWrapper();
        if(triggerAction == hed.TDTM_Runnable.Action.AfterInsert) {
           //Added by Kunal Taneja 26/04 to reomove oppotunities from the list which does not have an academic program so the affiliation record is not created for those opps.
            List<Opportunity> oppListforAffiliation= new List<Opportunity>();
            for(Opportunity opp  : ((List<Opportunity>) newList)){
                if(String.isNotBlank(opp.traa_Academic_Program__c)){
                    oppListforAffiliation.add(opp);
                }
            }
            processOpportunityCreationAndUpdation((List<Opportunity>) oppListforAffiliation, null);
            //Commenting the original peice of code.
            //processOpportunityCreationAndUpdation((List<Opportunity>) newList, null);
        }
        else if(triggerAction == hed.TDTM_Runnable.Action.AfterUpdate) {
            Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>((List<Opportunity>) oldList);
            processOpportunityCreationAndUpdation((List<Opportunity>) newList, oldMap);
        }
        return dmlWrapper;
    }

    /*@description  private method used to create affiliations for the given opp list*/
    private List<hed__Affiliation__c> createAffiliations(List<Opportunity> oppEnrollments) {
        List<hed__Affiliation__c> affiliationList = new List<hed__Affiliation__c>();
        for (Opportunity oppObject : oppEnrollments) {
            hed__Affiliation__c affiliation = new hed__Affiliation__c();
            affiliation.traa_Primary_at_Recruitment__c = true;
            affiliation.traa_Opportunity__c = oppObject.Id;
            affiliation.hed__Account__c = oppObject.traa_Academic_Program__c;
            affiliation.hed__Contact__c = oppObject.traa_Applicant__c;
            affiliation.hed__Role__c = 'Prospect';
            affiliation.hed__Status__c = oppObject.StageName;
            affiliationList.add(affiliation);

            if (String.isNotEmpty(oppObject.traa_Dual_Degree_Sec_Academic_Program__c)) {
                hed__Affiliation__c affiliationDualDegree = affiliation.clone();
                affiliation.traa_Primary_at_Recruitment__c = false;
                affiliation.hed__Account__c = oppObject.traa_Dual_Degree_Sec_Academic_Program__c;
                affiliationList.add(affiliationDualDegree);
            }
        }
        return affiliationList;
    }
 
    private void processOpportunityCreationAndUpdation(List<Opportunity> opportunities, Map<Id, Opportunity> oldMap) {
        Set<Id> opportunityRecordTypeIds = new Set<Id>(getOpportunityRecordTypeIds());
        Set<Id> applicantIds = new Set<Id>();
        List<Opportunity> opportunityAffiliations = new List<Opportunity>();
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        Map<Id, Id> affiliationIdToAcademicProgramIdMap = new Map<Id, Id>();
        Map<Id, Id> affiliationIdToSecondaryAcademicProgramIdMap = new Map<Id, Id>();
        List<hed__Affiliation__c> affiliationList = new List<hed__Affiliation__c>();
        if (!opportunityRecordTypeIds.isEmpty()) {
            for (Opportunity opportunity : opportunities) {
                if(opportunityRecordTypeIds.contains(opportunity.RecordTypeId) && String.isNotBlank(opportunity.traa_Academic_Program__c) && String.isNotBlank(opportunity.traa_Applicant__c)) {
                    if(oldMap == null || (isAcademicProgramChanged(opportunity, oldMap) || isApplicantChanged(opportunity, oldMap) || isDualAcademicProgramChanged(opportunity, oldMap))) {
                        Opportunity opp = new Opportunity(Id = opportunity.Id, traa_Is_Enrollment__c = true);
                        opportunitiesToUpdate.add(opp);
                        opportunityAffiliations.add(opportunity);
                        applicantIds.add(opportunity.traa_Applicant__c);
                        if (oldMap != null && oldMap.containsKey(opportunity.Id)) {
                            if (String.isNotBlank(oldMap.get(opportunity.Id).traa_Primary_Affiliation__c)) {
                                affiliationIdToAcademicProgramIdMap.put(oldMap.get(opportunity.Id).traa_Primary_Affiliation__c, opportunity.traa_Academic_Program__c);
                            } else if (String.isNotBlank(oldMap.get(opportunity.Id).traa_Secondary_Affiliation__c) && isDualAcademicProgramChanged(opportunity, oldMap)) {
                                affiliationIdToSecondaryAcademicProgramIdMap.put(oldMap.get(opportunity.Id).traa_Secondary_Affiliation__c, opportunity.traa_Dual_Degree_Sec_Academic_Program__c);
                            }
                        }
                    }
                }
            }
        }
        if (!opportunityAffiliations.isEmpty()) {
            update opportunitiesToUpdate; 
            system.debug('Mulesoft:' +opportunitiesToUpdate);
            affiliationList = createAffiliations(opportunityAffiliations);
        }
        if(oldMap == null || affiliationIdToAcademicProgramIdMap.isEmpty()) {
            system.debug('Mulesoft:' +opportunities);
            createAffiliations(affiliationList, opportunities);
        }
        else {
            system.debug('Mulesoft:' +affiliationIdToAcademicProgramIdMap);
            updateOldAffiliations(affiliationIdToAcademicProgramIdMap, affiliationIdToSecondaryAcademicProgramIdMap);
        }
    }

    private void createAffiliations(List<hed__Affiliation__c> affiliationList, List<Opportunity> opportunities) {
        Map<Id, List<hed__Affiliation__c>> opportunityToAffiliationMap = new Map<Id, List<hed__Affiliation__c>>();
        if(!affiliationList.isEmpty()) {
            insert affiliationList;
            for (hed__Affiliation__c affiliation : affiliationList) {
                if (!opportunityToAffiliationMap.containsKey(affiliation.traa_Opportunity__c)) {
                    opportunityToAffiliationMap.put(affiliation.traa_Opportunity__c, new List<hed__Affiliation__c>());
                }
                opportunityToAffiliationMap.get(affiliation.traa_Opportunity__c).add(affiliation);
            }
        }
        if(!opportunityToAffiliationMap.isEmpty()) {
            updateOpportunity(opportunityToAffiliationMap, opportunities);
        }
    }

    private void updateOpportunity( Map<Id, List<hed__Affiliation__c>> opportunityToAffiliationMap, List<Opportunity> opportunities) {
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        for (Opportunity opportunity : opportunities) {
            Opportunity newOpp = new Opportunity();
            newOpp.Id = opportunity.Id;
            newOpp.StageName = opportunity.StageName;
            List<hed__Affiliation__c> affiliations = opportunityToAffiliationMap.get(opportunity.Id);
            if (affiliations != null && !affiliations.isEmpty()  ) {  
            for (hed__Affiliation__c affiliation : affiliations) {
                if (affiliation.traa_Primary_at_Recruitment__c) {
                    newOpp.traa_Primary_Affiliation__c = affiliation.Id;
                } else {
                    newOpp.traa_Secondary_Affiliation__c = affiliation.Id;
                }
            }
        }
            oppsToUpdate.add(newOpp);
            }
        if (!oppsToUpdate.isEmpty()) {
            update oppsToUpdate;
            traa_StatusProcessor.execute(oppsToUpdate);
        }
    }

    private void updateOldAffiliations(Map<Id, Id> affiliationIdToAcademicProgramIdMap, Map<Id, Id> affiliationIdToSecondaryAcademicProgramIdMap) {
        List<hed__Affiliation__c> oldAffiliations = new List<hed__Affiliation__c>();
        for (hed__Affiliation__c affiliation : [SELECT hed__Account__c FROM hed__Affiliation__c WHERE Id IN : affiliationIdToAcademicProgramIdMap.keySet() OR Id IN :affiliationIdToSecondaryAcademicProgramIdMap.keySet()]) {
            affiliation.hed__Account__c = affiliationIdToAcademicProgramIdMap.containsKey(affiliation.Id) ? affiliationIdToAcademicProgramIdMap.get(affiliation.Id) : affiliationIdToSecondaryAcademicProgramIdMap.get(affiliation.Id);
            oldAffiliations.add(affiliation);
        }
        if(!oldAffiliations.isEmpty()) {
            update oldAffiliations;
        }
    }

    private Boolean isAcademicProgramChanged(Opportunity opportunity, Map<Id, Opportunity> oldMap) {
        return (oldMap != null && opportunity.traa_Academic_Program__c != oldMap.get(opportunity.Id).traa_Academic_Program__c);
    }
    private Boolean isApplicantChanged(Opportunity opportunity, Map<Id, Opportunity> oldMap) {
        return (oldMap != null && opportunity.traa_Applicant__c != oldMap.get(opportunity.Id).traa_Applicant__c);
    }
    private Boolean isDualAcademicProgramChanged(Opportunity opportunity, Map<Id, Opportunity> oldMap) {
        return (oldMap != null && opportunity.traa_Dual_Degree_Sec_Academic_Program__c != oldMap.get(opportunity.Id).traa_Dual_Degree_Sec_Academic_Program__c);
    }

    private Set<Id> getOpportunityRecordTypeIds() {
        Set<Id> opportunityRecordTypeIds = new Set<Id>();
        for (traa_Opportunity_Enrollment_Record_Types__mdt metadataRules : [ SELECT Id, traa_Is_Enrollment_Type__c, traa_RecordType_Developer_Name__c, traa_RecordType_Name__c
                    FROM traa_Opportunity_Enrollment_Record_Types__mdt
                    WHERE traa_Is_Enrollment_Type__c =: true ]) {
                opportunityRecordTypeIds.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(metadataRules.traa_RecordType_Developer_Name__c).getRecordTypeId());
        }
        return opportunityRecordTypeIds; 
    }
}