/**
 * @author          Traction on Demand (Traction TRAA Package)
 * @description     Trigger to Map Program of Interest Field and Other Program of Interest from Lead to traa_Academic_Program__c Lookup
 * and traa_Other_Academic_Program__c Picklist respectively on the Opportunity
 */

global without sharing class traa_LeadConversionPOI_TDTM extends hed.TDTM_Runnable {

    // the main entry point for TDTM to invoke our trigger handlers.
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        hed.TDTM_Runnable.DmlWrapper dmlWrapper = new hed.TDTM_Runnable.DmlWrapper();

        if (triggerAction == hed.TDTM_Runnable.Action.AfterUpdate) {
            Map<Id, Lead> oldLeadMap = new Map<Id, Lead>((List<Lead>) oldList);
            Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>();
            opportunityMap = updateOpportunity(newList, oldLeadMap);
            dmlWrapper.objectsToUpdate.addAll((List<SObject>) opportunityMap.values());
        }
        return dmlWrapper;
    }

    private Map<Id, Opportunity> updateOpportunity(List<Lead> leads, Map<Id, Lead> oldMap) {
        hed.TDTM_Runnable.DmlWrapper dmlWrapper = new hed.TDTM_Runnable.DmlWrapper();
        Map<String, Id> programOfInterestToOpportunityMap = new Map<String, Id>();
        Map<String, Id> otherProgramOfInterestToOpportunityMap = new Map<String, Id>(); 
        Map<String, Id> dualDegreeProgramOfInterestToOpportunityMap = new Map<String, Id>();
        Map<String, Account> accountMap = new Map<String, Account>();
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>();
        Map<String, Schema.RecordTypeInfo> accountRecordTypeMap = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
        for (Lead leadObj : leads) {
            if (leadObj.IsConverted && isStatusChanged(leadObj, oldMap) && String.isNotBlank(leadObj.traa_Program_of_Interest__c) && String.isNotBlank(leadObj.ConvertedOpportunityId)) {
                programOfInterestToOpportunityMap.put(leadObj.traa_Program_of_Interest__c, leadObj.ConvertedOpportunityId);
                if (String.isNotBlank(leadObj.traa_Other_Program_of_Interest__c)) {
                    otherProgramOfInterestToOpportunityMap.put(leadObj.traa_Other_Program_of_Interest__c, leadObj.ConvertedOpportunityId);
                }

                if (String.isNotEmpty(leadObj.traa_Dual_Degree_Sec_Program_Interest__c)) {
                    dualDegreeProgramOfInterestToOpportunityMap.put(leadObj.traa_Dual_Degree_Sec_Program_Interest__c, leadObj.ConvertedOpportunityId);
                }
            }
        }
        if(!programOfInterestToOpportunityMap.isEmpty()) {
            for (Account account : [SELECT Id, Name, RecordTypeId FROM Account WHERE Name IN : programOfInterestToOpportunityMap.keySet() OR Name IN :otherProgramOfInterestToOpportunityMap.keySet() OR Name IN : dualDegreeProgramOfInterestToOpportunityMap.keySet()]) {
                accountMap.put(account.Name, account);
            }
        }
        if(!accountMap.isEmpty()) {
            opportunityMap.putAll(populateAcademicProgramOnOpportunity(programOfInterestToOpportunityMap, accountMap));
            if(!otherProgramOfInterestToOpportunityMap.isEmpty()) {
                opportunityMap.putAll(populateOtherAcademicProgramOnOpportunity(opportunityMap, otherProgramOfInterestToOpportunityMap, accountMap, accountRecordTypeMap));
            }
            if(!dualDegreeProgramOfInterestToOpportunityMap.isEmpty()) {
                opportunityMap.putAll(populateDualAcademicProgramOnOpportunity(opportunityMap, dualDegreeProgramOfInterestToOpportunityMap, accountMap, accountRecordTypeMap));
            }
        }
        return opportunityMap;
    }

    private Boolean isStatusChanged(Lead lead, Map<Id, Lead> oldMap) {
        return (oldMap != null && lead.Status != oldMap.get(lead.Id).Status);
    }

    private Map<Id, Opportunity> populateAcademicProgramOnOpportunity(Map<String, Id> programOfInterestToOpportunityMap, Map<String, Account> accountMap) {
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>();
        for (String poi : programOfInterestToOpportunityMap.keySet()) {
            if (accountMap.containsKey(poi)) {
                Opportunity opp = new Opportunity(Id = programOfInterestToOpportunityMap.get(poi), traa_Academic_Program__c = accountMap.get(poi).Id);
                opportunityMap.put(opp.Id, opp);
            }
        }
        return opportunityMap;
    }

    private static Map<Id, Opportunity> populateOtherAcademicProgramOnOpportunity(Map<Id, Opportunity> opportunityMap, Map<String, Id> programOfInterestToOpportunityMap, Map<String, Account> accountMap, Map<String, Schema.RecordTypeInfo> accountRecordTypeMap) {
        Map<Id, Opportunity> otherOpportunityMap = new Map<Id, Opportunity>();
        for (String otherPoi : programOfInterestToOpportunityMap.keySet()) {
            if (accountMap.containsKey(otherPoi) && accountMap.get(otherPoi).RecordTypeId == accountRecordTypeMap.get(traa_Constants.RT_ACADEMIC_PROGRAM).getRecordTypeId()) {
                Opportunity opportunityToUpdate = opportunityMap.containsKey(programOfInterestToOpportunityMap.get(otherPoi)) ? opportunityMap.get(programOfInterestToOpportunityMap.get(otherPoi)) : new Opportunity(Id = programOfInterestToOpportunityMap.get(otherPoi));
                opportunityToUpdate.traa_Other_Academic_Program__c = otherPoi;
                otherOpportunityMap.put(opportunityToUpdate.Id, opportunityToUpdate);
            }
        }
        return otherOpportunityMap;
    }

    private static Map<Id, Opportunity> populateDualAcademicProgramOnOpportunity(Map<Id, Opportunity> opportunityMap, Map<String, Id> dualDegreeProgramOfInterestToOpportunityMap, Map<String, Account> accountMap, Map<String, Schema.RecordTypeInfo> accountRecordTypeMap) {
        Map<Id, Opportunity> dualOpportunityMap = new Map<Id, Opportunity>();
        for (String dualPoi : dualDegreeProgramOfInterestToOpportunityMap.keySet()) {
            if (accountMap.containsKey(dualPoi) && accountMap.get(dualPoi).RecordTypeId == accountRecordTypeMap.get(traa_Constants.RT_ACADEMIC_PROGRAM).getRecordTypeId()) {
                Opportunity opportunityToUpdate = opportunityMap.containsKey(dualDegreeProgramOfInterestToOpportunityMap.get(dualPoi)) ? opportunityMap.get(dualDegreeProgramOfInterestToOpportunityMap.get(dualPoi)) : new Opportunity(Id = dualDegreeProgramOfInterestToOpportunityMap.get(dualPoi));
                opportunityToUpdate.traa_Dual_Degree_Sec_Academic_Program__c = accountMap.get(dualPoi).Id;
                dualOpportunityMap.put(opportunityToUpdate.Id, opportunityToUpdate);
            }
        }
        return dualOpportunityMap;
    }
}