/**
 * @description Interface for OpportunityContactRolesDAO DAO framework
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------|
      | mark.j.mahilum                 | Aug 31, 2023          | DEPP-6565              | Created File                               |
 */
public interface IOpportunityContactRolesDAO extends DmlInterface{ 
    List<OpportunityContactRole> getOpportunityContactRoleByRoleContactIds(
        Set<Id> contactIds,
        Set<String> contactRoles,
        String accessLevel
    );
}