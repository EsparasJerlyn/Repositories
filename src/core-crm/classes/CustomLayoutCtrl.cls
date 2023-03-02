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
    public static Id getChildRecordId(
        String parentId,
        String parentField, 
        String childObjectType, 
        Map<String,String> grandChildInfo
    ){  
        Id currentRecord = queryRecord(ID, childObjectType, parentField, parentId);
        if(grandChildInfo.isEmpty()){
            return currentRecord;
        }else{
            Id parent = currentRecord;
            return queryRecord(
                ID,
                grandChildInfo.get('objectApiName'),
                grandChildInfo.get('conditionField'),
                parent
            );
        }
    }

    @AuraEnabled(cacheable=true)
    public static sObject getParentRecord(
        String parentId,
        String parentField, 
        String childObjectType, 
        String fields,
        Map<String,String> grandChildInfo
    ){  
        sObject currentRecord = queryRecordObject(fields, childObjectType, parentField, parentId);
        if(grandChildInfo.isEmpty()){
            return currentRecord;
        }else{
            Id parent = currentRecord.Id;
            return queryRecordObject(
                fields,
                grandChildInfo.get('objectApiName'),
                grandChildInfo.get('conditionField'),
                parent
            );
        }
    }
    

    /**
    * @description Method for getting the Id of an SObject
    * @param fields - fields to query
    * @param objectApiName - object to query from
    * @param conditionField - field api name for condition
    * @param conditionValue -value of condition
    * @return Id of SObject record
    */
    private static Id queryRecord(
        String fields,
        String objectApiName,
        String conditionField,
        String conditionValue
    ){
        Id record;
        List<SObject> records = Database.query(
            'SELECT ' + String.escapeSingleQuotes(fields) + 
            ' FROM ' + String.escapeSingleQuotes(objectApiName) + 
            ' WHERE ' + String.escapeSingleQuotes(conditionField) + 
            ' = \'' + String.escapeSingleQuotes(conditionValue) + 
            '\' LIMIT 1');
        if(!records.isEmpty()){
            record = (Id) records.iterator().next().get(ID);
        }

        return record;
    }

    /**
    * @description Method for getting the Id of an SObject
    * @param fields - fields to query
    * @param objectApiName - object to query from
    * @param conditionField - field api name for condition
    * @param conditionValue -value of condition
    * @return Id of SObject record
    */
    private static sObject queryRecordObject(
        String fields,
        String objectApiName,
        String conditionField,
        String conditionValue
    ){
        sObject record;
        List<SObject> records = Database.query(
            'SELECT ' + String.escapeSingleQuotes(fields) + 
            ' FROM ' + String.escapeSingleQuotes(objectApiName) + 
            ' WHERE ' + String.escapeSingleQuotes(conditionField) + 
            ' = \'' + String.escapeSingleQuotes(conditionValue) + 
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
        sObject tempObj = queryRecordObject(
            objectInfo.get('fieldApiName'),
            objectInfo.get('childObject'),
            objectInfo.get('parentField'),
            recordId
        );
        return [
            SELECT  MasterLabel, Section_Label__c, Left_Right_Column_Long__c, Left_Column_Long__c, Right_Column_Long__c, Single_Column_Long__c, Order__c
            FROM Field_Layout_Setting__mdt
            WHERE Record_Type_Setting__r.Object_Type__c =: objectInfo.get('childObject')
            AND Record_Type_Setting__r.DeveloperName =: objectInfo.get('recordType')
            AND Field_Dependency__c =: string.valueOf(tempObj.get(objectInfo.get('fieldApiName')))
            ORDER BY Order__c ASC
        ];
    }

}
