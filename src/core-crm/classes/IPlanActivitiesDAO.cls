/**
 * @description Interface for Plan Activity DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
      |--------------------------------|-----------------------|------------------------|------------------------------------------------|
      | kenneth.f.alsay                | February 29, 2024     | DEPP-7883              | Created file                                   |
      | jerlyn.esparas                 | February 29, 2024     | DEPP-7890              |                                                |
      | nicole.genon                   | March 7, 2024         | DEPP-7922              | Added getPlanActivityRecordsWithStewardshipIds |
*/

 public interface IPlanActivitiesDAO extends DmlInterface {
    List<Plan_Activity__c> getPlanActivityRecordsWithOpportunityIds (Set<Id> opptyIds, AccessLevel accessLevel);
    List<Plan_Activity__c> getPlanActivityRecordsWithStewardshipIds (Set<Id> stewardshipIds, AccessLevel accessLevel);
 }