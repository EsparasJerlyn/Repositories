/**
 * @description Interface for Asset DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file
 *    | alexander.cadalin              | Jan 05 ,2024          | n/a                    | Added methods
 */
public interface IAssetsDAO extends DmlInterface {
    Database.QueryLocator queryLocatorProductRequestsOfAssetToComplete();
    List<Asset> getAssetsByProductRequestIds(
        Set<Id> productRequestIds,
        AccessLevel accessLevel
    );
}
