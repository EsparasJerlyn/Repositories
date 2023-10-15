/**
 * @description Test class for LeadScoreConfigCountryTier
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
private class LeadScoreConfigCountryTierTest {
    @isTest
    private static void leadScoreConfigCountryTierTest() {//NOPMD test class for getter setter, user not needed

        LeadScoreConfigCountryTier data = new LeadScoreConfigCountryTier();

        data.setCountryTier1(10);
        data.setCountryTier2(10);
        data.setCountryTier3(10);
        data.setUntieredRestricted(10);
        data.setUntieredUnrestricted(10);

        System.assertEquals(10, data.getCountryTier1(), 'value did not match');
        System.assertEquals(10, data.getCountryTier2(), 'value did not match');
        System.assertEquals(10, data.getCountryTier3(), 'value did not match');
        System.assertEquals(10, data.getUntieredRestricted(), 'value did not match');
        System.assertEquals(10, data.getUntieredUnrestricted(), 'value did not match');
    }
}
