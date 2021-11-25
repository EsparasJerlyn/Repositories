/**
 * @description Test Class for GetCurriculumCtrl Class
 *
 * @see GetCurriculumCtrl
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA      | Change Summary                  |
      |---------------------------|-----------------------|-----------|---------------------------------|
      | aljohn.motas              | November 16, 2021     |  DEPP-649 | Created file                    | 
      | eccarius.karl.munoz       | November 23, 2021     |  DEPP-663 | Modified getCoursesTest to      |
      |                           |                       |           | align with GetCurriculumCtrl    | 
      |                           |                       |           | method update.                  | 
      |                           |                       |           |                                 | 
*/
@isTest(SeeAllData=false)
public class GetCurriculumCtrlTest {
    private static final String STR_QUTEX = 'QUTeX';
    private static User currentUser = TestDataFactory.createUserRecords(1, STR_QUTEX).iterator().next();
    private static final Integer NUMBER_OF_RECORDS = 100;

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
        courseList.addAll(TestDataFactory.createTestCourseRecords(NUMBER_OF_RECORDS, acc?.Id,null));
        courseList.addAll(TestDataFactory.createTestCourseRecords(NUMBER_OF_RECORDS, acc?.Id,prodReq?.Id));

        Test.startTest();
        insert(courseList);
        Test.stopTest();
    }   

    @IsTest
    private static void getCoursesTest(){
        Test.startTest();
        Integer expectedResult = 100;
        System.runAs(currentUser){
            Id prodReqId = [SELECT Id FROM Product_Request__c LIMIT 1]?.Id;
            GetCurriculumCtrl.ExistingCurriculumItems courseListToTest = GetCurriculumCtrl.getExistingCurriculumItems(prodReqId, true);                        
            System.assertEquals(expectedResult, courseListToTest.courses.size(), 'Course list did not match expected.');
        }
        Test.stopTest();
    }
}