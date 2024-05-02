/**
 * @description Class to be used in parsing Engagement_List_Criteria__c to Course Connection Assessment criteria
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                              |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------|
      | eccarius.munoz                 | May 2, 2024           | DEPP-8041              | Created file                                                |
*/
public with sharing class ELCCourseConnectionAssessmentParser {

    private Engagement_List_Criteria__c engagementListCriteria;
    private Date executionDate;

    private CourseConnectionAssessmentsDAO.Criteria courseConnectionAssessmentCriteria;

    public ELCCourseConnectionAssessmentParser(Engagement_List_Criteria__c engagementListCriteria, Date executionDate) {
        this.engagementListCriteria = engagementListCriteria;
        this.executionDate = executionDate;
        parse();
    }

    private void parse() {
        courseConnectionAssessmentCriteria = processFailedToSubmitAssessment(engagementListCriteria, courseConnectionAssessmentCriteria);
        courseConnectionAssessmentCriteria = processAssessmentPriority(engagementListCriteria, courseConnectionAssessmentCriteria);
    }

    //configurable criteria
    private CourseConnectionAssessmentsDAO.Criteria processFailedToSubmitAssessment(Engagement_List_Criteria__c engagementListCriteria, CourseConnectionAssessmentsDAO.Criteria courseConnectionAssessmentCriteria) {
        if (engagementListCriteria.Failed_To_Submit_Assessment__c != null) {
            if (courseConnectionAssessmentCriteria == null) {
                courseConnectionAssessmentCriteria = new CourseConnectionAssessmentsDAO.Criteria();
            }
            if(engagementListCriteria.Failed_To_Submit_Assessment__c == 'Yes'){
                courseConnectionAssessmentCriteria.assessmentGrade = null;
                courseConnectionAssessmentCriteria.submissionDate = null;
            }
            
        }
        return courseConnectionAssessmentCriteria;
    }

    private CourseConnectionAssessmentsDAO.Criteria processAssessmentPriority(Engagement_List_Criteria__c engagementListCriteria, CourseConnectionAssessmentsDAO.Criteria courseConnectionAssessmentCriteria) {
        if (engagementListCriteria.Assessment_Priority__c != null) {
            if (courseConnectionAssessmentCriteria == null) {
                courseConnectionAssessmentCriteria = new CourseConnectionAssessmentsDAO.Criteria();
            }
            courseConnectionAssessmentCriteria.assessmentPriority = engagementListCriteria.Assessment_Priority__c;
        }
        return courseConnectionAssessmentCriteria;
    }

    public CourseConnectionAssessmentsDAO.Criteria getCourseConnectionAssessmentCriteria() {
        return courseConnectionAssessmentCriteria;
    }


}