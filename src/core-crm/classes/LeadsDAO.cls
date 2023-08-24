/**
 * @description DAO Class for Lead Object. Contains soql and constants related to the Lead object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                               |
      |--------------------------------|-----------------------|------------------------|----------------------------------------------|
      | rhea.b.torres                  | April 25, 2023        | DEPP-5567              | Created file                                 |
      | mark.j.mahilum                 | June 26,2023          | DEPP-5846              | Added new method getExistingUnconvertedLeads |
      | roy.nino.s.regala              | Aug 09, 2023          | DEPP-5677              | Added new method             |
 */
public inherited sharing class LeadsDAO extends DmlBase implements ILeadsDAO {
    /**
     * Lead Constants
     */
    public static final String CCE_CORPORATE_PARTNER = 'CCE Corporate Partner';
    public static final String EXPLORE_JOURNEY_STATUS = 'Explore';
    public static final String APPLY_JOURNEY_STATUS = 'Apply';
    public static final String OFFER_JOURNEY_STATUS = 'Offer';
    public static final String ACCEPT_ADMIT_JOURNEY_STATUS = 'Accept-Admit';
    public static final String STUDY_JOURNEY_STATUS = 'Study';
    public static final String LEARNER_LEAD_TYPE = 'Learner';

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
        return [//NOPMD
            SELECT Email, Work_Email__c, Status, Future_Student_Journey_Status__c, Can_Nurture__c
            FROM Lead
            WITH SYSTEM_MODE//Only used in test class to verify record insert/update
            LIMIT :recordsCount
        ];
    }

    public List<Lead> getExistingUnconvertedLeads(
        Set<String> allEmailsToMatch,
        String accessLevel
    ) {
        return Database.query(
            'SELECT  Id, Email, Work_Email__c, IsConverted ' +
                'FROM Lead ' +
                'WHERE IsConverted = FALSE ' +
                'AND (Email IN: allEmailsToMatch ' +
                'OR Work_Email__c IN: allEmailsToMatch) ' +
                'WITH ' +
                String.escapeSingleQuotes(accessLevel)
        );
    }

    public static List<Lead> getLearnerLeadsByCalculatedCadences(Set<String> calculatedCadences) {
        return [//NOPMD
            SELECT
                Id,
                Name,
                hed__Gender__c,
                Email,
                Lead_Score__c,
                Marketing_Segmentation__r.My_Country_Of_Residency__c,
                Marketing_Segmentation__r.My_Country_Of_Citizenship__c
            FROM Lead
            WHERE
                Lead_Type__c = 'Learner'
                AND Calculated_Cadence__c IN :calculatedCadences
                AND IsConverted = FALSE
                AND Can_Nurture__c = TRUE
            WITH USER_MODE
        ];
    }
}
