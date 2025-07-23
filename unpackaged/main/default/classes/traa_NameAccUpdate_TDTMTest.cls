/*
* @author          Traction on Demand (Traction TRAA Package)
* @description     Test Class for traa_NameAccUpdate_TDTM
*/
@isTest
public class traa_NameAccUpdate_TDTMTest {
    @isTest
    private static void oppNameAccountUpdateTest(){
        //Retrieve default EDA trigger handlers
        List<hed.TDTM_Global_API.TdtmToken> tokens = hed.TDTM_Global_API.getTdtmConfig();
        
        //Create trigger handler using the constructor
        tokens.add(new hed.TDTM_Global_API.TdtmToken('traa_NameAccUpdate_TDTM', 'Opportunity', 'BeforeInsert, BeforeUpdate', 1.00));
       	
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
        
        List<Id> recordTypeIds = new List<Id>();
        //Get Enrollment Type Record Types of Opportunity from Metadata table
        for (traa_Opportunity_Enrollment_Record_Types__mdt metadataRules : [
            SELECT Id, traa_Is_Enrollment_Type__c, traa_RecordType_Developer_Name__c, traa_RecordType_Name__c
            FROM traa_Opportunity_Enrollment_Record_Types__mdt
            WHERE traa_Is_Enrollment_Type__c = :TRUE
        ]) {
            recordTypeIds.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(metadataRules.traa_RecordType_Developer_Name__c).getRecordTypeId());
        }
        recordTypeList = [Select Id From RecordType Where SobjectType = 'Opportunity' and DeveloperName = 'traa_Admissions_Enrollments'];
            
        Map<String, Object> opportunityAdditionalFields = new Map<String, Object>{
            'traa_Applicant__c'       => contact.Id,
                'AccountId' 		=> account.Id,
                'traa_Academic_Program__c' => academicProgram.Id,
                'RecordTypeId' => recordTypeIds[0]
                
                };
        
        //Create Opportunity Record
        test.startTest();
        Opportunity opp = (Opportunity) tf_TestFactory.createSObject(tf_OpportunityWrapper.class,  opportunityAdditionalFields, true);
        test.stopTest();
        
        Opportunity insertedOpprtunity = [SELECT Id, AccountId from Opportunity WHERE Id =: opp.Id];
        System.assertEquals(contact.AccountId, insertedOpprtunity.AccountId, 'Account on Opportunity Not Updated');

        opp.traa_Academic_Program__c = null;
        update opp;
        insertedOpprtunity = [SELECT Id, Name from Opportunity WHERE Id =: opp.Id LIMIT 1];
        System.assert(insertedOpprtunity.Name.contains('No Academic Program Chosen'), 'Name not updated.');
    }
}