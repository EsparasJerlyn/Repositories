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

    public Map<Id, List<Contact>> evaluate(Map<Id, Contact> contactMap) { 

        Map<Id, List<Contact>> contactListMap;

        if (!elcParser.getELCContactParser().getContactCriteria().isEmpty() && isAllChildCriteriaEmpty()) {

            elcParser.getELCContactParser().getContactCriteria().setContactIdSet(contactMap.keySet());
            List<Contact> contacts = ContactsDAO.newInstance().findByCriteria(
                elcParser.getELCContactParser().getContactCriteria(), 
                AccessLevel.SYSTEM_MODE
            );

            contactListMap = groupByContact(contacts);
        }

        return contactListMap;
    }

    private Map<Id, List<Contact>> groupByContact(List<Contact> contacts) {
        Map<Id, List<Contact>> contactByContactMap = new Map<Id, List<Contact>>();

        for(Contact con : contacts){
            if(contactByContactMap.containsKey(con.Id)){
                contactByContactMap.get(con.Id).add(con);
            }else{
                List<Contact> conList = new List<Contact>();
                conList.add(con);
                contactByContactMap.put(con.Id, conList);
            }
        }
        
        return contactByContactMap;
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