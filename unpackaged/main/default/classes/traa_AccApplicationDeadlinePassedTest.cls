/*
* @author          Traction on Demand
* @description     Test Class for traa_AccApplicationDeadlinePassed
*/
@isTest
public class traa_AccApplicationDeadlinePassedTest {

    // Dummy CRON expression: midnight on March 15.
    public static String CRON_EXP = '0 0 0 15 3 ? 2030';
    
    @isTest
    private static void accApplicationDeadlinePassedTest(){
        
        //Create Account Record
        Account account = (Account) tf_TestFactory.createSObject(tf_AccountWrapper.class,  true);
        
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Academic_Program').getRecordTypeId();
        
        Date dealineDate = System.today();
        Map<String, Object> academicProgramAdditionalFields = new Map<String, Object>{
            'RecordTypeId'       => recordTypeId,
                'traa_Application_Deadline__c' => dealineDate
                };
        
        //Create Academic Program Record 
        Account academicProgram = (Account) tf_TestFactory.createSObject(tf_AccountWrapper.class,  academicProgramAdditionalFields, true);
        
        Map<String, Object> contactAdditionalFields = new Map<String, Object>{
            'AccountId'       => account.Id
                };
                    
        //Create Contact Record
        Contact contact = (Contact) tf_TestFactory.createSObject(tf_ContactWrapper.class, contactAdditionalFields, true);
        
        List<Id> recordTypeIds = new List<Id>();
        //Get Enrollment Type Record Types of Opportunity from Metadata table
        for (traa_Opportunity_Enrollment_Record_Types__mdt metadataRules : [
            SELECT Id, traa_Is_Enrollment_Type__c, traa_RecordType_Developer_Name__c, traa_RecordType_Name__c
            FROM traa_Opportunity_Enrollment_Record_Types__mdt
            WHERE traa_Is_Enrollment_Type__c = :TRUE
        ]) {
            recordTypeIds.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(metadataRules.traa_RecordType_Developer_Name__c).getRecordTypeId());
        }
            
        Map<String, Object> opportunityAdditionalFields = new Map<String, Object>{
            'traa_Applicant__c'       => contact.Id,
                'AccountId' 		=> account.Id,
                'traa_Academic_Program__c' => academicProgram.Id,
                'RecordTypeId' => recordTypeIds[0]
                
                };
        
        //Create Opportunity Record
        Opportunity opp = (Opportunity) tf_TestFactory.createSObject(tf_OpportunityWrapper.class,  opportunityAdditionalFields, true);
        
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('ScheduledApexTest', CRON_EXP, new traa_AccApplicationDeadlinePassed());
        
        // Stopping the test will run the job synchronously
        Test.stopTest();
        
        List<Opportunity> UpdatedOpportunity = [SELECT Id, StageName from Opportunity WHERE traa_Academic_Program__c =: academicProgram.Id LIMIT 1];
        //System.assertEquals('Declined', UpdatedOpportunity[0].StageName, 'Stage is not updated');
        System.assertEquals('Stale', UpdatedOpportunity[0].StageName, 'Stage is not updated');
    }
}