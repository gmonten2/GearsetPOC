public class traa_StatusProcessor {
	private static final String RECORD_TYPE_ID = 'RecordTypeId';

    // Status Processor rules
    @testVisible
    private static List<traa_Status_Processor_Rule__mdt> rules;

    // Cache of Record Types
    private static Map<Id, RecordType> recordTypeMap;

    // Cache to optimize 'describe' calls
    private static DescribeCache describeCache = new DescribeCache();

    // List of source/rule combinations that have already been processed. Use to avoid circular dependencies.
    private static Set<String> processedRules;

    static {
        recordTypeMap = new Map<Id, RecordType>([SELECT Id, DeveloperName FROM RecordType]);
        processedRules = new Set<String>();
    }

    /**
     * @description Trigger entry-point for AFTER INSERT
     *
     * @param newRecords New records
     */
    public static void execute(List<SObject> newRecords) {
        execute(newRecords, new Map<Id, SObject>());
    }

    /**
     * @description Trigger entry-point for AFTER INSERT/UPDATE/UNDELETE
     *
     * @param newRecords   New records
     * @param oldRecordMap Old record map from trigger context
     */
    public static void execute(List<SObject> newRecords, Map<Id, SObject> oldRecordMap) {
        Map<Id, SObject> newTargets = ((newRecords == null) ? new Map<Id, SObject>() : new Map<Id, SObject>(newRecords));
        Map<Id, SObject> oldTargets = ((oldRecordMap == null) ? new Map<Id, SObject>() : new Map<Id, SObject>(oldRecordMap));
        Map<Id, SObject> targets = new Map<Id, SObject>();

        SOQLCache soqlCache = new SOQLCache();
        NestedMap ruleMap = loadRules();
		//System.debug('Rule map : '+ruleMap);
        // Re-evaluate changes until there's nothing left to process
        do {
            newTargets = process(ruleMap, soqlCache, newTargets.values(), oldTargets);
            for(Id targetId : targets.keySet()) {
                oldTargets.put(targetId, (SObject) targets.get(targetId));
            }
            //oldRecordMap.putAll(targets);
            targets.putAll(newTargets);
            
        } while (newTargets.size() != 0);

        // Update targets
       // system.debug('@@ Sobject Record to Update >> ' + targets.values());
        update targets.values();
    }

    /**
     * @description Process records using the specified set of rules.
     *
     * @param ruleMap      Nested map of status processor rules
     * @param soqlCache    Shared SQL Cache
     * @param newRecords   New records
     * @param oldRecordMap Old record map from trigger context
     *
     * @return Map<Id, SObject> Map of processed targets to update
     */
    public static Map<Id, SObject> process(
        NestedMap ruleMap,
        SOQLCache soqlCache,
        List<SObject> newRecords,
        Map<Id, SObject> oldRecordMap
    ) {
        Map<Id, SObject> recordMap = new Map<Id, SObject>(newRecords);

        // Identify 'valid rules' (i.e. those that should apply to the records in their current state)
        Map<Id, List<traa_Status_Processor_Rule__mdt>> validRuleMap = new Map<Id, List<traa_Status_Processor_Rule__mdt>>();

        // STEP 1: Collect valid rules for the collection of records based on rule source criteria
        for (SObject record : newRecords) {
            SObject oldRecord = oldRecordMap.get(record.Id);
            SObjectType sObjectType = record.getSObjectType();

            // Retrieve list of valid rules for this combination of SObject Type and Record Type
            String recordTypeDeveloperName;
            String sObjectTypeName = sObjectType.getDescribe().getName();

            if (describeCache.getFieldMap(sObjectType).containsKey(RECORD_TYPE_ID) && record.get(RECORD_TYPE_ID) != null) {
                Id recordTypeId = (Id) record.get(RECORD_TYPE_ID);
                recordTypeDeveloperName = String.valueOf(recordTypeMap.get(recordTypeId).DeveloperName);
            }
			//System.debug(sObjectTypeName+' < Type Name : DeveloperName > '+recordTypeDeveloperName);
            List<traa_Status_Processor_Rule__mdt> relevantRules = ruleMap.get(new List<String>{
                sObjectTypeName, recordTypeDeveloperName
            });
            
            List<traa_Status_Processor_Rule__mdt> activeRules = new List<traa_Status_Processor_Rule__mdt>();
           // System.debug('relevantRules size: '+relevantRules.size());
            for (traa_Status_Processor_Rule__mdt rule : relevantRules) {
              //  System.debug(  'rule.traa_Source_Value__c=='+rule.traa_Source_Value__c + '  record.get(rule.traa_Source_Field__c)='+record.get(rule.traa_Source_Field__c));
                if ((oldRecord == null || ((String.valueOf(oldRecord.get(rule.traa_Source_Field__c)) != rule.traa_Source_Value__c) || rule.traa_Override_source_condition__c)) &&
                    describeCache.getFieldMap(record.getSObjectType()).containsKey(rule.traa_Source_Field__c) &&
                    String.valueOf(record.get(rule.traa_Source_Field__c)) == rule.traa_Source_Value__c
                    ) {
                 	 activeRules.add(rule);
                }
            }

            validRuleMap.put(record.Id, activeRules);
        }

        // STEP 2: Build caches to optimize SOQL
        prepareCache(validRuleMap, soqlCache, recordMap);
       // STEP 3: Process rules
        Map<Id, SObject> targets = new Map<Id, SObject>();
        for (Id recordId : validRuleMap.keySet()) {
            List<traa_Status_Processor_Rule__mdt> rules = validRuleMap.get(recordId);
            SObject source = recordMap.get(recordId);
			//System.debug('Process rules Source Value : '+source);
            // Process rules
            for (traa_Status_Processor_Rule__mdt rule : rules) {
                processRule(soqlCache, rule, source, targets);
            }
        }

        return targets;
    }

    /**
     * @description Before processing the rules, make the SOQL Cache aware of any data we will need.
     *
     * @param validRuleMap Map of valid status processor rules for the provided record set
     * @param soqlCache    Shared SQL Cache
     * @param recordMap    New record map
     */
    private static void prepareCache(
        Map<Id, List<traa_Status_Processor_Rule__mdt>> validRuleMap,
        SOQLCache soqlCache,
        Map<Id, SObject> recordMap
    ) {
        // Add Target Reference and Record Type ID to the SOQL Cache
        for (Id recordId : validRuleMap.keySet()) {
            for (traa_Status_Processor_Rule__mdt rule : validRuleMap.get(recordId)) {
                if(rule.traa_Target_Reference__c.toUpperCase()=='ID'){
                    soqlCache.add(recordId, RECORD_TYPE_ID);
                }
                else
                {
                    soqlCache.add(recordId, rule.traa_Target_Reference__c);
                }
                //Modified for RecordType Error when Target Object has no Recordtypes associated with it
                String sourceObject = recordId.getSobjectType().getDescribe().getName();
                List<String> fieldPath = rule.traa_Target_Reference__c.split('\\.');
                fieldPath.remove(fieldPath.size() - 1);
                Boolean containsRecordType = false;
                while (fieldPath.size() > 0) {
                    String targetRefItem = fieldPath.get(0).endsWith('__r') ? fieldPath.get(0).replace('__r', '__c') : fieldPath.get(0);
                    List<Schema.sObjectType> schmeaSobjectTypeList = Schema.getGlobalDescribe().get(sourceObject).getDescribe().fields.getMap().get(targetRefItem).getDescribe().getReferenceTo();
                    if(schmeaSobjectTypeList.isEmpty()) break;
                    
                    sourceObject = schmeaSobjectTypeList[0].getDescribe().getName();
                    containsRecordType = Schema.getGlobalDescribe().get(sourceObject).getDescribe().fields.getMap().containsKey(RECORD_TYPE_ID);
                    fieldPath.remove(0);
                } 
                
                String recordTypeId = RECORD_TYPE_ID;
                if (rule.traa_Target_Reference__c.lastIndexOf('.') >= 0 && containsRecordType) {
                    recordTypeId = rule.traa_Target_Reference__c.substringBeforeLast('.') + '.' + recordTypeId;
                    soqlCache.add(recordId, recordTypeId);
                }
                
                if(Schema.getGlobalDescribe().get(recordId.getSobjectType().getDescribe().getName()).getDescribe().fields.getMap().containsKey(RECORD_TYPE_ID) ){
                    soqlCache.add(recordId, RECORD_TYPE_ID);
                }
                
            }
        }
        //Modification Ends
        
        // Pre-process rules to add Target Record Type ID to the SOQL Cache. We need to know the SObject Type of the target
        for (Id recordId : validRuleMap.keySet()) {
            List<traa_Status_Processor_Rule__mdt> rules = validRuleMap.get(recordId);
            SObject source = recordMap.get(recordId);

            Set<Id> targetsWithRecordTypes = new Set<Id>();

            for (traa_Status_Processor_Rule__mdt rule : rules) {
                for (Object value : soqlCache.get(source.Id, rule.traa_Target_Reference__c).values()) {
                    if (value instanceof Id && describeCache.getFieldMap(((Id) value).getSobjectType()).containsKey(RECORD_TYPE_ID)) {
                        targetsWithRecordTypes.add((Id) value);
                    }
                }
            }
            for(Id target : targetsWithRecordTypes) {
                soqlCache.add(target, RECORD_TYPE_ID, true);
            }
        }

        soqlCache.refresh();
    }

    /**
     * Process a single status processor rule with a single source object.
     *
     * @param rule    Status Processor rule to process
     * @param source  Source record to process
     * @param targets Targets to update. This Map is shared across all calls to this method.
     */
    private static void processRule(SOQLCache soqlCache, traa_Status_Processor_Rule__mdt rule, SObject source, Map<Id, SObject> targets) {
        SObjectType sObjectType = source.getSObjectType();
        List<SObject> result = new List<SObject>();
        List<String> path = rule.traa_Target_Reference__c.split('\\.');

        Set<Id> targetIds = new Set<Id>();

        for (Object value : soqlCache.get(source.Id, rule.traa_Target_Reference__c).values()) {
         //   System.debug('Inside If Check : '+value);
            if (value instanceof Id) {
                Id targetId = (Id) value;
                Id targetRecordTypeId = (Id) soqlCache.get(targetId, RECORD_TYPE_ID).values().get(0);
				//System.debug('Inside If Check Targets : '+targetId);
                // Only process this target under one of the following conditions:
                // - The Target SObject type has no Record Type ID field
                // - A Target Record Type is not specified on the rule
                // - The Target SObject Record Type matches the Record Type on the rule
                if (
                    !describeCache.getFieldMap(targetId.getSobjectType()).containsKey(RECORD_TYPE_ID) ||
                    String.isBlank(rule.traa_Target_Record_Type__c) ||
                    (
                        targetRecordTypeId != null &&
                        rule.traa_Target_Record_Type__c == recordTypeMap.get(targetRecordTypeId).DeveloperName
                    )
                ) {
                    //System.debug('Processing target ' + targetId + ' from source ' + source.Id + ' with rule ' + rule.Id);
                    //System.debug(rule.traa_Source_SObject_Type__c + '[' +  rule.traa_Source_Record_Type__c +']');
                    targetIds.add(targetId);
                }
            }
        }

        // Prevent circular references:
        // Store a composite of the rule ID and the target ID to ensure we don't reprocess the same combination.
        String targetToken = rule.Id + '_' + source.Id;
        //System.debug('Target Token : '+targetToken);
        //System.debug('Target Ids : '+targetIds);
        if (targetIds.isEmpty() || processedRules.contains(targetToken)) {
            return;
        }

        // Once the Target SObject Ids have been identified, update them
        for (Id targetId : targetIds) {
            SObject target;

            // If we have pending updates for this target, reference the same object instance.
            if (targets.containsKey(targetId)) {
                target = targets.get(targetId);
            } else {
                target = targetId.getSobjectType().newSObject(targetId);

                // If the Target SObject Type has a Record Type Id field, set it to help with later reevaluation.
                // This data should have been cached as part of the 'prepareCache' method.
                if (describeCache.getFieldMap(targetId.getSobjectType()).containsKey(RECORD_TYPE_ID)) {
                    target.put(RECORD_TYPE_ID, soqlCache.get(targetId, RECORD_TYPE_ID).get(targetId));
                }
            }

            // Set the new target value
            target.put(rule.traa_Target_Field__c, rule.traa_Target_Value__c);

            targets.put(target.Id, target);
        }

        processedRules.add(targetToken);
    }

    /**
     * @description Load Status Processor rules
     *
     * @return NestedMap Map of Status Processor rules keyed on Object and Record type
     */
    private static NestedMap loadRules() {
        if (rules == null) {
            rules = [
                SELECT Id, Label,
                    traa_Source_SObject_Type__c,
                    traa_Source_Record_Type__c,
                    traa_Source_Field__c,
                    traa_Source_Value__c,
                    traa_Target_Reference__c,
                    traa_Target_Record_Type__c,
                    traa_Target_Field__c,
                    traa_Target_Value__c, 
                	traa_Override_source_condition__c
                FROM traa_Status_Processor_Rule__mdt
            ];
        }

        return new NestedMap(new List<String>{
            'traa_Source_SObject_Type__c', 'traa_Source_Record_Type__c'
        }, false, rules);
    }


    /**
     * @description Cache describe calls for optimization
     * @date        2018-02-16
     * @author      Chris Turner, Traction on Demand
     */
    public class DescribeCache {
        private Map<SObjectType, DescribeSObjectResult> cachedDescribes;
        private Map<SObjectType, Map<String, SObjectField>> cachedFields;
        private Map<SObjectType, Map<String, SObjectType>> cachedRelationships;

        public DescribeCache() {
            this.cachedDescribes = new Map<SObjectType, DescribeSObjectResult>();
            this.cachedFields = new Map<SObjectType, Map<String, SObjectField>>();
            this.cachedRelationships = new Map<SObjectType, Map<String, SObjectType>>();
        }

        public Map<String, SObjectField> getFieldMap(SObjectType sObjectType) {
            if (!this.cachedFields.containsKey(sObjectType)) {
                this.cachedFields.put(sObjectType, sObjectType.getDescribe().fields.getMap());
            }
            return this.cachedFields.get(sObjectType);
        }

        public Map<String, SObjectType> getRelationshipMap(SObjectType sObjectType) {
            if (!this.cachedRelationships.containsKey(sObjectType)) {
                Map<String, SObjectType> relationshipMap = new Map<String, SObjectType>();
                for (ChildRelationship cr : this.getDescribe(sObjectType).getChildRelationships()) {
                    relationshipMap.put(cr.getRelationshipName(), cr.getChildSObject());
                }
                //System.debug('Inside relationshipMap : '+sObjectType);
                this.cachedRelationships.put(sObjectType, relationshipMap);
            }
            return this.cachedRelationships.get(sObjectType);
        }

        public DescribeSObjectResult getDescribe(SObjectType sObjectType) {
            if (!this.cachedDescribes.containsKey(sObjectType)) {
                this.cachedDescribes.put(sObjectType, sObjectType.getDescribe());
            }
            return this.cachedDescribes.get(sObjectType);
        }
    }


    /**
     * @description SOQL Cache for optimizing and caching requests for
     *              Also works with child relationship paths e.g. 'QuoteLineItems.Account.Name'
     *
     *              Could be improved by setting 'dirty' indicator per SObject Type?
     *
     * @date        2018-02-16
     * @author      Chris Turner, Traction on Demand
     */
    public class SOQLCache {
        private Boolean dirty;
        private Map<SObjectType, Set<String>> fieldCache;
        private Map<SObjectType, Map<String, Set<String>>> subFieldCache;
        private Map<SObjectType, Set<Id>> idCache;
        private Map<Id, SObject> resultCache;
        public Integer executions { get; private set; }

        public SOQLCache() {
            this.dirty = false;
            this.idCache = new Map<SObjectType, Set<Id>>();
            this.fieldCache = new Map<SObjectType, Set<String>>();
            this.subFieldCache = new Map<SObjectType, Map<String, Set<String>>>();
            this.resultCache = new Map<Id, SObject>();
            this.executions = 0;
        }

        /**
         * @description Add a new SObject ID and field path to the cache. This will invalidate _ALL_ existing caches.
         *
         * @param sObjectId SObject ID to cache
         * @param fieldPath Path to data e.g. 'QuoteLineItems.Product2.Name', 'Phone', 'Account.Id'
         */
        public void add(Id sObjectId, String fieldPath) {
            this.add(sObjectId, fieldPath, false);
        }

        public void add(Id sObjectId, String fieldPath, Boolean suppressRefresh) {
            SObjectType sObjectType = sObjectId.getSobjectType();
            
            if (!this.idCache.containsKey(sObjectType)) {
                this.idCache.put(sObjectType, new Set<Id>());
            }

            if (!this.fieldCache.containsKey(sObjectType)) {
                this.fieldCache.put(sObjectType, new Set<String>{'Id'});
            }

            if (!this.subFieldCache.containsKey(sObjectType)) {
                this.subFieldCache.put(sObjectType, new Map<String, Set<String>>());
            }

            Set<Id> idCache = this.idCache.get(sObjectType);
            Set<String> sObjectFieldCache = this.fieldCache.get(sObjectType);
            Map<String, Set<String>> sObjectSubFieldCache = this.subFieldCache.get(sObjectType);
			
            
            List<String> pathNodes = fieldPath.split('\\.');
            String node = pathNodes.remove(0);
            SObjectType nodeSObjectType = describeCache.getRelationshipMap(sObjectType).get(node);
            
            idCache.add(sObjectId);
            String lookupField = node.endsWith('__r') ? node.replace('__r', '__c') : node + 'Id';

            if (describeCache.getRelationshipMap(sObjectType).containsKey(node)) {
                if (!sObjectSubFieldCache.containsKey(node)) {
                    sObjectSubFieldCache.put(node, new Set<String>{'Id'});
                }
                //Added to check whether contains pathNode or not
                String tempPathNode = String.join(pathNodes, '.');
                
                if( nodeSObjectType != NULL && describeCache.getFieldMap(nodeSObjectType).containsKey(tempPathNode)) {
                    sObjectSubFieldCache.get(node).add(tempPathNode);
                }
                
            } else if (describeCache.getFieldMap(sObjectType).containsKey(node) || describeCache.getFieldMap(sObjectType).containsKey(lookupField)) {
                sObjectFieldCache.add(fieldPath);
                //System.debug(sObjectFieldCache);
            }

            this.dirty = !suppressRefresh;
        }

        /**
         * @description For the specified SObject ID, retrieve the value by field path
         *
         * @param sObjectId SObject ID to query
         * @param fieldPath Path to data e.g. 'QuoteLineItems.Product2.Name', 'Phone', 'Account.Id'
         *
         * @return Map<Id, Object> Result map, keyed on
         */
        public Map<Id, Object> get(ID sObjectId, String fieldPath) {
            //System.debug('FieldPath : '+fieldPath);
            if (this.dirty) {
                this.refresh();
            }
            SObject record = this.resultCache.get(sObjectId);
            List<String> pathNodes = fieldPath.split('\\.');

            //System.debug('Result for ' + sObjectId + ' (' + describeCache.getDescribe(sObjectId.getSobjectType()).getName() + ') at ' + fieldPath);
            Object value = this.getValue(record, pathNodes);
            //System.debug(value);

            Map<Id, Object> result;
            if (value instanceof Map<Id, Object>) {
                result = (Map<Id, Object>) value;
            } else {
                result = new Map<Id, Object>();
                result.put(sObjectId, value);
            }

            return result;
        }

        /**
         * @description Returns a value from an SObject or its children by path
         *
         * @param record SObject to interrogate
         * @param path   Path to query
         *
         * @return Object May return an atomic value or a Map of values depending on the cardinality of the target
         */
        private Object getValue(SObject record, List<String> path) {
            if (record == null) {
                return null;
            }

            List<String> localPath = path.clone();
            String node = localPath.remove(0);
            SObjectType sObjectType = record.getSObjectType();
            String lookupField = node.endsWith('__r') ? node.replace('__r', '__c') : node + 'Id';
            //System.debug(sObjectType+' : SObjectType<<>>Node : '+node);
            if (describeCache.getRelationshipMap(sObjectType).containsKey(node)) {
                Map<Id, Object> resultMap = new Map<Id, Object>();
                for (SObject result : ((SObject) record).getSObjects(node)) {
                    resultMap.put(result.Id, this.getValue(result, localPath));
                }
                return resultMap;
            } else if (describeCache.getFieldMap(sObjectType).containsKey(node)) {
                return ((SObject) record).get(node);
            } else if (describeCache.getFieldMap(sObjectType).containsKey(lookupField)) {
                return this.getValue((SObject) record.getSObject(node), localPath);
            }

            return null;
        }

        /**
         * @description Refresh the cache
         */
        public void refresh() {
            Map<SObjectType, String> queries = this.query();

            for (SObjectType sObjectType : queries.keySet()) {
                Set<Id> idSet = this.idCache.get(sObjectType);
                String query = queries.get(sObjectType) + ' WHERE Id IN :idSet';
                //System.debug('Query : '+query);
                List<SObject> results = Database.query(query);
                for (SObject result : results) {
                    resultCache.put(result.Id, result);
                    // IMPROVEMENT: It would be nice if we could directly access child records from the cache by ID
                    // rather than having to use parent ID + path.
                }
            }
            this.dirty = false;
            this.executions++;
        }

        /**
         * @description Generate SOQL queries for each SObject type added to the cache.
         *
         * @return Map<SObjectType, String> Map of SOQL query Strings by SObject Type
         */
        private Map<SObjectType, String> query() {
            Map<SObjectType, String> queries = new Map<SObjectType, String>();
            for (SObjectType sObjectType : this.fieldCache.keySet()) {
                List<String> subQueries = new List<String>();
                Map<String, Set<String>> sObjectSubFieldCache = this.subFieldCache.get(sObjectType);
				//System.debug('###' + sObjectSubFieldCache);
                // Build nested queries for any paths that point to child records
                for (String relationship : sObjectSubFieldCache.keySet()) {
                    subQueries.add(String.join(new List<String>{
                        '(',
                        'SELECT',
                        String.join(new List<String>(sObjectSubFieldCache.get(relationship)), ', '),
                        'FROM',
                        relationship,
                        ')'
                    }, ' '));
                }

                // Combine 'local' field names and nested queries
                List<String> tmp = new List<String>();
                tmp.addAll(fieldCache.get(sObjectType));
                tmp.addAll(subQueries);

                // Build 'final' query for SObject, encapsulating 'local' fields as well as fields on related records
                queries.put(sObjectType, String.join(new List<String>{
                    'SELECT',
                    String.join(tmp, ', '),
                    'FROM',
                    sObjectType.getDescribe().getName()
                }, ' '));
            }

            return queries;
        }
    }


    /**
     * @description Nested Map implementation to get/put SObjects using composite keys
     * @date        2018-02-16
     * @author      Chris Turner, Traction on Demand
     */
    class NestedMap {
        public Map<String, NestedMap> children { get; private set; }
        public List<SObject> values { get; private set; }
        public Boolean exactMatch { get; private set; }
        public String currentPath { get; private set; }
        public List<String> childPath { get; private set; }

        public NestedMap(List<String> path, Boolean exactMatch) {
            this.children = new Map<String, NestedMap>();
            this.exactMatch = exactMatch;
            this.childPath = path.clone();
            this.currentPath = this.childPath.size() > 0 ? this.childPath.remove(0) : null;
            this.values = new List<SObject>();
        }

        public NestedMap(List<String> path, Boolean exactMatch, List<SObject> records) {
            this(path, exactMatch);
            this.add(records);
        }

        public void add(List<SObject> records) {
            if (records != null && !records.isEmpty()) {
                for (SObject record : records) {
                    this.add(record);
                }
            }
        }

        public void add(SObject record) {
            if (record == null) {
                return;
            } else if (this.isLeaf()) {
                this.values.add(record);
            } else {
                final String recordKey = String.valueOf(record.get(this.currentPath));
                if (String.isBlank(recordKey)) {
                    this.values.add(record);
                } else {
                    if (!this.children.containsKey(recordKey)) {
                        this.children.put(recordKey, new NestedMap(this.childPath, this.exactMatch));
                    }
                    this.children.get(recordKey).add(record);
                }
            }
        }

        public List<SObject> get(List<String> keys) {
            List<SObject> result = new List<SObject>();
            List<String> path = keys.clone();
            final String recordKey = path.size() > 0 ? String.valueOf(path.remove(0)) : null;

            if (this.isLeaf()) {
                result.addAll(this.values);
            } else if (this.children.containsKey(recordKey)) {
                result.addAll(this.children.get(recordKey).get(path));
            }

            // If no results found and fallback is enabled, find the deepest fallback as we unwind
            if (result.isEmpty() && !this.exactMatch && this.values.size() > 0) {
                result.addAll(this.values);
            }

            return result;
        }

        public Boolean isLeaf() {
            return String.isBlank(this.currentPath);
        }

        public void debug() {
            debug('ROOT', 0);
        }

        private void debug(String key, Integer depth) {
            //System.debug('  '.repeat(depth) + this.currentPath + '(' + key + ')[' + this.values.size() + ']');
            for (String childKey : this.children.keySet()) {
                this.children.get(childKey).debug(childKey, depth + 1);
            }
        }
    }

}