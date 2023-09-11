/**
 * @description Interface for Completed Cadences
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | mark.j.mahilum                 | July 25, 2023         | DEPP-6106              | created file                 |
      | roy.nino.s.regala              | Aug 9, 2023           | DEPP-5677              | added new query              |
      | mark.j.mahilum                 | Aug 23, 2023          | DEPP-6215              | Added filter condition       |
 */
public interface ICompletedCadencesDAO extends DmlInterface {
    List<Completed_Cadence__c> getCompletedCadenceByContactIds(
        Set<Id> contactIds,
        String accessLevel
    );
    List<Completed_Cadence__c> getCompletedCadenceByLeadIds(
        Set<Id> leadIds,
        String accessLevel
    );
    List<Completed_Cadence__c> getCompletedCadenceByTargetIdsAndCadenceName(
        Set<String> targetIds,
        Set<String> cadenceNames,
        String accessLevel
    );
    List<Completed_Cadence__c> getCompletedCadenceByTargetIds(
        Set<Id> targetIds,
        Set<String> cadenceNames,
        String accessLevel
    );
}