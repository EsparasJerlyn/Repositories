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
private class LeadScoreConfigProgEngagmentTest {
    @isTest
    private static void leadScoreConfigProgEngagementTest() {//NOPMD test class for getter setter, user not needed

        LeadScoreConfigProgEngagment leadScoreConfigProgEng = new LeadScoreConfigProgEngagment();

        leadScoreConfigProgEng.setProgramEngAttendance(10);

        System.assertEquals(10, leadScoreConfigProgEng.getProgramEngAttendance(), 'value did not match');
    }
}
