/**
 * @description Class to be used in evaluating Course Connection Assement to contact criteria
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                              |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------|
      | eugene.andrew.abuan            | May 06, 2024          | DEPP-8487              | Created file                                                |
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
            // if none of the child or grand child criteria defined, fire query and inherit parent / grand parent criteria
            //elcParser.getContactCriteria().contactIdSet.addAll(contactMap.keySet());

            elcParser.getELCContactParser().getContactCriteria().setContactIdSet(contactMap.keySet());            
            //add contact id set into soql
            List<Course_Connection_Assessment__c> courseConnectionAssessments = CourseConnectionAssessmentsDAO.newInstance().findByCriteria(
                                                                elcParser.getELCCourseConnectionAssessmentParser().getCourseConnectionAssessmentCriteria(),
                                                                elcParser.getELCCourseConnectionParser().getCourseConnectionCriteria(), 
                                                                elcParser.getELCProgramEnrollmentParser().getProgramEnrollmentCriteria(), 
                                                                elcParser.getELCContactParser().getContactCriteria()
                                                                );
            courseConnectionAssessmentsMap = groupByContact(courseConnectionAssessments);
        }
        
        // if any of the child or grandchild criteria defined, only run the query in the child or grandchild
        return courseConnectionAssessmentsMap;
    }


    private Map<Id, List<Course_Connection_Assessment__c>> groupByContact(List<Course_Connection_Assessment__c> courseConnectionAssessments) {
        Map<Id, List<Course_Connection_Assessment__c>> courseConnectionAssesmentByContactMap = new Map<Id, List<Course_Connection_Assessment__c>>();

        for(Course_Connection_Assessment__c courseConnectionAssessment : courseConnectionAssessments){
            if(courseConnectionAssesmentByContactMap.containsKey(courseConnectionAssessment.Course_Connection__r.hed__Program_Enrollment__r.hed__Contact__c)){
                courseConnectionAssesmentByContactMap.get(courseConnectionAssessment.Course_Connection__r.hed__Program_Enrollment__r.hed__Contact__c).add(courseConnectionAssessment);
            }else{
                List<Course_Connection_Assessment__c> courseConnectionAssessmentList = new List<Course_Connection_Assessment__c>();
                courseConnectionAssessmentList.add(courseConnectionAssessment);
                courseConnectionAssesmentByContactMap.put(courseConnectionAssessment.Course_Connection__r.hed__Program_Enrollment__r.hed__Contact__c, courseConnectionAssessmentList);
            } // courseConnectionAssessment.Course_Connection__r.hed__Contact__c -- scenario??
        }
        
        return courseConnectionAssesmentByContactMap;
    }
}