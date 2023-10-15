/**
 * @description Queueable class for Lead Score Calculation
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | October 05, 2023      | DEPP-5866              | Created file                 |
      |                                |                       |                        |                              |
 */
public with sharing class LeadScoreQueueableCall implements Queueable{
    ILeadScoreCommand leadScoreCommand;
    LeadScoreCalculatorService.ObjectMap objectMap;
    Set<Id> contactLeadIds;

    public LeadScoreQueueableCall(ILeadScoreCommand leadScoreCommand, LeadScoreCalculatorService.ObjectMap objectMap, Set<Id> contactLeadIds) {
        this.leadScoreCommand = leadScoreCommand;
        this.objectMap = objectMap;
        this.contactLeadIds = contactLeadIds;
    }

    public void execute(QueueableContext context) {
        if (leadScoreCommand != null && objectMap != null && contactLeadIds!=null) {
            leadScoreCommand.executeCalculation(objectMap, contactLeadIds);
        }     
    }
    
}