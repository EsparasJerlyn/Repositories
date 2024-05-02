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
@isTest
public inherited sharing class LeaveOfAbsencesDAOMock extends DmlBaseMock implements ILeaveOfAbsencesDAO {
    public Map<Id, Leave_of_Absence__c> leaveOfAbsenceMap;
    public Schema.SObjectType getSObjectType() {
        return Leave_of_Absence__c.SObjectType;
    }
    public LeaveOfAbsencesDAOMock() {
        super(new Map<Id, Leave_of_Absence__c>(), Schema.Leave_of_Absence__c.SObjectType);
        this.leaveOfAbsenceMap = (Map<Id, Leave_of_Absence__c>) super.records;
    }

    public String getWhereClauseByCriteria(
        LeaveOfAbsencesDAO.Criteria leaveOfAbsenceCriteria,
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria,
        ContactsDAO.Criteria contactCriteria
    ){
        String soql = '';
        if(leaveOfAbsenceCriteria.isOnLeave != null){
            soql += 'AND Is_On_Leave__c = ' + leaveOfAbsenceCriteria.isOnLeave + ' ' ;
        }
        if(programEnrollmentCriteria.academicStatus != null){
            soql += 'AND hed_Program_Enrollment__r.Academic_Status__c = \'' + programEnrollmentCriteria.academicStatus + '\' ' ;
        }
        if(programEnrollmentCriteria.enrollmentStage != null){
            soql += 'AND hed_Program_Enrollment__r.Enrollment_Stage__c = \'' + programEnrollmentCriteria.enrollmentStage + '\' ' ;
        }
        if(programEnrollmentCriteria.enrollmentStatus != null){
            soql += 'AND hed_Program_Enrollment__r.Enrollment_Status__c = \'' + programEnrollmentCriteria.enrollmentStatus + '\' ' ;
        }
        if(contactCriteria.citizenshipStatus != null){
            soql += 'AND hed_Program_Enrollment__r.hed__Contact__r.hed__Citizenship_Status__c = \'' + contactCriteria.citizenshipStatus + '\' ' ;
        }
        if(contactCriteria.isQUTStudent != null){
            soql += 'AND hed_Program_Enrollment__r.hed__Contact__r.QUT_Student__c = ' + contactCriteria.isQUTStudent + ' ' ;
        }
        if(contactCriteria.recordType != null){
            soql += 'AND hed_Program_Enrollment__r.hed__Contact__r.RecordType.DeveloperName = \'' + contactCriteria.recordType + '\' ' ;
        }
        
        if(soql != '') {
            soql = 'WHERE ' + soql.trim().replaceFirst('^AND\\s*', '').trim();
        }
        
        /*temporarily commented out*/
        // if(leaveOfAbsenceCriteria.keyDateOffset != null && leaveOfAbsenceCriteria.executionDate != null){
        //     Date lowerKeyDateOffSetBoundary = leaveOfAbsenceCriteria.executionDate.addDays(-leaveOfAbsenceCriteria.keyDateOffset);
        //     Date upperKeyDateOffSetBoundary = leaveOfAbsenceCriteria.executionDate.addDays(leaveOfAbsenceCriteria.keyDateOffset);
        //     soql = soql + 'AND End_Date__c <= ' + lowerKeyDateOffSetBoundary + ' ' + 'AND End_Date__c >= ' + upperKeyDateOffSetBoundary ;
        // }

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
    ) {
        List<Leave_Of_Absence__c> leaveOfAbsenceList = new List<Leave_Of_Absence__c>();

        Date lowerKeyDateOffSetBoundary = leaveOfAbsenceCriteria.executionDate.addDays(-leaveOfAbsenceCriteria.keyDateOffset);
        Date upperKeyDateOffSetBoundary = leaveOfAbsenceCriteria.executionDate.addDays(leaveOfAbsenceCriteria.keyDateOffset);

        for (Leave_Of_Absence__c record : leaveOfAbsenceMap.values()) {
            if(
                record.Is_On_Leave__c == leaveOfAbsenceCriteria.isOnLeave &&
                record.End_Date__c <= lowerKeyDateOffSetBoundary && 
                record.End_Date__c >= upperKeyDateOffSetBoundary  
            )
            {
                leaveOfAbsenceList.add(record);
            }
        }
        return leaveOfAbsenceList;
    }
}