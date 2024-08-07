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
@isTest
public class GetCurriculumCtrlTest {
    private static final Integer NUMBER_OF_RECORDS = 100;
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();

    @testSetup static void setupMethod() {
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        Account acc = TestDataFactory.createTestAccountRecords(1).iterator().next();
        acc.RecordTypeId = ACCT_UNIV_DEP_ID;
        acc.Organization_Unit_Level__c = '2';
        insert acc;

        List<Contact> conList = TestDataFactory.createTestContactRecords(1);
        insert conList;

        List<Opportunity> oppList = TestDataFactory.createClosedWonOpportunities(1,acc?.Id,conList.iterator().next()?.Id);
        insert oppList;

        Product_Specification__c prodSpec = TestDataFactory.retrieveCCEProductSpecifications().iterator().next();

        Product_Request__c prodReq = TestDataFactory.createTestProductRequestRecords(1,prodSpec?.Id).iterator().next();
        insert prodReq;

        List<hed__Course__c> courseList = new List<hed__Course__c>();
        courseList.addAll(TestDataFactory.createTestCourseRecords(NUMBER_OF_RECORDS, acc?.Id,null));
        courseList.addAll(TestDataFactory.createTestCourseRecords(NUMBER_OF_RECORDS, acc?.Id,prodReq?.Id));

        Test.startTest();
        insert(courseList);
        Test.stopTest();
    }

    @isTest
    private static void getCoursesTest(){
        Test.startTest();
        Integer expectedResult = 100;
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Id prodReqId = [SELECT Id FROM Product_Request__c LIMIT 1]?.Id;
            GetCurriculumCtrl.ExistingCurriculumItems courseListToTest = GetCurriculumCtrl.getExistingCurriculumItems(prodReqId, true);
            System.assertEquals(expectedResult, courseListToTest.courses.size(), 'Course list did not match expected.');
        }
        Test.stopTest();
    }
}