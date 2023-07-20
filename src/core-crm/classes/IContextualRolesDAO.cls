/**
 * @description Interface for Contextual Roles DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                             |
 *    |--------------------------------|-----------------------|------------------------|------------------------------------------------------------|
 *    | kenneth.f.alsay                | June 16, 2023         | DEPP-5434              | Created file                                               |
 *    | ryan.j.a.dela.cruz             | July 18, 2023         | DEPP-5457/DEPP-5468    | Added getActiveOpportunityContextualRolesRecords method    |
 */
public interface IContextualRolesDAO extends DmlInterface {
    List<Contextual_Role__c> getActiveOpportunityContextualRolesRecords(
        Set<Id> opportunityIds,
        List<String> contextualRoleGroups
    );
}
