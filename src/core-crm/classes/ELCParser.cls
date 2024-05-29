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
    }

    public Engagement_List_Criteria__c getEngagementListCriteria(){
        return engagementListCriteria;
    }
    public Date getExecutionDate(){
        return executionDate;
    }

    public ELCContactParser getELCContactParser(){
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

