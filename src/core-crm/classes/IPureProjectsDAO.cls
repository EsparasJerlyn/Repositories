/**
 * @description Interface for Pure Projects DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                   |
 *    |--------------------------------|-----------------------|------------------------|--------------------------------------------------|
 *    | ryan.j.a.dela.cruz             | July 03, 2023         | DEPP-5390              | Created file                                     |
 *    | ryan.j.a.dela.cruz             | July 18, 2023         | DEPP-5457/DEPP-5468    | Added getOpportunityPureProjectRecords method    |
 */
public interface IPureProjectsDAO extends DmlInterface {
    List<Pure_Project__c> getOpportunityPureProjectRecords(Set<Id> opportunityIds);
}
