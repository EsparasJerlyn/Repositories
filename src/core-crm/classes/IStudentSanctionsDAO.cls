/**
 * @description Interface for StudentSanction DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 24, 2024        | DEPP-7984              | Created file
 */
public interface IStudentSanctionsDAO extends DmlInterface {
     Database.QueryLocator queryLocatorGetStudentSanctionsByBatchProcess(Set<String> batchProcessSet, AccessLevel accessLevel);
     List<Student_Sanction__c> getStudentSanctionsByBatchProcess(Set<String> batchProcessSet, AccessLevel accessLevel);
}
