/**
 * @description Test class for LeadScoreConfigFunding
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | October 06, 2023      | DEPP-5866              | Created file                 |
      |                                |                       |                        |                              |
 */
@isTest
private class LeadScoreConfigFundingTest {
    @isTest
    private static void leadScoreConfigFundingTest() {//NOPMD test class for getter setter, user not needed

        LeadScoreConfigFunding data = new LeadScoreConfigFunding();

        data.setCompanyFunded(10);
        data.setIAlreadyHaveScholarship(10);
        data.setIAmNotSure(10);
        data.setINeedFullScholarship(10);
        data.setIWillFundMyself(10);
        data.setMyFamilyWillFundMyStudy(10);

        System.assertEquals(10, data.getCompanyFunded(), 'value did not match');
        System.assertEquals(10, data.getIAlreadyHaveScholarship(), 'value did not match');
        System.assertEquals(10, data.getIAmNotSure(), 'value did not match');
        System.assertEquals(10, data.getINeedFullScholarship(), 'value did not match');
        System.assertEquals(10, data.getIWillFundMyself(), 'value did not match');
        System.assertEquals(10, data.getMyFamilyWillFundMyStudy(), 'value did not match');
    }
}
