/**
 * @description Interface for hed__Address__c DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | sep 22, 2023          | DEPP-6652              | Created file
 */
public interface IAddressesDAO extends DmlInterface {
    List<hed__Address__c> getAddressesByContactIdsSet(
        Set<Id> contactIdsSet,
        AccessLevel accessLevel
    );
    
    List<hed__Address__c> getAddressesByContactIdsAndAddressType(
        Set<Id> contactIdsSet,
        Set<String> addressTypes,
        String accessLevel
    );

    Database.QueryLocator getQueryLocatorByIds(Set<Id> recordIds);

    Database.QueryLocator getQueryLocatorByIntegrationStatus(Set<String> status);

    List<hed__Address__c> getAddressesByIds(
        Set<Id> recordIds,
        AccessLevel accessLevel
    );
}
