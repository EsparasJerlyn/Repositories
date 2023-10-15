/**
 * @description Model Class for Lead Score Configuration
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | September 22, 2023    | DEPP-5866              | Created file                 |
      |                                |                       |                        |                              |
 */
public with sharing abstract class LeadScoreConfigBaseModel {
    private Integer timeLimit;
    private Integer maxScore  = 0;

    public Integer getTimeLimit(){
        return timeLimit;
    }

    public void setTimeLimit(Integer timeLimit){
        this.timeLimit = timeLimit;
    }

    public Integer getMaxScore(){
        return maxScore;
    }

    public void setMaxScore(Integer maxScore){
        this.maxScore = maxScore;
    }
}