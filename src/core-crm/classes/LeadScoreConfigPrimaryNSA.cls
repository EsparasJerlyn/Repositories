/**
 * @description Model Class for Primary NSA Lead Score Configuration
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
public with sharing class LeadScoreConfigPrimaryNSA extends LeadScoreConfigBaseModel{
    private Integer isNotBlank = 0;
    private Integer isUnsure = 0;
    private Integer isBlank = 0;

    public Integer getIsNotBlank() {
        return isNotBlank;
    }

    public void setIsNotBlank(Integer isNotBlank) {
        this.isNotBlank = isNotBlank;
    }

    public Integer getIsUnsure() {
        return isUnsure;
    }

    public void setIsUnsure(Integer isUnsure) {
        this.isUnsure = isUnsure;
    }

    public Integer getIsBlank() {
        return isBlank;
    }

    public void setIsBlank(Integer isBlank) {
        this.isBlank = isBlank;
    }
}