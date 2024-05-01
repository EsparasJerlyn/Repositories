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
        return 
            'WHERE Is_On_Leave__c = ' + leaveOfAbsenceCriteria.isOnLeave + ' ' +
              'AND End_Date__c = ' + leaveOfAbsenceCriteria.keyDate + ' ' +
              'AND hed_Program_Enrollment__r.Academic_Status__c = \'' + programEnrollmentCriteria.academicStatus + '\' ' +
              'AND hed_Program_Enrollment__r.Enrollment_Stage__c = \'' + programEnrollmentCriteria.enrollmentStage + '\' ' +
              'AND hed_Program_Enrollment__r.Enrollment_Status__c = \'' + programEnrollmentCriteria.enrollmentStatus + '\' ' +
              'AND hed_Program_Enrollment__r.hed__Contact__r.hed__Citizenship_Status__c = \'' + contactCriteria.citizenshipStatus + '\' ' +
              'AND hed_Program_Enrollment__r.hed__Contact__r.QUT_Student__c = ' + contactCriteria.isQUTStudent + ' ' +
              'AND hed_Program_Enrollment__r.hed__Contact__r.RecordType.DeveloperName = \'' + contactCriteria.recordType + '\' ';
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
        public Boolean isOnLeave;
        public Date keyDate;
        
        public Boolean isEmpty() {
            return isOnLeave == null && keyDate == null;
        }
    }

}