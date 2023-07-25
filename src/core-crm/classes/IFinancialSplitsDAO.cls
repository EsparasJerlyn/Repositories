/**
 * @description Interface for Financial Split DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                             |
 *    |--------------------------------|-----------------------|------------------------|------------------------------------------------------------|
 *    | mark.j.mahilum                 | June 01, 2023         | DEPP-5687              | Created IFinancialSplitsDAO cls                            |
 *    | ryan.j.a.dela.cruz             | July 18, 2023         | DEPP-5457/DEPP-5468    | Added getActiveOpportunityFinancialSplitsRecords method    |
 */
public interface IFinancialSplitsDAO extends DmlInterface {
    List<Financial_Split__c> getFinancialSplitsRecords(
        String relatedParentField,
        Id relatedParentId
    );
    List<Financial_Split__c> getActiveOpportunityFinancialSplitsRecords(Set<Id> opportunityIds);
}
