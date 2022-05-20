/**
 * @description Controller Class for getCurriculum LWC
 * 
 * @see ../lwc/getCurriculum
 * 
 * @author Accenture
 * 
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                                  |
      |---------------------------|-----------------------|----------------------|-------------------------------------------------|
      | aljohn.motas	          | November 11, 2021     | DEPP-649             | Created file                                    |
      | angelika.j.s.galang       | November 19, 2021     | DEPP-663             | Modified method to query records from 2 objects | 
 */
public with sharing class GetCurriculumCtrl {

    /**
    * @description Method for getting related Program Plan and Course records of Product Request
    * @param productRequestId - record id of Product Request
    * @param isRecTypeProgramRequest - boolen identifying if Product Request is of type Program Request
    * @return curriculumItems - custom wrapper containing list of Program Plans and Courses
    */
    @AuraEnabled(cacheable=true)    
	public static ExistingCurriculumItems getExistingCurriculumItems(Id productRequestId, Boolean isRecTypeProgramRequest){
        ExistingCurriculumItems curriculumItems = new ExistingCurriculumItems();
        
        curriculumItems.courses = [
            SELECT Id, Name, Course_Code__c, Owning_Faculty__c, Owning_Faculty__r.Name, Implementation_Year__c, IsComplete__c, RecordType.Name
            FROM hed__Course__c 
            WHERE ProductRequestID__c =: productRequestId
            ORDER BY CreatedDate DESC
        ];

        if(isRecTypeProgramRequest == true){
            curriculumItems.programPlans = [
                SELECT Id, Name, Program_Type__c, Owning_Faculty__c, Owning_Faculty__r.Name, Implementation_Year__c, IsComplete__c
                FROM hed__Program_Plan__c 
                WHERE Product_Request__c =: productRequestId
                ORDER BY CreatedDate DESC
            ];
        }

        return curriculumItems;
    }

    /**
     * @description Wrapper to contain Program Plan and Course records
     */
    public class ExistingCurriculumItems{
        @AuraEnabled 
        public List<hed__Program_Plan__c> programPlans;
        @AuraEnabled 
        public List<hed__Course__c> courses;
    }

}