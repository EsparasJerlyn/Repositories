/**
 * @description Class to be used in evaluating Course Connection to contact criteria
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                              |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------|
      | eugene.andrew.abuan            | May 06, 2024          | DEPP-8487              | Created file                                                |
*/
public with sharing class ELCCourseEnrollmentEvaluator {
    private ELCParser elcParser;

    /**
    * @description Contructor method for ELCParser
    * @param elcParser - ELEParser instance
    * @return void 
    */
    public ELCCourseEnrollmentEvaluator(ELCParser elcParser) {
        this.elcParser = elcParser;
    }

    /**
    * @description Method to evaluate the contact
    * @param contactMap - Contact Record Map
    * @return Map<Id, List<Course_Connection_Assessment__c> - grouped Contact per List of Course Connection
    * @return null - when query is not executed
    */
    public Map<Id, List<hed__Course_Enrollment__c>> evaluate(Map<Id, Contact> contactMap) {  
        Map<Id, List<hed__Course_Enrollment__c>> courseConnectionByContactMap;
			
        if(!elcParser.getELCCourseConnectionParser().getCourseConnectionCriteria().isEmpty()) {

            elcParser.getELCContactParser().getContactCriteria().setContactIdSet(contactMap.keySet());            
            List<hed__Course_Enrollment__c> courseConnections = CourseConnectionsDAO.newInstance().findByCriteria(
                                                                elcParser.getELCCourseConnectionParser().getCourseConnectionCriteria(), 
                                                                elcParser.getELCProgramEnrollmentParser().getProgramEnrollmentCriteria(), 
                                                                elcParser.getELCContactParser().getContactCriteria(),
                                                                AccessLevel.SYSTEM_MODE
                                                                );
            courseConnectionByContactMap = groupByContact(courseConnections);
        }

        return courseConnectionByContactMap;
    }


    private Map<Id, List<hed__Course_Enrollment__c>> groupByContact(List<hed__Course_Enrollment__c> courseConnections) {
        Map<Id, List<hed__Course_Enrollment__c>> courseConnectionByContactMap = new Map<Id, List<hed__Course_Enrollment__c>>();

        for(hed__Course_Enrollment__c courseConnection : courseConnections){
            if(courseConnectionByContactMap.containsKey(courseConnection.hed__Contact__c)){
                courseConnectionByContactMap.get(courseConnection.hed__Contact__c).add(courseConnection);
            }else{
                List<hed__Course_Enrollment__c> courseConnectionList = new List<hed__Course_Enrollment__c>();
                courseConnectionList.add(courseConnection);
                courseConnectionByContactMap.put(courseConnection.hed__Contact__c, courseConnectionList);
            }
        }
        
        return courseConnectionByContactMap;
    }

}
