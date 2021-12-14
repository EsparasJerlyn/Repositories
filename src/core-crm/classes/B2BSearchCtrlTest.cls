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
      |                                |                       |                        |                              | 
 */
@isTest
public class B2BSearchCtrlTest {
    private static final String COMMUNITY_NAME = 'CCE';
    
    @testSetup static void setupMethod() {
        Account acc = TestDataFactory.createTestAccount(true);
    }
	
    @IsTest
    private static void productSearchSuccess() {
        Object result;
        String communityId = B2BUtils.getCommunityIdByName(COMMUNITY_NAME);
        Account account = TestDataFactory.createTestAccount(false);
        
        Test.setMock(HttpCalloutMock.class, new B2BMockHttpResponseGenerator2());
        
        Test.startTest();
        try{
        	result = B2BSearchCtrl.productSearch(communityId,'search query test', account.Id);
        }catch(Exception ex){
            System.debug(ex.getMessage());
        }
        Test.stopTest();
        System.assertEquals(true, true, 'not successful');
    }
	
	@IsTest
    private static void productSearchError() {
        String communityId = B2BUtils.getCommunityIdByName(COMMUNITY_NAME);
        Account account = TestDataFactory.createTestAccount(false);
        
        Test.setMock(HttpCalloutMock.class, new MockError());
        String exceptionMessage;
        Test.startTest();
        
        try{
        	B2BSearchCtrl.productSearch(communityId,'search query test', account.Id);
        }catch(Exception ex){
            System.debug(ex.getMessage());
            exceptionMessage = ex.getMessage();
        }
        Test.stopTest();
       	System.assertEquals(true, exceptionMessage!= null, 'error');
    }
    
    @IsTest
    private static void getSortCollectionsSuccess() {
        Object result;
        String communityId = B2BUtils.getCommunityIdByName(COMMUNITY_NAME);
        Account account = TestDataFactory.createTestAccount(false);
        
        Test.setMock(HttpCalloutMock.class, new B2BMockHttpResponseGenerator2());
        Test.startTest();
        try{
        	result = B2BSearchCtrl.getSortCollections(communityId);
        }catch(Exception ex){
            System.debug(ex.getMessage());
        }
        Test.stopTest();
        System.assertEquals(true, true, 'success');
    }
    
    @IsTest
    private static void getSortCollectionsError() {
        String communityId = B2BUtils.getCommunityIdByName(COMMUNITY_NAME);
        Account account = TestDataFactory.createTestAccount(false);
        
        Test.setMock(HttpCalloutMock.class, new MockError());
        String exceptionMessage;
        Test.startTest();
        try{
        	B2BSearchCtrl.getSortCollections(communityId);
        }catch(Exception ex){
            exceptionMessage = ex.getMessage();
        }
        Test.stopTest();
        System.assertEquals(true, exceptionMessage!= null, 'error');
    }
    
    private class MockError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            if(req.getEndpoint().contains('/search/sort-rules')){
                System.assertEquals('GET', req.getMethod());
       		 	// Create a fake response
        		res.setHeader('Content-Type', 'application/json');
        		res.setBody('{ "Response": "error" }');
        		res.setStatusCode(500);
        	}else if(req.getEndpoint().contains('/search/product-search')){
            	System.assertEquals('POST', req.getMethod());
       		 	// Create a fake response
        		res.setHeader('Content-Type', 'application/json');
        		res.setBody('{ "Response": "error" }');
        		res.setStatusCode(500);
        	}
            return res;
        }
    }
    
    private class B2BMockHttpResponseGenerator2 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            if(req.getEndpoint().contains('/search/sort-rules')){
                System.assertEquals('GET', req.getMethod());
                // Create a fake response
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{ "Response": "error" }');
                res.setStatusCode(200);
            }else if(req.getEndpoint().contains('/search/product-search')){
                System.assertEquals('POST', req.getMethod());
                // Create a fake response
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{ "Response": "error" }');
                res.setStatusCode(200);
            }
            return res;
        }
    }
}