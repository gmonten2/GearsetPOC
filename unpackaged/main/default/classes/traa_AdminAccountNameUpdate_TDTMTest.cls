/**
* @description Test class for traa_AdministrativeAccountNameUpdate_TDTM
* @author      Traction on Demand (Traction TRAA Package)
* @date        2020-03-19
*/
@isTest
public class traa_AdminAccountNameUpdate_TDTMTest {
    
    @isTest
    private static void testAccountNameBeforeInsert(){
        
        //Retrieve default EDA trigger handlers
        List<hed.TDTM_Global_API.TdtmToken> tokens = hed.TDTM_Global_API.getTdtmConfig();
        //Create trigger handler using the constructor
        tokens.add(new hed.TDTM_Global_API.TdtmToken('traa_AdministrativeAcntNameUpdate_TDTM', 'Account', 'BeforeInsert', 1.00));
        // Pass trigger handler config to set method for this test run
        hed.TDTM_Global_API.setTdtmConfig(tokens);
        
        Test.startTest();
        //Create Contact Record
        Contact contact = (Contact) tf_TestFactory.createSObject(tf_ContactWrapper.class,  true);
        Contact con = [SELECT AccountId FROM Contact WHERE Id=: contact.Id ];
        Account acc = [SELECT Name FROM Account WHERE Id =: con.AccountId];
        Test.stopTest();
        
        System.assertEquals(true, acc.Name.contains(traa_Constants.ADMIN_ACCOUNT_NAME));
    }
    
    @isTest
    private static void testAccountNameBeforeUpdate(){
        
        //Retrieve default EDA trigger handlers
        List<hed.TDTM_Global_API.TdtmToken> tokens = hed.TDTM_Global_API.getTdtmConfig();
        //Create trigger handler using the constructor
        tokens.add(new hed.TDTM_Global_API.TdtmToken('traa_AdministrativeAcntNameUpdate_TDTM', 'Account', 'BeforeUpdate', 1.00));
        // Pass trigger handler config to set method for this test run
        hed.TDTM_Global_API.setTdtmConfig(tokens);
        
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Administrative').getRecordTypeId();
        Map<String, Object> additionalFields = new Map<String, Object>{'RecordTypeId' => recordTypeId};
        //Create Account Record
        Account acc = (Account) tf_TestFactory.createSObject(tf_AccountWrapper.class,additionalFields, true);
        //Create Contact Record
        Contact contact = (Contact) tf_TestFactory.createSObject(tf_ContactWrapper.class,  true);
        
        Test.startTest();
        //Update Account
        acc.hed__Primary_Contact__c = contact.Id;
        update acc;
        Account acccount = [SELECT Name, hed__Primary_Contact__c FROM Account WHERE Id =: acc.Id];
        Test.stopTest();
        
        System.assertEquals(true, acccount.Name.contains(traa_Constants.ADMIN_ACCOUNT_NAME));
    }
    
}