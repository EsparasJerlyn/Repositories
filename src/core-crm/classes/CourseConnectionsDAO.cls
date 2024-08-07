/**
 * @description DAO Class for hed__Course_Enrollment__c Object. Contains soql and constants related to the Course Connection object.
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
 *    |--------------------------------|-----------------------|------------------------|------------------------------------------------|
 *    | mark.j.mahilum                 | June 19, 2023         | DEPP-5846              | created file                                   |
 *    | eccarius.munoz                 | August 08, 2023       | DEPP-5760              | added method named                             |
 *    |                                |                       |                        | getCourseConnectionByProgramEnrollmentIds      |
 *    | roy.nino.s.regala              | Sep 20, 2023          | DEPP-6714              | added method named                             |
 *    |                                |                       |                        | getActiveCourseConnectionsBySetContactIds      |
 *    | kenneth.f.alsay                | Sep 22, 2023          | DEPP-6299              | added method getCourseConnectionByStatus       |
 *    | arsenio.jr.dayrit              | January 03, 2023      | ApexCRUDViolationFix   | Added method for getCourseConnectionByCartItem |
 *    | gabriel.p.ventayen             | April 30, 2024        | DEPP-8041              | Added critera                                  |
 */

public inherited sharing class CourseConnectionsDAO extends DmlBase implements ICourseConnectionsDAO {

    public static final String ENROLLMENT_STATUS_DESIGNATED = 'Designated';
    public static final String ENROLLMENT_STATUS_FAILED = 'Failed';
    public static final String ENROLLMENT_STATUS_ENROLLED = 'Enrolled';
    public static final String ENROLLMENT_STATUS_LEAVE_OF_ABSENCE = 'Leave of Absence';
    public static final String ENROLLMENT_STATUS_CANCELLED = 'Cancelled';
    
    public static final Set<String> enrollmentStatus = new Set<String>{
       'Withdrawn'
    };

    public static final Set<String> programEnrollmentStatus = new Set<String>{
       'Admitted'
    };      
    
    public static ICourseConnectionsDAO newInstance() {
        return (ICourseConnectionsDAO) ImplementationSelector.DAO.newInstance(hed__Course_Enrollment__c.SObjectType);
    }

    public Schema.SObjectType getSObjectType() {
        return hed__Course_Enrollment__c.SObjectType;
    }

    public List<hed__Course_Enrollment__c> getCourseConnectionByPEContactIds(
        Set<Id> contactIds,
        String accessLevel
    ) {
        return Database.query(
            'SELECT Id,hed__Program_Enrollment__c,hed__Program_Enrollment__r.hed__Contact__c ' +
            'FROM hed__Course_Enrollment__c ' +
            'WHERE hed__Program_Enrollment__r.hed__Contact__c IN :contactIds ' + 
            'AND Enrollment_Status__c NOT IN :enrollmentStatus ' + 
            'AND hed__Program_Enrollment__r.Enrollment_Status__c IN :programEnrollmentStatus ' +
            'WITH ' +
            String.escapeSingleQuotes(accessLevel)
        );
    }

    public List<hed__Course_Enrollment__c> getCourseConnectionByProgramEnrollmentIds(
        Set<Id> programEnrollmentIds,
        String accessLevel
    ) {
        return Database.query(
            'SELECT Id, hed__Program_Enrollment__c, hed__Program_Enrollment__r.hed__Contact__c, hed__Contact__c, Enrollment_Status__c ' +
            'FROM hed__Course_Enrollment__c ' +
            'WHERE hed__Program_Enrollment__c IN :programEnrollmentIds ' +
            'WITH ' +
            String.escapeSingleQuotes(accessLevel)
        );
    }

    public List<hed__Course_Enrollment__c> getActiveCourseConnectionsBySetContactIds(
        Set<String> contactIds,
        AccessLevel accessLevel
    ) {
        return Database.query(
            'SELECT Id, Pricing_Validation__c,hed__Contact__c ' +
            'FROM hed__Course_Enrollment__c ' +
            'WHERE hed__Contact__c IN :contactIds ' + 
            'AND hed__Status__c = \'Active\' ',
            accessLevel
        );
    }

    public List<hed__Course_Enrollment__c> getCourseConnectionByStatus(
        String status,
        String lmsIntegrationStatus
    ){
        return [ //NOPMD
            SELECT Id, hed__Status__c,LMS_Integration_Status__c
            FROM hed__Course_Enrollment__c
            WHERE hed__Status__c = :status AND LMS_Integration_Status__c = :lmsIntegrationStatus
            WITH USER_MODE
        ];
    }

    public List<hed__Course_Enrollment__c> getRegisteredLearnersEmailByCourseOffering (
        Set<Id> courseOfferingIds,
        Set<Id> programOfferingIds,
        AccessLevel accessLevel
    ){
        return Database.query(
            'SELECT Id, hed__Contact__r.Registered_Email__c, hed__Course_Offering__c, Program_Offering__c  ' +
            'FROM hed__Course_Enrollment__c '+
            'WHERE  hed__Status__c = \'Active\' ' +
            'AND (hed__Course_Offering__c IN :courseOfferingIds '+
            'OR Program_Offering__c IN: programOfferingIds ) ',
            accessLevel
        );
    }

    public List<hed__Course_Enrollment__c> getCourseConnectionByCartItem (
        Set<Id> cartItemIdSet,
        AccessLevel accessLevel
    ){
        if(cartItemIdSet.isEmpty()){
            return new List<hed__Course_Enrollment__c>();
        }
        return Database.query(
            'SELECT Id, Cart_Item__c, Cart_ID__c, Cart_ID__r.TotalAmount, Cart_Id__r.Cart_Payment__c, hed__Status__c, ' +
            'Paid_in_Full__c, hed__Course_Offering__c, Program_Offering__c, Paid_Amount__c, Cart_Item__r.TotalPrice, Cart_Item__r.Promotion_Price__c  ' +
            'FROM hed__Course_Enrollment__c '+
            'WHERE Cart_Item__c IN: cartItemIdSet ',
            accessLevel
        );
    }

    public String getWhereClauseByCriteria(
        CourseConnectionsDAO.Criteria courseConnectionCriteria,
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria,
        ContactsDAO.Criteria contactCriteria
    ){
        String soql = '';
        soql = whereClauseCheckerForCourseConnectionCriteria(courseConnectionCriteria) 
            + whereClauseCheckerForProgramEnrollmentCriteria(programEnrollmentCriteria) 
            + whereClauseCheckerForContactCriteria(contactCriteria);        
        if(soql != '') {
            soql = 'WHERE ' + soql.trim().removeStart('AND').trim();
        }
        return soql;
    }

    public String getContactQueryByCriteria(
        CourseConnectionsDAO.Criteria courseConnectionCriteria,
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria,
        ContactsDAO.Criteria contactCriteria
    ){
        return 'SELECT hed__Contact__c FROM hed__Course_Enrollment__c ' + getWhereClauseByCriteria(courseConnectionCriteria, programEnrollmentCriteria, contactCriteria);
    }

    public String getQueryByCriteria(
        CourseConnectionsDAO.Criteria courseConnectionCriteria,
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria,
        ContactsDAO.Criteria contactCriteria
    ){
        return 'SELECT ' + 
        'Id, hed__Contact__c, Name, Enrollment_Status__c, hed__Display_Grade__c, ' +
        'hed__Program_Enrollment__r.Academic_Status__c, hed__Program_Enrollment__r.Previous_Academic_Status__c, hed__Program_Enrollment__r.Enrollment_Stage__c, hed__Program_Enrollment__r.Enrollment_Status__c, ' +
        'hed__Contact__r.hed__Citizenship_Status__c, hed__Contact__r.QUT_Student__c, hed__Contact__r.RecordType.DeveloperName ' +
        'FROM hed__Course_Enrollment__c ' +
        getWhereClauseByCriteria(courseConnectionCriteria, programEnrollmentCriteria, contactCriteria);
    }

    public List<hed__Course_Enrollment__c> findByCriteria(
        CourseConnectionsDAO.Criteria courseConnectionCriteria,
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria,
        ContactsDAO.Criteria contactCriteria,
        AccessLevel accessLevel
    ){
        return Database.query(getQueryByCriteria(courseConnectionCriteria, programEnrollmentCriteria, contactCriteria), accessLevel);
    }

    //Checks to ensure fields have values
    private String whereClauseCheckerForCourseConnectionCriteria(CourseConnectionsDAO.Criteria courseConnectionCriteria){
        String soql = '';
        if(courseConnectionCriteria.getStatus() != null){
            String statusSetString = DynamicQueryService.formatStringSetForWhereClause(courseConnectionCriteria.getStatus());
            soql += 'AND Enrollment_Status__c IN(' + statusSetString + ') ';
        }
        if(courseConnectionCriteria.getCourseGrade() != null){
            soql += 'AND hed__Display_Grade__c = \'' + courseConnectionCriteria.getCourseGrade() + '\' ' ;
        }
        
        return soql;
    }

    //Checks to ensure fields have values
    private String whereClauseCheckerForProgramEnrollmentCriteria(ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria){
        String soql = '';

        if(programEnrollmentCriteria.getAcademicStatus() != null){
            soql += 'AND hed__Program_Enrollment__r.Academic_Status__c = \'' + String.escapeSingleQuotes(programEnrollmentCriteria.getAcademicStatus()) + '\' ' ;
        }
        if(programEnrollmentCriteria.getPreviousAcademicStatus() != null){
            soql += 'AND hed__Program_Enrollment__r.Previous_Academic_Status__c = \'' + String.escapeSingleQuotes(programEnrollmentCriteria.getPreviousAcademicStatus()) + '\' ';
        }
        if(programEnrollmentCriteria.getEnrollmentStage() != null){
            soql += 'AND hed__Program_Enrollment__r.Enrollment_Stage__c = \'' + programEnrollmentCriteria.getEnrollmentStage() + '\' ' ;
        }
        if(programEnrollmentCriteria.getEnrollmentStatus() != null){
            String statusSetString = DynamicQueryService.formatStringSetForWhereClause(programEnrollmentCriteria.getEnrollmentStatus());
            soql += 'AND hed__Program_Enrollment__r.Enrollment_Status__c IN(' + statusSetString + ') ';
        }
        
        return soql;
    }

    //Checks to ensure fields have values
    private String whereClauseCheckerForContactCriteria(ContactsDAO.Criteria contactCriteria){
        String soql = '';

        if(contactCriteria.getCitizenshipStatus() != null){
            soql += 'AND hed__Contact__r.hed__Citizenship_Status__c = \'' + contactCriteria.getCitizenshipStatus() + '\' ' ;
        }
        if(contactCriteria.getIsQUTStudent() != null){
            soql += 'AND hed__Contact__r.QUT_Student__c = ' + contactCriteria.getIsQUTStudent() + ' ' ;
        }
        if(contactCriteria.getRecordType() != null){
            soql += 'AND hed__Contact__r.RecordType.DeveloperName = \'' + contactCriteria.getRecordType() + '\' ' ;
        }
        if(contactCriteria.getContactIdSet() != null){
            String contactIdString = DynamicQueryService.formatStringSetForWhereClause(contactCriteria.getContactIdSet());
            soql += 'AND hed__Contact__r.Id IN (' + contactIdString + ') ';
        }

        return soql;
    }



    /**
     * @Description:Wrapper Class that represents the Criteria for Course Connection.
     */
    public class Criteria {
        private String courseGrade;
        private Set<String> status;

        public String getCourseGrade() {
            return courseGrade;
        }

        public void setCourseGrade(String courseGrade) {
            this.courseGrade = courseGrade;
        }

        public Set<String> getStatus() {
            return status;
        }

        public void setStatus(Set<string> status) {
            this.status = status;
        }

        public Boolean isEmpty() {
            return courseGrade == null && status == null;
        }
    }

}