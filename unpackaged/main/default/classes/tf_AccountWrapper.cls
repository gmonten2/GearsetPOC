/**
* Wrapper class for Account Record operations.
*
* @author Traction on Demand (Traction TRAA Package)
* @date 2020-02-24
*
*/

public class tf_AccountWrapper implements tf_TestFactory.FieldDefaults{
    
    protected Type sObjectType;
    
    public Type getObjectType() {
        return Account.class;
    }
    public Map<String, Object> getFieldDefaults() {
        return new Map<String, Object> {
            'Name' => tf_TestFactory.generateRandomString(5,8)
                };
                    }
    
    public Map<String, Object> getRequiredFieldDefaults() {
        return new Map<String, Object> {
            'Name' => tf_TestFactory.generateRandomString(5,8)
                };
                    }
}