/**
* @description TDTM class for Lead trigger
*
*
* @author      Mitali Nahar, Traction on Demand
* @date        2020-02-13
*/
global without sharing class traa_LeadConversionOpportunity_TDTM extends hed.TDTM_Runnable{
    // the main entry point for TDTM to invoke our trigger handlers.
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        hed.TDTM_Runnable.DmlWrapper dmlWrapper = null;

        if (triggerAction == hed.TDTM_Runnable.Action.BeforeUpdate) {
            dmlWrapper = new hed.TDTM_Runnable.DmlWrapper();
            //Create Map from Lists
            Map<Id, Lead> oldLeadMap = new Map<Id, Lead>((List<Lead>)oldList);
            Map<Id, Lead> newLeadMap = new Map<Id, Lead>((List<Lead>)newList);
            List<CampaignMember> campaignMembers = new List<CampaignMember>();
            //Get Campaign Members associated with the Leads
            for (CampaignMember cpnMember : [
                    SELECT Id, LeadId, traa_Opportunity__c
                    FROM CampaignMember
                    WHERE LeadId IN :newLeadMap.keySet()
            ]) {

                Id leadId = cpnMember.LeadId;
                if (oldLeadMap.containsKey(leadId)
                        && newLeadMap.containsKey(leadId)) {
                    //Get Current and Previous Lead Status
                    String previousStatus = oldLeadMap.get(leadId).Status;
                    String status = newLeadMap.get(leadId).Status;
                    Boolean isConverted = newLeadMap.get(leadId).IsConverted;
                    //Check If the Lead Status was changed and the Lead is Converted now
                    Boolean isLeadConverted = previousStatus != status && isConverted;
                    //Populate Opportunity Lookup on Campaign Member
                    if (isLeadConverted && newLeadMap.get(leadId).ConvertedOpportunityId != null) {
                        cpnMember.traa_Opportunity__c = newLeadMap.get(leadId).ConvertedOpportunityId;
                        campaignMembers.add(cpnMember);
                    }
                }
            }
            dmlWrapper.objectsToUpdate.addAll((List<SObject>)campaignMembers);
        }
        return dmlWrapper;
    }
}