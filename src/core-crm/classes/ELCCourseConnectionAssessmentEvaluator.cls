/**
 * @description Class to be used in evaluating Course Connection Assement to contact criteria
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                              |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------|
      | eugene.andrew.abuan            | May 06, 2024          | DEPP-8487              | Created file                                                |
      | julie.jane.alegre              | May 17, 2024          | DEPP-8049              | Update contact field mapping                                |
*/
public with sharing class ELCCourseConnectionAssessmentEvaluator {
    private ELCParser elcParser;

    /**
    * @description Contructor method for ELCParser
    * @param elcParser - ELEParser instance
    * @return void 
    */
    public ELCCourseConnectionAssessmentEvaluator(ELCParser elcParser) {
        this.elcParser = elcParser;
    }

    /**
    * @description Method to evaluate the contact
    * @param contactMap - Contact Record Map
    * @return Map<Id, List<Course_Connection_Assessment__c> - grouped Contact per List of Course Connection Assessement
    */
    public Map<Id, List<Course_Connection_Assessment__c>> evaluate(Map<Id, Contact> contactMap) {  

        Map<Id, List<Course_Connection_Assessment__c>> courseConnectionAssessmentsMap;

        if (!elcParser.getELCCourseConnectionAssessmentParser().getCourseConnectionAssessmentCriteria().isEmpty()) {

            elcParser.getELCContactParser().getContactCriteria().setContactIdSet(contactMap.keySet());            
            List<Course_Connection_Assessment__c> courseConnectionAssessments = CourseConnectionAssessmentsDAO.newInstance().findByCriteria(
                                                                elcParser.getELCCourseConnectionAssessmentParser().getCourseConnectionAssessmentCriteria(),
                                                                elcParser.getELCCourseConnectionParser().getCourseConnectionCriteria(), 
                                                                elcParser.getELCProgramEnrollmentParser().getProgramEnrollmentCriteria(), 
                                                                elcParser.getELCContactParser().getContactCriteria(),
                                                                AccessLevel.SYSTEM_MODE
                                                                );
            courseConnectionAssessmentsMap = groupByContact(courseConnectionAssessments);
        }
        
        return courseConnectionAssessmentsMap;
    }


    private Map<Id, List<Course_Connection_Assessment__c>> groupByContact(List<Course_Connection_Assessment__c> courseConnectionAssessments) {
        Map<Id, List<Course_Connection_Assessment__c>> courseConnectionAssesmentByContactMap = new Map<Id, List<Course_Connection_Assessment__c>>();

        for(Course_Connection_Assessment__c courseConnectionAssessment : courseConnectionAssessments){
            if(courseConnectionAssesmentByContactMap.containsKey(courseConnectionAssessment.Contact__c)){
                courseConnectionAssesmentByContactMap.get(courseConnectionAssessment.Contact__c).add(courseConnectionAssessment);
            }else{
                List<Course_Connection_Assessment__c> courseConnectionAssessmentList = new List<Course_Connection_Assessment__c>();
                courseConnectionAssessmentList.add(courseConnectionAssessment);
                courseConnectionAssesmentByContactMap.put(courseConnectionAssessment.Contact__c, courseConnectionAssessmentList);
            }
        }
        
        return courseConnectionAssesmentByContactMap;
    }
}