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
   
    @testSetup static void setupMethod() {
        TestDataFactoryUser.generateUserSystemAdministrator();
    }
    
  	@isTest
    public static void resolveCommunityIdToWebstoreId() {
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
        System.runAs(PORTAL_SYS_ADMIN) {
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
            System.assertEquals(null, exceptionMessage, 'Network Id doesnt match');
        }
    }
    
    @isTest
    static void getAPIVersionTest() {
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
        System.runAs(PORTAL_SYS_ADMIN) {
            Test.startTest();
            Decimal retVal = B2BUtils.getAPIVersion('B2BUtilsTest');
            Test.stopTest();

            List<ApexClass> results = [SELECT ApiVersion FROM ApexClass WHERE Name = 'B2BUtilsTest'];
            System.assertEquals(results.get(0).ApiVersion, retVal, 'API version doesnt match');
        }
    }
    
    @isTest
    static void getCommunityIdByNameTest() {
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
        System.runAs(PORTAL_SYS_ADMIN) {
            Test.startTest();
            String retVal = B2BUtils.getCommunityIdByName('Test');
            Test.stopTest();

            System.assertEquals(null, retVal, 'Community name doesnt match');
        }
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