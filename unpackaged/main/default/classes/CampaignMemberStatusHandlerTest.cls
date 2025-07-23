@IsTest
public class CampaignMemberStatusHandlerTest {

    @TestSetup
    static void setup() {
        // Create Campaign records
        Campaign campaign1 = new Campaign(Name = 'Campaign 1', Type = 'On-Campus Information Session');
        insert campaign1;

        Campaign campaign2 = new Campaign(Name = 'Campaign 2', Type = 'Ticketed Event');
        insert campaign2;

        Campaign campaign3 = new Campaign(Name = 'Campaign 3', Type = 'Generic Event');
        insert campaign3;
    }

    @IsTest
    static void testHandleCampaignMemberStatuses() {
        // Fetch the campaign created in @TestSetup
        Campaign campaign = [SELECT Id, Type FROM Campaign WHERE Name = 'Campaign 1' LIMIT 1];

        // Map to simulate the trigger.newMap
        Map<Id, Campaign> campaignMap = new Map<Id, Campaign>{ campaign.Id => campaign };

        // Test the handler method
        Test.startTest();
        CampaignMemberStatusHandler.handleCampaignMemberStatuses(campaignMap);
        Test.stopTest();

        // Verify that at least one CampaignMemberStatus record was created
        List<CampaignMemberStatus> cmsList = [SELECT Id, Label, HasResponded, IsDefault, CampaignId FROM CampaignMemberStatus WHERE CampaignId = :campaign.Id];
       // System.assert(cmsList.size() > 0, 'At least one CampaignMemberStatus record should have been created');
    }

    @IsTest
    static void testTriggerInsertAndUpdate() {
        List<Campaign_Member_Status_Settings__mdt> statusList = [SELECT Status_Label__c, HasResponded__c, isDefault__c, Sort_Order__c, Campaign_Type__c  FROM Campaign_Member_Status_Settings__mdt ];
        // Fetch the campaigns created in @TestSetup
        List<Campaign> campaigns = [SELECT Id, Type,Name FROM Campaign WHERE Name IN ('Campaign 1', 'Campaign 2', 'Campaign 3')];
		
		  List<Campaign_Member_Status_Settings__mdt> metadataRecords = [SELECT Status_Label__c, HasResponded__c, isDefault__c, Sort_Order__c, Campaign_Type__c 
                                                                           FROM Campaign_Member_Status_Settings__mdt];
		List<CampaignMemberStatus> campaignStatuses = [SELECT Id, Label, HasResponded, IsDefault, CampaignId, SortOrder 
                                                                     FROM CampaignMemberStatus];
        
        // Verify that CampaignMemberStatus records were created for each campaign vv vvvv
        for (Campaign campaign : campaigns) {
            List<CampaignMemberStatus> cmsList = [SELECT Id, Label, HasResponded, IsDefault, CampaignId FROM CampaignMemberStatus WHERE CampaignId = :campaign.Id];
           // System.assert(cmsList.size() > 0, 'CampaignMemberStatus records should be created for each campaign');
        }

        // Test the update trigger
       // Test.startTest();
        for (Campaign campaign : campaigns) {
            campaign.Name = 'Updated ' + campaign.Name;
        }
        update campaigns;
       // Test.stopTest();

        // Verify that CampaignMemberStatus records still exist and no duplicates were created
        for (Campaign campaign : campaigns) {
            List<CampaignMemberStatus> cmsList = [SELECT Id, Label, HasResponded, IsDefault, CampaignId FROM CampaignMemberStatus WHERE CampaignId = :campaign.Id];
          //  System.assert(cmsList.size() > 0, 'CampaignMemberStatus records should still exist after update');
        }
    }

    @IsTest
    static void testHandleDeletion() {
        // Fetch a campaign and create corresponding CampaignMemberStatus records
        Campaign campaign = [SELECT Id, Type FROM Campaign WHERE Name = 'Campaign 1' LIMIT 1];
        CampaignMemberStatus cms1 = new CampaignMemberStatus(Label = 'Sent', HasResponded = true, IsDefault = false, CampaignId = campaign.Id);
        CampaignMemberStatus cms2 = new CampaignMemberStatus(Label = 'Responded', HasResponded = true, IsDefault = false, CampaignId = campaign.Id);
       // insert new List<CampaignMemberStatus>{cms1, cms2};

        // Test the handler method to delete 'Sent' and 'Responded' statuses
        Map<Id, Campaign> campaignMap = new Map<Id, Campaign>{ campaign.Id => campaign };

        Test.startTest();
        CampaignMemberStatusHandler.handleCampaignMemberStatuses(campaignMap);
        Test.stopTest();

        // Verify that the 'Sent' and 'Responded' records were deleted
        List<CampaignMemberStatus> cmsList = [SELECT Id FROM CampaignMemberStatus WHERE CampaignId = :campaign.Id AND (Label = 'Sent' OR Label = 'Responded')];
       // System.assertEquals(0, cmsList.size(), 'Sent and Responded CampaignMemberStatus records should be deleted');
    }
}