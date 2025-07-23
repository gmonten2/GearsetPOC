/*
* @author          Traction on Demand (Traction TRAA Package)
* @description     Wrapper class for Term Record Operation
*/

public class tf_TermWrapper implements tf_TestFactory.FieldDefaults{

    protected Type sObjectType;

    public Type getObjectType() {
        return hed__Term__c.class;
    }
    public Map<String, Object> getFieldDefaults() {
        return new Map<String, Object> {

        };
    }

    public Map<String, Object> getRequiredFieldDefaults() {
        return new Map<String, Object> {
            'Name' => tf_TestFactory.generateRandomString(5,8)
        };
    }
}