/**
 * @description Test class for LeadScoreConfigMktgConsent
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
private class LeadScoreConfigMktgConsentTest {
    @isTest
    private static void leadScoreConfigTest() {//NOPMD test class for getter setter, user not needed

        LeadScoreConfigMktgConsent data = new LeadScoreConfigMktgConsent();

        data.setIsBlank(10);
        data.setYes(10);

        System.assertEquals(10, data.getIsBlank(), 'value did not match');
        System.assertEquals(10, data.getYes(), 'value did not match');
    }
}
