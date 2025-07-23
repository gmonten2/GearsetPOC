/**
* Wrapper class for Opportunity Record operations.
*
* @author Traction on Demand (Traction TRAA Package)
* @date 2020-02-25
*
*/

public class tf_OpportunityWrapper implements tf_TestFactory.FieldDefaults{
    protected Type sObjectType;
    
    public Type getObjectType() {
        return Opportunity.class;
    }
    public Map<String, Object> getFieldDefaults() {
        return new Map<String, Object> {
            'Amount' => 10000
                };
                    }
    
    public Map<String, Object> getRequiredFieldDefaults() {
        return new Map<String, Object> {
            'Name' => tf_TestFactory.generateRandomString(5,8),
                'StageName' => 'Applicant',
                'CloseDate' => System.today()
                };
                    }
}