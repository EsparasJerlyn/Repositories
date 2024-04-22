/**
 * @description Model Class for Country Tier Lead Score Configuration
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | October 02, 2023      | DEPP-5866              | Created file                 |
      | johanna.a.gibas                | November 24, 2023     | DEPP-7143              | Added Developed Nations      |
 */
public with sharing class LeadScoreConfigCountryTier extends LeadScoreConfigBaseModel{
    private Integer countryTier1 = 0;
    private Integer countryTier2 = 0;
    private Integer countryTier3 = 0;
    private Integer untieredUnrestricted = 0;
    private Integer untieredRestricted = 0;
    private Integer developedNations = 0;
    private Integer unlisted = 0;

    public Integer getCountryTier1() {
        return countryTier1;
    }

    public void setCountryTier1(Integer countryTier1) {
        this.countryTier1 = countryTier1;
    }

    public Integer getCountryTier2() {
        return countryTier2;
    }

    public void setCountryTier2(Integer countryTier2) {
        this.countryTier2 = countryTier2;
    }

    public Integer getCountryTier3() {
        return countryTier3;
    }

    public void setCountryTier3(Integer countryTier3) {
        this.countryTier3 = countryTier3;
    }

    public Integer getUntieredUnrestricted() {
        return untieredUnrestricted;
    }

    public void setUntieredUnrestricted(Integer untieredUnrestricted) {
        this.untieredUnrestricted = untieredUnrestricted;
    }

    public Integer getUntieredRestricted() {
        return untieredRestricted;
    }

    public void setUntieredRestricted(Integer untieredRestricted) {
        this.untieredRestricted = untieredRestricted;
    }

    public Integer getDevelopedNations() {
        return developedNations;
    }

    public void setDevelopedNations(Integer developedNations) {
        this.developedNations = developedNations;
    }

    public Integer getUnlisted() {
        return unlisted;
    }

    public void setUnlisted(Integer unlisted) {
        this.unlisted = unlisted;
    }
}