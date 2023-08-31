/**
 * @description DAO Class for Risk Object. Contains soql and constants related to the Risk object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | neil.s.h.lesidan               | August 30, 2023       | DEPP-5835              | Created file
 */
public inherited sharing class LeadScoreConfigurationDAO extends DmlBase implements ILeadScoreConfigurationDAO {
    public Schema.SObjectType getSObjectType() {
        return Lead_Score_Configuration__c.SObjectType;
    }

    public static ILeadScoreConfigurationDAO newInstance() {
        return (ILeadScoreConfigurationDAO) ImplementationSelector.DAO.newInstance(Lead_Score_Configuration__c.SObjectType);
    }

    public List<Lead_Score_Configuration__c> getLeadScoreConfigByCitizenshipStudyLvl(
        String citizenshipStatus,
        String primaryStudyLevel
    ) {
        return [
            SELECT Id, Max_Score__c, Study_Level__c, Domestic_International__c
            FROM Lead_Score_Configuration__c
            WHERE Domestic_International__c =: citizenshipStatus
            AND Study_Level__c =: primaryStudyLevel
            WITH USER_MODE
        ];
    }
}
