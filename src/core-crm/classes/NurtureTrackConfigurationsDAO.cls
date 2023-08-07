/**
 * @description DAO Class for Nurturing Track Configuration Object. Contains soql and constants related to the custom object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                               |
      |--------------------------------|-----------------------|------------------------|----------------------------------------------|
      | mark.j.mahilum                 | July 25, 2023         | DEPP-6106              | Created file                                 |
 */
public inherited sharing class NurtureTrackConfigurationsDAO extends DmlBase implements INurtureTrackConfigurationsDAO {

    public static final String NURTURE_FIELDS = 'Id, Cadence_Name__c, Lead_Score_Threshold__c, Status__c,Key_Date_Offset_Days__c,Criteria_Type__c ';

    public static INurtureTrackConfigurationsDAO newInstance() {
        return (INurtureTrackConfigurationsDAO) ImplementationSelector.DAO.newInstance(Nurture_Track_Configuration__c.SObjectType);
    }

    public Schema.SObjectType getSObjectType() {
        return Nurture_Track_Configuration__c.SObjectType;
    }

    public List<Nurture_Track_Configuration__c> getNurtureTrackLeadScoreThreshold(
        String accessLevel
    ) {
        return Database.query(
            'SELECT  Id, Cadence_Name__c, Lead_Score_Threshold__c, Status__c,Key_Date_Offset_Days__c,Criteria_Type__c ' +
            'FROM Nurture_Track_Configuration__c ' +
            'WHERE Status__c = \'Active\' '+
            'AND Lead_Score_Threshold__c != NULL ' +
            'WITH ' +
            String.escapeSingleQuotes(accessLevel)
        );
    }
    
    public List<Nurture_Track_Configuration__c> getNurtureTrackByCadenceNames(
        Set<String> cadenceNames,
        String accessLevel
    ) {
        return Database.query(
            'SELECT  Id, Cadence_Name__c, Lead_Score_Threshold__c, Status__c ' +
            'FROM Nurture_Track_Configuration__c ' +
            'WHERE Status__c = \'Active\' '+
            'AND Cadence_Name__c IN :cadenceNames ' +
            'WITH ' +
            String.escapeSingleQuotes(accessLevel)
        );
    }

    public List<Nurture_Track_Configuration__c> getNurtureTrack(
        String fieldsToQuery,
        String accessLevel
    ) {
        return Database.query(
            'SELECT ' +
             String.escapeSingleQuotes(fieldsToQuery) +
            'FROM Nurture_Track_Configuration__c ' +
            'WHERE Status__c = \'Active\' '+
            'WITH ' +
            String.escapeSingleQuotes(accessLevel)
        );
    }
}