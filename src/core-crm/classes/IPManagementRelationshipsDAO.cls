/**
 * @description DAO Class for IP Management Relationships Object.
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                      |
 *    |--------------------------------|-----------------------|------------------------|---------------------------------------------------------------------|
 *    | kenneth.f.alsay                | July 17, 2023         | DEPP-5475              | Created File                                                        |
 *    | ryan.j.a.dela.cruz             | July 18, 2023         | DEPP-5457/DEPP-5468    | Added getActiveOpportunityIPManagementRelationshipRecords method    |
 */
public inherited sharing class IPManagementRelationshipsDAO extends DmlBase implements IIPManagementRelationshipsDAO {
    public static final Id IP_ENGAGEMENT_RELATIONSHIP_RECTYPE_ID = Schema.SObjectType.IP_Management_Relationship__c.getRecordTypeInfosByDeveloperName()
        .get('IP_Engagement_Relationship')
        .getRecordTypeId();
    public static final Id IP_OPPORTUNITY_OUTCOME_RELATIONSHIP_RECTYPE_ID = Schema.SObjectType.IP_Management_Relationship__c.getRecordTypeInfosByDeveloperName()
        .get('IP_Opportunity_Outcome_Relationship')
        .getRecordTypeId();
    public static final Id IP_OPPORTUNITY_RELATIONSHIP_RECTYPE_ID = Schema.SObjectType.IP_Management_Relationship__c.getRecordTypeInfosByDeveloperName()
        .get('IP_Opportunity_Relationship')
        .getRecordTypeId();

    public Schema.SObjectType getSObjectType() {
        return IP_Management_Relationship__c.SObjectType;
    }

    public static IIPManagementRelationshipsDAO newInstance() {
        return (IIPManagementRelationshipsDAO) ImplementationSelector.DAO.newInstance(
            IP_Management_Relationship__c.SObjectType
        );
    }

    public List<IP_Management_Relationship__c> getActiveOpportunityIPManagementRelationshipRecords(
        Set<Id> opportunityIds
    ) {
        return [ // NO PMD
            SELECT Id, IP_Management__c, Opportunity__c
            FROM IP_Management_Relationship__c
            WHERE Opportunity__c IN :opportunityIds
            AND Opportunity_Outcome__c = NULL
            AND Is_Active__c = TRUE
            WITH USER_MODE
        ];
    }
}
