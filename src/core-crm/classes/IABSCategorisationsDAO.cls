/**
 * @description Interface for ABS_Categorisation__c DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | mark.j.mahilum                 | May 29,2024           | DEPP-8956              | Created file                 |
 */
public interface IABSCategorisationsDAO extends DmlInterface {
    
    List<ABS_Categorisation__c> getLatestUpdatedActiveCategorisationRecord(
        String accessLevel
    );
}