/**
 * Test class to handle B2BGetInfo
 * 
 * @see B2BGetInfo
 * 
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | marygrace.li@qut.edu.au        | December 8, 2021      | DEPP-174               | Created file                 | 
      |                                |                       |                        |                              | 
 */

@isTest
private class B2BGetInfoTest {
    private static final String COMMUNITY_NAME = 'CCE';
  
    @testSetup static void setupMethod() {
        TestDataFactoryUser.generateUserSystemAdministrator();
        TestDataFactory.createTestAccount(true);
        TestDataFactory.createTestBuyerGroup(true);
        TestDataFactory.createTestProduct2(true);  
    }
    
    @isTest
    private static void getProductAndPriceTest() {  
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            Product2 prd = TestDataFactory.createTestProduct2(false);
            Account account = TestDataFactory.createTestAccount(false);
            String communityId = B2BUtils.getCommunityIdByName(COMMUNITY_NAME);
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new B2BReqMockHttpResponse());
            Object result = B2BGetInfo.getProduct(communityId,prd.Id,account.Id);
            Object result2 = B2BGetInfo.getProductPrice(communityId,prd.Id,account.Id);
            Test.stopTest();
            
            System.assertEquals(true, result == null, 'result is not null');
            System.assertEquals(true, result2 == null, 'result is not null');
        }
    }

    @isTest
    private static void addToCartAndGetCartSummaryTest() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            Account account = TestDataFactory.createTestAccount(false);
            String communityId = B2BUtils.getCommunityIdByName(COMMUNITY_NAME);
            
            Test.startTest();
            B2BGetInfo.WishlistDetails details = new B2BGetInfo.WishlistDetails();
            details.communityId = communityId;
            details.productId = '';
            details.quantity = '1';
            details.effectiveAccountId = account.Id;
            ConnectApi.CartItem result = B2BGetInfo.addToCart(details);
            ConnectApi.CartSummary resultSummary = B2BGetInfo.getCartSummary(communityId,account.Id);
            Test.stopTest();
            
            System.assertEquals(true, resultSummary == null, 'result is not null');
            System.assertEquals(true, result == null, 'result is not null');
        }
    }

    @isTest
    private static void createAndAddToListTest() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            Product2 prd = TestDataFactory.createTestProduct2(false);
            Account account = TestDataFactory.createTestAccount(false);
            String communityId = B2BUtils.getCommunityIdByName(COMMUNITY_NAME);
        
            Test.startTest();
            B2BGetInfo.WishlistDetails details = new B2BGetInfo.WishlistDetails();
            details.communityId = communityId;
            details.productId = prd.Id;
            details.wishlistName = 'Wishlist Test';
            details.effectiveAccountId = account.Id;
            ConnectApi.Wishlist result = B2BGetInfo.createAndAddToList(details);
            Test.stopTest();
            
            System.assertEquals(true, result == null, 'result is not null');
        }
    }

    @isTest
    private static void getOrCreateActiveCartSummaryTest() { 
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            Account account = TestDataFactory.createTestAccount(false);
            String communityId = B2BUtils.getCommunityIdByName(COMMUNITY_NAME);
            
            Test.startTest();
            B2BGetInfo.WishlistDetails details = new B2BGetInfo.WishlistDetails();
            details.communityId = communityId;
            details.productId = '';
            details.quantity = '1';
            details.effectiveAccountId = account.Id;
            ConnectApi.CartItem result = B2BGetInfo.addToCart(details);
            ConnectApi.CartSummary resultSummary = B2BGetInfo.getOrCreateActiveCartSummary(communityId,account.Id);
            Test.stopTest();
            
            System.assertEquals(true, resultSummary == null, 'result is not null');
            System.assertEquals(true, result == null, 'result is not null');
        }
    }
    
    public class B2BReqMockHttpResponse implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req){
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{}');
            res.setStatusCode(200);
            return res;
        }
    }
}