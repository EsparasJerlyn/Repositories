/**
 * @description Class to be used in parsing Engagement_List_Criteria__c to Course Connection criteria
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                              |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------|
      | eccarius.munoz                 | May 2, 2024           | DEPP-8041              | Created file                                                |
*/
public with sharing class ELCCourseConnectionParser {

    public static final Set<String> ENROLLMENT_STATUS_FOR_OUTREACH = new Set<String>{
        CourseConnectionsDAO.ENROLLMENT_STATUS_DESIGNATED,
        CourseConnectionsDAO.ENROLLMENT_STATUS_FAILED,
        CourseConnectionsDAO.ENROLLMENT_STATUS_ENROLLED,
        CourseConnectionsDAO.ENROLLMENT_STATUS_LEAVE_OF_ABSENCE
    };
    
    private Engagement_List_Criteria__c engagementListCriteria;
    private Date executionDate;

    private CourseConnectionsDAO.Criteria courseConnectionCriteria;

    public ELCCourseConnectionParser(Engagement_List_Criteria__c engagementListCriteria, Date executionDate) {
        this.engagementListCriteria = engagementListCriteria;
        this.executionDate = executionDate;
        parse();
    }

    private void parse() {
        courseConnectionCriteria = processCourseConnectionCourseGrade(engagementListCriteria, courseConnectionCriteria);
        courseConnectionCriteria = applyCourseConnectionHiddenCriteria(courseConnectionCriteria);
    }

    //configurable criteria
    private CourseConnectionsDAO.Criteria processCourseConnectionCourseGrade(Engagement_List_Criteria__c engagementListCriteria, CourseConnectionsDAO.Criteria courseConnectionCriteria) {
        if (engagementListCriteria.Course_Grade__c != null) {
            if (courseConnectionCriteria == null) {
                courseConnectionCriteria = new CourseConnectionsDAO.Criteria();
            }
            courseConnectionCriteria.courseGrade = engagementListCriteria.Course_Grade__c;
        }
        return courseConnectionCriteria;
    }

    //hidden criteria
    private CourseConnectionsDAO.Criteria applyCourseConnectionHiddenCriteria(CourseConnectionsDAO.Criteria courseConnectionCriteria) {
        if (courseConnectionCriteria == null) {
            courseConnectionCriteria = new CourseConnectionsDAO.Criteria();
        }
        courseConnectionCriteria.status = ENROLLMENT_STATUS_FOR_OUTREACH;

        return courseConnectionCriteria;
    }

    public CourseConnectionsDAO.Criteria getCourseConnectionCriteria() {
        return courseConnectionCriteria;
    }
}