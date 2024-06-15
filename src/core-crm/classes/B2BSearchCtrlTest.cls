/**
 * Test class to handle B2BSearchCtrl
 * 
 * @see B2BSearchCtrl
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | marygrace.li@qut.edu.au        | December 8, 2021      | DEPP-174               | Created file                 | 
      | roy.nino.s.regala              | February 04, 2022     | DEPP-213               | Updated to api methods       | 
 */
@isTest
public class B2BSearchCtrlTest {
    private static final String COMMUNITY_NAME = 'CCE';
    
    @testSetup static void setupMethod() {
        TestDataFactory.createTestAccount(true);
        TestDataFactoryUser.generateUserSystemAdministrator();
    }
	
    @isTest
    private static void productSearchTest() {
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
        System.runAs(PORTAL_SYS_ADMIN) {
            String communityId = B2BUtils.getCommunityIdByName(COMMUNITY_NAME);
            Account account = TestDataFactory.createTestAccount(false);
            
            ConnectApi.ProductSearchInput searchQuery;
            ConnectApi.ProductSearchResults result;

            Test.startTest();
            
            result = B2BSearchCtrl.searchProducts(communityId,account.Id, searchQuery);

            Test.stopTest();

            System.assertEquals(true, result == null, 'result is not null');
        }
    }
	
	@isTest
    private static void getSortRulesTest() {
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
        System.runAs(PORTAL_SYS_ADMIN) {
            String communityId = B2BUtils.getCommunityIdByName(COMMUNITY_NAME);

            ConnectApi.SortRulesCollection result;

            Test.startTest();
            
                result = B2BSearchCtrl.getSortRules(communityId);

            Test.stopTest();

            System.assertEquals(true, result == null, 'result is not null');
        }
    }
    
}