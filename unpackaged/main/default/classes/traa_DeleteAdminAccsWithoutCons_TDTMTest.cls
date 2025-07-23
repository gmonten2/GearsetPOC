/*
* @author          Traction on Demand (Traction TRAA Package)
* @description     Test class of traa_DeleteAdminAccsWithoutCons_TDTM
*/

@IsTest
private class traa_DeleteAdminAccsWithoutCons_TDTMTest {
    @IsTest
    static void testBehavior() {

        //Retrieve default EDA trigger handlers
        List<hed.TDTM_Global_API.TdtmToken> tokens = hed.TDTM_Global_API.getTdtmConfig();

        //Create trigger handler using the constructor
        tokens.add(new hed.TDTM_Global_API.TdtmToken('traa_DeleteAdminAccsWithoutCons_TDTM', 'Lead', 'AfterUpdate', 1.00));


        // Pass trigger handler config to set method for this test run
        hed.TDTM_Global_API.setTdtmConfig(tokens);

        //Create Lead Record
        Lead testLead = (Lead) tf_TestFactory.createSObject(tf_LeadWrapper.class, true);

        //Create Account Record
        Account account = (Account) tf_TestFactory.createSObject(tf_AccountWrapper.class,  true);

        //Create Contact Record
        Contact contact = (Contact) tf_TestFactory.createSObject(tf_ContactWrapper.class, true);

        Database.LeadConvert leadConvert = new database.LeadConvert();
        leadConvert.setLeadId(testLead.id);
        leadConvert.setDoNotCreateOpportunity(false);
        //leadConvert.setContactId(contact.Id);

        leadConvert.setConvertedStatus('Converted');

        Test.startTest();
        Database.LeadConvertResult lcresult = Database.convertLead(leadConvert);
        Lead convertedLead = [SELECT ConvertedAccountId FROM Lead WHERE Id =: testLead.Id];
        System.assert(convertedLead.ConvertedAccountId != null);
        Test.stopTest();
    }
}