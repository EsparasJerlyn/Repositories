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

        if (!elcParser.getELCContactParser().getContactCriteria().isEmpty() && isAllChildCriteriaEmpty()) {

            elcParser.getELCContactParser().getContactCriteria().setContactIdSet(contactMap.keySet());
            List<Contact> contacts = ContactsDAO.newInstance().findByCriteria(
                elcParser.getELCContactParser().getContactCriteria(), 
                AccessLevel.SYSTEM_MODE
            );

            contactEvaluatedMap = new Map<Id, Contact>(contacts);
        }

        return contactEvaluatedMap;
    }

    private Boolean isAllChildCriteriaEmpty() {
        return 
            elcParser.getELCLeaveOfAbsenceParser().getLeaveOfAbsencesCriteria().isEmpty() && 
            elcParser.getELCProgramEnrollmentBreachParser().getProgramEnrollmentBreachCriteria().isEmpty() && 
            elcParser.getELCCourseConnectionParser().getCourseConnectionCriteria().isEmpty() && 
            elcParser.getELCCourseConnectionAssessmentParser().getCourseConnectionAssessmentCriteria().isEmpty() && 
            elcParser.getELCCompletedCadenceParser().getCompletedCadenceCriteria().isEmpty() && 
            elcParser.getELCProgramEnrollmentParser().getProgramEnrollmentCriteria().isEmpty();
    }
    
}