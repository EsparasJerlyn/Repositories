/**
 * @description Interface for Affiliation DAO framework
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------|
      | mark.j.mahilum                 | July 21, 2023         | DEPP-5799              | Created File                               |
 */
public interface IAffiliationsDAO extends DmlInterface{
    List<hed__Affiliation__c> getAffiliationByContactIds(
        Set<Id> contactIds,
        String affilationStatus,
        String accessLevel
    );
}