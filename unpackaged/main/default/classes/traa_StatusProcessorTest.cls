@IsTest
public class traa_StatusProcessorTest {
    private static final String SA_SOURCE_STAGE = 'Admissions';
    private static final String SA_TARGET_STATUS = 'Completed';
    
    static {
        traa_StatusProcessor.rules = (List<traa_Status_Processor_Rule__mdt>) JSON.deserialize(
            JSON.serialize(new List<Map<String, String>>{
                // Standard Rules
                new Map<String, String>{
                    'Id'                     => '1',
                        'traa_Source_SObject_Type__c' => 'Opportunity',
                        'traa_Source_Field__c'        => 'StageName',
                        'traa_Source_Value__c'        => SA_SOURCE_STAGE,
                        'traa_Target_Reference__c'    => 'traa_Primary_Affiliation__r.Id',
                        'traa_Target_Field__c'        => 'hed__Status__c',
                        'traa_Target_Value__c'        => SA_TARGET_STATUS
                        }
            }),
            List<traa_Status_Processor_Rule__mdt>.class
        );
    }
    
    @isTest
    private static void testStandard() {
        
        hed__Affiliation__c affiliation = new hed__Affiliation__c();
        affiliation.hed__Status__c = 'Enrolled';
        insert affiliation;
        
        Opportunity oppt = (Opportunity)tf_TestFactory.createSObject(tf_OpportunityWrapper.class, true);
        Map<ID,Opportunity> oldMap = new Map<ID,Opportunity>([SELECT Id,StageName,RecordTypeId,traa_Primary_Affiliation__c FROM Opportunity WHERE Id =:oppt.Id]);
        oppt.StageName = SA_SOURCE_STAGE;
        oppt.traa_Primary_Affiliation__c = affiliation.Id;
        update oppt;
        
        Test.startTest();
        List<SObject> sObjects = new List<SObject>();
        sObjects.add(oppt);
        traa_StatusProcessor.execute(sObjects, oldMap);
        Test.stopTest();
        hed__Affiliation__c affl = [SELECT hed__Status__c FROM hed__Affiliation__c WHERE Id = :affiliation.Id].get(0);
        System.assertEquals(SA_TARGET_STATUS, affl.hed__Status__c);
    }
    
}