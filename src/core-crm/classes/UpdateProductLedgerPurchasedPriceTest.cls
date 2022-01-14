/**
 * @description Test for Update Product Ledger Purchased Price Flow
 *
 * @see UpdateProductLedgerPurchasedPriceTest
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA     | Change Summary                  |
      |---------------------------|-----------------------|----------|---------------------------------|
      | arsenio.dayrit@qut.edu.au | January 12, 2022      | DEPP-1359| Created file                    | 
      |                           |                       |          |                                 |
*/
@isTest(SeeAllData = false)
public with sharing class UpdateProductLedgerPurchasedPriceTest {

    private static User  currentUser = TestDataFactory.createUserRecords(1,'QUTeX').iterator().next();

    @isTest
    private static void updateProductLedgerPurchasedPrice(){
        System.runAs(currentUser){

            List<Account> acc = TestDataFactory.createTestAccountRecords(1);
            insert acc;

            List<Contact> conList = TestDataFactory.createTestContactRecords(1);
            insert conList;

            List<Opportunity> oppList = TestDataFactory.createTestOpportunityRecords(10,acc[0].Id,conList.iterator().next()?.Id);
            insert oppList;

            List<Product_Specification__c> prodSpecs = TestDataFactory.createTestProductSpecsRecords(1,conList,oppList);
            insert prodSpecs;

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
            
            List<hed__Course_Enrollment__c> courseConnection = TestDataFactory.createTestCourseConnectionRecord(10, conList[0].Id,courseOfferings,programOfferings );
            for(hed__Course_Enrollment__c courseCon : courseConnection){
                courseCon.Purchased_Price__c = 100;
            }
            insert courseConnection;

            Test.startTest();
            List<Product_Ledger__c> prodLedger = TestDataFactory.createTestProductLedgerRecords(10, courseConnection.iterator().next()?.Id, assetRec[0].Id);
            insert prodLedger;
            Test.stopTest();

            List<Product_Ledger__c> updateProdLedger = [SELECT id, Purchased_Price_v2__c FROM Product_Ledger__c LIMIT 100]; 
            for(Product_Ledger__c checkProdLedger : updateProdLedger){
                System.assertEquals(100, checkProdLedger.Purchased_Price_v2__c, 'not equal value');
            }
         
        }
   
    }   
}