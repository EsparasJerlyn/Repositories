/**
 * @description Interface for Distribution Management DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
      |--------------------------------|-----------------------|------------------------|------------------------------------------------|
      | kenneth.f.alsay                | April 8, 2024         | DEPP-8399              | Created file                                   |
*/
public interface IDistributionManagementsDAO extends DmlInterface{
      List<Distribution_Management__c> getDistributionManagementByDesignationId(
            Set<Id> designationIds,
            AccessLevel accessLevel
       );
}