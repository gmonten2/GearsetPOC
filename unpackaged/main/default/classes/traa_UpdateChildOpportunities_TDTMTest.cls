/*
* @author          Traction on Demand (Traction TRAA Package)
* @description     Test Class for traa_UpdateChildOpportunities_TDTM
*/
@isTest
public class traa_UpdateChildOpportunities_TDTMTest {
    @isTest
    private static void oppNameAccountUpdateTest(){
        //Retrieve default EDA trigger handlers
        List<hed.TDTM_Global_API.TdtmToken> tokens = hed.TDTM_Global_API.getTdtmConfig();
        
        //Create trigger handler using the constructor
        tokens.add(new hed.TDTM_Global_API.TdtmToken('traa_UpdateChildOpportunities_TDTM', 'Account', 'AfterUpdate', 1.00));
       	
        // Pass trigger handler config to set method for this test run
        hed.TDTM_Global_API.setTdtmConfig(tokens);
        
        //Create Account Record
        Account account = (Account) tf_TestFactory.createSObject(tf_AccountWrapper.class,  true);
        
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Academic_Program').getRecordTypeId();
        
        Map<String, Object> academicProgramAdditionalFields = new Map<String, Object>{
            'RecordTypeId'       => recordTypeId
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
        academicProgram.traa_Enrollment_Deadline__c = System.today();
        update academicProgram;
        Test.stopTest();
        
        List<Opportunity> UpdatedOpportunity = [SELECT Id, CloseDate from Opportunity WHERE traa_Academic_Program__c =: academicProgram.Id LIMIT 1];
        System.assertEquals(True, UpdatedOpportunity[0].CloseDate == System.Today(), 'Close Date is not updated');
    }
}