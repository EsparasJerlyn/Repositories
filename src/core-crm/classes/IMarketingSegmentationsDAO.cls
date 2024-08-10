/**
 * @description Interface for Marketing Segmentation DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                          |
      |--------------------------------|-----------------------|------------------------|-----------------------------------------|
      | julie.jane.alegre              | Sept 14, 2023         | DEPP-6679              | Created file                            |
      | eccarius.munoz                 | October 04, 2023      | DEPP-5866              | added get by contact or lead            |
      | johanna.a.gibas                | January 04, 2024      | ApexCRUDViolationFix   | Added getExistingMarketingSegmentations |
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

     List<Marketing_Segmentation__c> getExistingMarketingSegmentations(
          Map<String, Contact> emailToContactMap,
          AccessLevel accessLevel
     );

     List<Marketing_Segmentation__c> getMarketingSegmentationByContactOrLead(
          Set<Id> contactIdSet, 
          Set<Id> leadIdSet,
          AccessLevel accessLevel
     );

     List<Marketing_Segmentation__c> getLinkedMarketingSegByContactOrLeadIds(
          Set<Id> recordIds,
          AccessLevel accessLevel
     );

     Database.QueryLocator queryLocatorGetMarketingSegmentationsByContactOrLeadIds(
          Set<Id> recordIds
     );
}
