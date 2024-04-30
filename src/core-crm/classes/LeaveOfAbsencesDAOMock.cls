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
        return 
            'WHERE Is_On_Leave__c =: leaveOfAbsenceCriteria.isOnLeave ' +
              'AND End_Date__c =: leaveOfAbsenceCriteria.keyDate ' +
              'AND hed_Program_Enrollment__r.Academic_Status__c =: programEnrollmentCriteria.academicStatus ' +
              'AND hed_Program_Enrollment__r.Enrollment_Stage__c =: programEnrollmentCriteria.enrollmentStage ' +
              'AND hed_Program_Enrollment__r.Enrollment_Status__c =: programEnrollmentCriteria.enrollmentStatus ' +
              'AND Student__r.hed__Citizenship_Status__c =: contactCriteria.citizenshipStatus ' +
              'AND Student__r.QUT_Student__c =: contactCriteria.isQUTStudent ' +
              'AND Student__r.RecordType.DeveloperName =: contactCriteria.recordType ';
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
        return 'SELECT Id, Student__c, Name FROM Leave_Of_Absence__c ' + getWhereClauseByCriteria(leaveOfAbsenceCriteria, programEnrollmentCriteria, contactCriteria);
    }

    public List<Leave_Of_Absence__c> findByCriteria(
        LeaveOfAbsencesDAO.Criteria leaveOfAbsenceCriteria,
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria,
        ContactsDAO.Criteria contactCriteria
    ) {
        List<Leave_Of_Absence__c> leaveOfAbsenceList = new List<Leave_Of_Absence__c>();

        for (Leave_Of_Absence__c record : leaveOfAbsenceMap.values()) {
            if(
                record.Is_On_Leave__c == leaveOfAbsenceCriteria.isOnLeave &&
                record.End_Date__c == leaveOfAbsenceCriteria.keyDate)
            {
                leaveOfAbsenceList.add(record);
            }
        }
        return leaveOfAbsenceList;
    }
}