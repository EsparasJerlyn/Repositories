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
 *    | eugene.andrew.abuan            | May 20, 2024          | DEPP-8801              | Changes for Category Type                      |
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
        if(leaveOfAbsenceCriteria.getEndDateFrom() != null){
            soql += 'AND End_Date__c <= ' + DynamicQueryService.convertDatetoDateString(leaveOfAbsenceCriteria.getEndDateFrom()) + ' ' ;
        }
        if(leaveOfAbsenceCriteria.getEndDateTo() != null){
            soql += 'AND End_Date__c >= ' + DynamicQueryService.convertDatetoDateString(leaveOfAbsenceCriteria.getEndDateTo()) + ' ' ;
        }

        return soql;
    }

    //Checks to ensure fields have values
    private String whereClauseCheckerForProgramEnrollmentCriteria(ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria){
        String soql = '';

        if(programEnrollmentCriteria.getAcademicStatus() != null){
            soql += 'AND hed_Program_Enrollment__r.Academic_Status__c = \'' + String.escapeSingleQuotes(programEnrollmentCriteria.getAcademicStatus()) + '\' ';
        }
        if(programEnrollmentCriteria.getPreviousAcademicStatus() != null){
            soql += 'AND hed_Program_Enrollment__r.Previous_Academic_Status__c = \'' + String.escapeSingleQuotes(programEnrollmentCriteria.getPreviousAcademicStatus()) + '\' ';
        }
        if(programEnrollmentCriteria.getEnrollmentStage() != null){
            soql += 'AND hed_Program_Enrollment__r.Enrollment_Stage__c = \'' + programEnrollmentCriteria.getEnrollmentStage() + '\' ';
        }
        if(programEnrollmentCriteria.getEnrollmentStatus() != null){
            String statusSetString = DynamicQueryService.formatStringSetForWhereClause(programEnrollmentCriteria.getEnrollmentStatus());
            soql += 'AND hed_Program_Enrollment__r.Enrollment_Status__c IN (' + statusSetString + ') ';
        }
        if(programEnrollmentCriteria.getCategoryType() != null){
            String categoryString = DynamicQueryService.formatStringSetForWhereClause(new Set<String>(programEnrollmentCriteria.getCategoryType()));
            soql += 'AND hed_Program_Enrollment__r.hed__Program_Plan__r.Category_Type__c  IN (' + categoryString + ') ';
        } 
        
        return soql;
    }

    //Checks to ensure fields have values
    private String whereClauseCheckerForContactCriteria(ContactsDAO.Criteria contactCriteria){
        String soql = '';

        if(contactCriteria.getCitizenshipStatus() != null){
            soql += 'AND Student__r.hed__Citizenship_Status__c = \'' + contactCriteria.getCitizenshipStatus() + '\' ';
        }
        if(contactCriteria.getIsQUTStudent() != null){
            soql += 'AND Student__r.QUT_Student__c = ' + contactCriteria.getIsQUTStudent() + ' ' ;
        }
        if(contactCriteria.getRecordType() != null){
            soql += 'AND Student__r.RecordType.DeveloperName = \'' + contactCriteria.getRecordType() + '\' ';
        }
        if(contactCriteria.getContactIdSet() != null){
            String contactIdString = DynamicQueryService.formatStringSetForWhereClause(contactCriteria.getContactIdSet());
            soql += 'AND Student__r.Id IN (' + contactIdString + ') ';
        }

        return soql;
    }

    public String getContactQueryByCriteria(
        LeaveOfAbsencesDAO.Criteria leaveOfAbsenceCriteria,
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria,
        ContactsDAO.Criteria contactCriteria
    ){
        return 'SELECT Student__c FROM Leave_Of_Absence__c ' + getWhereClauseByCriteria(leaveOfAbsenceCriteria, programEnrollmentCriteria, contactCriteria);
    }

    public String getQueryByCriteria(
        LeaveOfAbsencesDAO.Criteria leaveOfAbsenceCriteria,
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria,
        ContactsDAO.Criteria contactCriteria
    ){
        return 'SELECT ' + 
        ' Id, Student__c, Name, Is_On_Leave__c, End_Date__c, ' +
        ' hed_Program_Enrollment__r.Academic_Status__c, hed_Program_Enrollment__r.Previous_Academic_Status__c, hed_Program_Enrollment__r.Enrollment_Stage__c, hed_Program_Enrollment__r.Enrollment_Status__c, ' +
        ' Student__r.hed__Citizenship_Status__c, Student__r.QUT_Student__c, Student__r.RecordType.DeveloperName ' +
        ' FROM Leave_Of_Absence__c ' +
        getWhereClauseByCriteria(leaveOfAbsenceCriteria, programEnrollmentCriteria, contactCriteria);
    }

    public List<Leave_Of_Absence__c> findByCriteria(
        LeaveOfAbsencesDAO.Criteria leaveOfAbsenceCriteria,
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria,
        ContactsDAO.Criteria contactCriteria,
        AccessLevel accessLevel
    ){
        return Database.query(getQueryByCriteria(leaveOfAbsenceCriteria, programEnrollmentCriteria, contactCriteria), accessLevel);
    }

    /**
     * @Description:Wrapper Class that represents the Criteria for Leave of Absence.
     */
    public class Criteria {
        private Boolean isOnLeave;  
        private Date endDateFrom;
        private Date endDateTo;
        

        public Boolean getIsOnLeave(){
            return isOnLeave;
        }

        public void setIsOnleave(Boolean isOnLeave){
            this.isOnLeave = isOnLeave;
        }

        public Date getEndDateFrom(){
            return this.endDateFrom;
        }

        public void setEndDateFrom(Date endDateFrom){
            this.endDateFrom = endDateFrom;
        }

        public Date getEndDateTo(){
            return this.endDateTo;
        }

        public void setEndDateTo(Date endDateTo){
            this.endDateTo = endDateTo;
        }
        
        public Boolean isEmpty() {
            return isOnLeave == null && endDateTo == null && endDateFrom == null;
        }
    }


}