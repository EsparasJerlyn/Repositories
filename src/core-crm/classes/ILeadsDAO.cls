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
      | roy.nino.s.regala              | July 20, 2023         | DEPP-5677              | Added new list               |
      | mark.j.mahilum                 | Aug 23, 2023          | DEPP-6215              | Added new list               |
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
    List<Lead> getLearnerLeadsByCalculatedCadences(
        Set<String> calculatedCadences
    );
    List<Lead> getLeadsCalculatedCadenceByIds(
        Set<String> recordIds,
        String accessLevel
    );
    List<Lead> getLeadsToConvert(Integer recordsCount);
}
