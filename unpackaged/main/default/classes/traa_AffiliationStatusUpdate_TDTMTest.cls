/**
* @description Test class for traa_AffiliationStatusUpdate_TDTM
*
*
* @author      Traction on Demand (Traction TRAA Package)
* @date        2020-02-28
*/

@isTest
public class traa_AffiliationStatusUpdate_TDTMTest {
    @isTest
    private static void affiliationStatusUpdateTest(){
        
        //Retrieve default EDA trigger handlers
        List<hed.TDTM_Global_API.TdtmToken> tokens = hed.TDTM_Global_API.getTdtmConfig();
        
        //Create trigger handler using the constructor
        tokens.add(new hed.TDTM_Global_API.TdtmToken('traa_AffiliationCreate_TDTM', 'Opportunity', 'AfterInsert', 1.00));
        tokens.add(new hed.TDTM_Global_API.TdtmToken('traa_AffiliationStatusUpdate_TDTM', 'Opportunity', 'AfterUpdate', 1.00));
        
       	
        // Pass trigger handler config to set method for this test run
        hed.TDTM_Global_API.setTdtmConfig(tokens);
        
        List<RecordType> recordTypeList = new List<RecordType>();
        
        //Create Account Record
        Account account = (Account) tf_TestFactory.createSObject(tf_AccountWrapper.class,  true);
        
        //Create Academic Program Record
        Id recordTypeIdAcc = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(traa_Constants.RT_ACADEMIC_PROGRAM).getRecordTypeId();
        Map<String, Object> academicProgramAdditionalFields = new Map<String, Object>{
            'RecordTypeId' => recordTypeIdAcc
                }; 
         Account academicProgram = (Account) tf_TestFactory.createSObject(tf_AccountWrapper.class,academicProgramAdditionalFields,  true);
        
        Map<String, Object> contactAdditionalFields = new Map<String, Object>{
            'AccountId'       => account.Id
                };
                    
        //Create Contact Record
        Contact contact = (Contact) tf_TestFactory.createSObject(tf_ContactWrapper.class, contactAdditionalFields, true);
        
        //Fetch Enrollment Recordtype Id
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
        
         //Create Opportunity Record
         Opportunity opp = (Opportunity) tf_TestFactory.createSObject(tf_OpportunityWrapper.class,  opportunityAdditionalFields, true);
        
        test.startTest();
        //Update Opportunity Record
        opp.StageName = 'Ineligible';
        update opp;
        test.stopTest();
        
        Opportunity insertedOpprtunity = [SELECT Id, stagename, traa_Primary_Affiliation__r.hed__Status__c from Opportunity WHERE Id =: opp.Id];
        System.assertEquals('Lost Opportunity', insertedOpprtunity.traa_Primary_Affiliation__r.hed__Status__c, 'Affiliation Status is not updated');
    }
}