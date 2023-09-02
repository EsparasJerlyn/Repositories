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
    
}