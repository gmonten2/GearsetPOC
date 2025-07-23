/*
* @author          Traction on Demand (Traction TRAA Package)
* @description     Trigger to automatically delete the administrative accounts without Contacts created out of Lead Conversion.
*/
global without sharing class traa_DeleteAdminAccsWithoutCons_TDTM extends hed.TDTM_Runnable {
    // the main entry point for TDTM to invoke our trigger handlers.
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        hed.TDTM_Runnable.DmlWrapper dmlWrapper = new hed.TDTM_Runnable.DmlWrapper();

        if (triggerAction == hed.TDTM_Runnable.Action.AfterUpdate) {
            Map<Id, Lead> oldLeadMap = new Map<Id, Lead>((List<Lead>) oldList);

            Set<Id> accIdSet = new Set<Id>();
            for (Lead objLead : (List<Lead>) newList) {
                if (oldLeadMap.containsKey(objLead.Id)) {
                    //Check if the Lead is Converted
                    String previousStatus = oldLeadMap.get(objLead.Id).Status;
                    String status = objLead.Status;
                    Boolean isConverted = objLead.IsConverted;
                    Boolean isLeadConverted = previousStatus != status && isConverted;
                    //Get Converted Account Ids
                    if (isLeadConverted && objLead.ConvertedAccountId != null) {
                        accIdSet.add(objLead.ConvertedAccountId);
                    }
                }
            }

            if (accIdSet.isEmpty()) return dmlWrapper;

            Id recordTypeIdAccAdmin = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Administrative').getRecordTypeId();
            List<Account> accList = new List<Account>();
            //Get Administrative Accounts without Contacts
            for (Account acc :[
                    SELECT Id, (SELECT Id FROM Contacts)
                    FROM Account
                    WHERE Id IN :accIdSet
                    AND RecordTypeId = :recordTypeIdAccAdmin
            ]) {
                if (acc.Contacts.size() == 0) {
                    accList.add(acc);
                }
            }

            if(accList.size() > 0)  delete accList;
        }
        return dmlWrapper;
    }
}