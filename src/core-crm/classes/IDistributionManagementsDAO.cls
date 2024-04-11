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
*/
public interface IDistributionManagementsDAO extends DmlInterface{
      Database.QueryLocator queryLocatorGetDistributionMgtsForStatusUpdate();
      List<Distribution_Management__c> getDistributionManagementByDesignationId(
            Set<Id> designationIds,
            AccessLevel accessLevel
       );
}