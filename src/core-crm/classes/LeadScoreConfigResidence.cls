/**
 * @description Model Class for Residence Lead Score Configuration
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
public with sharing class LeadScoreConfigResidence extends LeadScoreConfigBaseModel{

    private Integer australiaOnshore = 0;
    private Integer nonAustraliaOffShore = 0;

    public Integer getAustraliaOnshore() {
        return australiaOnshore;
    }

    public void setAustraliaOnshore(Integer australiaOnshore) {
        this.australiaOnshore = australiaOnshore;
    }

    public Integer getNonAustraliaOffShore() {
        return nonAustraliaOffShore;
    }

    public void setNonAustraliaOffShore(Integer nonAustraliaOffShore) {
        this.nonAustraliaOffShore = nonAustraliaOffShore;
    }
}