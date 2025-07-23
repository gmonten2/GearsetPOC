/**
*******************************************************************************************
* @author, Traction on Demand (Traction TRAA Package)
* @description this test class contains methods to test the methods of traa_UpdateFacingStatus_TDTM class
* @date 2020-04-08
*
*******************************************************************************************
*/
@IsTest
public class traa_UpdateFacingStatus_TDTMTest {
    @IsTest
    private static void updateFacingStatusTest(){
        
        //Retrieve default EDA trigger handlers
        List<hed.TDTM_Global_API.TdtmToken> tokens = hed.TDTM_Global_API.getTdtmConfig();
        
        //Create trigger handler using the constructor
        tokens.add(new hed.TDTM_Global_API.TdtmToken('traa_UpdateFacingStatus_TDTM', 'Application__c', 'AfterUpdate', 1.00));
        
        // Pass trigger handler config to set method for this test run
        hed.TDTM_Global_API.setTdtmConfig(tokens);
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(traa_Constants.RT_ACADEMIC_PROGRAM).getRecordTypeId();
        
        //Create Academic program Record
        Map<String, Object> academicProgramAdditionalFields = new Map<String, Object>{
            'RecordTypeId' => recordTypeId,
            'Decision_Type__c' => traa_Constants.ACCOUNT_DECISION_STAGE_ROLLING
                };
                    Account account = (Account) tf_TestFactory.createSObject(tf_AccountWrapper.class,academicProgramAdditionalFields,  true);
        
        Map<String, Object> contactAdditionalFields = new Map<String, Object>{
            'AccountId'       => account.Id
                };
                    
                    //Create Contact Record
                    Contact contact = (Contact) tf_TestFactory.createSObject(tf_ContactWrapper.class, contactAdditionalFields, true);
        
        Map<String, Object> applicationAdditionalFields = new Map<String, Object>{
            'hed__Applicant__c'       => contact.Id,
             'hed__Applying_To__c'    => account.Id,
              'hed__Application_Status__c' =>'Received'
                };     
                    //Create Application Record
                    hed__Application__c application = (hed__Application__c) tf_TestFactory.createSObject(tf_ApplicationWrapper.class,  applicationAdditionalFields, true);
        
        //Update Application Record
        application.hed__Application_Status__c = 'What';
        Test.startTest();
        update application;
        Test.stopTest();
        hed__Application__c updatedApplication = [SELECT Id, hed__Application_Status__c, traa_Applicant_Facing_Status__c FROM hed__Application__c WHERE Id =:application.Id];
        System.assertEquals(updatedApplication.traa_Applicant_Facing_Status__c, updatedApplication.hed__Application_Status__c, 'Application Facing Status is Updated');
    }
    
    @IsTest
    private static void updateFacingStatusOnUpdateTest(){
        
        //Retrieve default EDA trigger handlers
        List<hed.TDTM_Global_API.TdtmToken> tokens = hed.TDTM_Global_API.getTdtmConfig();
        
        //Create trigger handler using the constructor
        tokens.add(new hed.TDTM_Global_API.TdtmToken('traa_UpdateFacingStatus_TDTM', 'Application__c', 'AfterUpdate', 1.00));
        
        // Pass trigger handler config to set method for this test run
        hed.TDTM_Global_API.setTdtmConfig(tokens);
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(traa_Constants.RT_ACADEMIC_PROGRAM).getRecordTypeId();
        
        //Create Academic program Record
        Map<String, Object> academicProgramAdditionalFields = new Map<String, Object>{
            'RecordTypeId' => recordTypeId,
            'Decision_Type__c' => traa_Constants.ACCOUNT_DECISION_STAGE_ROLLING
                };
                    Account account = (Account) tf_TestFactory.createSObject(tf_AccountWrapper.class,academicProgramAdditionalFields,  true);
        
        Map<String, Object> contactAdditionalFields = new Map<String, Object>{
            'AccountId'       => account.Id
                };
                    
                    //Create Contact Record
                    Contact contact = (Contact) tf_TestFactory.createSObject(tf_ContactWrapper.class, contactAdditionalFields, true);
        
        Map<String, Object> applicationAdditionalFields = new Map<String, Object>{
            'hed__Applicant__c'       => contact.Id,
             'hed__Applying_To__c'    => account.Id
                };     
                    
                    //Create Application Record
                    hed__Application__c application = (hed__Application__c) tf_TestFactory.createSObject(tf_ApplicationWrapper.class,  applicationAdditionalFields, true);
        
        //Update Application Record
        application.hed__Application_Status__c = 'Who';
        Test.startTest();
        update application;
        Test.stopTest();
        
        hed__Application__c updatedApplication = [SELECT Id, hed__Application_Status__c, traa_Applicant_Facing_Status__c FROM hed__Application__c WHERE Id =:application.Id];
        System.assertEquals(updatedApplication.traa_Applicant_Facing_Status__c, updatedApplication.hed__Application_Status__c, 'Application Facing Status is Updated');
    }

    @IsTest
    private static void updateFacingStatusOnCreateTest(){

        //Retrieve default EDA trigger handlers
        List<hed.TDTM_Global_API.TdtmToken> tokens = hed.TDTM_Global_API.getTdtmConfig();

        //Create trigger handler using the constructor
        tokens.add(new hed.TDTM_Global_API.TdtmToken('traa_UpdateFacingStatus_TDTM', 'Application__c', 'AfterInsert', 1.00));

        // Pass trigger handler config to set method for this test run
        hed.TDTM_Global_API.setTdtmConfig(tokens);
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(traa_Constants.RT_ACADEMIC_PROGRAM).getRecordTypeId();

        //Create Academic program Record
        Map<String, Object> academicProgramAdditionalFields = new Map<String, Object>{
                'RecordTypeId' => recordTypeId,
                'Decision_Type__c' => traa_Constants.ACCOUNT_DECISION_STAGE_ROLLING
        };
        Account account = (Account) tf_TestFactory.createSObject(tf_AccountWrapper.class,academicProgramAdditionalFields,  true);

        Map<String, Object> contactAdditionalFields = new Map<String, Object>{
                'AccountId'       => account.Id
        };

        //Create Contact Record
        Contact contact = (Contact) tf_TestFactory.createSObject(tf_ContactWrapper.class, contactAdditionalFields, true);

        Map<String, Object> applicationAdditionalFields = new Map<String, Object>{
                'hed__Applicant__c'       => contact.Id,
                'hed__Applying_To__c'    => account.Id,
                'hed__Application_Status__c' => 'When'
        };

        //Create Application Record
        hed__Application__c application = (hed__Application__c) tf_TestFactory.createSObject(tf_ApplicationWrapper.class,  applicationAdditionalFields, true);

        Test.startTest();
        update application;
        Test.stopTest();

        hed__Application__c updatedApplication = [SELECT Id, hed__Application_Status__c, traa_Applicant_Facing_Status__c FROM hed__Application__c WHERE Id =:application.Id];
        System.assertEquals(updatedApplication.traa_Applicant_Facing_Status__c, updatedApplication.hed__Application_Status__c, 'Application Facing Status is Updated');
    }
}