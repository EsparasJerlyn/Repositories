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
      |                           |                       |           |                                 | 
*/
@IsTest
private class FinancialSplitCtrlTest {
	
    private static final String QUTEX = System.Label.QUTeX;
    private static final String COURSE_API_NAME = hed__Course__c.SObjectType.getDescribe().getLocalName();
    private static final String COURSE_PR_FIELD = 'ProductRequestID__c';
    private static final String FS_COURSE_FIELD = 'Course__c';
    private static User currentUser = TestDataFactory.createUserRecords(1, QUTEX).iterator().next();

    @testSetup static void setupMethod() {
        Account acc = TestDataFactory.createTestAccountRecords(1).iterator().next();
        acc.Name = QUTEX;
        insert acc;
        Product_Request__c pr = TestDataFactory.createTestProductRequestRecords(1).iterator().next();
        insert pr;
        hed__Course__c course = TestDataFactory.createTestCourseRecords(1,acc?.Id,pr?.Id).iterator().next();
        insert course;
        List<Financial_Split__c> financialSplits = TestDataFactory.createTestFinancialSplitRecords(1,course?.Id);
        insert financialSplits;
    }
	
    @IsTest
    private static void getQutexIdTest(){
        System.runAs(currentUser){
            Account qutexAcc = [SELECT Id FROM Account LIMIT 1];
            Test.startTest();
            Id qutexId = FinancialSplitCtrl.getQutexId(QUTEX);
            Test.stopTest();
            System.assertEquals(qutexAcc?.Id, qutexId,'QUTeX account did not match');
        }
    }
    
    @IsTest
    private static void getParentIdTest(){
        System.runAs(currentUser){
            Product_Request__c pr = [SELECT Id FROM Product_Request__c LIMIT 1];
            hed__Course__c course = [SELECT Id FROM hed__Course__c LIMIT 1];
            Test.startTest();
            Id courseId = FinancialSplitCtrl.getParentId(pr?.Id, COURSE_PR_FIELD, COURSE_API_NAME, new Map<String,String>());
            Test.stopTest();
            System.assertEquals(course?.Id, courseId, 'Course Id did not match expected.');
        }
    }

    @IsTest
    private static void getFinancialSplitsTest(){
        System.runAs(currentUser){
            hed__Course__c course = [SELECT Id FROM hed__Course__c LIMIT 1];
            Test.startTest();
            List<Financial_Split__c> financialSplits = FinancialSplitCtrl.getFinancialSplits(FS_COURSE_FIELD,course?.Id);
            Test.stopTest();
            System.assertEquals(1, financialSplits.size(),'Number of expected financial splits did not match');
        }
    }

    @IsTest
    private static void upsertFinancialSplitsTest(){
        System.runAs(currentUser){
            hed__Course__c course = [SELECT Id FROM hed__Course__c LIMIT 1];
            List<Financial_Split__c> financialSplits = TestDataFactory.createTestFinancialSplitRecords(1,course?.Id);
            Test.startTest();
            FinancialSplitCtrl.upsertFinancialSplits(financialSplits);
            Test.stopTest();
            List<Financial_Split__c> insertedFinancialSplits = [SELECT Id FROM Financial_Split__c];
            System.assertEquals(2, insertedFinancialSplits.size(),'Number of expected upserted financial splits did not match');
        }
    }
    
}