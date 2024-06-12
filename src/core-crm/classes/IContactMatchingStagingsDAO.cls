/**
 * @description Interface for ContactMatchingStagingsDAO DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | May 01, 2024          | DEPP-8676              | Created file
 */
public interface IContactMatchingStagingsDAO extends DmlInterface {
     Database.QueryLocator queryLocatorGetContactMatchingStagingsByBatchProcess(Set<String> batchProcessSet, AccessLevel accessLevel);
     List<Contact_Matching_Staging__c> getContactMatchingStagingsByBatchProcess(Set<String> batchProcessSet, AccessLevel accessLevel);
}
