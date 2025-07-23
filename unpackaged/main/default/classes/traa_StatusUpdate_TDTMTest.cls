/**
* @description Test class for traa_StatusUpdate_TDTM
*
*
* @author      Traction on Demand (Traction TRAA Package)
* @date        2020-02-28
*/ 
@isTest
public class traa_StatusUpdate_TDTMTest {
    
    @isTest
    private static void programEnrollmentStatusUpdateTest(){
        //Retrieve default EDA trigger handlers
        List<hed.TDTM_Global_API.TdtmToken> tokens = hed.TDTM_Global_API.getTdtmConfig();
        
        //Create trigger handler using the constructor
        tokens.add(new hed.TDTM_Global_API.TdtmToken('traa_AffiliationCreate_TDTM', 'Opportunity', 'AfterInsert', 1.00));
        tokens.add(new hed.TDTM_Global_API.TdtmToken('traa_StatusUpdate_TDTM', 'Program_Enrollment__c', 'AfterUpdate', 1.00));
        
        
        // Pass trigger handler config to set method for this test run
        hed.TDTM_Global_API.setTdtmConfig(tokens);
        
        //Create Account Record
        Account account = (Account) tf_TestFactory.createSObject(tf_AccountWrapper.class,  true);
        
        //Create Academic Program Record 
        Id recordTypeIdAcc = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(traa_Constants.RT_ACADEMIC_PROGRAM).getRecordTypeId();
        Map<String, Object> academicProgramAdditionalFields = new Map<String, Object>{
            'RecordTypeId' => recordTypeIdAcc
                }; 
         Account academicProgram = (Account) tf_TestFactory.createSObject(tf_AccountWrapper.class,academicProgramAdditionalFields,  true);
        
        //Create Contact Record
        Contact contact = (Contact) tf_TestFactory.createSObject(tf_ContactWrapper.class,  true);
        
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
                'RecordTypeId' => recordTypeIds[0],
                'traa_Is_Enrollment__c' => true
                };
                    
                    
                    Opportunity newOpp = (Opportunity) tf_TestFactory.createSObject(tf_OpportunityWrapper.class,  opportunityAdditionalFields, false);
        insert newOpp;
        
        Opportunity opp = [SELECT Id, traa_Primary_Affiliation__c, traa_Academic_Program__c,StageName  FROM Opportunity WHERE Id =: newOpp.Id];
        
        Map<String, Object> programEnrollmentAdditionalFields = new Map<String, Object>{
            'traa_Opportunity__c'       => opp.Id,
                'hed__Account__c' 		=> opp.traa_Academic_Program__c,
                'hed__Admission_Date__c' => System.today(),
                'hed__Affiliation__c'       => opp.traa_Primary_Affiliation__c,
                'hed__Enrollment_Status__c' 		=> opp.StageName,
                'hed__Contact__c' => contact.Id,
                'hed__Enrollment_Status__c' => 'Enrolled'
                };
                    //Create Program Enrollment Record
                    hed__Program_Enrollment__c programEnrollment = (hed__Program_Enrollment__c) tf_TestFactory.createSObject(tf_ProgramEnrollmentWrapper.class,  programEnrollmentAdditionalFields, true);
        
        Test.startTest();
        programEnrollment.hed__Enrollment_Status__c = 'Student';
        update programEnrollment;
        Test.stopTest();
        
        hed__Program_Enrollment__c progEnroll = [SELECT hed__Affiliation__r.hed__Status__c FROM hed__Program_Enrollment__c WHERE Id=: programEnrollment.Id];
        System.assertEquals('Student', progEnroll.hed__Affiliation__r.hed__Status__c, 'Affilaition Status did not upate ');
    }
}