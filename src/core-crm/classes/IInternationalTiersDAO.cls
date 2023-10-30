/**
 * @description Interface for InternationalTiersDAO
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
public interface IInternationalTiersDAO extends DmlInterface {
    List<International_Tier__c> getActiveInternationalTiers(AccessLevel accessLevel);
}
