/**
* @description Test class for traa_LeadConversionOpportunity_TDTM
* @author      Traction on Demand (Traction TRAA Package)
* @date        2020-03-19
*/
@isTest
public class traa_UpdateLeadCompany_TDTMTest {
    
    @isTest
    private static void testLeadUpdate(){
        //Retrieve default EDA trigger handlers
        List<hed.TDTM_Global_API.TdtmToken> tokens = hed.TDTM_Global_API.getTdtmConfig();
        //Create trigger handler using the constructor
        tokens.add(new hed.TDTM_Global_API.TdtmToken('traa_UpdateLeadCompany_TDTM', 'Lead', 'BeforeInsert', 1.00));
        // Pass trigger handler config to set method for this test run
        hed.TDTM_Global_API.setTdtmConfig(tokens);
        
        Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('traa_Admissions_Prospect').getRecordTypeId();
        Map<String, Object> LeadAdditionalFields = new Map<String, Object>{'RecordTypeId' => recordTypeId};
            
        Test.startTest();
        //Create Lead Record
        Lead testLead = (Lead) tf_TestFactory.createSObject(tf_LeadWrapper.class, LeadAdditionalFields, true);
        Test.stopTest();
        
        Lead newLead = [SELECT Company FROM Lead WHERE Id =: testLead.Id ];
        System.assertNotEquals(testLead.Company, newLead.Company,'Company name changed by the trigger');
        System.assertEquals(newLead.Company, traa_Constants.LEAD_COMPANY_NAME, 'Company name not updated to Individual');
    }
    
}