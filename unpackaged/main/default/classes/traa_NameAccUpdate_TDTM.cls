/*
* @author          Traction on Demand (Traction TRAA Package)
* @description     Class to update name, account and Close date on Opportunity
*/
global without sharing class traa_NameAccUpdate_TDTM extends hed.TDTM_Runnable {

    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        
        hed.TDTM_Runnable.DmlWrapper dmlWrapper = new hed.TDTM_Runnable.DmlWrapper();
        List<Opportunity> newOpps = new List<Opportunity>((List<Opportunity>) newList);
        if (triggerAction == hed.TDTM_Runnable.Action.BeforeInsert) {
            updateNameAndAccount(newOpps, null);
        }else if(triggerAction == hed.TDTM_Runnable.Action.BeforeUpdate) {
            Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>((List<Opportunity>) oldList);
            updateNameAndAccount(newOpps, oldMap);
        }
        return dmlWrapper;
    }

    private void updateNameAndAccount(List<Opportunity> opportunities, Map<Id, Opportunity> oldMap) {
        Set<Id> opportunityRecordTypeIds = new Set<Id>(getRecordTypeIds());
        Set<Id> applicantIds = new Set<Id>();
        Set<Id> academicProgramIds = new Set<Id>();
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        if(!opportunityRecordTypeIds.isEmpty()) {
            for(Opportunity opportunity : opportunities) {
                if(opportunityRecordTypeIds.contains(opportunity.RecordTypeId) && String.isNotBlank(opportunity.traa_Applicant__c)) {
                    if(oldMap == null || isApplicantChanged(opportunity, oldMap) || isAcademicProgramChanged(opportunity, oldMap)|| isTermChanged(opportunity, oldMap)) {
                        applicantIds.add(opportunity.traa_Applicant__c);
                        if(String.isNotBlank(opportunity.traa_Academic_Program__c)) {
                            academicProgramIds.add(opportunity.traa_Academic_Program__c);
                        }
                        opportunitiesToUpdate.add(opportunity);
                    }
                }
            }
        }
        if(!applicantIds.isEmpty()) {
            populateNameAndAccountOnOpportunity(opportunitiesToUpdate, applicantIds, academicProgramIds);
        }
    }

    private void populateNameAndAccountOnOpportunity(List<Opportunity> opportunities, Set<Id> applicantIds, Set<Id> academicProgramIds) {
        Map<Id, Contact> contactsMap = new Map<Id, Contact>([SELECT Id, FirstName, LastName, AccountId FROM Contact WHERE Id IN : applicantIds]);
        Map<Id, Account> accountsMap;
        String name = '';
        if (!academicProgramIds.isEmpty()) {
            accountsMap = new Map<Id, Account>([SELECT Id, Name, traa_Enrollment_Deadline__c FROM Account WHERE Id IN : academicProgramIds]);
        }
        for(Opportunity opportunity : opportunities) {
            if (contactsMap.containsKey(opportunity.traa_Applicant__c) && String.isNotBlank(contactsMap.get(opportunity.traa_Applicant__c).FirstName)) {
                name += contactsMap.get(opportunity.traa_Applicant__c).FirstName + ' ';
            }
            name += contactsMap.get(opportunity.traa_Applicant__c).LastName + ' - ';
            
            if (String.isBlank(opportunity.traa_Academic_Program__c)) {
                name += 'No Academic Program Chosen';
                 //Added by Kunal Taneja - 11/04/2023 - Add term to Opportunity Name
                if(String.isNotBlank(opportunity.Term__c)){
                    name += ' - '+opportunity.Term__c;
                }
            } 
            else if(accountsMap != null && accountsMap.containsKey(opportunity.traa_Academic_Program__c)){
                name += accountsMap.get(opportunity.traa_Academic_Program__c).Name;
                 //Added by Kunal Taneja - 11/04/2023 - Add term to Opportunity Name
                if(String.isNotBlank(opportunity.Term__c)){
                    name += ' - '+opportunity.Term__c;
                }
            }
            if(name.length() > 120){
                name = name.substring(0, 120);
            }
            opportunity.Name = name;
            opportunity.AccountId = contactsMap.get(opportunity.traa_Applicant__c).AccountId;
            
            if(accountsMap != null && accountsMap.containsKey(opportunity.traa_Academic_Program__c) && accountsMap.get(opportunity.traa_Academic_Program__c).traa_Enrollment_Deadline__c != null){
                opportunity.CloseDate = accountsMap.get(opportunity.traa_Academic_Program__c).traa_Enrollment_Deadline__c;
            }
            name = '';
        }
    }

    private Set<Id> getRecordTypeIds() {
        Set<Id> opportunityRecordTypeIds = new Set<Id>();
        for (traa_Opportunity_Enrollment_Record_Types__mdt metadataRules : [SELECT Id, traa_Is_Enrollment_Type__c, traa_RecordType_Developer_Name__c, traa_RecordType_Name__c
                                                                            FROM traa_Opportunity_Enrollment_Record_Types__mdt
                                                                            WHERE traa_Is_Enrollment_Type__c =: true]){
            if(String.isNotBlank(metadataRules.traa_RecordType_Developer_Name__c)) {                                                                   
                opportunityRecordTypeIds.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(metadataRules.traa_RecordType_Developer_Name__c).getRecordTypeId());
            }
        }
        return opportunityRecordTypeIds;
    }

    private  Boolean isApplicantChanged(Opportunity opportunity, Map<Id, Opportunity> oldMap) {
        return(oldMap != null && opportunity.traa_Applicant__c != oldMap.get(opportunity.Id).traa_Applicant__c);
    }

    private  Boolean isAcademicProgramChanged(Opportunity opportunity, Map<Id, Opportunity> oldMap) {
        return(oldMap != null && opportunity.traa_Academic_Program__c != oldMap.get(opportunity.Id).traa_Academic_Program__c);
    }
    //Added by Kunal Taneja - 11/04/2023 - Add term to Opportunity Name
    private Boolean isTermChanged(Opportunity opportunity,Map<Id,Opportunity> oldMap){
        return(oldMap !=null && Opportunity.Term__c != oldMap.get(Opportunity.Id).Term__c);
    }
}