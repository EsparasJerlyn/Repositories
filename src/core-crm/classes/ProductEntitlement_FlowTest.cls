/**
 * @description Test Class for Product Entitlement Assignment 
 *
 * @see ../flows/CCE_Products_Entitlement_Assignment
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | eugene.andrew.abuan       | December 13, 2021     | DEPP-802     | Created file                                | 
      | eugene.andrew.abuan       | January 05, 2022      | DEPP - 1442  | Added another assert to cover FlowCoverage  | 
*/
@IsTest(SeeAllData = false)
private class ProductEntitlement_FlowTest {
    private static final Id BUSINESS_ACC_RECTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Organization').getRecordTypeId();
    
    @testSetup static void setupMethod() {

        Account acc = TestDataFactory.createTestAccountRecords(1).iterator().next();
        insert acc;
        List<Contact> conList = TestDataFactory.createTestContactRecords(1);
        insert conList;
        List<Opportunity> oppList = TestDataFactory.createTestOpportunityRecords(1,acc?.Id,conList.iterator().next()?.Id);
        insert oppList;
        Product_Specification__c prodSpec = TestDataFactory.createTestProductSpecsRecords(1,conList,oppList).iterator().next();
        insert prodSpec;
        Product_Request__c prodReq = TestDataFactory.createTestProductRequestRecords(1,prodSpec?.Id).iterator().next();
        insert prodReq;
        List<hed__Course__c> courseList = TestDataFactory.createTestCourseRecords(1,acc?.Id,prodReq?.Id);
        insert courseList;
        BuyerGroup buyerGroup = new BuyerGroup(Name='Test Buyer Group');
        insert buyerGroup;
        BuyerGroupMember buyerGroupMember = new BuyerGroupMember(BuyerId = acc.Id, BuyerGroupId = buyerGroup.Id);
        insert buyerGroupMember;
        CommerceEntitlementPolicy commerceEntl = new CommerceEntitlementPolicy(Name = 'Test Entitlement', CanViewProduct = true, CanViewPrice = true, IsActive = true);
        insert commerceEntl;
        CommerceEntitlementBuyerGroup commerceEntbg = new CommerceEntitlementBuyerGroup(BuyerGroupId = buyerGroup.Id, PolicyId =commerceEntl.Id);
        insert commerceEntbg;
    }

    @IsTest
    static void assignProductToEntitlement(){
        List<hed__Course__c> courseList = ([SELECT Id, ProductRequestID__c FROM hed__Course__c]);
        List<Product2> product = TestDataFactory.createTestProductRecords(1,courseList);
        insert product;
        
        Test.startTest();
        
        List<Account> acc = new List<Account>([SELECT Id FROM Account]);
        for(Account a : acc){
            a.IsPartner = true;
        }
        update(acc);

        List<Product2> prod = new List<Product2>([SELECT Id FROM Product2 LIMIT 1]);
        for(Product2 p : prod){
            p.Family = 'CCE';
        }
        update(prod);
        System.Assert(![SELECT Id FROM CommerceEntitlementProduct].isEmpty(), 'No Product was Assigned to an Entitlement Policy');

        for(Product2 p1 : prod){
            p1.Family = 'OPE';
        }
        update(prod);
        System.Assert([SELECT Id FROM CommerceEntitlementProduct].isEmpty(), 'Product has been removed');

        Test.stopTest();

    }
}