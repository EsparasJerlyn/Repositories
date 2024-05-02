/**
 * @description Class to be used in parsing Engagement_List_Criteria__c to Leave of absence criteria
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                              |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------|
      | eccarius.munoz                 | May 2, 2024           | DEPP-8041              | Created file                                                |
*/
public with sharing class ELCLeaveOfAbsenceParser {
    private Engagement_List_Criteria__c engagementListCriteria;
    private Date executionDate;

    private LeaveOfAbsencesDAO.Criteria leaveOfAbsenceCriteria;

    public ELCLeaveOfAbsenceParser(Engagement_List_Criteria__c engagementListCriteria, Date executionDate) {
        this.engagementListCriteria = engagementListCriteria;
        this.executionDate = executionDate;
        parse();
    }

    private void parse() {
        leaveOfAbsenceCriteria = processLeaveOfAbsenceIsOnLeave(engagementListCriteria, leaveOfAbsenceCriteria);
    }

    //configurable criteria
    private LeaveOfAbsencesDAO.Criteria processLeaveOfAbsenceIsOnLeave(Engagement_List_Criteria__c engagementListCriteria, LeaveOfAbsencesDAO.Criteria leaveOfAbsenceCriteria) {
        if (engagementListCriteria.Is_On_Leave_of_Absence__c != null) {
            if (leaveOfAbsenceCriteria == null) {
                leaveOfAbsenceCriteria = new LeaveOfAbsencesDAO.Criteria();
            }
            if (engagementListCriteria.Is_On_Leave_of_Absence__c == 'Yes') {
                leaveOfAbsenceCriteria.isOnLeave = true;
            } else {
                leaveOfAbsenceCriteria.isOnLeave = false;
            }
        }
        return leaveOfAbsenceCriteria;
    }   

    private LeaveOfAbsencesDAO.Criteria processLeaveOfAbsenceKeyDate(Engagement_List_Criteria__c engagementListCriteria, LeaveOfAbsencesDAO.Criteria leaveOfAbsenceCriteria) {
        if (leaveOfAbsenceCriteria == null) {
            leaveOfAbsenceCriteria = new LeaveOfAbsencesDAO.Criteria();
        }

        leaveOfAbsenceCriteria.keyDateOffset = Integer.valueOf(engagementListCriteria.Key_Date_Offset__c);
        leaveOfAbsenceCriteria.executionDate = this.executionDate;

        return leaveOfAbsenceCriteria;
    }
    
    public LeaveOfAbsencesDAO.Criteria getLeaveOfAbsencesCriteria() {
        return leaveOfAbsenceCriteria;
    }

}