/**
 * @description Test Class for LeadScoreService
 *
 * @see LeadScoreService
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                               |
      |---------------------------|-----------------------|--------------|----------------------------------------------|
      | roy.nino.s.regala         | Oct 10,2023           | DEPP-5866    | Created file                                 |
*/
@isTest
private class LeadScoreServiceTest {
    @isTest
    private static void getLeadStatusTest() {// NOPMD Test class is testing service method no user needed
        System.assertEquals('New', LeadScoreService.getLeadStatus(10), 'status not matched');
        System.assertEquals('Engaging', LeadScoreService.getLeadStatus(50), 'status not matched');
        System.assertEquals('Nurturing', LeadScoreService.getLeadStatus(100), 'status not matched');
    }
}
