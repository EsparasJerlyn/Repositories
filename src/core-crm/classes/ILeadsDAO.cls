/**
 * @description Interface for Lead DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file                 |
      | mark.j.mahilum                 | June 26, 2023         | DEPP-5846              | Added new list               |
 */
public interface ILeadsDAO extends DmlInterface {
    List<Lead> getExistingUnconvertedLeadsByEmail(
        Set<String> emailsToMatch,
        Set<Id> excludedLeadsRecordsSet,
        String accessLevel
    );
    List<Lead> getLeadsWithLimit(Integer recordsCount);
    List<Lead> getExistingUnconvertedLeads(
        Set<String> emailsToMatch,
        String accessLevel
    );
}
