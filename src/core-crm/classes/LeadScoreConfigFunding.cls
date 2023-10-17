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
public with sharing class LeadScoreConfigFunding extends LeadScoreConfigBaseModel {

    private Integer iWillFundMyself = 0;
    private Integer myFamilyWillFundMyStudy = 0;
    private Integer iAlreadyHaveScholarship = 0;
    private Integer iAmNotSure = 0;
    private Integer companyFunded = 0;
    private Integer iNeedFullScholarship = 0;

    public Integer getIWillFundMyself() {
        return iWillFundMyself;
    }

    public void setIWillFundMyself(Integer iWillFundMyself) {
        this.iWillFundMyself = iWillFundMyself;
    }

    public Integer getMyFamilyWillFundMyStudy() {
        return myFamilyWillFundMyStudy;
    }

    public void setMyFamilyWillFundMyStudy(Integer myFamilyWillFundMyStudy) {
        this.myFamilyWillFundMyStudy = myFamilyWillFundMyStudy;
    }

    public Integer getIAlreadyHaveScholarship() {
        return iAlreadyHaveScholarship;
    }

    public void setIAlreadyHaveScholarship(Integer iAlreadyHaveScholarship) {
        this.iAlreadyHaveScholarship = iAlreadyHaveScholarship;
    }

    public Integer getIAmNotSure() {
        return iAmNotSure;
    }

    public void setIAmNotSure(Integer iAmNotSure) {
        this.iAmNotSure = iAmNotSure;
    }

    public Integer getCompanyFunded() {
        return companyFunded;
    }

    public void setCompanyFunded(Integer companyFunded) {
        this.companyFunded = companyFunded;
    }

    public Integer getINeedFullScholarship() {
        return iNeedFullScholarship;
    }

    public void setINeedFullScholarship(Integer iNeedFullScholarship) {
        this.iNeedFullScholarship = iNeedFullScholarship;
    }

}