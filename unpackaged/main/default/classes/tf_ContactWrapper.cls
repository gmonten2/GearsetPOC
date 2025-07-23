/**
* Wrapper class for Contact Record operations.
*
* @author Traction on Demand (Traction TRAA Package)
* @date 2020-02-25
*
*/

public class tf_ContactWrapper implements tf_TestFactory.FieldDefaults{
    protected Type sObjectType;
    
    public Type getObjectType() {
        return Contact.class;
    }
    public Map<String, Object> getFieldDefaults() {
        return new Map<String, Object> {
            'FirstName' => tf_TestFactory.generateRandomString(5,8)
                };
                    }
    
    public Map<String, Object> getRequiredFieldDefaults() {
        return new Map<String, Object> {
            'LastName' => tf_TestFactory.generateRandomString(5,8)
                };
                    }
}