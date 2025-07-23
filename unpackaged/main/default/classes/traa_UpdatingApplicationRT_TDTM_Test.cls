/**
 * Unit tests for the traa_UpdatingChildApplicationRT_TDTM class.
 *
 * @author Pranshu Sharma, Traction on Demand
 * @date   2021-05-07
 */

@IsTest
private class traa_UpdatingApplicationRT_TDTM_Test {

    @testSetup
    static void testData() {
        //Retrieve default EDA trigger handlers
        List<hed.TDTM_Global_API.TdtmToken> tokens = hed.TDTM_Global_API.getTdtmConfig();

        //Create trigger handler using the constructor
        tokens.add(new hed.TDTM_Global_API.TdtmToken('traa_UpdatingChildApplicationRT_TDTM', 'Account',
                'AfterUpdate', 1.00));

        // Pass trigger handler config to set method for this test run
        hed.TDTM_Global_API.setTdtmConfig(tokens);
    }

    @IsTest
    static void testUpdatingChildApplicationRT_TDTM() {

        String recordTypeName1, recordTypeName2;
        Account account = (Account) tf_TestFactory.createSObject(tf_AccountWrapper.class, new Map<String, Object>{
                'traa_Application_Record_Types__c' => traa_Constants.RT_ACADEMIC_APPLICATION
        }, true);
        hed__Application__c application;

        Contact contact = (Contact) tf_TestFactory.createSObject(tf_ContactWrapper.class, new Map<String, Object>{
                'AccountId' => account.Id
        }, true);

        Map<String, Object> applicationAdditionalFields = new Map<String, Object>{
                'hed__Applicant__c' => contact.Id,
                'hed__Applying_To__c' => account.Id,
                'RecordTypeId' => Schema.SObjectType.hed__Application__c.getRecordTypeInfosByName().get(traa_Constants.RT_ACADEMIC_APPLICATION).getRecordTypeId()
        };

        Test.startTest();
        application = (hed__Application__c) tf_TestFactory.createSObject(tf_ApplicationWrapper.class, applicationAdditionalFields, true);
        recordTypeName1 = [SELECT Id, RecordType.Name FROM hed__Application__c WHERE Id = :application.Id].RecordType?.Name;
        account.traa_Application_Record_Types__c = traa_Constants.RT_ACADEMIC_APPLICATION;
        update account;
        recordTypeName2 = [SELECT Id, RecordType.Name FROM hed__Application__c WHERE Id = :application.Id].RecordType?.Name;
        Test.stopTest();

        System.assertEquals(recordTypeName1,recordTypeName2,'Record Type updated based on account traa_Application_Record_Types__c field change');
        System.assertEquals(recordTypeName1,traa_Constants.RT_ACADEMIC_APPLICATION,'Record Type assigned on creation can not differ');
        System.assertEquals(recordTypeName2,traa_Constants.RT_ACADEMIC_APPLICATION,'Record Type not updated on account picklist traa_Application_Record_Types__c field change');
    }
}