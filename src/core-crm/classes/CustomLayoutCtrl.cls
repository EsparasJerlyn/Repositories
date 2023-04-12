/**
 * @description Controller class for Custom Page and Section Layouts LWC
 *
 * @see ../lwc/customPageLayout
 * @see ../lwc/customSectionLayout
 * 
 * @author Accenture
 *      
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                                         |
      |---------------------------|-----------------------|----------------------|--------------------------------------------------------|
      | angelika.j.s.galang       | January 26, 2022      | DEPP-838,1299,1407   | Created file                                           |
      |                           |                       |                      |                                                        | 
*/
public with sharing class CustomLayoutCtrl {

    private static final String ID = 'Id';
    /**
    * @description Method for getting the Id of related child of parent record
    * @param parentId - Id of Parent
    * @param parentField - parent field api name
    * @param childObjectType - object api name of child
    * @param grandChildInfo - map containing info of grandchild
    * @return Id of Child
    */
    @AuraEnabled(cacheable=true)
    public static Id getChildRecordId(GetRecordFilter filter){  
        QueryParts q = new QueryParts();
        q.fields = ID;
        q.objectApiName = filter.childObjectType;
        q.conditionField = filter.parentField;
        q.conditionValue = filter.parentId;
        Id currentRecord = queryRecord(q);
        if(filter.grandChildInfo.isEmpty()){
            return currentRecord;
        }else{
            q.objectApiName = filter.grandChildInfo.get('objectApiName');
            q.conditionField = filter.grandChildInfo.get('conditionField');
            q.conditionValue = currentRecord;
            return queryRecord(q);
        }
    }

    @AuraEnabled(cacheable=true)
    public static sObject getParentRecord(GetRecordFilter filter){
        QueryParts q = new QueryParts();
        q.fields = filter.fields;
        q.objectApiName = filter.childObjectType;
        q.conditionField = filter.parentField;
        q.conditionValue = filter.parentId; 
        sObject currentRecord = queryRecordObject(q);
        if(filter.grandChildInfo.isEmpty()){
            return currentRecord;
        }else{
            q.objectApiName = filter.grandChildInfo.get('objectApiName');
            q.conditionField = filter.grandChildInfo.get('conditionField');
            q.conditionValue = currentRecord.Id;
            return queryRecordObject(q);
        }
    }
    

    /**
    * @description Method for getting the Id of an SObject
    * @param q - parts of the query
    * @return Id of SObject record
    */
    private static Id queryRecord(QueryParts q){
        Id record;
        List<SObject> records = Database.query(
            'SELECT ' + String.escapeSingleQuotes(q.fields) + 
            ' FROM ' + String.escapeSingleQuotes(q.objectApiName) + 
            ' WHERE ' + String.escapeSingleQuotes(q.conditionField) + 
            ' = \'' + String.escapeSingleQuotes(q.conditionValue) + 
            '\' LIMIT 1');
        if(!records.isEmpty()){
            record = (Id) records.iterator().next().get(ID);
        }

        return record;
    }

    /**
    * @description Method for getting the Id of an SObject
    * @param q - parts of the query
    * @return Id of SObject record
    */
    private static sObject queryRecordObject(QueryParts q){
        sObject record;
        List<SObject> records = Database.query(
            'SELECT ' + String.escapeSingleQuotes(q.fields) + 
            ' FROM ' + String.escapeSingleQuotes(q.objectApiName) + 
            ' WHERE ' + String.escapeSingleQuotes(q.conditionField) + 
            ' = \'' + String.escapeSingleQuotes(q.conditionValue) + 
            '\' LIMIT 1'
        );
                
        if(!records.isEmpty()){
            record = (sObject) records.iterator().next();
        }

        return record;
    }

    /**
    * @description Method for getting the metadata of given object api name set in Field Layout Setting
    * @param objApiName - API name of object passed from component
    * @param rtDevName - record type setting api name
    * @param isOpe - determines if layout is for an OPE feature
    * @return list of Field Layout Setting records
    */
    @AuraEnabled(cacheable=true)
    public static List<Field_Layout_Setting__mdt> getLayoutMapping(
        String objApiName, 
        String rtDevName, 
        Boolean isOpe
    ){
        return [
            SELECT  MasterLabel, Section_Label__c, Left_Right_Column_Long__c, Left_Column_Long__c, Right_Column_Long__c, Single_Column_Long__c, Order__c
            FROM Field_Layout_Setting__mdt
            WHERE Record_Type_Setting__r.Object_Type__c =: objApiName
            AND Record_Type_Setting__r.DeveloperName =: rtDevName
            AND Record_Type_Setting__r.For_OPE__c =: isOpe
            ORDER BY Order__c ASC
        ];
    }


    /**
    * @description Method for getting the metadata of given object api name set in Field Layout Setting with field dependency
    * @param objApiName - API name of object passed from component
    * @param label - record type setting label name
    * @param objectInfo - object info to be queried
    * @return list of Field Layout Setting records
    */
    @AuraEnabled(cacheable=true)
    public static List<Field_Layout_Setting__mdt> getLayoutMappingWithField(
        Map<String,String> objectInfo,
        String recordId
    ){
        QueryParts q = new QueryParts();
        q.fields = objectInfo.get('fieldApiName');
        q.objectApiName = objectInfo.get('childObject');
        q.conditionField = objectInfo.get('parentField');
        q.conditionValue = recordId;
        sObject tempObj = queryRecordObject(q);
        return [
            SELECT  MasterLabel, Section_Label__c, Left_Right_Column_Long__c, Left_Column_Long__c, Right_Column_Long__c, Single_Column_Long__c, Order__c
            FROM Field_Layout_Setting__mdt
            WHERE Record_Type_Setting__r.Object_Type__c =: objectInfo.get('childObject')
            AND Record_Type_Setting__r.DeveloperName =: objectInfo.get('recordType')
            AND Field_Dependency__c =: string.valueOf(tempObj.get(objectInfo.get('fieldApiName')))
            ORDER BY Order__c ASC
        ];
    }

    public class GetRecordFilter {
        @AuraEnabled public String parentId { get; set; }
        @AuraEnabled public String parentField { get; set; }
        @AuraEnabled public String childObjectType { get; set; }
        @AuraEnabled public String fields { get; set; }
        @AuraEnabled public Map<String,String> grandChildInfo { get; set; }
    }

    private class QueryParts {
        public String fields { get; set; }
        public String objectApiName { get; set; }
        public String conditionField { get; set; }
        public String conditionValue { get; set; }
    }    
}
