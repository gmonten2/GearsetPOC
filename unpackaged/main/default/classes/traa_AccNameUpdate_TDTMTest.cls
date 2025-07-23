/*
* @author          Traction on Demand (Traction TRAA Package)
* @description     Test class for traa_AccNameUpdate_TDTM
*/

@isTest
public class traa_AccNameUpdate_TDTMTest {
    @isTest
    private static void accNameUpdateTest() {

        //Retrieve default EDA trigger handlers
        List<hed.TDTM_Global_API.TdtmToken> tokens = hed.TDTM_Global_API.getTdtmConfig();

        //Create trigger handler using the constructor
        tokens.add(new hed.TDTM_Global_API.TdtmToken('traa_AccNameUpdate_TDTM', 'Account', 'BeforeInsert, BeforeUpdate', 1.00));

        // Pass trigger handler config to set method for this test run
        hed.TDTM_Global_API.setTdtmConfig(tokens);

        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Academic_Program').getRecordTypeId();

        //Create Account Record
        Account account = (Account) tf_TestFactory.createSObject(tf_AccountWrapper.class, true);

        Map<String, Object> termAdditionalFields = new Map<String, Object>{
                'hed__Account__c' => account.Id
        };

        List<hed__Term__c> term = (List<hed__Term__c>) tf_TestFactory.createSObjectList(2, tf_TermWrapper.class, termAdditionalFields, true);

        //Create Parent Account Record
        Account parentAccount = (Account) tf_TestFactory.createSObject(tf_AccountWrapper.class, true);

        Map<String, Object> academicProgramAdditionalFields = new Map<String, Object>{
        'ParentId' => parentAccount.Id,
        'Starting_Term__c' => term[0].Id,
        'RecordTypeId' => recordTypeId
            };

        //Create Academic Program Record
        Account academicProgram = (Account) tf_TestFactory.createSObject(tf_AccountWrapper.class, academicProgramAdditionalFields, true);

        Account insertedAcademicProgram = [SELECT Id, Name FROM Account WHERE Id = :academicProgram.Id];
        System.assertEquals(parentAccount.Name + ' - ' + term[0].Name, insertedAcademicProgram.Name, 'Academic Program Name is not Updated');
        
        //Update Academic Program
        Test.startTest();
        academicProgram.Starting_Term__c = term[1].id;
        update academicProgram;
        Test.stopTest();
        
        Account updatedAcademicProgram = [SELECT Id, Name FROM Account WHERE Id = :academicProgram.Id];
        System.assertEquals(parentAccount.Name + ' - ' + term[1].Name, updatedAcademicProgram.Name, 'Academic Program Name is not Updated');
        
    }
}