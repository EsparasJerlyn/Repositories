/**
 * @description Interface for Nurturing Track Configuration
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | mark.j.mahilum                 | July 25, 2023         | DEPP-6106              | created file                 |
 */
public interface INurtureTrackConfigurationsDAO extends DmlInterface {
    List<Nurture_Track_Configuration__c> getNurtureTrackLeadScoreThreshold(
        String accessLevel
    );
    List<Nurture_Track_Configuration__c> getNurtureTrackByCadenceNames(
        Set<String> cadenceNames,
        String accessLevel
    );
    List<Nurture_Track_Configuration__c> getNurtureTrack(
        String fieldsToQuery,
        String accessLevel
    );
} 