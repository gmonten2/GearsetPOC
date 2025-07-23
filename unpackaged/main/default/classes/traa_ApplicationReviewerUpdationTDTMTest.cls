/*
* @author          Traction on Demand (Traction traa Package)
* @description     Test class for traa_ApplicationReviewerUpdation_TDTM
*/
@isTest
public class traa_ApplicationReviewerUpdationTDTMTest {
    @isTest
    private static void applicationReviewerTest() {

//Retrieve default EDA trigger handlers
        List<hed.TDTM_Global_API.TdtmToken> tokens = hed.TDTM_Global_API.getTdtmConfig();

//Create trigger handler using the constructor
        tokens.add(new hed.TDTM_Global_API.TdtmToken('traa_ApplicationReviewerUpdation_TDTM', 'Application__c', 'AfterInsert;AfterUpdate', 1.00));

// Pass trigger handler config to set method for this test run
        hed.TDTM_Global_API.setTdtmConfig(tokens);

//Create Account Record
        Account account = (Account) tf_TestFactory.createSObject(tf_AccountWrapper.class, true);

        Map<String, Object> contactAdditionalFields = new Map<String, Object>{
                'AccountId' => account.Id
        };

//Create Contact Record
        Contact contact = (Contact) tf_TestFactory.createSObject(tf_ContactWrapper.class, contactAdditionalFields, true);

        Map<String, Object> applicationAdditionalFields = new Map<String, Object>{
                'hed__Applicant__c' => contact.Id,
                'hed__Applying_To__c' => account.Id,
                'traa_Score__c' => 1000
        };

//Create Application Record
        test.startTest();
        hed__Application__c application = (hed__Application__c) tf_TestFactory.createSObject(tf_ApplicationWrapper.class, applicationAdditionalFields, true);
        test.stopTest();

        hed__Application__c insertedApplication = [SELECT Id, traa_Application_Reviewer__c, LastModifiedById from hed__Application__c WHERE Id = :application.Id];
        System.assertEquals(insertedApplication.traa_Application_Reviewer__c, insertedApplication.LastModifiedById, 'Application Reviewer is not Populated');

//Update Application Record
        application.traa_Score__c = 1100;
        update application;

        hed__Application__c updatedApplication = [SELECT Id, traa_Application_Reviewer__c, LastModifiedById from hed__Application__c WHERE Id = :application.Id];
        System.assertEquals(updatedApplication.traa_Application_Reviewer__c, updatedApplication.LastModifiedById, 'Application Reviewer is not Updated');
    }
}