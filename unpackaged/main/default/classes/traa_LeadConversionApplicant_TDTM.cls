/*
* @author          Traction on Demand (Traction TRAA Package)
* @description     Trigger to Map Applicant from Lead to the Opportunity
*/
global without sharing class traa_LeadConversionApplicant_TDTM extends hed.TDTM_Runnable {

    // the main entry point for TDTM to invoke our trigger handlers.
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        hed.TDTM_Runnable.DmlWrapper dmlWrapper = new hed.TDTM_Runnable.DmlWrapper();

        if (triggerAction == hed.TDTM_Runnable.Action.AfterUpdate) {
            Map<Id, Lead> oldLeadMap = new Map<Id, Lead>((List<Lead>) oldList);
            Map<Id, Lead> newLeadMap = new Map<Id, Lead>((List<Lead>) newList);
            List<Opportunity> opportunities = new List<Opportunity>();

            for (Lead leadObj : newLeadMap.values()) {
                if(leadObj.IsConverted && oldLeadMap.get(leadObj.Id).Status != leadObj.Status && String.isNotBlank(leadObj.ConvertedContactId)  && String.isNotBlank(leadObj.ConvertedOpportunityId)){
                    opportunities.add(new Opportunity(Id = leadObj.ConvertedOpportunityId, traa_Applicant__c = leadObj.ConvertedContactId));
                }
            }
            if(!opportunities.isEmpty()){
                //Not adding it to the dmlWrapper as it throws duplicate opp exception
                update opportunities;
            }
        }
        return dmlWrapper;
    }
}