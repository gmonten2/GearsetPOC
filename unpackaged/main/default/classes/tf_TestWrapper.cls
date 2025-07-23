/*
* @author          Traction on Demand (Traction TRAA Package)
* @description     Wrapper class for Test Record Operation
*/
public class tf_TestWrapper implements tf_TestFactory.FieldDefaults{
    
    protected Type sObjectType;
    
    public Type getObjectType() {
        return hed__Test__c.class;
    }
    public Map<String, Object> getFieldDefaults() {
        return new Map<String, Object> {
            'hed__Source__c' => 'Official'
                };
                    }
    
    public Map<String, Object> getRequiredFieldDefaults() {
        return new Map<String, Object> {
            'hed__Test_Type__c' => 'GRE',
                'hed__Test_Date__c' => System.today()
                };
                    }
}