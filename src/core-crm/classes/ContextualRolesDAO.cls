/**
 * @description DAO Class for Contextual Role Object.
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                             |
 *    |--------------------------------|-----------------------|------------------------|------------------------------------------------------------|
 *    | kenneth.f.alsay                | June 16, 2023         | DEPP-5434, 5399        | Created File                                               |
 *    | ryan.j.a.dela.cruz             | July 18, 2023         | DEPP-5457/DEPP-5468    | Added getActiveOpportunityContextualRolesRecords method    |
 *    | mark.j.mahilum                 | July 18, 2023         | DEPP-5799              | Added method getActiveContextualRoleByContactIds           |
 */
public inherited sharing class ContextualRolesDAO extends DmlBase implements IContextualRolesDAO {

    public static final Id ENGAGEMENT_ROLE_RECTYPE_ID = Schema.SObjectType.Contextual_Role__c.getRecordTypeInfosByDeveloperName()
        .get('Engagement_Role')
        .getRecordTypeId();
    public static final Id OPPORTUNITY_OUTCOME_ROLE_RECTYPE_ID = Schema.SObjectType.Contextual_Role__c.getRecordTypeInfosByDeveloperName()
        .get('Opportunity_Outcome_Role')
        .getRecordTypeId();
    public static final Id OPPORTUNITY_ROLE_RECTYPE_ID = Schema.SObjectType.Contextual_Role__c.getRecordTypeInfosByDeveloperName()
        .get('Opportunity_Role')
        .getRecordTypeId(); 
    public static final Id ADVANCEMENT_OPPORTUNITY_ROLE_RECTYPE_ID = Schema.SObjectType.Contextual_Role__c.getRecordTypeInfosByDeveloperName()
        .get('Advancement_Opportunity_Role')
        .getRecordTypeId();
    public static final Set<String> contextualRoleValues = new Set<String>{
        'Partner', 'Partner Contact', 'Primary Partner Contact'
    }; 
    
    public Schema.SObjectType getSObjectType() {
        return Contextual_Role__c.SObjectType;
    }

    public static IContextualRolesDAO newInstance() {
        return (IContextualRolesDAO) ImplementationSelector.DAO.newInstance(
            Contextual_Role__c.SObjectType
        );
    }

    public List<Contextual_Role__c> getActiveOpportunityContextualRolesRecords(
        Set<Id> opportunityIds,
        List<String> contextualRoleGroups
    ) {
        return [ // NO PMD
            SELECT Id, Opportunity__c, Account__c, Contact__c, Contextual_Role_Group__c, Contextual_Role__c, Is_QUT_Internal_Participant__c
            FROM Contextual_Role__c
            WHERE
                Opportunity__c IN :opportunityIds
                AND Role_Is_Active__c = true
                AND Contextual_Role_Group__c IN :contextualRoleGroups
            WITH USER_MODE
        ];
    }

    public List<Contextual_Role__c> getActiveContextualRoleByContactIds(
        Set<Id> contactIds,
        Set<String> recordTypeIds,
        String accessLevel
    ) {     
        return Database.query(
            'SELECT Id,Contact__c,Account__r.RecordType.DeveloperName ' +
            'FROM Contextual_Role__c ' +
            'WHERE RecordTypeId IN: recordTypeIds ' + 
            'AND Contact__c IN:contactIds ' +
			'AND Contextual_Role__c IN: contextualRoleValues ' +            
            'AND Role_Is_Active__c = TRUE ' +
            'WITH ' +
            String.escapeSingleQuotes(accessLevel)
        );
    }
}