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

    private CourseConnectionsDAO.Criteria processCourseConnectionCourseGrade(Engagement_List_Criteria__c engagementListCriteria, CourseConnectionsDAO.Criteria courseGradeCriteria) {
        if (engagementListCriteria.Course_Grade__c != null) {
            if (courseGradeCriteria == null) {
                courseGradeCriteria = new CourseConnectionsDAO.Criteria();
            }
            courseGradeCriteria.courseGrade = engagementListCriteria.Course_Grade__c;
        }
        return courseGradeCriteria;
    }

    private CourseConnectionsDAO.Criteria applyCourseConnectionHiddenCriteria(CourseConnectionsDAO.Criteria courseConnectionCriteria) {
        if (courseConnectionCriteria == null) {
            courseConnectionCriteria = new CourseConnectionsDAO.Criteria();
        }
        courseConnectionCriteria.status = CourseConnectionsDAO.ENROLLMENT_STATUS_FOR_OUTREACH;

        return courseConnectionCriteria;
    }

    public CourseConnectionsDAO.Criteria getCourseConnectionCriteria() {
        return courseConnectionCriteria;
    }
}