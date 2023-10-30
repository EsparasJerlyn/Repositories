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
private class LeadScoreConfigDownloadPDFTest {
    @isTest
    private static void leadScoreConfigDownloadPDFTest() {//NOPMD test class for getter setter, user not needed

        LeadScoreConfigDownloadPDF data = new LeadScoreConfigDownloadPDF();

        data.setCourseGuide(10);
        data.setCoursePagePDF(10);
        data.setWelcomeGuide(10);

        System.assertEquals(10, data.getCourseGuide(), 'value did not match');
        System.assertEquals(10, data.getCoursePagePDF(), 'value did not match');
        System.assertEquals(10, data.getWelcomeGuide(), 'value did not match');
    }
}
