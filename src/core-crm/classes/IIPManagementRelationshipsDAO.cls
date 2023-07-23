/**
 * @description Interface for IP Management Relationship DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                      |
 *    |--------------------------------|-----------------------|------------------------|---------------------------------------------------------------------|
 *    | kenneth.f.alsay                | July 12, 2023         | DEPP-5475              | Created file                                                        |
 *    | ryan.j.a.dela.cruz             | July 18, 2023         | DEPP-5457/DEPP-5468    | Added getActiveOpportunityIPManagementRelationshipRecords method    |
 */
public interface IIPManagementRelationshipsDAO extends DmlInterface {
    List<IP_Management_Relationship__c> getActiveOpportunityIPManagementRelationshipRecords(
        Set<Id> opportunityIds
    );
}
