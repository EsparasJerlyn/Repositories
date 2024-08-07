/**
 * @description Interface for ProgramEnrollmentsDAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary                      |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------------|
 *    | eccarius.munoz                 | August 08, 2023       |DEPP-5760               | Created File                        |
 */
public interface IProgramEnrollmentsDAO extends DmlInterface{

    List<hed__Program_Enrollment__c> getProgramEnrollmentsById(Set<Id> programEnrollmentIds, String accessLevel);
    List<hed__Program_Enrollment__c> getProgramEnrollmentsByContactIds(Set<Id> contactIds, String accessLevel);
    List<hed__Program_Enrollment__c> getProgramEnrollmentsByContactIdAndEnrollmentStatuses(Set<Id> contactIds, Set<String> statuses, AccessLevel accessLevel);
    List<hed__Program_Enrollment__c> getAllProgramEnrollmentsByContactId(Set<Id> contactIds, AccessLevel accessLevel);
    Database.QueryLocator queryLocatorGetAllProgramEnrollmentsByContactId(Set<Id> recordIds);
    String getWhereClauseByCriteria(
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria,
        ContactsDAO.Criteria contactCriteria
    );

    String getContactQueryByCriteria(
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria,
        ContactsDAO.Criteria contactCriteria
    );

    String getQueryByCriteria(
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria,
        ContactsDAO.Criteria contactCriteria
    );

    List<hed__Program_Enrollment__c> findByCriteria(
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria,
        ContactsDAO.Criteria contactCriteria,
        AccessLevel accessLevel
    );

    List<hed__Program_Enrollment__c> getPriorityCourses(
        Map<String, Object> params,
        AccessLevel accessLevel
    );
}
