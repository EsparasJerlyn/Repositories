/**
 * @description FinancialSplitsDAOTest Class for Financial Split Object
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                 |
 *    |--------------------------------|-----------------------|------------------------|----------------------------------------------------------------|
 *    | mark.j.mahilum                 | June 01,2023          | DEPP-5687              | Created File                                                   |              
 *    | ryan.j.a.dela.cruz             | July 19, 2023         | DEPP-5457/DEPP-5468    | Added getActiveOpportunityFinancialSplitsRecordsTest method    |
 */
@isTest
public with sharing class FinancialSplitsDAOTest {

    private static final String QUTEXPROD = System.Label.QUT_GSB;
	private static final String FS_COURSE_FIELD = 'Course__c';

    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUTeX_Program_Administrator', 'Industry_Partnership_Manager' });
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
    static void getFinancialSplitsRecordsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {            
            hed__Course__c course = [SELECT Id FROM hed__Course__c LIMIT 1];
            List<Financial_Split__c> financialSplitList = FinancialSplitsDAO.newInstance()
                .getFinancialSplitsRecords(FS_COURSE_FIELD,course?.Id);
            System.assert(!financialSplitList.isEmpty(), 'financialSplitList is not empty');
        }
        Test.stopTest();
    }
    
    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new FinancialSplitsDAO().getSObjectType() == Financial_Split__c.SObjectType,
                'SObject is not Financial Split'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getActiveOpportunityFinancialSplitsRecordsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            List<Financial_Split__c> financialSplits = FinancialSplitsDAO.newInstance().getActiveOpportunityFinancialSplitsRecords(new Set<Id>());
            System.assert(financialSplits != null, 'Financial Splits not found');
        }
        Test.stopTest();
    }
}