/**
 * @description DAO Class for Course_Connection_Assessment__c Object. Contains soql and constants related to the Course Connection Assessment object.
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
 *    |--------------------------------|-----------------------|------------------------|------------------------------------------------|
 *    | julie.jane.alegre              | April 29, 2024        | DEPP-8041              | Created file                                   |
 *    |                                |                       |                        |                                                |
 */
public inherited sharing class CourseConnectionAssessmentsDAO extends DmlBase implements ICourseConnectionAssessmentsDAO {
    
    public static ICourseConnectionAssessmentsDAO newInstance() {
        return (ICourseConnectionAssessmentsDAO) ImplementationSelector.DAO.newInstance(
            Course_Connection_Assessment__c.SObjectType
        );
    }

    public Schema.SObjectType getSObjectType() {
        return 	Course_Connection_Assessment__c.SObjectType;
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
        soql = whereClauseCheckerForCourseConnectionAssessmentCriteria(courseConnectionAssessmentsCriteria) + whereClauseCheckerForCourseConnectionCriteria(courseConnectionCriteria) + whereClauseCheckerForProgramEnrollmentCriteria(programEnrollmentCriteria) + whereClauseCheckerForContactCriteria(contactCriteria); 
        
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

    public List<Course_Connection_Assessment__c> findByCriteria(
        CourseConnectionAssessmentsDAO.Criteria courseConnectionAssessmentsCriteria, 
        CourseConnectionsDAO.Criteria courseConnectionCriteria, 
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria, 
        ContactsDAO.Criteria contactCriteria
    ){
        return Database.query(getQueryByCriteria(courseConnectionAssessmentsCriteria, courseConnectionCriteria, programEnrollmentCriteria, contactCriteria));
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
        if(courseConnectionAssessmentsCriteria.assessmentGrade != null){
            soql += 'AND Assessment_Grade__c = \'' + courseConnectionAssessmentsCriteria.assessmentGrade + '\' ' ;
        }
        if(courseConnectionAssessmentsCriteria.submissionDate != null){
            soql += 'AND Submission_Date__c = ' + courseConnectionAssessmentsCriteria.submissionDate + ' ' ;
        }
        if(courseConnectionAssessmentsCriteria.assessmentPriority != null){
            soql += 'AND Assessment_Name__r.Assessment_Priority__c = \'' + courseConnectionAssessmentsCriteria.assessmentPriority + '\' ';
        }

        return soql;
    }

    //Checks to ensure fields have values
    private String whereClauseCheckerForCourseConnectionCriteria(CourseConnectionsDAO.Criteria courseConnectionCriteria){
        String soql = '';

        if(courseConnectionCriteria.courseGrade != null){
            soql += 'AND Course_Connection__r.hed__Display_Grade__c   = \'' + courseConnectionCriteria.courseGrade + '\' ';
        }
        
        return soql;
    }

    //Checks to ensure fields have values
    private String whereClauseCheckerForProgramEnrollmentCriteria(ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria){
        String soql = '';

        if(programEnrollmentCriteria.academicStatus != null){
            soql += 'AND Course_Connection__r.hed__Program_Enrollment__r.Academic_Status__c  = \'' + programEnrollmentCriteria.academicStatus + '\' ';
        }
        if(programEnrollmentCriteria.categoryType != null){
            soql += 'AND Course_Connection__r.hed__Program_Enrollment__r.hed__Program_Plan__r.Category_Type__c  = \'' + programEnrollmentCriteria.categoryType + '\' ';
        }
        
        return soql;
    }

    //Checks to ensure fields have values
    private String whereClauseCheckerForContactCriteria(ContactsDAO.Criteria contactCriteria){
        String soql = '';

        if(contactCriteria.citizenshipStatus != null){
            soql += 'AND Course_Connection__r.hed__Program_Enrollment__r.hed__Contact__r.hed__Citizenship_Status__c = \'' + contactCriteria.citizenshipStatus + '\' ';
        }
        if(contactCriteria.isQUTStudent != null){
            soql += 'AND Course_Connection__r.hed__Program_Enrollment__r.hed__Contact__r.QUT_Student__c = ' + contactCriteria.isQUTStudent + ' ' ;
        }
        if(contactCriteria.recordType != null){
            soql += 'AND Course_Connection__r.hed__Program_Enrollment__r.hed__Contact__r.RecordType.DeveloperName = \'' + contactCriteria.recordType + '\'';
        }

        return soql;
    }

    

    /**
     * @Description:Wrapper Class that represents the Criteria for outreach Case.
     */
    public class Criteria {
        public String assessmentGrade;
        public Date submissionDate;
        public String assessmentPriority;

        public Boolean isEmpty() {
            return assessmentGrade == null && submissionDate == null && assessmentPriority == null;
        }
    }

}
