@istest
public class OpportunityRTFAutoAssignTest {
 @testSetup
    static void setupTestData() {
        // Ensure these values match exactly with the values in Salesforce
        String validPicklistValue1 = 'Hialeah'; // Example valid value from your picklist
        String validPicklistValue2 = 'Homestead';   // Another example valid value

        // Create Users with different Home Campus and Active status
        User user1 = new User(
            FirstName = 'User',
            LastName = 'One',
            Email = 'user1@example.com',
            Username = 'user1@example.com.' + System.currentTimeMillis(),
            Alias = 'uone',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US',
            PCA_Assigned_Home_Campus__c = validPicklistValue1,
            IsActive = true
        );
        User user2 = new User(
            FirstName = 'User',
            LastName = 'Two',
            Email = 'user2@example.com',
            Username = 'user2@example.com.' + System.currentTimeMillis(),
            Alias = 'utwo',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US',
            PCA_Assigned_Home_Campus__c = validPicklistValue2,
            IsActive = true
        );
        insert new List<User>{user1, user2};

        // Create Opportunities with valid Home Campus values
        Opportunity opp1 = new Opportunity(
            Name = 'Opportunity 1',
            StageName = 'Lead',
            CloseDate = Date.today(),
            PCA_Assignment_trigger__c = true,
            Home_Campus__c = validPicklistValue1,Student_Onboarding_Type__c= 'FTIC - Direct Entry',Primary_PCA__c = user1.Id
        );
        Opportunity opp2 = new Opportunity(
            Name = 'Opportunity 2',
            StageName = 'Applicant',
            CloseDate = Date.today(),
            PCA_Assignment_trigger__c = true,
            Home_Campus__c = validPicklistValue2,Student_Onboarding_Type__c= 'FTIC - Direct Entry',Primary_PCA__c = user1.Id
        );
        insert new List<Opportunity>{opp1, opp2};
    }
@isTest
    static void updateOppCounttest() {
		List<Opportunity> oppList = [select id,Name,StageName,closeDate,PCA_Assignment_trigger__c,Home_Campus__c,Primary_PCA__c,Student_Onboarding_Type__c from opportunity];
		List<User> userList = [select id,PCA_Assigned_Home_Campus__c,IsActive from user];
		List<OpportunityRTFAutoAssign.inputs> inputList = new List<OpportunityRTFAutoAssign.inputs>();
		OpportunityRTFAutoAssign.inputs inputRec1 = new OpportunityRTFAutoAssign.inputs();
		system.debug('oppList'+oppList);
		system.debug('userList'+userList);
		inputRec1.homeCampusOpps = userList;
		inputRec1.opp = oppList[1];
		inputList.add(inputRec1);
		Test.StartTest();
       List<OpportunityRTFAutoAssign.outputs> outpulist =  OpportunityRTFAutoAssign.updateOppCount(inputList);
		Test.StopTest();
	}
}