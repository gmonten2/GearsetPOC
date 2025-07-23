/*
* @author          Traction on Demand (Traction TRAA Package)
* @description     Trigger to populate Company field for Admissions Prospect type Leads.
*/
global without sharing class traa_UpdateLeadCompany_TDTM extends hed.TDTM_Runnable {
    // the main entry point for TDTM to invoke our trigger handlers.
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        hed.TDTM_Runnable.DmlWrapper dmlWrapper = new hed.TDTM_Runnable.DmlWrapper();
        
        if (triggerAction == hed.TDTM_Runnable.Action.BeforeInsert) {
            
            Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('traa_Admissions_Prospect').getRecordTypeId();
            //Get Admissions Prospect type Leads and update it's Company
            for(Lead objLead : (List<Lead>) newList){
                if(objLead.RecordTypeId == recordTypeId){
                    objLead.Company = traa_Constants.LEAD_COMPANY_NAME;
                }
            }
        }
        return dmlWrapper;
    }
}