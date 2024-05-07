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
        leaveOfAbsenceCriteria = processLeaveOfAbsenceKeyDateOffsets(engagementListCriteria, leaveOfAbsenceCriteria);
    }

    //configurable criteria
    private LeaveOfAbsencesDAO.Criteria processLeaveOfAbsenceIsOnLeave(Engagement_List_Criteria__c engagementListCriteria, LeaveOfAbsencesDAO.Criteria leaveOfAbsenceCriteria) {
        if (engagementListCriteria.Is_On_Leave_of_Absence__c != null) {
            if (leaveOfAbsenceCriteria == null) {
                leaveOfAbsenceCriteria = new LeaveOfAbsencesDAO.Criteria();
            }
            leaveOfAbsenceCriteria.setIsOnleave(engagementListCriteria.Is_On_Leave_of_Absence__c == 'Yes');
        }
        return leaveOfAbsenceCriteria;
    }   

    private LeaveOfAbsencesDAO.Criteria processLeaveOfAbsenceKeyDateOffsets(Engagement_List_Criteria__c engagementListCriteria, LeaveOfAbsencesDAO.Criteria leaveOfAbsenceCriteria) {
        if (
            this.executionDate != null
            && engagementListCriteria.Key_Date__c == 'Leave of Absence End Date'
            && engagementListCriteria.Key_Date_Offset_Lower_Boundary__c != null
            && engagementListCriteria.Key_Date_Offset_Upper_Boundary__c != null
        ) {
            if (leaveOfAbsenceCriteria == null) {
                leaveOfAbsenceCriteria = new LeaveOfAbsencesDAO.Criteria();
            }
            leaveOfAbsenceCriteria.setleaveOfAbsenceDateFrom(Integer.ValueOf(engagementListCriteria.Key_Date_Offset_Lower_Boundary__c));
            leaveOfAbsenceCriteria.setleaveOfAbsenceDateTo(Integer.ValueOf(engagementListCriteria.Key_Date_Offset_Upper_Boundary__c));
            leaveOfAbsenceCriteria.setExecutionDate(this.executionDate);
        }
        return leaveOfAbsenceCriteria;
    }

    
    public LeaveOfAbsencesDAO.Criteria getLeaveOfAbsencesCriteria() {
        return leaveOfAbsenceCriteria;
    }

}