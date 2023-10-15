/**
 * @description Test class for LeadScoreConfigIntDoubleDeg
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
private class LeadScoreConfigIntDoubleDegTest {
    @isTest
    private static void leadScoreConfigIntDoubleDegTest() {//NOPMD test class for getter setter, user not needed

        LeadScoreConfigIntDoubleDeg data = new LeadScoreConfigIntDoubleDeg();

        data.setYes(10);
        data.setNo(10);

        System.assertEquals(10, data.getNo(), 'value did not match');
        System.assertEquals(10, data.getYes(), 'value did not match');
    }
}
