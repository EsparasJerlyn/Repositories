/**
 * @description Test class for LeadScoreConfigMatchMySkills
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
private class LeadScoreConfigMatchMySkillsTest {
    @isTest
    private static void leadScoreConfigTest() {//NOPMD test class for getter setter, user not needed

        LeadScoreConfigMatchMySkills data = new LeadScoreConfigMatchMySkills();

        data.setCompleted(10);

        System.assertEquals(10, data.getCompleted(), 'value did not match');
    }
}
