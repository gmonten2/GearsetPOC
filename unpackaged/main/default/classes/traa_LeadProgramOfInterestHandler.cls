/*
* @author          Traction on Demand (Traction TRAA Package)
* @description     Class to update program of interest on Lead 
*/
global without sharing class traa_LeadProgramOfInterestHandler extends hed.TDTM_Runnable {
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        
        hed.TDTM_Runnable.DmlWrapper dmlWrapper = new hed.TDTM_Runnable.DmlWrapper();
        List<Lead> leads = new List<Lead>((List<Lead>) newList);
        if (triggerAction == hed.TDTM_Runnable.Action.BeforeInsert) {
            populateProgramOfInterest(leads, null);
            
        }else if(triggerAction == hed.TDTM_Runnable.Action.BeforeUpdate) {
            Map<Id, Lead> oldMap = new Map<Id, Lead>((List<Lead>) oldList);
            populateProgramOfInterest(leads, oldMap);
        }
        return dmlWrapper;
    }

    private void populateProgramOfInterest(List<Lead> leads, Map<Id, Lead> oldMap) {
        List<String> programOfInterestNameFields = new List<String>(System.Label.traa_Lead_Program_of_Interest_Naming_Convention.split('-'));
        List<hed__Term__c> openTerms = new List<hed__Term__c>(getOpenTerms());
        for(Lead lead : leads) {
            if(oldMap == null || (isAcademicProgramChanged(lead, oldMap) || isAreaOfInteresChanged(lead, oldMap) || isStartTermChanged(lead, oldMap) || isLevelChanged(lead, oldMap))) {
                if(String.isNotBlank(lead.traa_Academic_Program__c)) {
                    if(String.isNotBlank(lead.traa_Start_Term__c)) {
                        lead.traa_Program_of_Interest__c = lead.get(programOfInterestNameFields[0])+'-'+((String)lead.get(programOfInterestNameFields[1])).toUpperCase();
                    }
                    else {
                        if(!openTerms.isEmpty()) {
                            lead.traa_Program_of_Interest__c = lead.traa_Academic_Program__c+' - '+openTerms[0].Name.toUpperCase();
                        }
                    }
                }
            }
        }
    }

    private Boolean isAcademicProgramChanged(Lead lead, Map<Id, Lead> oldMap) {
        return (oldMap != null && lead.traa_Academic_Program__c != oldMap.get(lead.Id).traa_Academic_Program__c);
    }

    private Boolean isAreaOfInteresChanged(Lead lead, Map<Id, Lead> oldMap) {
        return (oldMap != null && lead.traa_Area_of_Interest__c != oldMap.get(lead.Id).traa_Area_of_Interest__c);
    }

    private Boolean isStartTermChanged(Lead lead, Map<Id, Lead> oldMap) {
        return (oldMap != null && lead.traa_Start_Term__c != oldMap.get(lead.Id).traa_Start_Term__c);
    }

    private Boolean isLevelChanged(Lead lead, Map<Id, Lead> oldMap) {
        return (oldMap != null && lead.traa_Level__c != oldMap.get(lead.Id).traa_Level__c);
    }

    private List<hed__Term__c> getOpenTerms() {
        List<hed__Term__c> openTerms = new List<hed__Term__c>([SELECT Id, Name FROM hed__Term__c WHERE traa_Open_for_Applications__c = true]);
        return openTerms;
    }

}