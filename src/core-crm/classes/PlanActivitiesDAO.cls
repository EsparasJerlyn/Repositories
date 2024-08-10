/**
 * @description DAO Class for Plan Activity Object.
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

 public inherited sharing class PlanActivitiesDAO extends DmlBase implements IPlanActivitiesDAO {
    public Schema.SObjectType getSObjectType() {
        return Plan_Activity__c.SObjectType;
    }

    public static List<Plan_Activity__c> getPlanActivityRecordsWithStewardshipIds(
        Set<Id> stewardshipIds,
        AccessLevel accessLevel
    ) {
        if(!stewardshipIds.isEmpty() && accessLevel != null) {
            return Database.query(
                'SELECT Id, Status__c, Stewardship__c ' +
                    'FROM Plan_Activity__c ' +
                    'WHERE Stewardship__c IN :stewardshipIds ',
                    accessLevel
            );
        }  else { return new List<Plan_Activity__c>(); }
    }
    
    public List<Plan_Activity__c> getPlanActivityRecordsWithOpportunityIds(
        Set<Id> opptyIds,
        AccessLevel accessLevel
    ) {
        if(!opptyIds.isEmpty() && accessLevel != null) {
            return Database.query(
                'SELECT Id, Status__c, Opportunity__c ' +
                    'FROM Plan_Activity__c ' +
                    'WHERE Opportunity__c IN :opptyIds ',
                    accessLevel
            );
        }  else { return new List<Plan_Activity__c>(); }
    }

    public static IPlanActivitiesDAO newInstance() {
        return (IPlanActivitiesDAO) ImplementationSelector.DAO.newInstance(
            Plan_Activity__c.SObjectType
        );
    }
}