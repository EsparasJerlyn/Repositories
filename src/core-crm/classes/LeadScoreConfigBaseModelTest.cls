/**
 * @description Test class for LeadScoreConfigBaseModel
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
private class LeadScoreConfigBaseModelTest {
    @isTest
    private static void leadScoreConfigTest() {//NOPMD test class for getter setter, user not needed

        LeadScoreConfigIntEngPathway data = new LeadScoreConfigIntEngPathway();

        data.setMaxScore(10);
        data.setTimeLimit(10);

        System.assertEquals(10, data.getMaxScore(), 'value did not match');
        System.assertEquals(10, data.getTimeLimit(), 'value did not match');
    }
}
