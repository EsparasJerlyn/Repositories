/**
 * @description Test Class for the PublishingEndDateBatch
 *
 * @see PublishingEndDateBatch
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | eugene.andrew.abuan       | March 01, 2022	      | DEPP-1256            | Created file                 |
      |                           |                       |                      |                              |
 */
@isTest
public with sharing class PublishingEndDateBatchTest {
    private static final String PR_IN_DELIVERY = System.Label.PL_ProductRequest_InDelivery;
    private static final string PR_PROGRAM = System.Label.RT_ProductRequest_Program;
    private static final string PR_SHORTCOURSE = System.Label.RT_ProductRequest_ShortCourse;
    private static User currentUser = TestDataFactory.createUserRecords(1, 'QUTeX').iterator().next();
    private static Id opeShortProdReqId = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(PR_SHORTCOURSE).getRecordTypeId();
    private static Id opeShortCourseId = Schema.SObjectType.hed__Course__c.getRecordTypeInfosByDeveloperName().get(PR_SHORTCOURSE).getRecordTypeId();
    private static Id opeProgProdReqId =  Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(PR_PROGRAM).getRecordTypeId();
    private static Integer numberOfRecords = 50;
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();
    private static final String PR_RELEASE = System.Label.PL_ProductRequest_Release;

    @testSetup
    static void setupMethod(){
        List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
        for(Account acc : accounts){
            acc.RecordTypeId = ACCT_UNIV_DEP_ID;
            acc.Organization_Unit_Level__c = '2';
        }
        insert accounts;

        List<Contact> contacts;
        contacts = TestDataFactory.createTestContactRecords(1);
        insert contacts;

        List<Opportunity> opps;
        opps = TestDataFactory.createTestOpportunityRecords(1,accounts[0].Id,contacts[0].Id);
        insert opps;

        List<Product_Specification__c> productSpecs;
        productSpecs = TestDataFactory.createTestProductSpecsRecords(1,contacts,opps);
        insert productSpecs;

        List<Product_Request__c> prodRequestOPEProgramRequest;
        prodRequestOPEProgramRequest = TestDataFactory.createTestProductRequestRecords(numberOfRecords,productSpecs[0].Id);
        for(Product_Request__c productRequest : prodRequestOPEProgramRequest){
            productRequest.Product_Request_Name__c = PR_PROGRAM;
            productRequest.Product_Request_Status__c = PR_IN_DELIVERY;
            productRequest.RecordTypeId = opeProgProdReqId;
        }

        insert prodRequestOPEProgramRequest;

        List<hed__Program_Plan__c> programPlanList;
        programPlanList = TestDataFactory.createTestProgramPlanRecords(numberOfRecords);
        for(Integer i = 0; i<prodRequestOPEProgramRequest.size(); i++){
            programPlanList[i].Product_Request__c = prodRequestOPEProgramRequest[i].Id;
            programPlanList[i].hed__End_Date__c = date.today();
            programPlanList[i].Program_Delivery_Structure__c = 'Prescribed Program';
        }
        insert programPlanList;


        List<Product_Request__c> productRequests = TestDataFactory.createTestProductRequestRecords(numberOfRecords,productSpecs[0].Id);
        for(Product_Request__c productRequest : productRequests){
            productRequest.RecordTypeId = opeShortProdReqId;
            productRequest.Product_Request_Status__c = PR_RELEASE;
        }
        insert productRequests;

        hed__Facility__c facility = new hed__Facility__c();
        facility.Name = 'Externals';
        insert facility;

        List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(numberOfRecords, accounts[0].Id, productRequests[0].Id);
        for(Integer i = 0 ; i < courses.size() ; i++){
            courses[i].ProductRequestID__c = productRequests[i].Id;
            courses[i].RecordTypeId = opeShortCourseId;
            courses[i].Location__c = facility.Id;
            courses[i].Start_Date__c = date.today() - 2;
            courses[i].End_Date__c = date.today();
        }
        insert courses;

        List<Product2> products = TestDataFactory.createTestProductRecords(numberOfRecords,courses);
        insert products;

        ProductCatalog prodCatalog = new ProductCatalog(Name = 'Study Catalog');
        insert prodCatalog;
        ProductCategory prodCateg = new ProductCategory(Name = 'Products',CatalogId = prodCatalog.Id);
        insert prodCateg;

        CommerceEntitlementPolicy commEntPolicy = new CommerceEntitlementPolicy(Name = 'OPE Entitlement');
        insert commEntPolicy;
    }
    
    @isTest
    public static void testPublishingEndDateBatch() {
        System.runAs(currentUser){
            List<Product_Request__c> productRequests = [SELECT Id, Product_Request_Status__c FROM Product_Request__c WHERE RecordTypeId =: opeShortProdReqId];
            for(Product_Request__c productRequest : productRequests){
                productRequest.Product_Request_Status__c = PR_RELEASE;
            }
            update productRequests;
            
            List<Product2> products = [SELECT Id,Publishing_End_date__c,IsActive,Course__r.ProductRequestID__c, Publishing_Start_date__c, QA_Review_Completed__c,Ready_for_publishing__c  FROM Product2 WHERE Course__r.ProductRequestID__c != NULL];
            for(Product2 product : products){
                product.IsActive = true;
                product.Decommission_Product__c = true;
                product.Decommission_Reason__c = 'test';
                product.Publishing_End_date__c = date.today() + 2;
                product.Publishing_Start_date__c = date.today() - 1;
                product.End_Date__c = date.today() + 2;
                product.QA_Review_Completed__c = 'Yes';
                product.Ready_for_publishing__c = 'Yes';
            }
            update products;

            Test.startTest();

            PublishingEndDateBatch batch = new PublishingEndDateBatch();
            Id batchId = Database.executeBatch(batch);

            Test.stopTest();

            System.assert(![SELECT Id FROM AsyncApexJob WHERE ApexClass.Name = 'PublishingEndDateBatch'].isEmpty() , 'PublishingEndDate Job was not executed');
        }
    }
 
    @isTest
    public static void testPublishingEndDateBatchWithParent() {
        System.runAs(currentUser){

            List<Product_Request__c> childProductRequest = [SELECT Id FROM Product_Request__c WHERE RecordTypeId =: opeShortProdReqId];
            List<Product_Request__c> parentProductRequest = [SELECT Id FROM Product_Request__c WHERE RecordTypeId =: opeProgProdReqId];

            List<Product2> products = [SELECT Id,Publishing_End_date__c,IsActive,Course__r.ProductRequestID__c, Publishing_Start_date__c, QA_Review_Completed__c,Ready_for_publishing__c  FROM Product2 WHERE Program_Plan__r.Product_Request__c != NULL];
            for(Product2 product : products){
                product.IsActive = true;
                product.Decommission_Product__c = false;
                product.Decommission_Reason__c = 'test';
                product.Publishing_End_date__c = date.today() + 2;
                product.Publishing_Start_date__c = date.today() - 1;
                product.QA_Review_Completed__c = 'Yes';
                product.Ready_for_publishing__c = 'Yes';
            }
            update products;

            List<Related_Product_Request__c> relatedProductRequests;
            relatedProductRequests = TestDataFactory.createTestRelatedPRRecords(50,childProductRequest,parentProductRequest);
            insert relatedProductRequests;

            Test.startTest();

            PublishingEndDateBatch batch = new PublishingEndDateBatch();
            Id batchId = Database.executeBatch(batch);

            System.assert(![SELECT Id FROM AsyncApexJob WHERE ApexClass.Name = 'PublishingEndDateBatch'].isEmpty() , 'PublishingEndDate Job was not executed');

            Test.stopTest();

        }
    }
 }