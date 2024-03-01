/**
 * @description DAO Class for Plan Activity Object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | kenneth.f.alsay                | February 29, 2024     | DEPP-7883              | Created file
 */

 public class PlanActivitiesDAO extends DmlBase implements IPlanActivitiesDAO {
    public Schema.SObjectType getSObjectType() {
        return Plan_Activity__c.SObjectType;
    }
    public static IPlanActivitiesDAO newInstance() {
        return (IPlanActivitiesDAO) ImplementationSelector.DAO.newInstance(
            Plan_Activity__c.SObjectType
        );
    }
}