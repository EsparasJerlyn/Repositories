/**
 * @description Controller class for Course Detail Fields LWC
 *
 * @see ../lwc/courseDetailFields
 * 
 * @author Accenture
 *      
 * @history
 *    | Developer                 | Date                  | JIRA            | Change Summary                                         |
      |---------------------------|-----------------------|-----------------|--------------------------------------------------------|
      | angelika.j.s.galang       | December 21, 2021     | DEPP-838,1299   | Created file                                           |
      |                           |                       |                 |                                                        | 
*/
public with sharing class CourseDetailFieldsCtrl {

    /**
    * @description Method for getting the Id of related Course of Product Request
    * @param productRequestId - Id of Product Request
    * @return Id of Course
    */
    @AuraEnabled(cacheable=true)
    public static Id getCourseId(Id productRequestId){
        return [
            SELECT Id
            FROM hed__Course__c
            WHERE ProductRequestID__c =: productRequestId
            LIMIT 1
        ]?.Id;
    }

    /**
    * @description Method for getting the metadata of given object api name set in Field Layout Setting
    * @param objApiName - API name of object passed from component
    * @param rtLabel - record type label
    * @return list of Field Layout Setting records
    */
    @AuraEnabled(cacheable=true)
    public static List<Field_Layout_Setting__mdt> getLayoutMapping(String objApiName, String rtLabel){
        return [
            SELECT  MasterLabel, Left_Column_Long__c, Right_Column_Long__c, Single_Column_Long__c
            FROM Field_Layout_Setting__mdt
            WHERE Record_Type_Setting__r.Object_Type__c =: objApiName
            AND Record_Type_Setting__r.MasterLabel =: rtLabel
            AND Record_Type_Setting__r.For_OPE__c = true
            ORDER BY Order__c ASC
        ];
    }
}
