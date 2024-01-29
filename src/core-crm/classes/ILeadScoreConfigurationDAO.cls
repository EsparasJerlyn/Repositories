/**
 * @description Interface for Risk DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | neil.s.h.lesidan               | August 30, 2023       | DEPP-5835              | Created file                 |
 *    | eccarius.munoz                 | October 05, 2023      | DEPP-5866              | Added getLeadScoreConfig     |
 */
public interface ILeadScoreConfigurationDAO extends DmlInterface {
    List<Lead_Score_Configuration__c> getLeadScoreConfigByCitizenshipStudyLvl(
        String citizenshipStatus,
        String primaryStudyLevel
    );

    List<Lead_Score_Configuration__c> getLeadScoreConfigByRecordTypeIds(AccessLevel accessLevel, Set<Id> recordTypes);
    
    List<Lead_Score_Configuration__c> getLeadScoreConfigsById(Set<Id> leadScoreConfigIds, List<String> fields, AccessLevel accessLevel);

    Database.QueryLocator queryLocatorLeadScoreConfigByIds(Set<Id> leadScoreConfigIds);

    List<Lead_Score_Configuration__c> getCategoryLeadScoreConfigsById(Set<Id> leadScoreConfigIds, List<String> fields, AccessLevel accessLevel);
} 
