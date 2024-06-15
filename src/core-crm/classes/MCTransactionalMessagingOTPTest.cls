/**
 * @description Test Class for 
 * @see ..MCTransactionalMessagingOTP
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                    |
      |---------------------------|-----------------------|----------------------|-----------------------------------|
      | rhea.b.torres             | June 06, 2022         | DEPP-2861            | Created File                      |
      |                           |                       |                      |                                   |
 */
@isTest
public with sharing class MCTransactionalMessagingOTPTest {
    
    @testSetup
    public static void setUp(){
        Test.startTest();
        TestDataFactoryUser.generateUserSystemAdministrator();
        Test.stopTest();
        final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
        System.runAs(PORTAL_SYS_ADMIN){
            // Create Custom Setting
            MC_Messaging_OTP_Setting__c setting = TestDataFactory.createOTPCustomSetting();
            insert setting;
        }
    }
    
    @isTest
    public static void sendSMSOTPTest(){
        final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
        System.runAs(PORTAL_SYS_ADMIN){
            Test.setMock(HttpCalloutMock.class, new ReqMockHttpResponse());
            Test.startTest();
            String mobile = '12345678910';
            String otp = MCTransactionalMessagingOTP.sendSMSOTP(mobile);
            System.assert(otp!=null, 'No OTP generated.');
            Test.stopTest();
        } 
    }
    
    public class ReqMockHttpResponse implements HttpCalloutMock {
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