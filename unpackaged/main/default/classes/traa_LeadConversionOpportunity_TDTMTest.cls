/**
* @description Test class for traa_LeadConversionOpportunity_TDTM
*
*
* @author      Traction on Demand (Traction TRAA Package)
* @date        2020-02-25
*/
@isTest
public class traa_LeadConversionOpportunity_TDTMTest {
    
    @isTest
    private static void LeadConversionTest(){
        //Retrieve default EDA trigger handlers
        List<hed.TDTM_Global_API.TdtmToken> tokens = hed.TDTM_Global_API.getTdtmConfig();
        
        //Create trigger handler using the constructor
        tokens.add(new hed.TDTM_Global_API.TdtmToken('traa_LeadConversionOpportunity_TDTM', 'Lead', 'BeforeUpdate', 1.00));
        
        // Pass trigger handler config to set method for this test run
        hed.TDTM_Global_API.setTdtmConfig(tokens);
        
        //Create Campaign Record
        Campaign testCampaign = (Campaign) tf_TestFactory.createSObject(tf_CampaignWrapper.class, true);
        
        //Create Lead Record
        Lead testLead = (Lead) tf_TestFactory.createSObject(tf_LeadWrapper.class, true);
        
        Map<String, Object> campMemAdditionalFields = new Map<String, Object>{'LeadId' => testLead.Id,'CampaignId' => testCampaign.Id};
            
        //Create Campaign Member Record
        CampaignMember testCampaignMember = (CampaignMember) tf_TestFactory.createSObject(tf_CampaignMemberWrapper.class, campMemAdditionalFields, true);
        
        System.assertEquals('New',testLead.Status);
        //Convert Lead
        Database.LeadConvert leadConvert = new database.LeadConvert();
        leadConvert.setLeadId(testLead.id);
        leadConvert.setDoNotCreateOpportunity(false);
        leadConvert.setConvertedStatus('Converted');
        
        Test.startTest();
        Database.LeadConvertResult lcresult = Database.convertLead(leadConvert);
        Test.stopTest();

        Lead convertedLead = [SELECT Status FROM Lead WHERE Id =: testLead.Id];
        CampaignMember campMem = [SELECT traa_Opportunity__c FROM CampaignMember WHERE Id =: testCampaignMember.Id ];

        System.assertEquals('Converted',convertedLead.Status);
        System.assert(campMem.traa_Opportunity__c != null);
    }
    
}