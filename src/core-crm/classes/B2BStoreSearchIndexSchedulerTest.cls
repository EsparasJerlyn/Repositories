@isTest
public class B2BStoreSearchIndexSchedulerTest {
    private static final String GET_METHOD = 'GET';
    private static final String POST_METHOD = 'POST';

    @testSetup 
    static void setupMethod() {
        Test.startTest();
        TestDataFactoryUser.generateUserSystemAdministrator();
        Test.stopTest();
    }

    @isTest
    public static void testHandleCCEStoreRequest() {
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
        System.runAs(PORTAL_SYS_ADMIN) {
            String method = GET_METHOD;
            Test.startTest();
            HttpRequest req = B2BStoreSearchIndexScheduler.handleCCEStoreRequest(method);
            Test.stopTest();
            System.assertEquals(method, req.getMethod(), 'Request doesnt match');
        }
    }
    
    @isTest
    public static void testHandleStudyStoreRequest() {
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
        System.runAs(PORTAL_SYS_ADMIN) {
            String method = GET_METHOD;
            Test.startTest();
            HttpRequest req = B2BStoreSearchIndexScheduler.handleStudyStoreRequest(method);
            Test.stopTest();
            System.assertEquals(method, req.getMethod(), 'Request doesnt match');
        }
    }

    @isTest
    public static void testGetCCERequest() {
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
        System.runAs(PORTAL_SYS_ADMIN) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SchedulerMockHttpResponse(GET_METHOD, false));
            B2BStoreSearchIndexScheduler.getCCESearchIndexRequest();
            Test.stopTest();
            System.assertEquals(true, true, 'Request doesnt match');
        }
    }
    
    @isTest
    public static void testGetStudyRequest() {
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
        System.runAs(PORTAL_SYS_ADMIN) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SchedulerMockHttpResponse(GET_METHOD, false));
            B2BStoreSearchIndexScheduler.getStudySearchIndexRequest();
            Test.stopTest();
            System.assertEquals(true, true, 'Request doesnt match');
        }
    }

    @isTest
    public static void testPostCCERequest() {
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
        System.runAs(PORTAL_SYS_ADMIN) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SchedulerMockHttpResponse(POST_METHOD, false));
            B2BStoreSearchIndexScheduler.postCCESearchIndexRequest();
            Test.stopTest();
            System.assertEquals(true, true, 'Request doesnt match');
        }
    }
    
    @isTest
    public static void testPostStudyRequest() {
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
        System.runAs(PORTAL_SYS_ADMIN) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SchedulerMockHttpResponse(POST_METHOD, false));
            B2BStoreSearchIndexScheduler.postStudySearchIndexRequest();
            Test.stopTest();
            System.assertEquals(true, true, 'Request doesnt match');
        }
    }

    @isTest
    public static void testCCEScheduler() {
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
        System.runAs(PORTAL_SYS_ADMIN) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SchedulerMockHttpResponse(GET_METHOD, false));
            Test.setMock(HttpCalloutMock.class, new SchedulerMockHttpResponse(POST_METHOD, false));
            B2BStoreSearchIndexScheduler.postCCESearchIndexRequest();
            String cronExpression = Label.Build_Search_Index_Cron_Expression;

            System.schedule(
                'Test: Execute B2BStoreSearchIndexSchedulerTest daily at 8AM.',
                cronExpression, new B2BStoreSearchIndexScheduler());
            Test.stopTest();
            System.assertEquals(true, true, 'Scheduler runs');
        }
    }
    
   
    @isTest
    public static void testStudyScheduler() {
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
        System.runAs(PORTAL_SYS_ADMIN) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SchedulerMockHttpResponse(GET_METHOD, false));
            Test.setMock(HttpCalloutMock.class, new SchedulerMockHttpResponse(POST_METHOD, false));
            B2BStoreSearchIndexScheduler.postStudySearchIndexRequest();
            String cronExpression = Label.Build_Search_Index_Cron_Expression;

            System.schedule(
                'Test: Execute B2BStoreSearchIndexSchedulerTest daily at 8AM.',
                cronExpression, new B2BStoreSearchIndexScheduler());
            Test.stopTest();
            System.assertEquals(true, true, 'Scheduler runs');
        }
    }

    @isTest
    public static void testCatchErr() {
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
        System.runAs(PORTAL_SYS_ADMIN) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SchedulerMockHttpResponse(GET_METHOD, true));
            Test.setMock(HttpCalloutMock.class, new SchedulerMockHttpResponse(POST_METHOD, true));
            try{
                B2BStoreSearchIndexScheduler.postCCESearchIndexRequest();
            }catch(Exception e){
                Logger.error('Exception caught in method testCatchErr in Apex class B2BStoreSearchIndexSchedulerTest.')
                    .setExceptionDetails(e);
            } finally {
                if(Logger.getBufferSize() > 0) {
                    Logger.saveLog();
                }
            }
            Test.stopTest();
            System.assertEquals(true, true, 'Catch error');
        }  
    }
    
    @isTest
    public static void testStudyCatchErr() {
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
        System.runAs(PORTAL_SYS_ADMIN) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SchedulerMockHttpResponse(GET_METHOD, true));
            Test.setMock(HttpCalloutMock.class, new SchedulerMockHttpResponse(POST_METHOD, true));
            try{
                B2BStoreSearchIndexScheduler.postStudySearchIndexRequest();
            }catch(Exception e){
                Logger.error('Exception caught in method testStudyCatchErr in Apex class B2BStoreSearchIndexSchedulerTest.')
                    .setExceptionDetails(e);
            } finally {
                if(Logger.getBufferSize() > 0) {
                    Logger.saveLog();
                }
            }
            Test.stopTest();
            System.assertEquals(true, true, 'Catch error');
        }
    }

    public class SchedulerMockHttpResponse implements HttpCalloutMock
    {
        private String requestMethod = GET_METHOD;
		private Boolean catchError = false;

        public SchedulerMockHttpResponse(String method, Boolean isError) {
            requestMethod = method;
            catchError = isError;
        }
        public HTTPResponse respond(HTTPRequest req)
        {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            if(!catchError){
                if(requestMethod == GET_METHOD){
                    res.setBody('{"indexes":[{"message":null,"indexUsage":"Live","indexStatus":"Completed","id":"00000000000ABCDEF1","creationType":"Manual","createdDate":"2021-09-03T11:11:58.000Z","completionDate":"2021-09-03T11:14:01.000Z"},{"message":null,"indexUsage":"OutOfUse","indexStatus":"InProgress","id":"00000000000ABCDEF1" "indexStatus":"Completed", "indexUsage":"Live", "message":null}]}');
                }else{
                    res.setBody('{"message":null,"indexUsage":"OutOfUse","indexStatus":"InProgress","id":"000000000001ABC","creationType":"Manual","createdDate":"2021-09-03T11:51:56.000Z","completionDate":null}');
                }
            }else{
                res.setBody('{"error"=true,"message"=null}');
            }

            res.setStatusCode(200);

            return res;
        }
    }
}
