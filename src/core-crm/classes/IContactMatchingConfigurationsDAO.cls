/**
 * @description Interface for ContactMatchingConfiguration DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 06, 2024        | DEPP-7986              | Created file
 */
public interface IContactMatchingConfigurationsDAO extends DmlInterface {
     List<Contact_Matching_Configuration__c> getContactMatchingConfigurationRecords(AccessLevel accessLevel);
}
