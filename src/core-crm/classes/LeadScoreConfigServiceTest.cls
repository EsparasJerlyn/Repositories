/**
 * @description Test class for LeadScoreConfigService
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
private class LeadScoreConfigServiceTest {

    @isTest 
    private static void getLeadScoreConfigTest(){ //NOPMD test class is mocked user is not needed
        ImplementationSelector.DAO.setMock(new LeadScoreConfigurationDAOMock());
        LeadScoreConfigurationDAO.newInstance().insertRecords(TestDataFactory.createCategoryLeadScoreConfigurations(),true,AccessLevel.USER_MODE);
        LeadScoreConfigService.LeadScoreConfigReference leadScoreConfigReference = new LeadScoreConfigService.LeadScoreConfigReference();
        Test.startTest();
        System.assert(LeadScoreConfigService.getLeadScoreConfig() != null,'lead score config was not retrieved');
        Test.stopTest();
    }
    
}