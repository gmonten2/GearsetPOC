/**
* @description Test class for traa_CampaignMemberUpdate_TDTM
*
*
* @author      Traction on Demand (Traction TRAA Package)
* @date        2020-02-28
*/
@isTest
public class traa_CampaignMemberUpdate_TDTMTest {
    
    
    @isTest
    private static void OppCreationTest(){
        //Retrieve default EDA trigger handlers
        List<hed.TDTM_Global_API.TdtmToken> tokens = hed.TDTM_Global_API.getTdtmConfig();
        
        //Create trigger handler using the constructor
        tokens.add(new hed.TDTM_Global_API.TdtmToken('traa_CampaignMemberUpdate_TDTM', 'Opportunity', 'AfterInsert,AfterUpdate', 1.00));
        
        // Pass trigger handler config to set method for this test run
        hed.TDTM_Global_API.setTdtmConfig(tokens);
        
        //Create Campaign Record
        Campaign testCampaign = (Campaign) tf_TestFactory.createSObject(tf_CampaignWrapper.class, true);
        //Create Account Record
        Account account = (Account) tf_TestFactory.createSObject(tf_AccountWrapper.class,  true);
        //Create Contact Record
        Contact contact = (Contact) tf_TestFactory.createSObject(tf_ContactWrapper.class, true);
        //Create Campaign Member Record
        Map<String, Object> campMemAdditionalFields = new Map<String, Object>{'ContactId' => contact.Id,'CampaignId' => testCampaign.Id};
        CampaignMember testCampaignMember = (CampaignMember) tf_TestFactory.createSObject(tf_CampaignMemberWrapper.class, campMemAdditionalFields, true);
        
        List<Id> recordTypeIds = new List<Id>();
        //Get Enrollment Type Record Types of Opportunity from Metadata table
        for (traa_Opportunity_Enrollment_Record_Types__mdt metadataRules : [
            SELECT Id, traa_Is_Enrollment_Type__c, traa_RecordType_Developer_Name__c, traa_RecordType_Name__c
            FROM traa_Opportunity_Enrollment_Record_Types__mdt
            WHERE traa_Is_Enrollment_Type__c = :TRUE
        ]) {
            recordTypeIds.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(metadataRules.traa_RecordType_Developer_Name__c).getRecordTypeId());
        }
        
        Map<String, Object> opportunityAdditionalFields = new Map<String, Object>{
            'traa_Applicant__c'       => contact.Id,
                'AccountId' 		=> account.Id,
                'RecordTypeId' => recordTypeIds[0],
                'CampaignId' => testCampaign.Id,
                'traa_Is_Enrollment__c' => true
                };
                    
        //Create Campaign Record
        Campaign testCamp = (Campaign) tf_TestFactory.createSObject(tf_CampaignWrapper.class, true);
        //Create Campaign Member Record
        Map<String, Object> campMemberAdditionalFields = new Map<String, Object>{'ContactId' => contact.Id,'CampaignId' => testCamp.Id};
        CampaignMember testCampMember = (CampaignMember) tf_TestFactory.createSObject(tf_CampaignMemberWrapper.class, campMemberAdditionalFields, true);
        
        Test.startTest();
        //Create Opportunity Record
        Opportunity opp = (Opportunity) tf_TestFactory.createSObject(tf_OpportunityWrapper.class,  opportunityAdditionalFields, true);
        
        CampaignMember campMem = [SELECT traa_Opportunity__c FROM CampaignMember WHERE Id =: testCampaignMember.Id ];
        System.assertEquals(true,campMem.traa_Opportunity__c != null);
        //Update Campaign on Opportuntiy
        opp.CampaignId = testCamp.Id;
        update opp;
        Test.stopTest();
        CampaignMember campMemUpdated = [SELECT traa_Opportunity__c FROM CampaignMember WHERE Id =: testCampMember.Id ];
        System.assertEquals(opp.Id,campMemUpdated.traa_Opportunity__c);
    }
    
}