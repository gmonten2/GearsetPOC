/**
* Wrapper class for Program Enrollment Record operations.
*
* @author Sanjay Kumar Gupta, Traction on Demand
* @date 2020-02-25
*
*/

public class tf_ProgramEnrollmentWrapper implements tf_TestFactory.FieldDefaults{
    protected Type sObjectType;
    
    public Type getObjectType() {
        return hed__Program_Enrollment__c.class;
    }
    public Map<String, Object> getFieldDefaults() {
        return new Map<String, Object> {
            
                };
                    }
    
    public Map<String, Object> getRequiredFieldDefaults() {
        return new Map<String, Object> {
            
                };
                    }
}