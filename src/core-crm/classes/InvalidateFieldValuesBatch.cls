/**
 * @description Batch Job for invalidating values on Sandbox refresh or by pipelines.
 * to use it, instanciate the object, then call the invalidateFieldsForObject method passing as 1st argument the sObject API name
 * where the fields reside, and then, a set with the api name of all the fields.
 * it invalidates ONLY EMAIL AND PHONE fields.
 *
 *
 * @author Marcelo Marsson
 */
public with sharing class InvalidateFieldValuesBatch implements Database.Batchable<sObject>, Database.Stateful{
    public static final String PHONE_NUMBER = '\'61491571266\'';
    private String query = '';
    private AnObject aObject = new AnObject();
    private Boolean shouldInvalidateMCSync;
    
    /**
     * @description invalidateFieldsForObject
     * @param anObject - sObject API Name
     * @param allFields - Set with api name of all the fields that will be invalidated.
     */
    public void invalidateFieldsForObject(String anObject, Set<String> allFields, Boolean shouldInvalidateMC){
        this.shouldInvalidateMCSync = shouldInvalidateMC;
        Schema.DescribeSObjectResult aObjectDescribe;
        try{
            aObjectDescribe = Schema.describeSObjects(new List<String>{ AnObject }, SObjectDescribeOptions.DEFERRED)[0];
            aObject.name = aObjectDescribe.getName();
        } catch (Exception e){
            throw new InvalidateException('sObject requested does not exist or user has no access to it');
        }
        Map<String, Schema.SObjectField> fieldMap = aObjectDescribe.fields.getMap();

        for (String field : allFields){
            if (!fieldMap.containsKey(field)){
                throw new InvalidateException(String.format('Field {0} does not exist for {1} sObject', new List<String>{ field, anObject }));
            }
            aObject.fields.add(new AnField(fieldMap.get(field)));
        }
        AnField anF = aObject.fields[0];
        this.generateQuery();
        Database.executeBatch(this);
    }

    /**
     * @description generateQuery
     * private method thatgenerates the querylocator for the batch job
     */
    private void generateQuery(){
        String fieldsWithComma = '';
        String filters = '';

        for (AnField field : aObject.fields){
            fieldsWithComma = fieldsWithComma + field.aname + ',';
            filters = filters + field.filter + ' OR ';
        }

        fieldsWithComma = fieldsWithComma.removeEnd(',');
        filters = filters.removeEnd(' OR ');
        this.query = String.format('SELECT {0} FROM {1} WHERE {2}', new List<String>{ fieldsWithComma, aObject.name, filters });
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<SObject> objList){
        for (SObject obj : objList){

            for (anField aField : aObject.fields){
                if (!String.isEmpty(((String) obj.get(aField.aname))) && aField.atype == 'EMAIL' && !((String) obj.get(aField.aname)).endsWith('.invalid')){
                    obj.put(aField.aname, obj.get(aField.aname) + '.invalid');
                }
                if (!String.isEmpty(((String) obj.get(aField.aname))) && aField.atype == 'PHONE' && ((String) obj.get(aField.aname)) != '61491571266'){
                    obj.put(aField.aname, '61491571266');
                }
            }
        }
        update objList;
    }

    public void finish(Database.BatchableContext context){
        if (this.shouldInvalidateMCSync == true){
            RemoveMarketingCloudFlag remover = new RemoveMarketingCloudFlag();
            remover.invalidateFieldsForObject(aObject.name);
        }
    }

    /**
     * @description
     * Inner Class that represents the object that has the fields that will be invalidated
     */
    Class AnObject{
        public String name;
        public List<AnField> fields;

        public AnObject(){
            this.fields = new List<AnField>();
        }

    }

    /**
     * @description
     * Inner Class that represents the fields that will be invalidated
     */
    Class AnField{
        String atype;
        String aname;
        String filter;
        public AnField(Schema.SObjectField field){
            this.atype = field.getDescribe(FieldDescribeOptions.DEFAULT).getType().name();
            this.aname = field.getDescribe(FieldDescribeOptions.DEFAULT).getName();
            validateField(this.atype);
        }

        /**
         * @description validateField
         * @param fieldType - validates the feild type and adds a filter string for future generation of SOQL Query
         */
        private void validateField(String fieldType){
            if (fieldType == 'EMAIL'){
                this.filter = String.format('({0}!= null AND (NOT {0} LIKE \'%{1}\'))', new List<String>{ aname, '.invalid' });
                return;
            }

            if (fieldType == 'PHONE'){
                this.filter = String.format('({0} != null AND {0} != {1})', new List<String>{ aname, InvalidateFieldValuesBatch.PHONE_NUMBER });
                return;
            }

            throw new InvalidateException('FieldTypes for objects MUST be either Phone or Email.');
        }

    }

    Class InvalidateException extends Exception{
       
    }

}