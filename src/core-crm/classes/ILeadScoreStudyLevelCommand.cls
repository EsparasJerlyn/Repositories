/**
 * @description Command interface for Lead Score by Study Level
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | September 24, 2023    | DEPP-5866              | Created file                 |
      |                                |                       |                        |                              |
 */
public interface ILeadScoreStudyLevelCommand {
    List<Lead_Score_Detail__c> processStudyLevel(LeadScoreCalculatorService.LeadScoreCalculatorParams leadScoreCalculatorParams);
}