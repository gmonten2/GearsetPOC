/*
* @author          Traction on Demand (Traction TRAA Package)
* @description     Wrapper class for Application Record Operation
*/

public class tf_ApplicationWrapper implements tf_TestFactory.FieldDefaults{
    
    protected Type sObjectType;
    
    public Type getObjectType() {
        return hed__Application__c.class;
    }
    public Map<String, Object> getFieldDefaults() {
        return new Map<String, Object> {
            'hed__Application_Status__c' => 'Submitted'
                };
                    }
    
    public Map<String, Object> getRequiredFieldDefaults() {
        return new Map<String, Object> {
            
                };
                    }
}