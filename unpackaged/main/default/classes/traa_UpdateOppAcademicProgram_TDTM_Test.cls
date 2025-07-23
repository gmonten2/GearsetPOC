/**
 * Unit tests for the traa_UpdateOppAcademicProgram_TDTM class.
 *
 * @author Pranshu Sharma, Traction on Demand
 * @date   2021-05-21
 */

@IsTest
private class traa_UpdateOppAcademicProgram_TDTM_Test {
    @testSetup
    static void testData() {
        //Retrieve default EDA trigger handlers
        List<hed.TDTM_Global_API.TdtmToken> tokens = hed.TDTM_Global_API.getTdtmConfig();

        //Create trigger handler using the constructor
        tokens.add(new hed.TDTM_Global_API.TdtmToken('traa_UpdateOppAcademicProgram_TDTM', 'Application__c',
                'AfterInsert;AfterUpdate', 1.00));

        // Pass trigger handler config to set method for this test run
        hed.TDTM_Global_API.setTdtmConfig(tokens);
    }

    @IsTest
    static void testUpdateOppAcademicProgram_TDTM() {

        Id recordTypeIdAcc = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(traa_Constants.RT_ACADEMIC_PROGRAM).getRecordTypeId();
        List<Account> accountList = (List<Account>) tf_TestFactory.createSObjectList(2,tf_AccountWrapper.class, new Map<String, Object>{
                'traa_Application_Record_Types__c' => traa_Constants.RT_ACADEMIC_APPLICATION,
                'RecordTypeId' => recordTypeIdAcc
        }, true);

        Contact contact = (Contact) tf_TestFactory.createSObject(tf_ContactWrapper.class, new Map<String, Object>{
                'AccountId' => accountList[0].Id
        }, true);
        Map<String, Object> applicationAdditionalFields = new Map<String, Object>{
                'hed__Applicant__c' => contact.Id,
                'hed__Applying_To__c' => accountList[0].Id,
                'traa_Secondary_Program_Applying_To__c' => accountList[1].Id,
                'hed__Application_Status__c' => 'When'
        };
        //Create Application Record
        hed__Application__c application = (hed__Application__c) tf_TestFactory.createSObject(tf_ApplicationWrapper.class,  applicationAdditionalFields, true);
        Map<String, Object> opportunityAdditionalFields = new Map<String, Object>{
                'traa_Applicant__c' => contact.Id,
                'traa_Academic_Program__c' => accountList[0].Id,
                'traa_Dual_Degree_Sec_Academic_Program__c' => accountList[1].Id,
                'traa_Primary_Application__c' => application.Id
        };

        Opportunity opportunity = (Opportunity) tf_TestFactory.createSObject(tf_OpportunityWrapper.class, opportunityAdditionalFields, true);

        Test.startTest();
        application.traa_Opportunity__c = opportunity.Id;
        application.hed__Applying_To__c = accountList[1].Id;
        application.traa_Secondary_Program_Applying_To__c = accountList[0].Id;
        update application;
        Test.stopTest();
        Opportunity updatedOpportunity = [SELECT traa_Academic_Program__c,traa_Dual_Degree_Sec_Academic_Program__c FROM Opportunity WHERE Id = :opportunity.Id];
        System.assertNotEquals(updatedOpportunity.traa_Academic_Program__c, updatedOpportunity.traa_Dual_Degree_Sec_Academic_Program__c,'Both Academic Program and dual degree can not be same.');
        System.assertEquals(updatedOpportunity.traa_Academic_Program__c, application.hed__Applying_To__c,'Applying to should be updated to match with opportunity Academic Program');
        System.assertEquals(updatedOpportunity.traa_Dual_Degree_Sec_Academic_Program__c,application.traa_Secondary_Program_Applying_To__c,'Secondary Program Applying to should be updated to match with opportunity Dual Degree Secondary Academic Program');
    }
}