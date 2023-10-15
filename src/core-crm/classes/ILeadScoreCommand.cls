/**
 * @description Interface for Lead Score Command Framework
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | October 05, 2023      | DEPP-5866              | Created file                 |
      |                                |                       |                        |                              |
 */

public interface ILeadScoreCommand {
    void executeCalculation(LeadScoreCalculatorService.ObjectMap objectMap, Set<Id> contactLeadIds);
}