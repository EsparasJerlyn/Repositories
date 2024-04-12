/**
 * @description Test Class for CourseConnectionTriggerHelper.cls
 * @see CourseConnectionTriggerHelper
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | kenneth.f.alsay                | September 22, 2023    | DEPP-6629              | Created file                 |
      |                                |                       |                        |                              |
      
 */
@isTest
public class CourseConnectionTriggerHelperTest {

    @TestSetup
    public static void testSetup(){
        //create test user
        TestDataFactory.generateTestUsers(
            new List<String>{ 'QUT_Program_Administrator'}
        );
        //create Course Connection Records
        List<hed__Course_Enrollment__c> courseConnectionRecords = TestDataFactory.createTestCourseConnectionRecordsByStatus(200, 'Active', 'Sent');
        CourseConnectionsDAO.newInstance().insertRecords(courseConnectionRecords, false, AccessLevel.USER_MODE);
    }
    
    @isTest
    public static void testSetLMSIntegrationStatusToNull(){
        System.RunAs(TestDataFactory.getProgramAdminUser()){
            List<hed__Course_Enrollment__c> courseConnectionRecords = CourseConnectionsDAO.newInstance().getCourseConnectionByStatus('Active', 'Sent');
            Test.StartTest();
            for(hed__Course_Enrollment__c courseConnection : courseConnectionRecords){
                courseConnection.hed__Status__c = 'Cancelled';
            }
            CourseConnectionsDAO.newInstance().updateRecords(courseConnectionRecords, false, AccessLevel.USER_MODE);
            Test.StopTest();
            
            //get Updated Records
            List<hed__Course_Enrollment__c> updatedCourseConnectionRecords = CourseConnectionsDAO.newInstance().getCourseConnectionByStatus('Cancelled', null);
            
            System.assertEquals(200, updatedCourseConnectionRecords.size(), 'Expected 200 Course Connection records with null LMS Integration Status');            
        }
    }
}