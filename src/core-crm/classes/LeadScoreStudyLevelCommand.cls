/**
 * @description Invoker class for Lead Score Study Level Command
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | September 25, 2023    | DEPP-5866              | Created file                 |
      |                                |                       |                        |                              |
 */
public with sharing class LeadScoreStudyLevelCommand {

    ILeadScoreStudyLevelCommand leadScoreStudyLevelCommand;

    public LeadScoreStudyLevelCommand(ILeadScoreStudyLevelCommand leadScoreStudyLevelCommand) {
        this.leadScoreStudyLevelCommand = leadScoreStudyLevelCommand;
    }

    public List<Lead_Score_Detail__c> processStudyLevel(LeadScoreCalculatorService.LeadScoreCalculatorParams leadScoreCalculatorParams){
        List<Lead_Score_Detail__c> response = new List<Lead_Score_Detail__c>();
        if(leadScoreStudyLevelCommand != null){
            response = leadScoreStudyLevelCommand.processStudyLevel(leadScoreCalculatorParams);
        }
        return response;
    }

}