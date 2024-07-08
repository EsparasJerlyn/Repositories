/**
 * @description Test for Get Updated Purchased Price Flow
 *
 * @see GetUpdatePurchasedPriceFlowTest
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA     | Change Summary                  |
      |---------------------------|-----------------------|----------|---------------------------------|
      | arsenio.dayrit@qut.edu.au | January 12, 2022      | DEPP-1359| Created file                    |
      | justine.javier@qut.edu.au | February 25, 2022     | DEPP-1819| Removed Program_Offering logic  |
 	  |                           |                       |          |                                 |
*/
@isTest
public with sharing class GetUpdatePurchasedPriceFlowTest {

    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();

    @TestSetup
    static void makeData(){
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    private static void updateCourseConnectionPurchasedPrice(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){

            List<Account> acc = TestDataFactory.createTestAccountRecords(1);
            for(Account account : acc){
                account.RecordTypeId = ACCT_UNIV_DEP_ID;
                account.Organization_Unit_Level__c = '2';
            }
            insert acc;

            List<Contact> conList = TestDataFactory.createTestContactRecords(1);
            insert conList;

            List<Opportunity> oppList = TestDataFactory.createClosedWonOpportunities(10,acc[0].Id,conList.iterator().next()?.Id);
            insert oppList;

            List<Product_Request__c> prodRequest = TestDataFactory.createTestProductRequestRecords(1);
            insert prodRequest;

            List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(10, acc[0].Id, prodRequest[0].Id);
            insert courses;

            List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(10, acc[0].Id);
            insert terms;

            List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(10, courses, terms);
            insert courseOfferings;

            List<hed__Program_Plan__c> programPlans = TestDataFactory.createTestProgramPlanRecords(10);
            insert programPlans;

            List<Program_Offering__c> programOfferings = TestDataFactory.createTestProgramOfferingRecords(10, programPlans);
            insert programOfferings;

            List<Asset> assetRec = TestDataFactory.createTestAssetRecords(1,acc[0].Id,prodRequest[0].Id);
            insert assetRec;

            List<hed__Course_Enrollment__c> courseConnection = TestDataFactory.createTestCourseConnectionRecord(10, conList[0].Id,courseOfferings);
            for(hed__Course_Enrollment__c courseCon : courseConnection){
                courseCon.Amount__c = 100;
            }
            insert courseConnection;

            List<Product_Ledger__c> prodLedger = TestDataFactory.createTestProductLedgerRecords(1, courseConnection.iterator().next()?.Id, assetRec[0].Id);
            insert prodLedger;

            Test.startTest();

            for(hed__Course_Enrollment__c courseRec : courseConnection){
                courseRec.Amount__c = 1000;
            }
            update courseConnection;

            Test.stopTest();

            List<Product_Ledger__c> updateProdLedger = [SELECT id, Purchased_Price_v2__c FROM Product_Ledger__c LIMIT 100];
            for(Product_Ledger__c checkProdLedger : updateProdLedger){
                System.assertEquals(1000, checkProdLedger.Purchased_Price_v2__c, 'not equal value');
            }

        }

    }
}