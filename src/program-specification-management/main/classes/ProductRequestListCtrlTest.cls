/**
 * @description Tests the Product Request Controller Test Class
 *
 * @see ProductRequestListCtrl
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA      | Change Summary                  |
      |---------------------------|-----------------------|-----------|---------------------------------|
      | roy.nino.s.regala         | October 01, 2021      | DEPP40,42 | Created file                    | 
      |                           |                       |           |                                 | 
*/
@isTest(SeeAllData=false)
private class ProductRequestListCtrlTest {
    private static User  currentUser = TestDataFactory.createUserRecords(1,'QUTeX').iterator().next();

    @testSetup static void setupMethod() {
        List<Account> accs = new List<Account>();
        List<Contact> contacts = new List<Contact>();
        List<Opportunity> opps = new List<Opportunity>();
        List<Product_Request__c> childOfPR = new List<Product_Request__c>();
        List<Product_Request__c> childOfPR2 = new List<Product_Request__c>();
        List<Product_Request__c> childOfPS = new List<Product_Request__c>();
        List<Program_Specification__c> programSpecs = new List<Program_Specification__c>();

        accs = TestDataFactory.createTestAccountRecords(1);
        contacts = TestDataFactory.createTestContactRecords(1);
        insert accs;
        opps = TestDataFactory.createTestOpportunityRecords(1,accs[0].Id);
        insert opps;
        insert contacts;
        

        Test.startTest();
        programSpecs = TestDataFactory.createTestProgramSpecsRecords(1,contacts,opps);
        insert programSpecs;
        childOfPS = TestDataFactory.createTestProductRequestRecords(100, new List<Product_Request__c>(),programSpecs);
        insert childOfPS;
        childOfPR = TestDataFactory.createTestProductRequestRecords(100, childOfPS, new List<Program_Specification__c>());
        insert childOfPR;
        childOfPR2 = TestDataFactory.createTestProductRequestRecords(100, childOfPS, new List<Program_Specification__c>());
        insert childOfPR2;
        Test.stopTest();
        
    }   

    static testMethod void testGetProductRequests() {
        Test.startTest();
        System.runAs(currentUser){
            ProductRequestListCtrl.ProductRequestData getProdReqs = new ProductRequestListCtrl.ProductRequestData();
            getProdReqs = ProductRequestListCtrl.getProductRequests(string.valueOf([SELECT Id FROM Program_Specification__c Limit 1].Id));
            system.assert( !getProdReqs.parentList.isEmpty(), 'unable to get product requests');
        }

        Test.stopTest();
    }

}