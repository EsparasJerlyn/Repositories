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

    //NOTE: Too many parameters
    //Return where clause string with related objects based on hierarchy
    public String getWhereClauseByCriteria(
        CourseConnectionAssessmentsDAO.Criteria courseConnectionAssessmentsCriteria, 
        CourseConnectionsDAO.Criteria courseConnectionCriteria, 
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria, 
        ContactsDAO.Criteria contactCriteria
    ){ 
        String soql = '';
        //Collate all criteria checked in every Criteria fields
        soql = 
            whereClauseCheckerForCourseConnectionAssessmentCriteria(courseConnectionAssessmentsCriteria) + 
            whereClauseCheckerForCourseConnectionCriteria(courseConnectionCriteria) + 
            whereClauseCheckerForProgramEnrollmentCriteria(programEnrollmentCriteria) + 
            whereClauseCheckerForContactCriteria(contactCriteria); 
        
        if(soql != '') {
            soql = 'WHERE ' + soql.trim().removeStart('AND').trim();
        }
    
        return soql;
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

    //Checks to ensure fields have values
    private String whereClauseCheckerForCourseConnectionAssessmentCriteria(CourseConnectionAssessmentsDAO.Criteria courseConnectionAssessmentsCriteria){
        
        String soql = '';
        if(courseConnectionAssessmentsCriteria.getAssessmentGrade() != null){
            soql += 'AND Assessment_Grade__c = \'' + courseConnectionAssessmentsCriteria.getAssessmentGrade() + '\' ' ;
        }
        if(courseConnectionAssessmentsCriteria.getSubmissionDate() != null){
            Date submissionDate = courseConnectionAssessmentsCriteria.getSubmissionDate();
            String submissionDateString = DateTime.newInstance(submissionDate.year(), submissionDate.month(), submissionDate.day()).format('YYYY-MM-dd');
            soql += 'AND Submission_Date__c = ' + submissionDateString + ' ' ;
        }
        if(courseConnectionAssessmentsCriteria.getAssessmentPriority() != null){
            soql += 'AND Assessment_Name__r.Assessment_Priority__c = \'' + courseConnectionAssessmentsCriteria.getAssessmentPriority() + '\' ';
        }

        return soql;
    }

    //Checks to ensure fields have values
    private String whereClauseCheckerForCourseConnectionCriteria(CourseConnectionsDAO.Criteria courseConnectionCriteria){
        String soql = '';
        if(courseConnectionCriteria.getStatus() != null){
            soql += 'AND Course_Connection__r.Enrollment_Status__c IN (' + formatSetForWhereClause(courseConnectionCriteria.getStatus()) + ') ';
        }
        if(courseConnectionCriteria.getCourseGrade() != null){
            soql += 'AND Course_Connection__r.hed__Display_Grade__c = \'' + courseConnectionCriteria.getCourseGrade() + '\' ';
        }
        
        return soql;
    }

    //Checks to ensure fields have values
    private String whereClauseCheckerForProgramEnrollmentCriteria(ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria){
        String soql = '';

        if(programEnrollmentCriteria.getAcademicStatus() != null){
            soql += 'AND Course_Connection__r.hed__Program_Enrollment__r.Academic_Status__c = \'' + programEnrollmentCriteria.getAcademicStatus() + '\' ';
        }
        if(programEnrollmentCriteria.getEnrollmentStage() != null){
            soql += 'AND Course_Connection__r.hed__Program_Enrollment__r.Enrollment_Stage__c = \'' + programEnrollmentCriteria.getEnrollmentStage() + '\' ';
        }
        if(programEnrollmentCriteria.getCategoryType() != null){
            soql += 'AND Course_Connection__r.hed__Program_Enrollment__r.hed__Program_Plan__r.Category_Type__c  = \'' + programEnrollmentCriteria.getCategoryType() + '\' ';
        }
        if(programEnrollmentCriteria.getEnrollmentStatus() != null){
            soql += 'AND Course_Connection__r.hed__Program_Enrollment__r.Enrollment_Status__c IN (' + formatSetForWhereClause(ELCProgramEnrollmentParser.ENROLLMENT_STATUS_FOR_OUTREACH) + ') ';
        }
        
        return soql;
    }

    //Checks to ensure fields have values
    private String whereClauseCheckerForContactCriteria(ContactsDAO.Criteria contactCriteria){
        String soql = '';

        if(contactCriteria.getCitizenshipStatus() != null){
            soql += 'AND Course_Connection__r.hed__Program_Enrollment__r.hed__Contact__r.hed__Citizenship_Status__c = \'' + contactCriteria.getCitizenshipStatus() + '\' ';
        }
        if(contactCriteria.getIsQUTStudent() != null){
            soql += 'AND Course_Connection__r.hed__Program_Enrollment__r.hed__Contact__r.QUT_Student__c = ' + contactCriteria.getIsQUTStudent() + ' ' ;
        }
        if(contactCriteria.getRecordType() != null){
            soql += 'AND Course_Connection__r.hed__Program_Enrollment__r.hed__Contact__r.RecordType.DeveloperName = \'' + contactCriteria.getRecordType() + '\'';
        }

        return soql;
    }

    private String formatSetForWhereClause(Set<String> statusSet){
        List<String> formattedStatus = new List<String>();
        for(String status : statusSet){
            formattedStatus.add('\'' + status + '\'');
        }
        return String.join(formattedStatus, ', ');
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
                record.Assessment_Grade__c == courseConnectionAssessmentsCriteria.getAssessmentGrade() &&
                record.Submission_Date__c == courseConnectionAssessmentsCriteria.getSubmissionDate() &&
                record.Assessment_Name__r.Assessment_Priority__c == courseConnectionAssessmentsCriteria.getAssessmentPriority())
            {
                courseConnectionAssessmentList.add(record);
            }
        }
        return courseConnectionAssessmentList;
    }

}
