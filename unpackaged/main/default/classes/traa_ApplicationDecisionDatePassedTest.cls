/*
* @author          Traction on Demand (Traction TRAA Package)
* @description     Test Class for traa_ApplicationDecisionDatePassed
*/
@isTest
public class traa_ApplicationDecisionDatePassedTest {
    
    // Dummy CRON expression: midnight on April 9.
    public static String CRON_EXP = '0 0 0 09 4 ?';
    
    @isTest
    private static void applicationDecisionDatePassedTest(){
        
        //Create Account Record
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(traa_Constants.RT_ACADEMIC_PROGRAM).getRecordTypeId();
        Date decisionDate = System.today();
        Map<String, Object> academicProgramAdditionalFields = new Map<String, Object>{
            'RecordTypeId'                  => recordTypeId,
             'traa_Publish_Decision_Date__c' => decisionDate,
             'Decision_Type__c'             => traa_Constants.ACCOUNT_DECISION_STAGE_UPDATE_ON_PUBLISH_DATE
                };
                    
                    //Create Academic Program Record 
                    Account academicProgram = (Account) tf_TestFactory.createSObject(tf_AccountWrapper.class,  academicProgramAdditionalFields, true);
        
        Map<String, Object> contactAdditionalFields = new Map<String, Object>{
            'AccountId'       => academicProgram.Id
                };
                    
                    //Create Contact Record
                    Contact contact = (Contact) tf_TestFactory.createSObject(tf_ContactWrapper.class, contactAdditionalFields, true);
        
        Map<String, Object> applicationAdditionalFields = new Map<String, Object>{
            'hed__Applicant__c'       => contact.Id,
                'hed__Applying_To__c'    => academicProgram.Id
                
                };     
                    
                    //Create Application Record
        hed__Application__c application = (hed__Application__c) tf_TestFactory.createSObject(tf_ApplicationWrapper.class,  applicationAdditionalFields, true);
        application.hed__Application_Status__c = 'Accepted';
        update application;
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('ScheduledApexTest', CRON_EXP, new traa_ApplicationDecisionDatePassed());
        // Stopping the test will run the job synchronously
        Test.stopTest();

        AsyncApexJob results = [SELECT JobType, Status, NumberOfErrors FROM AsyncApexJob LIMIT 1];
        System.assertEquals('ScheduledApex', results.JobType,'Incorrect Job type returned');
        System.assertEquals('Queued',results.Status, 'Status or returned job is incorrect');
        System.assertEquals(0,results.NumberOfErrors,'Job returned errors');
    }
}