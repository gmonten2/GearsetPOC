/*
* @author          Traction on Demand (Traction TRAA Package)
* @description     Test Class for traa_LeadProgramOfInterestHandler class
*/
@IsTest
private with sharing class traa_LeadProgramOfInterestHandlerTest {
    @testSetup static void setup() {
        List<hed.TDTM_Global_API.TdtmToken> tokens = hed.TDTM_Global_API.getTdtmConfig();
        //Create trigger handler using the constructor
        tokens.add(new hed.TDTM_Global_API.TdtmToken('traa_LeadProgramOfInterestHandler', 'Lead', 'BeforeInsert, BeforeUpdate', 1.00));
        // Pass trigger handler config to set method for this test run
        hed.TDTM_Global_API.setTdtmConfig(tokens);
    }

    @IsTest
    static void onBeforeInsert() {
        Lead lead = new Lead(
            LastName = 'Doe',
            FirstName = 'John',
            Company = 'Test',
            Status = 'New',
            traa_Academic_Program__c = 'Master of Education',
            traa_Area_of_Interest__c = 'Business',
            traa_Level__c = 'Certificate',
            traa_Start_Term__c = '2237',
            Email = 'test123@test.com'
        );

        Test.startTest();
        insert lead;
        Test.stopTest();
        Lead updatedLead = getLead();
        System.assertEquals('Master of Education-2237', updatedLead.traa_Program_of_Interest__c, 'Program of interest should match');
    }

    @IsTest
    static void onBeforeAcedemicProgramUpdate() {
        Lead lead = new Lead(
            LastName = 'Doe',
            FirstName = 'John',
            Company = 'Test',
            Status = 'New',
            traa_Academic_Program__c = 'Master of Education',
            traa_Area_of_Interest__c = 'Business',
            traa_Level__c = 'Certificate',
            traa_Start_Term__c = '2237',
            Email = 'test123@test.com'
        );
        insert lead;
        Test.startTest();
        Lead updateLead = getLead();
        updateLead.traa_Academic_Program__c = 'Master of Arts in Special Education';
        update updateLead;
        Test.stopTest();
        Lead updatedLeadRecord = getLead();
        System.assertEquals('Master of Arts in Special Education-2237', updatedLeadRecord.traa_Program_of_Interest__c, 'Program of interest should match');
    }

    @IsTest
    static void onBeforeTermUpdate() {
        Lead lead = new Lead(
            LastName = 'Doe',
            FirstName = 'John',
            Company = 'Test',
            Status = 'New',
            traa_Academic_Program__c = 'Master of Education',
            traa_Area_of_Interest__c = 'Business',
            traa_Level__c = 'Certificate',
            traa_Start_Term__c = '2237',
            Email = 'test123@test.com'
        );
        insert lead;
        Test.startTest();
        Lead updateLead = getLead();
        updateLead.traa_Start_Term__c = '2243';
        update updateLead;
        Test.stopTest();
        Lead updatedLeadRecord = getLead();
        System.assertEquals('Master of Education-2243', updatedLeadRecord.traa_Program_of_Interest__c, 'Program of interest should match');
    }

    @IsTest
    static void onBeforeLevelUpdate() {
        Lead lead = new Lead(
            LastName = 'Doe',
            FirstName = 'John',
            Company = 'Test',
            Status = 'New',
            traa_Academic_Program__c = 'Master of Education',
            traa_Area_of_Interest__c = 'Business',
            traa_Level__c = 'Certificate',
            traa_Start_Term__c = '2237',
            Email = 'test123@test.com'
        );
        insert lead;
        Test.startTest();
        Lead updateLead = getLead();
        updateLead.traa_Level__c = 'Bachelor';
        update updateLead;
        Test.stopTest();
        Lead updatedLeadRecord = getLead();
        System.assertEquals('Master of Education-2237', updatedLeadRecord.traa_Program_of_Interest__c, 'Program of interest should match');
    }

    private  static Lead getLead() {
        return [SELECT Id, traa_Academic_Program__c, traa_Program_of_Interest__c, traa_Start_Term__c FROM Lead WHERE Email = 'test123@test.com' LIMIT 1];
    }
}