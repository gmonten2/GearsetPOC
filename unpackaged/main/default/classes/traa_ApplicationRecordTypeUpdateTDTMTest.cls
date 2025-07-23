/**
 * Unit tests for the traa_ApplicationRecordTypeUpdate_TDTM class.
 *
 * @author Pranshu Sharma, Traction on Demand
 * @date   2021-05-06
 */

@IsTest
private class traa_ApplicationRecordTypeUpdateTDTMTest {

    @testSetup
    static void testData() {
        //Retrieve default EDA trigger handlers
        List<hed.TDTM_Global_API.TdtmToken> tokens = hed.TDTM_Global_API.getTdtmConfig();

        //Create trigger handler using the constructor
        tokens.add(new hed.TDTM_Global_API.TdtmToken('traa_ApplicationRecordTypeUpdate_TDTM', 'Application__c',
                'BeforeInsert; BeforeUpdate', 1.00));

        // Pass trigger handler config to set method for this test run
        hed.TDTM_Global_API.setTdtmConfig(tokens);
    }

    @IsTest
    static void testApplicationRecordTypeUpdate() {

        String recordTypeName1, recordTypeName2;
        Account account1 = (Account) tf_TestFactory.createSObject(tf_AccountWrapper.class, new Map<String, Object>{
                'traa_Application_Record_Types__c' => traa_Constants.RT_ACADEMIC_APPLICATION
        }, true);
        Account account2 = (Account) tf_TestFactory.createSObject(tf_AccountWrapper.class, new Map<String, Object>{
                'traa_Application_Record_Types__c' => traa_Constants.RT_EDA_APPLICATION
        }, true);
        hed__Application__c application;

        Contact contact = (Contact) tf_TestFactory.createSObject(tf_ContactWrapper.class, new Map<String, Object>{
                'AccountId' => account1.Id
        }, true);

        Map<String, Object> applicationAdditionalFields = new Map<String, Object>{
                'hed__Applicant__c' => contact.Id,
                'hed__Applying_To__c' => account1.Id
        };

        Test.startTest();
        application = (hed__Application__c) tf_TestFactory.createSObject(tf_ApplicationWrapper.class, applicationAdditionalFields, true);
        recordTypeName1 = [SELECT Id, RecordType.Name FROM hed__Application__c WHERE Id = :application.Id].RecordType?.Name;
        application.hed__Applying_To__c = account2.Id;
        update application;
        recordTypeName2 = [SELECT Id, RecordType.Name FROM hed__Application__c WHERE Id = :application.Id].RecordType?.Name;
        Test.stopTest();

        System.assertNotEquals(recordTypeName1,recordTypeName2,'Record Type updates based on account Application Record Type field');
        System.assertEquals(recordTypeName1,traa_Constants.RT_ACADEMIC_APPLICATION,'Record Type assigned on creation can not differ');
        System.assertEquals(recordTypeName2,traa_Constants.RT_EDA_APPLICATION,'Record Type not updated on account change on Application');
    }
}