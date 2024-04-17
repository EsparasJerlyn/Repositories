/**
 * @description Interface for Distribution Management DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                         |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------------------|
      | kenneth.f.alsay                | April 8, 2024         | DEPP-8399              | Created file                                           |
      | kenneth.f.alsay                | April 11, 2024        | DEPP-8453              | Added queryLocatorGetDistributionMgtsForStatusUpdate   |
      | nicole.genon                   | April 11, 2024        | DEPP-8452              | Added getDistributionManagementsBySetRecordIds         |
*/
public interface IDistributionManagementsDAO extends DmlInterface{
      Database.QueryLocator queryLocatorGetDistributionMgtsForStatusUpdate();
      List<Distribution_Management__c> getDistributionManagementByDesignationId(
            Set<Id> designationIds,
            AccessLevel accessLevel
      );
      
      List<Distribution_Management__c> getDistributionManagementsBySetRecordIds(
            Set<Id> recordIds, 
            AccessLevel accessLevel
      );
}