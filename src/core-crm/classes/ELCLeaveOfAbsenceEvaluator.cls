/**
 * @description Class to be used in parsing Engagement_List_Criteria__c for outreach case
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                              |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------|
      | vincent.ferrer                 | May 03, 2024          | DEPP-8750              | Created file                                                |
*/
public with sharing class ELCLeaveOfAbsenceEvaluator {
    
    private ELCParser elcParser;

    public ELCLeaveOfAbsenceEvaluator(ELCParser elcParser) {
        this.elcParser = elcParser;
    }

    // Return null if query not executed
    public Map<Id, List<Leave_of_Absence__c>> evaluate(Map<Id, Contact> contactMap) {

        Map<Id, List<Leave_of_Absence__c>> leaveOfAbsencesMap;

        if (!elcParser.getELCLeaveOfAbsenceParser().getLeaveOfAbsencesCriteria().isEmpty()) {

            elcParser.getELCContactParser().getContactCriteria().setContactIdSet(contactMap.keySet());
            List<Leave_of_Absence__c> leaveOfAbsences = LeaveOfAbsencesDAO.newInstance().findByCriteria(
                elcParser.getELCLeaveOfAbsenceParser().getLeaveOfAbsencesCriteria(),
                elcParser.getELCProgramEnrollmentParser().getProgramEnrollmentCriteria(), 
                elcParser.getELCContactParser().getContactCriteria(),
                AccessLevel.SYSTEM_MODE
            );
            
            leaveOfAbsencesMap = groupByContact(leaveOfAbsences);
        }

        return leaveOfAbsencesMap;
    }


    private Map<Id, List<Leave_of_Absence__c>> groupByContact(List<Leave_of_Absence__c> leaveOfAbsences) {
        Map<Id, List<Leave_of_Absence__c>> leaveOfAbsenceByContactMap = new Map<Id, List<Leave_of_Absence__c>>();

        for(Leave_of_Absence__c leaveOfAbsence : leaveofAbsences){
            if(leaveOfAbsenceByContactMap.containsKey(leaveOfAbsence.Student__c)){
                leaveOfAbsenceByContactMap.get(leaveOfAbsence.Student__c).add(leaveOfAbsence);
            }else{
                List<Leave_of_Absence__c> leaveOfAbsenceList = new List<Leave_of_Absence__c>();
                leaveOfAbsenceList.add(leaveOfAbsence);
                leaveOfAbsenceByContactMap.put(leaveofAbsence.Student__c, leaveOfAbsenceList);
            }
        }
        
        return leaveOfAbsenceByContactMap;
    }

}

