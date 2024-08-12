/**
 * @description Interface for Course Connection DAO framework
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------|
      | mark.j.mahilum                 | June 21, 2023         | DEPP-5799              | Created File                               |
      | eccarius.munoz                 | August 08, 2023       | DEPP-5760              | added method named                         |
      |                                |                       |                        | getCourseConnectionByProgramEnrollmentIds  |
      | roy.nino.s.regala              | Sep 20, 2023          | DEPP-6714              | getActiveCourseConnectionsBySetContactIds  |
      | kenneth.f.alsay                | Sep 22, 2023          | DEPP-6299              | added method getCourseConnectionByStatus   |
      | arsenio.jr.dayrit              | January 03, 2023      | ApexCRUDViolationFix   | Added method for getCartItemsByWebCartId   |   
      | eccarius.munoz                 | August 12, 2024       | DEPP-10490             | Added queryLocator method for MDM.         |
 */
public interface ICourseConnectionsDAO extends DmlInterface{
    List<hed__Course_Enrollment__c> getCourseConnectionByPEContactIds(
        Set<Id> contactIds,
        String accessLevel
    );

    List<hed__Course_Enrollment__c> getCourseConnectionByProgramEnrollmentIds(
        Set<Id> programEnrollmentIds,
        String accessLevel
    );

    List<hed__Course_Enrollment__c> getActiveCourseConnectionsBySetContactIds(
        Set<String> contactIds,
        AccessLevel accessLevel
    );

    List<hed__Course_Enrollment__c> getCourseConnectionByStatus(
        String status,
        String lmsIntegrationTStatus
    );
    
    List<hed__Course_Enrollment__c> getRegisteredLearnersEmailByCourseOffering (
        Set<Id> courseOfferingIds, 
        Set<Id> programOfferingIds,
        AccessLevel accessLevel
    );

    List<hed__Course_Enrollment__c> getCourseConnectionByCartItem(
        Set<Id> cartItemIdSet,
        AccessLevel accessLevel
    );

    String getWhereClauseByCriteria(
        CourseConnectionsDAO.Criteria courseConnectionCriteria,
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria,
        ContactsDAO.Criteria contactCriteria
    );

    String getContactQueryByCriteria(
        CourseConnectionsDAO.Criteria courseConnectionCriteria,
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria,
        ContactsDAO.Criteria contactCriteria
    );

    String getQueryByCriteria(
        CourseConnectionsDAO.Criteria courseConnectionCriteria,
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria,
        ContactsDAO.Criteria contactCriteria
    );

    List<hed__Course_Enrollment__c> findByCriteria(
        CourseConnectionsDAO.Criteria courseConnectionCriteria,
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria,
        ContactsDAO.Criteria contactCriteria,
        AccessLevel accessLevel
    );

    Database.QueryLocator queryLocatorGetMDMStudentEnrollmentByIds(
        Set<Id> studentEnrollmentIds,
        AccessLevel accessLevel
    );
}