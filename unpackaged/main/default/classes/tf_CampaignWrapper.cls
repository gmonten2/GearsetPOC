/**
* @description 	Wrapper Class for Campaign Record operations.
*
* @author 		Traction on Demand (Traction TRAA Package)
* @date 		2020-02-26
*
*/

public class tf_CampaignWrapper implements tf_TestFactory.FieldDefaults{
    
    protected Type sObjectType;
    
    public Type getObjectType() {
        return Campaign.class;
    }
    
    public Map<String, Object> getFieldDefaults() {
        return new Map<String, Object> {
            	'Status' => 'In Progress',
                'IsActive' => True
                };
                    }
    
    public Map<String, Object> getRequiredFieldDefaults() {
        return new Map<String, Object> {
            'Name' => 'TestCamapign'+ tf_TestFactory.generateRandomString(10)
                };
                    }
}