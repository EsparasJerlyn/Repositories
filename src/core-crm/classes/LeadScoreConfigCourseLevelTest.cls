/**
 * @description Test class for LeadScoreConfigCourseLevel
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
private class LeadScoreConfigCourseLevelTest {
    @isTest
    private static void leadScoreConfigCourseLevelTest() {//NOPMD test class for getter setter, user not needed

        LeadScoreConfigCourseLevel data = new LeadScoreConfigCourseLevel();

        data.setStudyLevelExchange(10);
        data.setStudyLevelHigherDeg(10);
        data.setStudyLevelIsBlank(10);
        data.setStudyLevelPostGrad(10);
        data.setStudyLevelShortCoursePD(10);
        data.setStudyLevelUnderGrad(10);

        System.assertEquals(10, data.getStudyLevelExchange(), 'value did not match');
        System.assertEquals(10, data.getStudyLevelHigherDeg(), 'value did not match');
        System.assertEquals(10, data.getStudyLevelIsBlank(), 'value did not match');
        System.assertEquals(10, data.getStudyLevelPostGrad(), 'value did not match');
        System.assertEquals(10, data.getStudyLevelShortCoursePD(), 'value did not match');
        System.assertEquals(10, data.getStudyLevelUnderGrad(), 'value did not match');
    }
}
