/**
 * @description DAO Class for Contextual Role Object. 
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------|
      | kenneth.f.alsay                | June 16, 2023         | DEPP-5434, 5399        | Created File                               |

 */
public inherited sharing class ContextualRolesDAO extends DmlBase implements IContextualRolesDAO {
	public static final Id ENGAGEMENT_ROLE_RECTYPE_ID = Schema.SObjectType.Contextual_Role__c.getRecordTypeInfosByDeveloperName().get('Engagement_Role').getRecordTypeId();
    public static final Id OPPORTUNITY_OUTCOME_ROLE_RECTYPE_ID = Schema.SObjectType.Contextual_Role__c.getRecordTypeInfosByDeveloperName().get('Opportunity_Outcome_Role').getRecordTypeId();
    public static final Id OPPORTUNITY_ROLE_RECTYPE_ID = Schema.SObjectType.Contextual_Role__c.getRecordTypeInfosByDeveloperName().get('Opportunity_Role').getRecordTypeId();
    public Schema.SObjectType getSObjectType() {
        return Contextual_Role__c.SObjectType;
    }
    
    public static IContextualRolesDAO newInstance() {
        return (IContextualRolesDAO) ImplementationSelector.DAO.newInstance(Contextual_Role__c.SObjectType);
    }
}