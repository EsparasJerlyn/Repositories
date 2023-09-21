/**
 * @description Interface for Marketing Segmentation DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | julie.jane.alegre              | Sept 14, 2023         | DEPP-6679              | Created file                 |
 */
public interface IMarketingSegmentationsDAO extends DmlInterface{
     
     List<Marketing_Segmentation__c> getMarketingSegmentationByContactIds(
          Set<Id> contactIds,
          AccessLevel accessLevel
      );
     List<Marketing_Segmentation__c> getMarketingSegmentationByLeadIds(
          Set<Id> leadIds,
          AccessLevel accessLevel
     );
}