/**
 * Base wrapper class for SFDC record-related operations.
 *
 * @author Paulo Oliveira, Traction on Demand
 * @date 2019-10-12
 *
 * Aug/13/2019 - Paulo Oliveira, Traction on Demand - Created
 * Feb/18/2020 - Chris Shinnimin, Traction on Demand - Applied to Admissions Liftoff
 */
public abstract with sharing class tf_BaseWrapper {
    protected Type sObjectType;

    public tf_BaseWrapper(Type sObjectType) {
        this.sObjectType = sObjectType;
    }

    public Type getObjectType() {
        return this.sObjectType;
    }

    public Map<String, Object> getRequiredFieldDefaults() {
        return new Map<String, Object>();
    }
}