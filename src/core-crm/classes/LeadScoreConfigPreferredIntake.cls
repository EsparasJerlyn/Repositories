/**
 * @description Model Class for Preferred Intake Lead Score Configuration
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | October 02, 2023      | DEPP-5866              | Created file                 |
      |                                |                       |                        |                              |
 */
public with sharing class LeadScoreConfigPreferredIntake extends LeadScoreConfigBaseModel{
    private Integer isThisYear = 0;
    private Integer isNextYear = 0;
    private Integer isNotBlank = 0;
    private Integer isBlank = 0;

    public Integer getIsThisYear() {
        return isThisYear;
    }

    public void setIsThisYear(Integer isThisYear) {
        this.isThisYear = isThisYear;
    }

    public Integer getIsNextYear() {
        return isNextYear;
    }

    public void setIsNextYear(Integer isNextYear) {
        this.isNextYear = isNextYear;
    }

    public Integer getIsNotBlank() {
        return isNotBlank;
    }

    public void setIsNotBlank(Integer isNotBlank) {
        this.isNotBlank = isNotBlank;
    }

    public Integer getIsBlank() {
        return isBlank;
    }

    public void setIsBlank(Integer isBlank) {
        this.isBlank = isBlank;
    }
}