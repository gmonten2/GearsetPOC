/**
* @description 	Wrapper Class for Campaign Member Record operations.
*
* @author 		Traction on Demand (Traction TRAA Package)
* @date 		2020-02-26
*
*/

public class tf_CampaignMemberWrapper implements tf_TestFactory.FieldDefaults{
    
    protected Type sObjectType;
    
    public Type getObjectType() {
        return CampaignMember.class;
    }
    
    public Map<String, Object> getFieldDefaults() {
        return new Map<String, Object> {
            	'Status' => 'Sent'
                };
                    }
    
    public Map<String, Object> getRequiredFieldDefaults() {
        return new Map<String, Object> {
          
                };
                    }
}