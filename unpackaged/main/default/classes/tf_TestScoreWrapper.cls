/*
* @author          Traction on Demand (Traction TRAA Package)
* @description     Wrapper class for Test Score Record Operation
*/
public class tf_TestScoreWrapper implements tf_TestFactory.FieldDefaults{
    
    protected Type sObjectType;
    
    public Type getObjectType() {
        return hed__Test_Score__c.class;
    }
    public Map<String, Object> getFieldDefaults() {
        return new Map<String, Object> {
            'hed__Score__c' => 90
                };
                    }
    
    public Map<String, Object> getRequiredFieldDefaults() {
        return new Map<String, Object> {
            'hed__Subject_Area__c' => 'Reading'
                };
                    }
}