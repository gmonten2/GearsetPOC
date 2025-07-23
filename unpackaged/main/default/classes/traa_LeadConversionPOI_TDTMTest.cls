/*
* @author          Traction on Demand (Traction TRAA Package)
* @description     Test Class for traa_LeadConversionPOI_TDTM class
*/
@IsTest
private class traa_LeadConversionPOI_TDTMTest {

    @IsTest
    static void testBehavior() {
        //Retrieve default EDA trigger handlers
        List<hed.TDTM_Global_API.TdtmToken> tokens = hed.TDTM_Global_API.getTdtmConfig();

        //Create trigger handler using the constructor
        tokens.add(new hed.TDTM_Global_API.TdtmToken('traa_LeadConversionPOI_TDTM', 'Lead', 'AfterUpdate', 1.00));

        // Pass trigger handler config to set method for this test run
        hed.TDTM_Global_API.setTdtmConfig(tokens);

        //Create Account Record
        Id recordTypeIdAcc = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(traa_Constants.RT_ACADEMIC_PROGRAM).getRecordTypeId();
        Account account1 = (Account) tf_TestFactory.createSObject(tf_AccountWrapper.class,  false);
        account1.RecordTypeId = recordTypeIdAcc;
        String accountName1 = account1.Name;
        Account account2 = (Account) tf_TestFactory.createSObject(tf_AccountWrapper.class,  false);
        account2.RecordTypeId = recordTypeIdAcc;
        String accountName2 = account2.Name;
        insert new List<Account>{account1, account2};

        Lead lead = new Lead(
                LastName = 'Doe',
                FirstName = 'John',
                Company = 'Test',
                Status = 'New',
                traa_Program_of_Interest__c = accountName1,
                traa_Other_Program_of_Interest__c = accountName2);
        insert lead;

        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.Id);
        lc.setDoNotCreateOpportunity(false);
        lc.setConvertedStatus('Converted');

        Test.startTest();
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        Test.stopTest();
        System.assert(lcr.isSuccess());

        List<Opportunity> opportunities = new List<Opportunity>();
        opportunities = [SELECT Id, traa_Academic_Program__c, traa_Academic_Program__r.Name, traa_Other_Academic_Program__c FROM Opportunity];
        System.assert(opportunities.size() == 1);
        System.assert(opportunities[0].traa_Academic_Program__r.Name == accountName1);
        System.assertEquals(opportunities[0].traa_Other_Academic_Program__c,lead.traa_Other_Program_of_Interest__c, 'Other Academic Program not filled on opportunity based on the Lead.');
    }

}