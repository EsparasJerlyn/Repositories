/**
 * @description Model Class for Email Interaction Lead Score Configuration
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | October 26, 2023      | DEPP-5866              | Created file                 |
      |                                |                       |                        |                              |
 */
public with sharing class LeadScoreConfigEmailInteract extends LeadScoreConfigBaseModel{
    private Integer hasClickedEmail = 0;

    public Integer getHasClickedEmail() {
        return hasClickedEmail;
    }

    public void setHasClickedEmail(Integer hasClickedEmail) {
        this.hasClickedEmail = hasClickedEmail;
    }
}