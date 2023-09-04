/**
 * @description DAO Class for Opportunity Contact Role Object. Contains soql and constants related to the Opportunity Contact Role Object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | mark.j.mahilum                 | Aug 31, 2023          | DEPP-6455              | Created file                 |
 */
public inherited sharing class OpportunityContactRolesDAO extends DmlBase implements IOpportunityContactRolesDAO {
        
    public static IOpportunityContactRolesDAO newInstance() {
        return (IOpportunityContactRolesDAO) ImplementationSelector.DAO.newInstance(OpportunityContactRole.SObjectType);
    }
    
    public Schema.SObjectType getSObjectType() {
        return OpportunityContactRole.SObjectType;
    }
       
    public List<OpportunityContactRole> getOpportunityContactRoleByRoleContactIds(
        Set<Id> contactIds,
        Set<String> contactRoles,
        String accessLevel
    ) {
        return Database.query(
            'SELECT Id, ContactId, role ' +
            'FROM OpportunityContactRole ' +
            'WHERE ContactId IN :contactIds ' +
            'AND role IN: contactRoles ' +
            'WITH ' +
            String.escapeSingleQuotes(accessLevel)
        );
    }  
}