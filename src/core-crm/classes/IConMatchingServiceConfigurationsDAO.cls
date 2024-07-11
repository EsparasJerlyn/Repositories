/**
 * @description Interface for ContactMatchingConfigurationsDAO DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | June 05, 2024         | DEPP-9210              | Created file
 */
public interface IConMatchingServiceConfigurationsDAO extends DmlInterface {
     Contact_Matching_Service_Configuration__mdt getInstanceByDeveloperName(String developerName);
}
