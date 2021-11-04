/**
 * @description Tests the CreateCoursesCtrl class 
 *
 * @see CreateCoursesCtrl
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA     | Change Summary                  |
      |---------------------------|-----------------------|----------|---------------------------------|
      | angelika.j.s.galang       | October 25, 2021      | DEPP-383 | Created file                    | 
      |                           |                       |          |                                 |
*/
@IsTest(SeeAllData = false)
private class CreateCoursesCtrlTest {

    private static final String STR_QUTEX = 'QUTeX';
    private static User currentUser = TestDataFactory.createUserRecords(1, STR_QUTEX).iterator().next();

    @testSetup static void setupMethod() {
        Account acc = TestDataFactory.createTestAccountRecords(1).iterator().next();
        insert acc;

        List<Contact> conList = TestDataFactory.createTestContactRecords(1);
        insert conList;

        List<Opportunity> oppList = TestDataFactory.createTestOpportunityRecords(1,acc?.Id,conList.iterator().next()?.Id);
        insert oppList;

        Product_Specification__c prodSpec = TestDataFactory.createTestProductSpecsRecords(1,conList,oppList).iterator().next();
        insert prodSpec;

        Product_Request__c prodReq = TestDataFactory.createTestProductRequestRecords(1,new List<Product_Request__c>(),prodSpec?.Id).iterator().next();
        insert prodReq;

        List<hed__Course__c> courseList = new List<hed__Course__c>();
        courseList.addAll(TestDataFactory.createTestCourseRecords(50,acc?.Id,null));
        courseList.addAll(TestDataFactory.createTestCourseRecords(50,acc?.Id,prodReq?.Id));

        Test.startTest();
        insert(courseList);
        Test.stopTest();
    }   

    @IsTest
    private static void getCoursesTest(){
        Test.startTest();
        System.runAs(currentUser){
            Id prodReqId = [SELECT Id FROM Product_Request__c LIMIT 1]?.Id;
            List<hed__Course__c> courseListToTest = CreateCoursesCtrl.getCourses(prodReqId);
            
            System.assertEquals(50, courseListToTest.size(), 'Course list did not match expected.');
        }
        Test.stopTest();
    }

}
