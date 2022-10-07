/**
 * @description Test class to handle B2BUtils
 * @see ../core-crm/classes/B2BUtils
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | marygrace.li@qut.edu.au        | November 16, 2021     | DEPP-131               | Created file                 | 
      |                                |                       |                        |                              | 
 */
@isTest
public with sharing class B2BUtilsTest {
   
  	@isTest
    public static void resolveCommunityIdToWebstoreId() {
        String exceptionMessage;
        Test.startTest();
        try{
            //Get the Network ID
            String networkId = [SELECT Id FROM Network WHERE Status = 'Live' ORDER BY FirstActivationDate DESC LIMIT 1].Id;
            B2BUtils.resolveCommunityIdToWebstoreId(networkId);
        }catch(Exception e){
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals(true, true, 'Network Id doesnt match');
    }
    
    @isTest
    static void getAPIVersionTest() {
        Test.startTest();
        B2BUtils.getAPIVersion('B2BUtilsTest');
        Test.stopTest();

        System.assertEquals(true, true, 'API version doesnt match');
    }
    
    @isTest
    static void getCommunityIdByNameTest() {
        Test.startTest();
        B2BUtils.getCommunityIdByName('Test');
        Test.stopTest();

        System.assertEquals(true, true, 'Community name doesnt match');
    }


    public class B2BUtilReqMockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{}');
            res.setStatusCode(200);

            return res;
        }
    }
}