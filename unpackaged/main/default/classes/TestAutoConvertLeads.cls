/*
* Class - TestAutoConvertLeads
* Description - This is the test class for AutoConvertLeads class
* Author - Swathi
* Version - 1
*/
@isTest 
public class TestAutoConvertLeads{
    //This method tests the lead conversion with a System Admin user assigned with Opportunity_Edit_key_fields permission set
    static testMethod void testConversionAsUser() {
        // This code runs as the System Administrator user
        Profile prof = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
        Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tempUser = new User(
            firstname = 'Test First Name',
            lastName = 'Test Last Name',
            email = uniqueName + '@test' + orgId + '.org',
            Username = uniqueName + '@test' + orgId + '.org',
            EmailEncodingKey = 'ISO-8859-1',
            Alias = uniqueName.substring(18, 23),
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            ProfileId = prof.Id
        );
        insert tempUser;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Opportunity_Edit_key_fields'];
        insert new PermissionSetAssignment(AssigneeId = tempUser.id, PermissionSetId = ps.Id);
        
        System.runAs(tempUser) {
            Test.startTest();    
            Lead newLeadData = new Lead();
            List<id> leadIds= New List<Id>();
            newLeadData.LastName ='Test Last Name';
            newLeadData.Company='Test Company';
            insert newLeadData; 
            system.assert(newLeadData != null, true);
            leadIds.add(newLeadData.id);
            AutoConvertLeads.LeadAssign(leadIds);
            Test.stopTest();
        }
    }
    
    //This method tests the lead conversion
    static testMethod void testConversion() {
        Test.startTest();    
        Lead newLeadData = new Lead();
        List<id> leadIds= New List<Id>();
        newLeadData.LastName ='Test Last Name';
        newLeadData.Company='Test Company';
        insert newLeadData; 
        system.assert(newLeadData != null, true);
        leadIds.add(newLeadData.id);
        AutoConvertLeads.LeadAssign(leadIds);
        Test.stopTest();
    }
}