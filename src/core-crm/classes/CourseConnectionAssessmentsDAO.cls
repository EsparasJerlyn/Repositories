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
 *    | julie.jane.alegre              | May 06, 2024          | DEPP-8049              | Add access level                               |
 *    | eugene.andrew.abuan            | May 20, 2024          | DEPP-8801              | Changes for Category Type                      |
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
        return 'SELECT Contact__c FROM Course_Connection_Assessment__c ' + getWhereClauseByCriteria(courseConnectionAssessmentsCriteria, courseConnectionCriteria, programEnrollmentCriteria, contactCriteria);
    }

    public List<Course_Connection_Assessment__c> findByCriteria(
        CourseConnectionAssessmentsDAO.Criteria courseConnectionAssessmentsCriteria, 
        CourseConnectionsDAO.Criteria courseConnectionCriteria, 
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria, 
        ContactsDAO.Criteria contactCriteria,
        AccessLevel accessLevel
    ){
        return Database.query(getQueryByCriteria(courseConnectionAssessmentsCriteria, courseConnectionCriteria, programEnrollmentCriteria, contactCriteria), accessLevel);
    }

    public String getQueryByCriteria(
        CourseConnectionAssessmentsDAO.Criteria courseConnectionAssessmentsCriteria, 
        CourseConnectionsDAO.Criteria courseConnectionCriteria, 
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria, 
        ContactsDAO.Criteria contactCriteria
    ){
        return 'SELECT Id, Contact__c, Assessment_Grade__c, Submission_Date__c, Assessment_Name__r.Due_Date__c, Assessment_Name__r.Assessment_Priority__c FROM Course_Connection_Assessment__c ' + getWhereClauseByCriteria(courseConnectionAssessmentsCriteria, courseConnectionCriteria, programEnrollmentCriteria, contactCriteria);
    }

    //Checks to ensure fields have values
    private String whereClauseCheckerForCourseConnectionAssessmentCriteria(CourseConnectionAssessmentsDAO.Criteria courseConnectionAssessmentsCriteria){
        
        String soql = '';
        if(!courseConnectionAssessmentsCriteria.getIsSubmissionDateNull()){
            soql += 'AND Submission_Date__c != null ';
        }else if(courseConnectionAssessmentsCriteria.getIsSubmissionDateNull()){
            soql += 'AND Submission_Date__c = null ';
        }

        if(courseConnectionAssessmentsCriteria.getAssessmentPriority() != null){
            soql += 'AND Assessment_Name__r.Assessment_Priority__c = \'' + courseConnectionAssessmentsCriteria.getAssessmentPriority() + '\' ';
        }

        if(courseConnectionAssessmentsCriteria.getDueDateFrom() != null){
            soql += 'AND Assessment_Name__r.Due_Date__c <= ' + DynamicQueryService.convertDatetoDateString(courseConnectionAssessmentsCriteria.getDueDateFrom()) + ' ';
        }

        if(courseConnectionAssessmentsCriteria.getDueDateTo() != null){
            soql += 'AND Assessment_Name__r.Due_Date__c >= ' + DynamicQueryService.convertDatetoDateString(courseConnectionAssessmentsCriteria.getDueDateTo()) + ' ';
        }

        return soql;
    }

    //Checks to ensure fields have values
    private String whereClauseCheckerForCourseConnectionCriteria(CourseConnectionsDAO.Criteria courseConnectionCriteria){
        String soql = '';
        if(courseConnectionCriteria.getStatus() != null){
            String statusSetString = DynamicQueryService.formatStringSetForWhereClause(courseConnectionCriteria.getStatus());
            soql += 'AND Course_Connection__r.Enrollment_Status__c IN (' + statusSetString + ') ';
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
            soql += 'AND Course_Connection__r.hed__Program_Enrollment__r.Academic_Status__c = \'' + String.escapeSingleQuotes(programEnrollmentCriteria.getAcademicStatus()) + '\' ';
        }
        if(programEnrollmentCriteria.getPreviousAcademicStatus() != null){
            soql += 'AND Course_Connection__r.hed__Program_Enrollment__r.Previous_Academic_Status__c = \'' + String.escapeSingleQuotes(programEnrollmentCriteria.getPreviousAcademicStatus()) + '\' ';
        }
        if(programEnrollmentCriteria.getEnrollmentStage() != null){
            soql += 'AND Course_Connection__r.hed__Program_Enrollment__r.Enrollment_Stage__c = \'' + programEnrollmentCriteria.getEnrollmentStage() + '\' ';
        }
        if(programEnrollmentCriteria.getCategoryType() != null){
            String categoryString = DynamicQueryService.formatStringSetForWhereClause(new Set<String>(programEnrollmentCriteria.getCategoryType()));
            soql += 'AND Course_Connection__r.hed__Program_Enrollment__r.hed__Program_Plan__r.Category_Type__c  IN (' + categoryString + ') ';
        }
        if(programEnrollmentCriteria.getEnrollmentStatus() != null){
            String statusSetString = DynamicQueryService.formatStringSetForWhereClause(programEnrollmentCriteria.getEnrollmentStatus());
            soql += 'AND Course_Connection__r.hed__Program_Enrollment__r.Enrollment_Status__c IN (' + statusSetString + ') ';
        }
        
        return soql;
    }

    //Checks to ensure fields have values
    private String whereClauseCheckerForContactCriteria(ContactsDAO.Criteria contactCriteria){
        String soql = '';

        if(contactCriteria.getCitizenshipStatus() != null){
            soql += 'AND Contact__r.hed__Citizenship_Status__c = \'' + contactCriteria.getCitizenshipStatus() + '\' ';
        }
        if(contactCriteria.getIsQUTStudent() != null){
            soql += 'AND Contact__r.QUT_Student__c = ' + contactCriteria.getIsQUTStudent() + ' ' ;
        }
        if(contactCriteria.getRecordType() != null){
            soql += 'AND Contact__r.RecordType.DeveloperName = \'' + contactCriteria.getRecordType() + '\' ';
        }
        if(contactCriteria.getContactIdSet() != null){
            String contactIdString = DynamicQueryService.formatStringSetForWhereClause(contactCriteria.getContactIdSet());
            soql += 'AND Contact__r.Id IN (' + contactIdString + ') ';
        }

        return soql;
    }
    

    /**
     * @Description:Wrapper Class that represents the Criteria for Course Connection Assessment.
     */
    public class Criteria {
        private String assessmentGrade;
        private Boolean isSubmissionDateNull;
        private String assessmentPriority; 
        private Date dueDateFrom;
        private Date dueDateTo;


        public String getAssessmentGrade() {
            return assessmentGrade;
        }

        public void setAssessmentGrade(String assessmentGrade) {
            this.assessmentGrade = assessmentGrade;
        }       
        
        public Boolean getIsSubmissionDateNull(){
            return isSubmissionDateNull;
        }

        public void setIsSubmissionDateNull(Boolean isSubmissionDateNull){
            this.isSubmissionDateNull = isSubmissionDateNull;
        }

        public String getAssessmentPriority() {
            return assessmentPriority;
        }

        public void setAssessmentPriority(String assessmentPriority) {
            this.assessmentPriority = assessmentPriority;
        }

        public Date getDueDateFrom(){
            return this.dueDateFrom;
        }

        public void setDueDateFrom(Date dueDateFrom){
            this.dueDateFrom = dueDateFrom;
        }

        public Date getDueDateTo(){
            return this.dueDateTo;
        }

        public void setDueDateTo(Date dueDateTo){
            this.dueDateTo = dueDateTo;
        }

        public Boolean isEmpty() {
            return isSubmissionDateNull == null && assessmentPriority == null;
        }
    }

}