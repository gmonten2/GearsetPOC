/*
* @author          Traction on Demand (Traction TRAA Package)
* @description     Test Class for traa_LeadConversionApplicant_TDTM class
*/
@IsTest
private class traa_LeadConversionApplicant_TDTMTest {

    @IsTest
    static void testBehavior() {
        //Retrieve default EDA trigger handlers
        List<hed.TDTM_Global_API.TdtmToken> tokens = hed.TDTM_Global_API.getTdtmConfig();

        //Create trigger handler using the constructor
        tokens.add(new hed.TDTM_Global_API.TdtmToken('traa_LeadConversionApplicant_TDTM', 'Lead', 'AfterUpdate', 1.00));

        // Pass trigger handler config to set method for this test run
        hed.TDTM_Global_API.setTdtmConfig(tokens);

        //Create Account Record
        Account account = (Account) tf_TestFactory.createSObject(tf_AccountWrapper.class, true);

        Lead lead = new Lead(
                LastName = 'Doe',
                FirstName = 'John',
                Company = 'Test',
                Status = 'Contacted',
                traa_Program_of_Interest__c = 'History');
        insert lead;

        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.Id);
        lc.setDoNotCreateOpportunity(false);
        lc.setConvertedStatus('Converted');

        Test.startTest();
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        Test.stopTest();
        System.assert(lcr.isSuccess(), 'Lead conversion failed.');

        List<Contact> contacts = new List<Contact>();
        contacts = [SELECT Id, Name FROM Contact WHERE LastName = 'Doe'];
        System.assert(contacts.size() == 1, 'Contact not created.');
        List<Opportunity> opportunities = new List<Opportunity>();
        opportunities = [SELECT Id, traa_Applicant__c FROM Opportunity];
        System.assert(opportunities.size() == 1, 'Opportunity not created.');
        System.assert(opportunities[0].traa_Applicant__c == contacts[0].Id, 'Applicant not populated.');
    }

}