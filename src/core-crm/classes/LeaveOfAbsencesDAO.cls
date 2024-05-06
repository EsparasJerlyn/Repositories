/**
 * @description DAO Class for Leave_of_Absence__c Object. Contains soql and constants related to the Leave_of_Absence__c object.
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
 *    |--------------------------------|-----------------------|------------------------|------------------------------------------------|
 *    | gabriel.p.ventayen             | April 30, 2024        | DEPP-8041              | Created file                                   |
 *    |                                |                       |                        |                                                |
 */
public inherited sharing class LeaveOfAbsencesDAO extends DmlBase implements ILeaveOfAbsencesDAO {
    
    public static ILeaveOfAbsencesDAO newInstance() {
        return (ILeaveOfAbsencesDAO) ImplementationSelector.DAO.newInstance(
            Leave_of_Absence__c.SObjectType
        );
    }
    public Schema.SObjectType getSObjectType() {
        return 	Leave_of_Absence__c.SObjectType;
    }

    public String getWhereClauseByCriteria(
        LeaveOfAbsencesDAO.Criteria leaveOfAbsenceCriteria,
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria,
        ContactsDAO.Criteria contactCriteria
    ){
        String soql = '';
        //Collate all criteria checked in every Criteria fields
        soql = 
            whereClauseCheckerForLeaveOfAbsenceCriteria(leaveOfAbsenceCriteria) + 
            whereClauseCheckerForProgramEnrollmentCriteria(programEnrollmentCriteria) + 
            whereClauseCheckerForContactCriteria(contactCriteria); 
        
        if(soql != '') {
            soql = 'WHERE ' + soql.trim().removeStart('AND').trim();
        }
    
        return soql;    
    }

    //Checks to ensure fields have values
    private String whereClauseCheckerForLeaveOfAbsenceCriteria(LeaveOfAbsencesDAO.Criteria leaveOfAbsenceCriteria){
        
        String soql = '';
        if(leaveOfAbsenceCriteria.getIsOnLeave() != null){
            soql += 'AND Is_On_Leave__c = ' + leaveOfAbsenceCriteria.getIsOnLeave() + ' ' ;
        }

        if(
            leaveOfAbsenceCriteria.executionDate != null 
            && leaveOfAbsenceCriteria.keyDateOffsetLowerBoundary != null  
            && leaveOfAbsenceCriteria.keyDateOffsetUpperBoundary != null
        ){
            soql = soql 
            + 'AND End_Date__c >= ' + leaveOfAbsenceCriteria.getkeyDateOffsetLowerBoundary() + ' ' 
            + 'AND End_Date__c <= ' + leaveOfAbsenceCriteria.getkeyDateOffsetUpperBoundary() + ' ';
        }

        return soql;
    }

    //Checks to ensure fields have values
    private String whereClauseCheckerForProgramEnrollmentCriteria(ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria){
        String soql = '';

        if(programEnrollmentCriteria.getAcademicStatus() != null){
            soql += 'AND hed_Program_Enrollment__r.Academic_Status__c = \'' + programEnrollmentCriteria.getAcademicStatus() + '\' ';
        }
        if(programEnrollmentCriteria.getEnrollmentStage() != null){
            soql += 'AND hed_Program_Enrollment__r.Enrollment_Stage__c = \'' + programEnrollmentCriteria.getEnrollmentStage() + '\' ';
        }
        if(programEnrollmentCriteria.getEnrollmentStatus() != null){
            soql += 'AND hed_Program_Enrollment__r.Enrollment_Status__c IN (' + formatSetForWhereClause(ELCProgramEnrollmentParser.ENROLLMENT_STATUS_FOR_OUTREACH) + ') ';
        }
        if(programEnrollmentCriteria.getCategoryType() != null){
            soql += 'AND hed_Program_Enrollment__r.hed__Program_Plan__r.Category_Type__c  = \'' + programEnrollmentCriteria.getCategoryType() + '\' ';
        } 
        
        return soql;
    }

    //Checks to ensure fields have values
    private String whereClauseCheckerForContactCriteria(ContactsDAO.Criteria contactCriteria){
        String soql = '';

        if(contactCriteria.getCitizenshipStatus() != null){
            soql += 'AND hed_Program_Enrollment__r.hed__Contact__r.hed__Citizenship_Status__c = \'' + contactCriteria.getCitizenshipStatus() + '\' ';
        }
        if(contactCriteria.getIsQUTStudent() != null){
            soql += 'AND hed_Program_Enrollment__r.hed__Contact__r.QUT_Student__c = ' + contactCriteria.getIsQUTStudent() + ' ' ;
        }
        if(contactCriteria.getRecordType() != null){
            soql += 'AND hed_Program_Enrollment__r.hed__Contact__r.RecordType.DeveloperName = \'' + contactCriteria.getRecordType() + '\'';
        }

        return soql;
    }

    public String getContactQueryByCriteria(
        LeaveOfAbsencesDAO.Criteria leaveOfAbsenceCriteria,
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria,
        ContactsDAO.Criteria contactCriteria
    ){
        return 'SELECT hed_Program_Enrollment__r.hed__Contact__c FROM Leave_Of_Absence__c ' + getWhereClauseByCriteria(leaveOfAbsenceCriteria, programEnrollmentCriteria, contactCriteria);
    }

    public String getQueryByCriteria(
        LeaveOfAbsencesDAO.Criteria leaveOfAbsenceCriteria,
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria,
        ContactsDAO.Criteria contactCriteria
    ){
        return 'SELECT ' + 
        ' Id, hed_Program_Enrollment__r.hed__Contact__c, Name, Is_On_Leave__c, End_Date__c, ' +
        ' hed_Program_Enrollment__r.Academic_Status__c, hed_Program_Enrollment__r.Enrollment_Stage__c, hed_Program_Enrollment__r.Enrollment_Status__c, ' +
        ' hed_Program_Enrollment__r.hed__Contact__r.hed__Citizenship_Status__c, hed_Program_Enrollment__r.hed__Contact__r.QUT_Student__c, hed_Program_Enrollment__r.hed__Contact__r.RecordType.DeveloperName ' +
        ' FROM Leave_Of_Absence__c ' +
        getWhereClauseByCriteria(leaveOfAbsenceCriteria, programEnrollmentCriteria, contactCriteria);
    }

    public List<Leave_Of_Absence__c> findByCriteria(
        LeaveOfAbsencesDAO.Criteria leaveOfAbsenceCriteria,
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria,
        ContactsDAO.Criteria contactCriteria
    ){
        return Database.query(getQueryByCriteria(leaveOfAbsenceCriteria, programEnrollmentCriteria, contactCriteria));
    }

    /**
     * @Description:Wrapper Class that represents the Criteria for outreach Case.
     */
    public class Criteria {
        private Boolean isOnLeave;
        public Integer keyDateOffset;    
        private Date executionDate;
        private Integer keyDateOffsetLowerBoundary;
        private Integer keyDateOffsetUpperBoundary;
        

        public Boolean getIsOnLeave(){
            return isOnLeave;
        }

        public void setIsOnleave(Boolean isOnLeave){
            this.isOnLeave = isOnLeave;
        }

        public Date getExecutionDate(){
            return executionDate;
        }

        public void setExecutionDate(Date executionDate){
            this.executionDate = executionDate;
        }

        public String getkeyDateOffsetLowerBoundary(){
            if ( this.executionDate != null ) {
                Date returnDate = this.executionDate.addDays(this.keyDateOffsetLowerBoundary);
                String strReturnDate =  DateTime.newInstance(returnDate.year(), returnDate.month(), returnDate.day()).format('YYYY-MM-dd');
                return strReturnDate;
            } else {
                return null;
            }
        }

        public void setkeyDateOffsetLowerBoundary(Integer keyDateOffsetLowerBoundary){
            this.keyDateOffsetLowerBoundary = keyDateOffsetLowerBoundary;
        }

        public String getkeyDateOffsetUpperBoundary(){
            if ( this.executionDate != null ) {
                Date returnDate = this.executionDate.addDays(this.keyDateOffsetUpperBoundary);
                String strReturnDate =  DateTime.newInstance(returnDate.year(), returnDate.month(), returnDate.day()).format('YYYY-MM-dd');
                return strReturnDate;
            } else {
                return null;
            }
        }

        public void setkeyDateOffsetUpperBoundary(Integer keyDateOffsetUpperBoundary){
            this.keyDateOffsetUpperBoundary = keyDateOffsetUpperBoundary;
        }
        
        public Boolean isEmpty() {
            return isOnLeave == null && keyDateOffset == null && executionDate == null;
        }
    }

    private String formatSetForWhereClause(Set<String> statusSet){
        List<String> formattedStatus = new List<String>();
        for(String status : statusSet){
            formattedStatus.add('\'' + status + '\'');
        }
        return String.join(formattedStatus, ', ');
    }

}