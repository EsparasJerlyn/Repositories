/**
 * @description Mock DAO Class for Course Connection Assessments Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
 *    |--------------------------------|-----------------------|------------------------|------------------------------------------------|
 *    | julie.jane.alegre              | April 29, 2024        | DEPP-8041              | Created file                                   |
 *    |                                |                       |                        |                                                |
 */
@isTest
public inherited sharing class CourseConnectionAssessmentsDAOMock extends DmlBaseMock implements ICourseConnectionAssessmentsDAO{
    public Map<Id, Course_Connection_Assessment__c> courseConnectionAssessmentMap;

    public Schema.SObjectType getSObjectType() {
        return Course_Connection_Assessment__c.SObjectType;
    }

    public CourseConnectionAssessmentsDAOMock() {
        super(new Map<Id, Course_Connection_Assessment__c>(), Schema.Course_Connection_Assessment__c.SObjectType);
        this.courseConnectionAssessmentMap = (Map<Id, Course_Connection_Assessment__c>) super.records;
    }

    public String getWhereClauseByCriteria(
        CourseConnectionAssessmentsDAO.Criteria courseConnectionAssessmentsCriteria, 
        CourseConnectionsDAO.Criteria courseConnectionCriteria, 
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria, 
        ContactsDAO.Criteria contactCriteria
    ) {
        return 
            'WHERE Assessment_Grade__c = \'' + courseConnectionAssessmentsCriteria.assessmentGrade + '\' ' +
            'AND Submission_Date__c = ' + courseConnectionAssessmentsCriteria.submissionDate + ' ' +
            'AND Assessment_Name__r.Assessment_Priority__c = \'' + courseConnectionAssessmentsCriteria.assessmentPriority + '\' ' +
            'AND Course_Connection__r.hed__Display_Grade__c   = \'' + courseConnectionCriteria.courseGrade + '\' ' +
            'AND Course_Connection__r.hed__Program_Enrollment__r.Academic_Status__c  = \'' + programEnrollmentCriteria.academicStatus + '\' ' +
            'AND Course_Connection__r.hed__Program_Enrollment__r.hed__Program_Plan__r.Category_Type__c  = \'' + programEnrollmentCriteria.categoryType + '\' ' +
            'AND Course_Connection__r.hed__Program_Enrollment__r.hed__Contact__r.hed__Citizenship_Status__c = \'' + contactCriteria.citizenshipStatus + '\' ' +
            'AND Course_Connection__r.hed__Program_Enrollment__r.hed__Contact__r.QUT_Student__c = ' + contactCriteria.isQUTStudent + ' ' +
            'AND Course_Connection__r.hed__Program_Enrollment__r.hed__Contact__r.RecordType.DeveloperName = \'' + contactCriteria.recordType + '\'';
    }

    public String getContactQueryByCriteria(
        CourseConnectionAssessmentsDAO.Criteria courseConnectionAssessmentsCriteria, 
        CourseConnectionsDAO.Criteria courseConnectionCriteria, 
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria, 
        ContactsDAO.Criteria contactCriteria
    ){
        return 'SELECT Course_Connection__r.hed__Program_Enrollment__r.hed__Contact__c FROM Course_Connection_Assessment__c ' + getWhereClauseByCriteria(courseConnectionAssessmentsCriteria, courseConnectionCriteria, programEnrollmentCriteria, contactCriteria);
    }

    public String getQueryByCriteria(
        CourseConnectionAssessmentsDAO.Criteria courseConnectionAssessmentsCriteria, 
        CourseConnectionsDAO.Criteria courseConnectionCriteria, 
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria, 
        ContactsDAO.Criteria contactCriteria
    ){
        return 'SELECT Id, Assessment_Grade__c, Submission_Date__c, Assessment_Name__r.Assessment_Priority__c, Course_Connection__r.hed__Program_Enrollment__r.hed__Contact__c FROM Course_Connection_Assessment__c ' + getWhereClauseByCriteria(courseConnectionAssessmentsCriteria, courseConnectionCriteria, programEnrollmentCriteria, contactCriteria);
    }

    public List<Course_Connection_Assessment__c> findByCriteria(
        CourseConnectionAssessmentsDAO.Criteria courseConnectionAssessmentsCriteria, 
        CourseConnectionsDAO.Criteria courseConnectionCriteria, 
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria, 
        ContactsDAO.Criteria contactCriteria
    ) {
        List<Course_Connection_Assessment__c> courseConnectionAssessmentList = new List<Course_Connection_Assessment__c>();

        for (Course_Connection_Assessment__c record : courseConnectionAssessmentMap.values()) {
            if(
                record.Assessment_Grade__c == courseConnectionAssessmentsCriteria.assessmentGrade &&
                record.Submission_Date__c == courseConnectionAssessmentsCriteria.submissionDate &&
                record.Assessment_Name__r.Assessment_Priority__c == courseConnectionAssessmentsCriteria.assessmentPriority)
            {
                courseConnectionAssessmentList.add(record);
            }
        }
        return courseConnectionAssessmentList;
    }

}
