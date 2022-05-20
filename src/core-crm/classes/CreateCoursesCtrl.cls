/**
 * @description Controller class for createCourses LWC
 *
 * @see ../lwc/createCourses
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA     | Change Summary                  |
      |---------------------------|-----------------------|----------|---------------------------------|
      | angelika.j.s.galang       | October 25, 2021      | DEPP-383 | Created file                    | 
      |                           |                       |          |                                 | 
*/
public with sharing class CreateCoursesCtrl {

    /**
    * @description Method for getting list of Courses related to Product Request
    * @param productRequestId - id of related Product Request
    * @return list of Courses
    */
    @AuraEnabled(cacheable=true)
    public static List<hed__Course__c> getCourses(Id productRequestId){
        return [
            SELECT Id, Name, RecordType.Id, RecordType.Name, Start_Date__c, End_Date__c
            FROM hed__Course__c 
            WHERE ProductRequestID__c =: productRequestId
            ORDER BY CreatedDate DESC
        ];
    }

}
