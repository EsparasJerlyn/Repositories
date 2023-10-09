/**
 * @description Interface for CasePriorityConfigurationsDAO
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | Octover 5, 2023       | DEPP-6426              | Created file                 |
      |                                |                       |                        |                              |
 */
public interface ICasePriorityConfigurationsDAO extends DmlInterface {
    List<Case_Priority_Configuration__c> getActiveCasePriorityConfigurations(AccessLevel accessLevel);
}
