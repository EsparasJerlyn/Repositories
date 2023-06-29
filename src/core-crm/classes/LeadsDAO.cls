/**
 * @description DAO Class for Lead Object. Contains soql and constants related to the Lead object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | rhea.b.torres                  | April 25, 2023        | DEPP-5567              | Created file
 */
public inherited sharing class LeadsDAO extends DmlBase implements ILeadsDAO {
    /**
     * Lead Constants
     */
    public static final String CCE_CORPORATE_PARTNER = 'CCE Corporate Partner';

    public static ILeadsDAO newInstance() {
        return (ILeadsDAO) ImplementationSelector.DAO.newInstance(Lead.SObjectType);
    }

    public Schema.SObjectType getSObjectType() {
        return Lead.SObjectType;
    }

    public List<Lead> getExistingUnconvertedLeadsByEmail(
        Set<String> allEmailsToMatch,
        Set<Id> excludedLeadsRecordsSet,
        String accessLevel
    ) {
        return Database.query(
            'SELECT  Id, Email, Work_Email__c, IsConverted ' +
                'FROM Lead ' +
                'WHERE Id NOT IN: excludedLeadsRecordsSet ' +
                'AND (Email IN: allEmailsToMatch ' +
                'OR Work_Email__c IN: allEmailsToMatch) ' +
                'WITH ' +
                String.escapeSingleQuotes(accessLevel)
        );
    }

    public static List<Lead> getLeadsWithLimit(Integer recordsCount) {
        return [
            SELECT Email, Work_Email__c
            FROM Lead
            WITH USER_MODE
            LIMIT :recordsCount
        ];
    }
}
