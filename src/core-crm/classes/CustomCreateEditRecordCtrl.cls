/**
 * @description Controller class for customCreateEditRecord LWC
 *
 * @see ../lwc/customCreateEditRecord
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA     | Change Summary                  |
      |---------------------------|-----------------------|----------|---------------------------------|
      | angelika.j.s.galang       | October 25, 2021      | DEPP-383 | Created file                    | 
      |                           |                       |          |                                 | 
*/
public with sharing class CustomCreateEditRecordCtrl {

    /**
    * @description Method for getting the metadata of given object api name set in Field Layout Setting
    * @param objApiName - API name of object passed from component
    * @return list of Field Layout Setting records
    */
    @AuraEnabled(cacheable=true)
    public static List<Field_Layout_Setting__mdt> getLayoutMapping(String objApiName){
        return [
            SELECT  MasterLabel, Left_Column_Long__c, Right_Column_Long__c, Single_Column_Long__c, Order__c,
                    Record_Type_Setting__r.Object_Type__c, Record_Type_Setting__r.Order__c,
                    Record_Type_Setting__r.Parent_Record_Type__c, Record_Type_Setting__r.MasterLabel
            FROM Field_Layout_Setting__mdt
            WHERE Record_Type_Setting__r.Object_Type__c =: objApiName
            ORDER BY Order__c ASC
        ];
    }

}