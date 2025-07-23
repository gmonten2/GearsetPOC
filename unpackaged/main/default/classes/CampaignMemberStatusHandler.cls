public with sharing class CampaignMemberStatusHandler {

    public static void handleCampaignMemberStatuses(Map<Id, Campaign> campaignMap) {
        // Collect all campaign IDs
        Set<Id> campaignIds = campaignMap.keySet();
        
        // Step 1: Get Metadata Records
        Map<String, List<Campaign_Member_Status_Settings__mdt>> metadataMap = new Map<String, List<Campaign_Member_Status_Settings__mdt>>();
        for (Campaign campaign : campaignMap.values()) {
            String campaignType = campaign.Type; // Ensure this is a String
            List<Campaign_Member_Status_Settings__mdt> metadataRecords = [SELECT Status_Label__c, HasResponded__c, isDefault__c, Sort_Order__c, Campaign_Type__c 
                                                                           FROM Campaign_Member_Status_Settings__mdt WHERE Campaign_Type__c = :campaignType];
            metadataMap.put(campaignType, metadataRecords);
        }

        // Step 2: Get Existing Campaign Member Status Records
		Map<Id, Set<String>> cmsMap = new Map<Id, Set<String>>();
		for (CampaignMemberStatus cms : [SELECT Id, Label, HasResponded, IsDefault, CampaignId, SortOrder 
                                                                     FROM CampaignMemberStatus WHERE CampaignId IN :campaignIds ]) {
			if (cmsMap!=null && cmsMap.containsKey(cms.CampaignId)) {
				Set<String> tempList = cmsMap.get(cms.CampaignId);
				tempList.add(cms.Label);
                cmsMap.put(cms.CampaignId, tempList);
            }
			else{
				cmsMap.put(cms.CampaignId, new Set<String>{cms.Label});
			}
		}
        // Step 3: Initialize Collections
        List<CampaignMemberStatus> uniqueCampaignMemberStatusCollection = new List<CampaignMemberStatus>();
        Set<String> existingLabelsSet = new Set<String>();

        // Step 4: Iterate over Campaigns
        for (Id campaignId : campaignIds) {
            Campaign campaign = campaignMap.get(campaignId);
            String campaignType = campaign.Type; // Ensure this is a String
            List<Campaign_Member_Status_Settings__mdt> metadataRecords = metadataMap.get(campaignType);
            Set<String> campaignStatus = cmsMap.get(campaignId);
            if (metadataRecords != null) {
                for (Campaign_Member_Status_Settings__mdt metadata : metadataRecords) {
					if((campaignStatus!=null && !campaignStatus.contains(metadata.Status_Label__c)) || campaignStatus==null ){
                    CampaignMemberStatus cms = new CampaignMemberStatus();
                    cms.Label = metadata.Status_Label__c;
                    cms.HasResponded = metadata.HasResponded__c;
                    cms.IsDefault = metadata.isDefault__c;
                    cms.CampaignId = campaignId;
                    cms.SortOrder = Integer.valueOf(metadata.Sort_Order__c); // Convert Decimal to Integer
						system.debug('cms---'+cms);
                    uniqueCampaignMemberStatusCollection.add(cms);
					}
                }
            }
        }

        // Step 5: Insert/Update Unique Campaign Member Status Records
        if (!uniqueCampaignMemberStatusCollection.isEmpty()) {
            upsert uniqueCampaignMemberStatusCollection;
        }

        // Step 6: Delete Existing Records with Label 'Sent' or 'Responded'
        List<CampaignMemberStatus> cmsToDelete = [SELECT Id FROM CampaignMemberStatus 
                                                  WHERE CampaignId IN :campaignIds 
                                                  AND (Label = 'Sent' OR Label = 'Responded')];
        if (!cmsToDelete.isEmpty()) {
            try {
                delete cmsToDelete;
            } catch (DmlException e) {
                // Handle exception - perhaps log the error or send an email notification
                System.debug('DML Exception occurred: ' + e.getMessage());
            }
        }
    }
}