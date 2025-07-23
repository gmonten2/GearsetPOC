/**
* @description 	Wrapper Class for Lead Record operations.
*
* @author 		Traction on Demand (Traction TRAA Package)
* @date 		2020-02-26
*
*/

public class tf_LeadWrapper implements tf_TestFactory.FieldDefaults{
    
    protected Type sObjectType;
    
    public Type getObjectType() {
        return Lead.class;
    }
    public Map<String, Object> getFieldDefaults() {
        return new Map<String, Object> {
            	'FirstName' => 'Test',
                'LastName' => tf_TestFactory.generateRandomString(10),
                'Company' => 'Test Company ' + tf_TestFactory.generateRandomString(10)
                };
                    }
    
    public Map<String, Object> getRequiredFieldDefaults() {
        return new Map<String, Object> {
            'Status' => 'New'
                };
                    }
}