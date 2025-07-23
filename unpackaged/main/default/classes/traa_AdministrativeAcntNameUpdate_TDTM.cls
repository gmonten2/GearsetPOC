/*
* @author          Traction on Demand (Traction TRAA Package)
* @description     Trigger to populate Company field for Admissions Prospect type Leads.
*/
global without sharing class traa_AdministrativeAcntNameUpdate_TDTM extends hed.TDTM_Runnable {
    // the main entry point for TDTM to invoke our trigger handlers.
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        hed.TDTM_Runnable.DmlWrapper dmlWrapper = new hed.TDTM_Runnable.DmlWrapper();

        if (triggerAction == hed.TDTM_Runnable.Action.BeforeInsert) {
            getAccountsAndContactIds((List<Account>) newList, null);
            
        }
        if (triggerAction == hed.TDTM_Runnable.Action.BeforeUpdate) {
            Map<Id, Account> oldMap = new Map<Id, Account>((List<Account>) oldList);
            getAccountsAndContactIds((List<Account>) newList, oldMap);

        }
        return dmlWrapper;
    }

    public void getAccountsAndContactIds(List<Account> accounts, Map<Id, Account> oldMap) {
        Id administrativeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Administrative').getRecordTypeId();
        Set<Id> contactIds = new Set<Id>();
        List<Account> accountsToUpdate = new List<Account>();
        for(Account acc : accounts) {
            if(acc.RecordTypeId == administrativeRecordTypeId) {
                if(String.isNotBlank(acc.hed__Primary_Contact__c) && (oldMap == null || isPrimaryContactChanged(acc, oldMap) || isNameChanged(acc, oldMap))) {
                    contactIds.add(acc.hed__Primary_Contact__c);
                    accountsToUpdate.add(acc);
                }
            }
        }

        if(!accountsToUpdate.isEmpty() && !contactIds.isEmpty()) {
            updateAccountName(contactIds, accountsToUpdate);
        }
    }

    public Boolean isPrimaryContactChanged(Account acc, Map<Id, Account> oldMap) {
        return (oldMap != null && acc.hed__Primary_Contact__c != oldMap.get(acc.Id).hed__Primary_Contact__c);
    }

    public Boolean isNameChanged(Account acc, Map<Id, Account> oldMap) {
        return (oldMap != null && acc.Name != oldMap.get(acc.Id).Name);
    }

    private void updateAccountName(Set<Id> contactIds, List<Account> accountsToUpdate) {

        List<traa_Custom_Auto_Number__mdt> customAutoNumber = [SELECT traa_Field_API_Name__c FROM traa_Custom_Auto_Number__mdt WHERE MasterLabel = 'Contact Account Auto Number'];
        String account_auto_num = customAutoNumber[0].traa_Field_API_Name__c;
        String query = 'SELECT Id, FirstName, LastName,' + account_auto_num + ' FROM Contact WHERE ID In : contactIds';
        List<Contact> contacts = Database.query(query);
        Map<Id, Contact> contactsMap = new Map<Id, Contact>(contacts);
        for (Account acc : accountsToUpdate) {
            if(!contactsMap.isEmpty() && contactsMap.containsKey(acc.hed__Primary_Contact__c)) {
                String name = '';
                if (String.isNotBlank(contactsMap.get(acc.hed__Primary_Contact__c).FirstName)) {
                    name += contactsMap.get(acc.hed__Primary_Contact__c).FirstName;
                }
                if (String.isNotBlank(contactsMap.get(acc.hed__Primary_Contact__c).LastName)) {
                    name += ' ' + contactsMap.get(acc.hed__Primary_Contact__c).LastName + ' ';
                }
                name += contactsMap.get(acc.hed__Primary_Contact__c).get(account_auto_num) + ' ' + traa_Constants.ADMIN_ACCOUNT_NAME;
                acc.Name = name;
            }
        }
    }
}