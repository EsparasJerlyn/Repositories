/**
 * @description Class to be used as an Evaluator Class for Contact
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                              |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------|
      | kim.howard.capanas             | May 6, 2024           | DEPP-8488              | Created file                                                |
*/
public with sharing class ELCContactEvaluator {

    private ELCParser elcParser;

    public ELCContactEvaluator(ELCParser elcParser) {
        this.elcParser = elcParser;
    }

    public Map<Id, Contact> evaluate(Map<Id, Contact> contactMap) { 

        Map<Id, Contact> contactEvaluatedMap;

        Boolean isValid = !isAllParserEmpty() && isAllChildCriteriaEmpty();
        if (isValid && !elcParser.getELCContactParser().getContactCriteria().isEmpty()) {

            elcParser.getELCContactParser().getContactCriteria().setContactIdSet(contactMap.keySet());
            List<Contact> contacts = ContactsDAO.newInstance().findByCriteria(
                elcParser.getELCContactParser().getContactCriteria(), 
                AccessLevel.SYSTEM_MODE
            );

            contactEvaluatedMap = new Map<Id, Contact>(contacts);
        }

        return contactEvaluatedMap;
    }

    private Boolean isAllParserEmpty(){
        return elcParser.getELCContactParser().isEmpty();
    }

    private Boolean isAllChildCriteriaEmpty() {
        return 
            (!elcParser.getELCLeaveOfAbsenceParser().isEmpty() && elcParser.getELCLeaveOfAbsenceParser().getLeaveOfAbsencesCriteria().isEmpty()) && 
            (!elcParser.getELCProgramEnrollmentBreachParser().isEmpty() && elcParser.getELCProgramEnrollmentBreachParser().getProgramEnrollmentBreachCriteria().isEmpty()) && 
            (!elcParser.getELCCourseConnectionParser().isEmpty() && elcParser.getELCCourseConnectionParser().getCourseConnectionCriteria().isEmpty()) && 
            (!elcParser.getELCCourseConnectionAssessmentParser().isEmpty() && elcParser.getELCCourseConnectionAssessmentParser().getCourseConnectionAssessmentCriteria().isEmpty()) && 
            (!elcParser.getELCCompletedCadenceParser().isEmpty() && elcParser.getELCCompletedCadenceParser().getCompletedCadenceCriteria().isEmpty()) && 
            (!elcParser.getELCProgramEnrollmentParser().isEmpty() && elcParser.getELCProgramEnrollmentParser().getProgramEnrollmentCriteria().isEmpty());
    }
    
}