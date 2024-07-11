/**
 * @description Tests the Financial Split Controller Class
 *
 * @see FinancialSplitCtrl
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA      | Change Summary                  |
      |---------------------------|-----------------------|-----------|---------------------------------|
      | marlon.vasquez            | February 15, 2022     | DEPP1834  | Created file                    |
      | mark.j.mahilum            | June 01, 2023         | DEPP-5686 | Methods updated to DAO          |
*/
@isTest
private class FinancialSplitCtrlTest {

    private static final String QUTEXPROD = System.Label.QUT_GSB;
    private static final String COURSE_API_NAME = hed__Course__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName();
    private static final String COURSE_PR_FIELD = 'ProductRequestID__c';
    private static final String FS_COURSE_FIELD = 'Course__c';

    @testSetup static void setupMethod() {
        Test.startTest();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        Test.stopTest();
        Account acc = TestDataFactory.createTestAccountRecords(1).iterator().next();
        acc.RecordTypeId = AccountsDAO.ACCT_UNIV_DEP_ID;
        acc.Organization_Unit_Level__c = '2';
        acc.Name = QUTEXPROD;
        AccountsDAO.newInstance().insertRecords(new List<Account>{acc}, false, AccessLevel.USER_MODE);
        Product_Request__c pr = TestDataFactory.createTestProductRequestRecords(1).iterator().next();
        insert pr;
        hed__Course__c course = TestDataFactory.createTestCourseRecords(1,acc?.Id,pr?.Id).iterator().next();
        insert course;
        List<Financial_Split__c> financialSplits = TestDataFactory.createTestFinancialSplitRecords(1,course?.Id);
        financialSplits[0].RecordTypeId = FinancialSplitsDAO.COURSE_FINANCIAL_SPLIT_RECORDTYPEID;
        FinancialSplitsDAO.newInstance().insertRecords(financialSplits,false,AccessLevel.USER_MODE);
    }

    @isTest
    private static void getQutexIdTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Account qutexAcc = [SELECT Id FROM Account LIMIT 1];
            Test.startTest();
            Id qutexId = FinancialSplitCtrl.getQutexId(QUTEXPROD);
            Test.stopTest();
            System.assertEquals(qutexAcc?.Id, qutexId,'QUTeX account did not match');
        }
    }

    @isTest
    private static void getParentIdTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Product_Request__c pr = [SELECT Id FROM Product_Request__c LIMIT 1];
            hed__Course__c course = [SELECT Id FROM hed__Course__c LIMIT 1];
            Test.startTest();
            CustomLayoutCtrl.GetRecordFilter filter = new CustomLayoutCtrl.GetRecordFilter();
            filter.parentId = pr?.Id;
            filter.parentField = COURSE_PR_FIELD;
            filter.childObjectType = COURSE_API_NAME;
            filter.grandChildInfo = new Map<String,String>();
            Id courseId = FinancialSplitCtrl.getParentId(filter);
            Test.stopTest();
            System.assertEquals(course?.Id, courseId, 'Course Id did not match expected.');
        }
    }

    @isTest
    private static void getFinancialSplitsTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            hed__Course__c course = [SELECT Id FROM hed__Course__c LIMIT 1];
            Test.startTest();
            List<Financial_Split__c> financialSplits = FinancialSplitCtrl.getFinancialSplits(FS_COURSE_FIELD,course?.Id);
            Test.stopTest();
            System.assertEquals(1, financialSplits.size(),'Number of expected financial splits did not match');
        }
    }

    @isTest
    private static void upsertFinancialSplitsTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            hed__Course__c course = [SELECT Id FROM hed__Course__c LIMIT 1];
            List<Financial_Split__c> financialSplits = TestDataFactory.createTestFinancialSplitRecords(1,course?.Id);
            Test.startTest();
            FinancialSplitCtrl.upsertFinancialSplits(financialSplits);
            Test.stopTest();
            List<Financial_Split__c> insertedFinancialSplits =  FinancialSplitsDAO.newInstance().getFinancialSplitsRecords(FS_COURSE_FIELD,course?.Id);
            System.assertEquals(2, insertedFinancialSplits.size(),'Number of expected upserted financial splits did not match');
        }
    }
    
	@isTest
    private static void upsertFinancialSplitsWithRecordTypeTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            hed__Course__c course = [SELECT Id FROM hed__Course__c LIMIT 1];
            List<Financial_Split__c> financialSplits = TestDataFactory.createTestFinancialSplitRecords(1,course?.Id);
            Test.startTest();
            FinancialSplitCtrl.upsertFinancialSplits(financialSplits);
            Test.stopTest();
            List<Financial_Split__c> insertedFinancialSplits = FinancialSplitsDAO.newInstance().getFinancialSplitsRecords(FS_COURSE_FIELD,course?.Id);
            System.assertEquals(FinancialSplitsDAO.COURSE_FINANCIAL_SPLIT_RECORDTYPEID, insertedFinancialSplits[0].RecordTypeId,'Course Financial Record type is Match');
        }
    }
}