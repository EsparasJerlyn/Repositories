/**
 * @description DAO Class for Plan Activity Object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | kenneth.f.alsay                | February 29, 2024     | DEPP-7883              | Created file                 |
      | jerlyn.esparas                 | February 29, 2024     | DEPP-7890              |                              |

*/

 public inherited sharing class PlanActivitiesDAO extends DmlBase implements IPlanActivitiesDAO {
    public Schema.SObjectType getSObjectType() {
        return Plan_Activity__c.SObjectType;
    }

    public List<Plan_Activity__c> getPlanActivityRecordsWithOpportunityIds(
        Set<Id> opptyIds,
        AccessLevel accessLevel
    ) {
        return Database.query(
            'SELECT Id, Status__c, Opportunity__c ' +
                'FROM Plan_Activity__c ' +
                'WHERE Opportunity__c IN :opptyIds ',
				accessLevel
        );
    }

    public static IPlanActivitiesDAO newInstance() {
        return (IPlanActivitiesDAO) ImplementationSelector.DAO.newInstance(
            Plan_Activity__c.SObjectType
        );
    }
}