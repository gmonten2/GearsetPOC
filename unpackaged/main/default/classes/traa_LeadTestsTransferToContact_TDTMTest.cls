/*
* @author          Traction on Demand (Traction TRAA Package)
* @description     Test class for traa_LeadTestsTransferToContact_TDTM
*/
@isTest
public class traa_LeadTestsTransferToContact_TDTMTest {
	@isTest
    //Lead child test record transfer to Converted Contact where Contact doesn't have any Tests
    private static void LeadTestsTransferTest(){
        
        //Retrieve default EDA trigger handlers
        List<hed.TDTM_Global_API.TdtmToken> tokens = hed.TDTM_Global_API.getTdtmConfig();
        
        //Create trigger handler using the constructor
        tokens.add(new hed.TDTM_Global_API.TdtmToken('traa_LeadTestsTransferToContact_TDTM', 'Lead', 'AfterUpdate', 1.00));
        
        // Pass trigger handler config to set method for this test run
        hed.TDTM_Global_API.setTdtmConfig(tokens);
        
        //Create Account Record
        Account account = (Account) tf_TestFactory.createSObject(tf_AccountWrapper.class,  true);
                
        Map<String, Object> contactAdditionalFields = new Map<String, Object>{
            'AccountId'       => account.Id
                };
                    
        //Create Contact Record
        Contact contact = (Contact) tf_TestFactory.createSObject(tf_ContactWrapper.class, contactAdditionalFields, true);
        
        //Create Lead Record
        Lead lead = (Lead) tf_TestFactory.createSObject(tf_LeadWrapper.class, true);
        
        Map<String, Object> testAdditionalFields = new Map<String, Object>{
            'traa_Lead__c'       => lead.Id
                };

        //Create Test Record
        hed__Test__c testRecord = (hed__Test__c) tf_TestFactory.createSObject(tf_TestWrapper.class, testAdditionalFields, true);
        
        Map<String, Object> testScoreAdditionalFields = new Map<String, Object>{
            'hed__Test__c'       => testRecord.Id
                };
        
        //Create Test Score Record
        hed__Test_Score__c testScore = (hed__Test_Score__c) tf_TestFactory.createSObject(tf_TestScoreWrapper.class, testScoreAdditionalFields, true);
        
        //Convert Lead
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.Id);
        lc.setDoNotCreateOpportunity(false);
        lc.setConvertedStatus('Converted');
        lc.setContactId(contact.Id);
        lc.setAccountId(account.Id);

        Test.startTest();
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        Test.stopTest();

        System.assert(lcr.isSuccess());

        
        Contact updatedContact = [SELECT Id, (SELECT Id, hed__Test_Type__c FROM hed__Tests__r) FROM Contact WHERE Id =:contact.Id];
        System.assertEquals(True, updatedContact.hed__Tests__r != null, 'Lead child Tests are not transferred to Contact');
    }
    
    @isTest
    //Lead child test record transfer to Converted Contact where Contact has child Tests and Test type matches
    private static void LeadTestsTransferToContactTestsTest(){
        
        //Retrieve default EDA trigger handlers
        List<hed.TDTM_Global_API.TdtmToken> tokens = hed.TDTM_Global_API.getTdtmConfig();
        
        //Create trigger handler using the constructor
        tokens.add(new hed.TDTM_Global_API.TdtmToken('traa_LeadTestsTransferToContact_TDTM', 'Lead', 'AfterUpdate', 1.00));
        
        // Pass trigger handler config to set method for this test run
        hed.TDTM_Global_API.setTdtmConfig(tokens);
        
        //Create Account Record
        Account account = (Account) tf_TestFactory.createSObject(tf_AccountWrapper.class,  true);
                
        Map<String, Object> contactAdditionalFields = new Map<String, Object>{
            'AccountId'       => account.Id
                };
                    
        //Create Contact Record
        Contact contact = (Contact) tf_TestFactory.createSObject(tf_ContactWrapper.class, contactAdditionalFields, true);
        
        //Create Lead Record
        Lead lead = (Lead) tf_TestFactory.createSObject(tf_LeadWrapper.class, true);
        
        Map<String, Object> testAdditionalFields = new Map<String, Object>{
            'traa_Lead__c'       => lead.Id,
                'hed__Test_Type__c' => 'GRE'
                };

        //Create Test Record
        hed__Test__c leadTest = (hed__Test__c) tf_TestFactory.createSObject(tf_TestWrapper.class, testAdditionalFields, true);
        
        Map<String, Object> testScoreAdditionalFields = new Map<String, Object>{
            'hed__Test__c'       => leadTest.Id
                };
        
        //Create Test Score Record
        hed__Test_Score__c leadTestScore = (hed__Test_Score__c) tf_TestFactory.createSObject(tf_TestScoreWrapper.class, testScoreAdditionalFields, true);
        
        testAdditionalFields.put('hed__Contact__c',contact.Id);
        testAdditionalFields.put('traa_Lead__c',null);
        testAdditionalFields.put('hed__Test_Type__c','GRE');
        
        //Create Test Record
        hed__Test__c contactTest = (hed__Test__c) tf_TestFactory.createSObject(tf_TestWrapper.class, testAdditionalFields, true);
        
        testScoreAdditionalFields.put('hed__Test__c', contactTest.Id);
        
        //Create Test Score Record
        hed__Test_Score__c contactTestScore = (hed__Test_Score__c) tf_TestFactory.createSObject(tf_TestScoreWrapper.class, testScoreAdditionalFields, true);
        
        //Convert Lead
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.Id);
        lc.setDoNotCreateOpportunity(false);
        lc.setConvertedStatus('Converted');
        lc.setContactId(contact.Id);
        lc.setAccountId(account.Id);

        Test.startTest();
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        Test.stopTest();

        System.assert(lcr.isSuccess());

        List<hed__Test__c> updatedTestList = [SELECT Id, (SELECT Id FROM hed__Test_Scores__r) FROM hed__Test__c  WHERE hed__Contact__c =:contact.Id];
        for(hed__Test__c updatedTest:updatedTestList){
           
           System.assertEquals(1, updatedTest.hed__Test_Scores__r.size(), 'Test Scores are not transferred'); 
        }
        
    }
}