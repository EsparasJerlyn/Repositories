/**
 * @description Class to be used in parsing Engagement_List_Criteria__c for outreach case
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                              |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------|
      | eccarius.munoz                 | April 29, 2024        | DEPP-8041              | Created file                                                |
      |                                |                       |                        | Added criterion methods for the ff:                         |
      |                                |                       |                        | 1. citizenshipStatus                                        |
      |                                |                       |                        | 2. academicStatus                                           |
      |                                |                       |                        | 3. cadenceName                                              |
      |                                |                       |                        | Added hidden criteria methods for the ff:                   |
      |                                |                       |                        | 1. Contact                                                  |
      |                                |                       |                        | 2. Program Enrollment                                       |
      |                                |                       |                        | 3. Completed Cadence                                        |
      | julie.jane.alegre              | April 29, 2024        | DEPP-8041              | Added hidden criteria methods for the ff:                   |
      |                                |                       |                        | 1. Course Connection Assessment                             |
      |                                |                       |                        | 2. Program Enrollment Breach                                |
      | eccarius.munoz                 | April 30, 2024        | DEPP-8041              | Added getter methods                                        |
*/
public with sharing class ELCParser {

    private Engagement_List_Criteria__c engagementListCriteria;
    private Date executionDate;

    private ELCContactParser eLCContactParser;
    private ELCProgramEnrollmentParser eLCProgramEnrollmentParser;
    private ELCCompletedCadenceParser eLCCompletedCadenceParser;
    private ELCCourseConnectionParser eLCCourseConnectionParser;
    private ELCCourseConnectionAssessmentParser eLCCourseConnectionAssessmentParser;
    private ELCProgramEnrollmentBreachParser eLCProgramEnrollmentBreachParser;
    private ELCLeaveOfAbsenceParser eLCLeaveOfAbsenceParser;

    public ELCParser(Engagement_List_Criteria__c engagementListCriteria, Date executionDate) {
        this.engagementListCriteria = engagementListCriteria;
        this.executionDate = executionDate;
        parse();
    }

    private void parse() {
        eLCContactParser = new ELCContactParser(engagementListCriteria, executionDate);
        eLCProgramEnrollmentParser = new ELCProgramEnrollmentParser(engagementListCriteria, executionDate);
        eLCCompletedCadenceParser = new ELCCompletedCadenceParser(engagementListCriteria, executionDate);
        eLCCourseConnectionParser = new ELCCourseConnectionParser(engagementListCriteria, executionDate);
        eLCCourseConnectionAssessmentParser = new ELCCourseConnectionAssessmentParser(engagementListCriteria, executionDate);
        eLCProgramEnrollmentBreachParser = new ELCProgramEnrollmentBreachParser(engagementListCriteria, executionDate);
        eLCLeaveOfAbsenceParser = new ELCLeaveOfAbsenceParser(engagementListCriteria, executionDate);

       /*  if(engagementListCriteria.Key_Date__c != null){
            if(engagementListCriteria.Key_Date__c == 'Leave of Absence End Date'){ //declare to engagement list criteria dao
                leaveOfAbsenceCriteria = processLeaveOfAbsenceKeyDate(engagementListCriteria, leaveOfAbsenceCriteria);
            } else if(engagementListCriteria.Key_Date__c == 'Completed Cadence Date'){ //declare to engagement list criteria dao
                completedCadenceCriteria = processCompletedCadenceKeyDate(engagementListCriteria, completedCadenceCriteria);
            } else if(engagementListCriteria.Key_Date__c == 'Breach Start Date'){ //declare to engagement list criteria dao
                programEnrollmentBreachCriteria = processProgramEnrollmentBreachKeyDate(engagementListCriteria, programEnrollmentBreachCriteria);
            } 
            //add others
        } */
        
    }
    /**
     * Criterions with Key Dates
     */
    private LeaveOfAbsencesDAO.Criteria processLeaveOfAbsenceKeyDate(Engagement_List_Criteria__c engagementListCriteria, LeaveOfAbsencesDAO.Criteria leaveOfAbsenceCriteria) {
        if (leaveOfAbsenceCriteria == null) {
            leaveOfAbsenceCriteria = new LeaveOfAbsencesDAO.Criteria();
        }

        leaveOfAbsenceCriteria.keyDateOffset = Integer.valueOf(engagementListCriteria.Key_Date_Offset__c);
        leaveOfAbsenceCriteria.executionDate = this.executionDate;

        return leaveOfAbsenceCriteria;
    }

    private CompletedCadencesDAO.Criteria processCompletedCadenceKeyDate(Engagement_List_Criteria__c engagementListCriteria, CompletedCadencesDAO.Criteria completedCadenceCriteria) {
        if (completedCadenceCriteria == null) {
            completedCadenceCriteria = new CompletedCadencesDAO.Criteria();
        }

        completedCadenceCriteria.keyDateOffset = Integer.valueOf(engagementListCriteria.Key_Date_Offset__c);
        completedCadenceCriteria.executionDate = this.executionDate;

        return completedCadenceCriteria;
    }

    private ProgramEnrollmentBreachesDAO.Criteria processProgramEnrollmentBreachKeyDate(Engagement_List_Criteria__c engagementListCriteria, ProgramEnrollmentBreachesDAO.Criteria programEnrollmentBreachCriteria) {
        if (programEnrollmentBreachCriteria == null) {
            programEnrollmentBreachCriteria = new ProgramEnrollmentBreachesDAO.Criteria();
        }

        programEnrollmentBreachCriteria.keyDateOffset = Integer.valueOf(engagementListCriteria.Key_Date_Offset__c);
        programEnrollmentBreachCriteria.executionDate = this.executionDate;

        return programEnrollmentBreachCriteria;
    }

    /**
     * Getter methods
     */
    public ELCContactParser getELCContactParser() {
        return eLCContactParser;
    }
    
    public ELCProgramEnrollmentParser getELCProgramEnrollmentParser(){
        return eLCProgramEnrollmentParser;
    }

    public ELCCompletedCadenceParser getELCCompletedCadenceParser(){
        return eLCCompletedCadenceParser;
    }
        
    public ELCCourseConnectionParser getELCCourseConnectionParser(){
        return eLCCourseConnectionParser;
    }

    public ELCCourseConnectionAssessmentParser getELCCourseConnectionAssessmentParser(){
        return eLCCourseConnectionAssessmentParser;
    }

    public ELCProgramEnrollmentBreachParser getELCProgramEnrollmentBreachParser(){
        return eLCProgramEnrollmentBreachParser;
    }

    public ELCLeaveOfAbsenceParser getELCLeaveOfAbsenceParser(){
        return eLCLeaveOfAbsenceParser;
    }

}
