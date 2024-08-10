/**
 * @description Interface for DistributionSplitsDAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
      |--------------------------------|-----------------------|------------------------|------------------------------------------------|
      | neil.s.h.lesidan               | April 12, 2024        | DEPP-8392              | Created file                                   |
*/
public interface IDistributionSplitsDAO extends DmlInterface{
      List<Distribution_Split__c> getDistributionSplitByDistributionManagement(
            Set<Id> ids,
            AccessLevel accessLevel
      );
}