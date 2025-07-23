/**
* @description TDTM class for to update Campaign Member's related Opportunity
*
*
* @author      Traction on Demand (Traction TRAA Package)
* @date        2020-02-13
*/
global without sharing class traa_CampaignMemberUpdate_TDTM extends hed.TDTM_Runnable {
    
    // the main entry point for TDTM to invoke our trigger handlers.
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        
        hed.TDTM_Runnable.DmlWrapper dmlWrapper = new hed.TDTM_Runnable.DmlWrapper();
        List<CampaignMember> campaignMembers = new List<CampaignMember>();
        if (triggerAction == hed.TDTM_Runnable.Action.AfterInsert) {
            campaignMembers = updateCampaignMembers((List<Opportunity>) newList, null);
        }
        
        if (triggerAction == hed.TDTM_Runnable.Action.AfterUpdate) {
            Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>((List<Opportunity>) oldList);
            campaignMembers = updateCampaignMembers((List<Opportunity>) newList, oldMap);
        }
        if(!campaignMembers.isEmpty()){
            dmlWrapper.objectsToUpdate.addAll((List<SObject>) campaignMembers);
        }
        return dmlWrapper;
    }

    private List<CampaignMember> updateCampaignMembers(List<Opportunity> opportunities, Map<Id, Opportunity> oldMap) {
        List<Opportunity> campaignOpportunities = new List<Opportunity>();
        List<CampaignMember> campaignMembers = new List<CampaignMember>(); 
        Set<Id> campaignIds = new Set<Id>();
        for(Opportunity opportunity : opportunities) {
            if(String.isNotBlank(opportunity.CampaignId) && String.isNotBlank(opportunity.traa_Applicant__c)) {
                if(oldMap == null || isCampaignChanged(opportunity, oldMap)) {
                    campaignIds.add(opportunity.CampaignId);
                    campaignOpportunities.add(opportunity);
                }
            }
        }
        campaignMembers = getUpdatedCampaignMembers(campaignOpportunities, campaignIds);
        return campaignMembers;
    }
    
    /**
    * @description     Prepare a list of all Campaign Members to update
    * @param 		   List of Opportunities, Set of Campaign Ids
    * @return		   List of Campaign Members to update
    */    
    private List<CampaignMember> getUpdatedCampaignMembers(List<Opportunity> campaignOpportunities, Set<Id> campIds) {
        List<CampaignMember> campaignMembers = new List<CampaignMember>();
        Map<Id, List<CampaignMember>> campaignToMembers = new Map<Id, List<CampaignMember>>();
        for (CampaignMember cmpMember : [SELECT CampaignId, ContactId,traa_Opportunity__c FROM CampaignMember WHERE CampaignId IN :campIds AND ContactId != null]) {
            if (!campaignToMembers.containsKey(cmpMember.CampaignId)) {
                campaignToMembers.put(cmpMember.CampaignId, new List<CampaignMember>());
            }
            campaignToMembers.get(cmpMember.CampaignId).add(cmpMember);
        }
        for (Opportunity oppObject : campaignOpportunities) {
            if (campaignToMembers.containsKey(oppObject.CampaignId)) {
                for (CampaignMember cmpMember : campaignToMembers.get(oppObject.CampaignId)) {
                    if (cmpMember.ContactId == oppObject.traa_Applicant__c) {
                        cmpMember.traa_Opportunity__c = oppObject.Id;
                        campaignMembers.add(cmpMember);
                    }
                }
            }
        }
        return campaignMembers;
    }

    private Boolean isCampaignChanged(Opportunity opportunity, Map<Id, Opportunity> oldMap) {
        return (oldMap != null && opportunity.CampaignId != oldMap.get(opportunity.Id).CampaignId);
    }
}