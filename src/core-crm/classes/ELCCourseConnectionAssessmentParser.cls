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
        courseConnectionAssessmentCriteria = new CourseConnectionAssessmentsDAO.Criteria();
        parse();
    }

    private void parse() {
        courseConnectionAssessmentCriteria = processFailedToSubmitAssessment(engagementListCriteria, courseConnectionAssessmentCriteria);
        courseConnectionAssessmentCriteria = processAssessmentPriority(engagementListCriteria, courseConnectionAssessmentCriteria);
        courseConnectionAssessmentCriteria = processKeyDateOffsets(engagementListCriteria, courseConnectionAssessmentCriteria);
    }

    //configurable criteria
    private CourseConnectionAssessmentsDAO.Criteria processFailedToSubmitAssessment(Engagement_List_Criteria__c engagementListCriteria, CourseConnectionAssessmentsDAO.Criteria courseConnectionAssessmentCriteria) {
        if (String.isNotBlank(engagementListCriteria.Failed_To_Submit_Assessment__c)) {
            courseConnectionAssessmentCriteria.setIsSubmissionDateNull(false);
            if(engagementListCriteria.Failed_To_Submit_Assessment__c == 'Yes'){
                courseConnectionAssessmentCriteria.setIsSubmissionDateNull(true);
            }
            
        }
        return courseConnectionAssessmentCriteria;
    }

    private CourseConnectionAssessmentsDAO.Criteria processAssessmentPriority(Engagement_List_Criteria__c engagementListCriteria, CourseConnectionAssessmentsDAO.Criteria courseConnectionAssessmentCriteria) {
        if (String.isNotBlank(engagementListCriteria.Assessment_Priority__c)) {
            courseConnectionAssessmentCriteria.setAssessmentPriority(engagementListCriteria.Assessment_Priority__c);
        }
        return courseConnectionAssessmentCriteria;
    }

    private CourseConnectionAssessmentsDAO.Criteria processKeyDateOffsets(Engagement_List_Criteria__c engagementListCriteria, CourseConnectionAssessmentsDAO.Criteria courseConnectionAssessmentCriteria) {
        Boolean isKeyDateValid = this.executionDate != null && engagementListCriteria.Key_Date__c == 'Assessment Due Date';
        if (isKeyDateValid && engagementListCriteria.Key_Date_Offset_Lower_Boundary__c != null) {
            courseConnectionAssessmentCriteria.setDueDateFrom(this.executionDate.addDays(-Integer.ValueOf(engagementListCriteria.Key_Date_Offset_Lower_Boundary__c)));
        }

        if (isKeyDateValid && engagementListCriteria.Key_Date_Offset_Upper_Boundary__c != null
        ) {
            courseConnectionAssessmentCriteria.setDueDateTo(this.executionDate.addDays(-Integer.ValueOf(engagementListCriteria.Key_Date_Offset_Upper_Boundary__c)));
        }

        return courseConnectionAssessmentCriteria;
    }

    public CourseConnectionAssessmentsDAO.Criteria getCourseConnectionAssessmentCriteria() {
        return courseConnectionAssessmentCriteria;
    }

}