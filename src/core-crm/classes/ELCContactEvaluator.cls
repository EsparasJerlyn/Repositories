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

    // Return null if query not executed
    public Map<Id, List<Contact>> evaluate(Map<Id, Contact> contactMap) {  
        if (!elcParser.getELCContactParser().getContactCriteria().isEmpty() && isAllChildCriteriaEmpty()) {
            // if none of the child or grand child criteria defined, fire query and inherit parent / grand parent criteria
            //elcParser.getContactCriteria().contactIdSet.addAll(contactMap.keySet());

            elcParser.getELCContactParser().getContactCriteria().setContactIdSet(contactMap.keySet());

            //add contact id set into soql
            List<Contact> contacts = ContactsDAO.newInstance().findByCriteria(elcParser.getELCContactParser().getContactCriteria(), AccessLevel.SYSTEM_MODE);
            return groupByContact(contacts);
        }
        // if any of the child or grandchild criteria defined, only run the query in the child or grandchild
        return null;
    }

    private Boolean isAllChildCriteriaEmpty() {
        return 
            elcParser.getELCLeaveOfAbsenceParser().getLeaveOfAbsencesCriteria().isEmpty() && 
            elcParser.getELCProgramEnrollmentBreachParser().getProgramEnrollmentBreachCriteria().isEmpty() && 
            elcParser.getELCCourseConnectionParser().getCourseConnectionCriteria().isEmpty() && 
            elcParser.getELCCourseConnectionAssessmentParser().getCourseConnectionAssessmentCriteria().isEmpty() && 
            elcParser.getELCCompletedCadenceParser().getCompletedCadenceCriteria().isEmpty() && 
            elcParser.getELCProgramEnrollmentParser().getProgramEnrollmentCriteria().isEmpty() &&
            elcParser.getELCContactParser().getContactCriteria().isEmpty();
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
}