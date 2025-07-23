/*
* Class - AutoConvertLeads
* Description - This class auto converts Lead to Contact, Account and Opportunity
* Author - Swathi
* Version - 1
* Change log - Added try-catch block - Swathi
*/
public with sharing class AutoConvertLeads {
    @InvocableMethod(label='Custom Lead Convert')
    public static void LeadAssign(List<Id> LeadIds)  
    {
        LeadStatus CLeadStatus= [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true Limit 1];
        List<Database.LeadConvert> MassLeadconvert = new List<Database.LeadConvert>();    
        for(id currentlead: LeadIds){
            Database.LeadConvert Leadconvert = new Database.LeadConvert();
            Leadconvert.setLeadId(currentlead);
            Leadconvert.setConvertedStatus(CLeadStatus.MasterLabel);
            MassLeadconvert.add(Leadconvert);    
        }
        if (!MassLeadconvert.isEmpty())
        {
            try{
                List<Database.LeadConvertResult> lcr = Database.convertLead(MassLeadconvert); 
            }
            catch(exception ex){
                system.debug('Lead conversion failed due to an exception=='+ex);
            }
        }
    } 
}