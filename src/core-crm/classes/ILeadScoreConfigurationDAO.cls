/**
 * @description Interface for Risk DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | neil.s.h.lesidan               | August 30, 2023       | DEPP-5835              | Created file
 */
public interface ILeadScoreConfigurationDAO extends DmlInterface {
    List<Lead_Score_Configuration__c> getLeadScoreConfigByCitizenshipStudyLvl(
        String citizenshipStatus,
        String primaryStudyLevel
    );
}
