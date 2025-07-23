public class OpportunityRTFAutoAssign {
    @InvocableMethod
    public static List<outputs> updateOppCount(List<inputs> inputList){
        Set<Id> userIds = new Set<Id>();
        Map<Id,List<Opportunity>> userOppMap = new Map<Id,List<Opportunity>>();
        Integer oppCountval = 15000;
        List<outputs> outputInfo = new List<outputs>();
        for(inputs inVal:inputList){
            for(User u:inVal.homeCampusOpps){
                userIds.add(u.Id);
            }
        }
        
        for(opportunity oppRec:[select id,Primary_PCA__c from opportunity where Primary_PCA__c IN:userIds AND ( StageName ='Lead' OR StageName ='Applicant' OR StageName ='Enrolled-Not Paid' ) AND Student_Onboarding_Type__c = 'FTIC - Direct Entry' ]){
            if(userOppMap!=null && userOppMap.containskey(oppRec.Primary_PCA__c)){
                List<Opportunity> tempMap = userOppMap.get(oppRec.Primary_PCA__c);
                tempMap.add(oppRec);
                userOppMap.put(oppRec.Primary_PCA__c,tempMap);
            }
            else{
                userOppMap.put(oppRec.Primary_PCA__c,new List<opportunity>{oppRec});
            }
        }
        system.debug('userOppMap'+userOppMap);
        system.debug('oppCountval'+oppCountval);
        system.debug('inputList'+inputList);
        for(inputs inVal:inputList){
            for(User u:inVal.homeCampusOpps){
                if(userOppMap!=null && userOppMap.get(u.id)!=null && userOppMap.get(u.id).size() < oppCountval){
                    outputs sendVals = new outputs();
                    sendVals.oppCount = userOppMap.get(u.id).size();
                    sendVals.userRec = u;
                    outputInfo.add(sendVals);
                }
                
            }
            
        }
        return outputInfo;
    }
    public class inputs{
        @InvocableVariable public List<User> homeCampusOpps;
        @InvocableVariable public opportunity opp;
    }
    public class outputs{
        @InvocableVariable public Integer oppCount;
        @InvocableVariable public User userRec;
        
    }
}