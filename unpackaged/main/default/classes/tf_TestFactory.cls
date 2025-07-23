/**
 * Test Factory class for SFDC record-related operations.
 *
 * @author Paulo Oliveira, Traction on Demand
 * @date 2019-10-12
 *
 * Aug/13/2019 - Paulo Oliveira, Traction on Demand - Created
 * Feb/18/2020 - Chris Shinnimin, Traction on Demand - Applied to Admissions Liftoff
 */
@IsTest
public without sharing class tf_TestFactory {
    private static Map<String, Profile> profileMap = new Map<String, Profile>();
    private static Map<String, PermissionSet> permissionSetMap = new Map<String, PermissionSet>();
    private static Map<String, UserRole> roleMap = new Map<String, UserRole>();

    public static SObject createSObject(Type classType) {
        FieldDefaults defaults = (FieldDefaults) classType.newInstance();
        sObject sObj = Schema.getGlobalDescribe().get(defaults.getObjectType().getName()).newSObject();

        addFieldDefaults(sObj, defaults.getRequiredFieldDefaults());
        addAdditionalFieldDefaults(sObj, defaults.getFieldDefaults());

        return sObj;
    }

    public static SObject createSObject(Type classType, Boolean doInsert) {
        SObject retObject = createSObject(classType);

        if (doInsert) {
            insert retObject;
        }

        return retObject;
    }

    public static SObject createSObject(Type classType, Map<String, Object> additionalParameters, Boolean doInsert) {
        SObject retObject = createSObject(classType);

        addAdditionalFieldDefaults(retObject, additionalParameters);

        if (doInsert) {
            insert retObject;
        }

        return retObject;
    }

    public static SObject[] createSObjectList(
        Integer numberOfObjects,
        Type classType,
        Map<String, Object> additionalParameters,
        Boolean doInsert) {
        SObject[] retList = createSObjectList(numberOfObjects, classType, additionalParameters);

        if (doInsert) {
            insert retList;
        }

        return retList;
    }

    public static SObject[] createSObjectList(Integer numberOfObjects, Type classType) {
        SObject[] sObjs = new SObject[] {};
        SObject newObj;

        newObj = createSObject(classType);
        FieldDefaults defaults = (FieldDefaults) classType.newInstance();
        sObject sObj = Schema.getGlobalDescribe().get(defaults.getObjectType().getName()).newSObject();

        List<String> uniqueFields = getUpdatableNameFields(sObj);

        for (Integer i = 0; i < numberOfObjects; i++) {
            SObject clonedsobj = newObj.clone(false, true);

            if (uniqueFields.size() > 0) {
                setUniqueFields(clonedsobj, i, uniqueFields);
            }

            sObjs.add(clonedsobj);
        }

        return sObjs;
    }

    public static SObject[] createSObjectList(
        Integer numberOfObjects,
        Type classType,
        Map<String, Object> additionalParameters) {
        SObject[] sObjs = new SObject[] {};
        SObject newObj;

        newObj = createSObject(classType);
        FieldDefaults defaults = (FieldDefaults) classType.newInstance();
        sObject sObj = Schema.getGlobalDescribe().get(defaults.getObjectType().getName()).newSObject();

        addAdditionalFieldDefaults(newObj, additionalParameters);

        List<String> uniqueFields = getUpdatableNameFields(sObj);

        for (Integer i = 0; i < numberOfObjects; i++) {
            SObject clonedSObj = newObj.clone(false, true);

            if (uniqueFields.size() > 0) {
                setUniqueFields(clonedSObj, i, uniqueFields);
            }

            sObjs.add(clonedSObj);
        }

        return sObjs;
    }

    public static void setUniqueFields(SObject clonedSObj, Integer index, List<String> uniqueFields) {
        for (String uniqueField: uniqueFields) {
            if (clonedSObj.get(uniqueField) != null) {
                clonedSObj.put(uniqueField, clonedSObj.get(uniqueField) + ' ' + index);
            }
        }
    }

    public static void addFieldDefaults(SObject sObj, Map<String, Object> defaults) {
        for (String field: defaults.keySet()) {
            if (sObj.get(field) == null) {
                sObj.put(field, defaults.get(field));
            }
        }
    }

    public static void addAdditionalFieldDefaults(SObject sObj, Map<String, Object> additionalFields) {
        for (String field: additionalFields.keySet()) {
            sObj.put(field, additionalFields.get(field));
        }
    }

    public static List<String> getUpdatableNameFields(SObject sObj) {
        List<String> uniqueFields = new List<String>();
        Schema.DescribeSObjectResult objectDescribe = sObj.getSObjectType().getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap();

        for (String fieldName: fieldMap.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();

            if (fieldDescribe.isNameField() && !fieldDescribe.autoNumber) {
                uniqueFields.add(fieldDescribe.getName());
            }
        }

        return uniqueFields;
    }

    public class tf_TestFactoryException extends Exception {}

    public interface FieldDefaults {
        Type getObjectType();
        Map<String, Object> getFieldDefaults();
        Map<String, Object> getRequiredFieldDefaults();
    }

    // HELPER METHODS
    public static Profile getProfilebyName(String profileName) {
        Profile profile;

        if (profileMap.keySet().contains(profileName.toLowerCase())) {
            profile = profileMap.get(profileName.toLowerCase());
        } else {
            profile = [
                SELECT Id
                FROM Profile
                WHERE Name = :profileName
            ];

            profileMap.put(profileName.toLowerCase(), profile);
        }

        return profile;
    }

    public static PermissionSet getPermissionSetByName(String permissionSetName) {
        PermissionSet permissionSet;

        if (permissionSetMap.keySet().contains(permissionSetName.toLowerCase())) {
            permissionSet = permissionSetMap.get(permissionSetName.toLowerCase());
        } else {
            permissionSet = [
                SELECT Id
                FROM PermissionSet
                WHERE Name = :permissionSetName
            ];

            permissionSetMap.put(permissionSetName.toLowerCase(), permissionSet);
        }

        return permissionSet;
    }

    public static UserRole getRolebyName(String roleName) {
        UserRole role;

        if (roleMap.keySet().contains(roleName.toLowerCase())) {
            role = roleMap.get(roleName.toLowerCase());
        } else {
            role = [
                SELECT Id
                FROM UserRole
                WHERE Name = :roleName
            ];

            roleMap.put(roleName.toLowerCase(), role);
        }

        return role;
    }

    public static String generateRandomEmail() {
        return generateRandomString(5) + '@' + generateRandomString(5) + '.com';
    }

    public static String generateRandomString() {
        return generateRandomString(5, 15);
    }

    public static String generateRandomString(Integer characters) {
        return generateRandomString(characters, characters);
    }

    public static String generateRandomString(Integer min, Integer max) {
        final Integer length = Math.round(Math.random() * (max - min)) + min;
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';

        while (randStr.length() < length) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }

        return randStr;
    }
}