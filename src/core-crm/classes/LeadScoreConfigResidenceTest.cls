/**
 * @description Test class for LeadScoreConfigResidence
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
private class LeadScoreConfigResidenceTest {
    @isTest
    private static void leadScoreConfigResidenceTest() {//NOPMD test class for getter setter, user not needed

        LeadScoreConfigResidence leadScoreConfigRes = new LeadScoreConfigResidence();

        leadScoreConfigRes.setAustraliaOnshore(10);
        leadScoreConfigRes.setNonAustraliaOffShore(10);

        System.assertEquals(10, leadScoreConfigRes.getAustraliaOnshore(), 'value did not match');
        System.assertEquals(
            10,
            leadScoreConfigRes.getNonAustraliaOffShore(),
            'value did not match'
        );
    }
}
