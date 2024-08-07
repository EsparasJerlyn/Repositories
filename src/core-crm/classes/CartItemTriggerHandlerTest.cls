/**
 * @description CartItemTriggerHandler Test Class
 * @see CartItemTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------|
      | eugene.andrew.abuan            | March 22, 2022        | DEPP-1991              | Created file                               |
      | arsenio.jr.dayrit              | April 07, 2022        | DEPP-2057              | Adding test method for  counting Cart Item |
 */
@isTest
public with sharing class CartItemTriggerHandlerTest {
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();

    @TestSetup
    static void makeData(){
      TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    static void insertCartItemTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();

            List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
            insert accounts;

            WebStore testWebStore = new WebStore(Name='CCE', DefaultLanguage='en_US');
            insert testWebStore;

            WebCart cart = new WebCart(Name='Cart', AccountId = accounts[0].Id , Status = 'Active', WebStoreId = testWebStore.Id);
            insert cart;

            CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery');
            insert cartDeliveryGroup;

            CartItem cartItem = new CartItem(CartId=cart.Id, Sku='SKU_Test1', Quantity=3.0, Type='Product', Name='TestProduct', CartDeliveryGroupId=cartDeliveryGroup.Id);
            insert cartItem;

            Test.stopTest();

            System.assert(![SELECT External_Id__c FROM CartItem].IsEmpty(), 'External Id is not populated');
        }
    }

    @isTest
    static void afterInsertCartItemTest() {

        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {

            Test.startTest();

            List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
            for(Account acc : accounts){
              acc.RecordTypeId = ACCT_UNIV_DEP_ID;
              acc.Organization_Unit_Level__c = '2';
            }
            insert accounts;

            List<Contact> contacts = TestDataFactory.createTestContactRecords(1);
            insert contacts;

            List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(10,accounts[0].Id);
            insert terms;

            List<Product_Request__c> prodRequest = TestDataFactory.createTestProductRequestRecords(1);
            insert prodRequest;

            List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(10,accounts[0].Id,prodRequest[0].Id);
            insert courses;

            List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(10,courses,terms);
            insert courseOfferings;

            List<hed__Program_Plan__c> programPlans = TestDataFactory.createTestProgramPlanRecords(10);
            insert programPlans;

            List<Program_Offering__c> programOffs = TestDataFactory.createTestProgramOfferingRecords(10,programPlans);
            insert programOffs;

            WebStore testWebStore = new WebStore(Name='CCE', DefaultLanguage='en_US');
            insert testWebStore;

            WebCart cart = new WebCart(Name='Cart', AccountId = accounts[0].Id , Status__c = 'Checkout', WebStoreId = testWebStore.Id);
            insert cart;

            CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery');
            insert cartDeliveryGroup;


            CartItem cartItem1 = new CartItem(CartId=cart.Id, Name='TestProductCourse1', Course_Offering__c= courseOfferings[0].Id, CartDeliveryGroupId=cartDeliveryGroup.Id);
            insert cartItem1;


            Id courseOfferId = courseOfferings[0].Id;
            CartItem cartItem2 = new CartItem(CartId=cart.Id, Name='TestProductCourse2', Course_Offering__c= courseOfferId, CartDeliveryGroupId=cartDeliveryGroup.Id);
            insert cartItem2;


            CartItem cartItemProg = new CartItem(CartId=cart.Id, Name='TestProductProgram', Program_Offering__c= programOffs[0].Id, CartDeliveryGroupId=cartDeliveryGroup.Id);
            insert cartItemProg;
            Id programOfferId = programOffs[0].Id;

            Test.stopTest();

            List<hed__Course_Offering__c> courseOff = [SELECT Id, Name ,Checkout_Cart_Items_Count__c FROM hed__Course_Offering__c WHERE Id =: courseOfferId LIMIT 100];
            List<Program_Offering__c> progOff = [SELECT Id, Name ,Checkout_Cart_Items_Count__c FROM Program_Offering__c WHERE Id =: programOfferId LIMIT 100];

            System.assertEquals(2, courseOff[0].Checkout_Cart_Items_Count__c,'Total Cart Item Count for Course Offering after creating new Cart Item');
            System.assertEquals(1, progOff[0].Checkout_Cart_Items_Count__c,'Total Cart Item Count for Program Offering after creating new Cart Item');




        }

    }

    @isTest
    private static void afterUpdateCartItemTest() {
      System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
        Test.startTest();
        List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
        for(Account acc : accounts){
          acc.RecordTypeId = ACCT_UNIV_DEP_ID;
          acc.Organization_Unit_Level__c = '2';
        }
        insert accounts;

        List<Contact> contacts = TestDataFactory.createTestContactRecords(1);
        insert contacts;

        List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(10,accounts[0].Id);
        insert terms;

        List<Product_Request__c> prodRequest = TestDataFactory.createTestProductRequestRecords(1);
        insert prodRequest;

        List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(10,accounts[0].Id,prodRequest[0].Id);
        insert courses;

        List<Product2> products = TestDataFactory.createTestProductRecords(10, courses);
        insert products;

        List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(10,courses,terms);
        insert courseOfferings;

        List<hed__Program_Plan__c> programPlans = TestDataFactory.createTestProgramPlanRecords(10);
        insert programPlans;

        List<Program_Offering__c> programOffs = TestDataFactory.createTestProgramOfferingRecords(10,programPlans);
        insert programOffs;

        WebStore testWebStore = new WebStore(Name='CCE', DefaultLanguage='en_US');
        insert testWebStore;

        WebCart cart = new WebCart(Name='Cart', AccountId = accounts[0].Id , Status__c = 'Checkout', WebStoreId = testWebStore.Id);
        insert cart;

        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery');
        insert cartDeliveryGroup;

        CartItem cartItem1 = new CartItem(CartId=cart.Id, Name='TestProductCourse', Course_Offering__c=courseOfferings[1].id, CartDeliveryGroupId=cartDeliveryGroup.Id);
        insert cartItem1;

        CartItem cartItem2 = new CartItem(CartId=cart.Id, Name='TestProductProgram', Program_Offering__c=programOffs[1].id, CartDeliveryGroupId=cartDeliveryGroup.Id);
        insert cartItem2;

        Set<Id> courseOfferIdSet = new Set<Id>();
        Set<Id> programOfferIdSet = new Set<Id>();

        courseOfferIdSet.add(courseOfferings[1].Id);
        programOfferIdSet.add(programOffs[1].Id);



        List<CartItem> cartItem1List = [SELECT Id, Course_Offering__c FROM CartItem
                                        WHERE Course_Offering__c = :courseOfferIdSet];

        for (CartItem upDateCartItem1List : cartItem1List) {
            upDateCartItem1List.Course_Offering__c = courseOfferings[0].Id;
            upDateCartItem1List.Product2Id = products[0].Id;
            upDateCartItem1List.ListPrice = 1;
            upDateCartItem1List.Quantity = 1;
            upDateCartItem1List.SalesPrice = 1;
            upDateCartItem1List.Sku = 'test';
            upDateCartItem1List.AdjustmentAmount = 1;
            upDateCartItem1List.AdjustmentTaxAmount = 1;
            upDateCartItem1List.TotalAdjustmentAmount = 1;
            upDateCartItem1List.TotalPriceAfterAllAdjustments = 1;
            upDateCartItem1List.TotalLineAmount = 1;
            upDateCartItem1List.TotalListPrice = 1;
            upDateCartItem1List.TotalPrice = 1;
            upDateCartItem1List.UnitAdjustedPrice = 1;
            upDateCartItem1List.UnitAdjustmentAmount = 1;
        }
        update cartItem1List;

        List<CartItem> cartItem2List = [SELECT Id, Program_Offering__c FROM CartItem
                                        WHERE Program_Offering__c = :programOfferIdSet];

        for (CartItem upDateCartItem2List : cartItem2List) {
            upDateCartItem2List.Program_Offering__c = programOffs[0].Id;
            upDateCartItem2List.Product2Id = products[0].Id;
            upDateCartItem2List.ListPrice = 1;
            upDateCartItem2List.Quantity = 1;
            upDateCartItem2List.SalesPrice = 1;
            upDateCartItem2List.Sku = 'test';
            upDateCartItem2List.AdjustmentAmount = 1;
            upDateCartItem2List.AdjustmentTaxAmount = 1;
            upDateCartItem2List.TotalAdjustmentAmount = 1;
            upDateCartItem2List.TotalPriceAfterAllAdjustments = 1;
            upDateCartItem2List.TotalLineAmount = 1;
            upDateCartItem2List.TotalListPrice = 1;
            upDateCartItem2List.TotalPrice = 1;
            upDateCartItem2List.UnitAdjustedPrice = 1;
            upDateCartItem2List.UnitAdjustmentAmount = 1;
        }
        update cartItem2List;

        Set<Id> courseOfferIdSet1 = new Set<Id>();
        Set<Id> programOfferIdSet1 = new Set<Id>();
        courseOfferIdSet1.add(courseOfferings[0].Id);
        programOfferIdSet1.add(programOffs[0].Id);

        Test.stopTest();

        List<hed__Course_Offering__c> courseOfferingsResult = [SELECT Id, Checkout_Cart_Items_Count__c FROM hed__Course_Offering__c WHERE Id = :courseOfferIdSet1];

        List<Program_Offering__c> programOfferingsResult = [SELECT Id, Checkout_Cart_Items_Count__c FROM Program_Offering__c WHERE Id = :programOfferIdSet1];

        System.assertEquals(1,courseOfferingsResult[0].Checkout_Cart_Items_Count__c,'Then Total Checkout Cart Item Count Value should be equal to the number of related Cart Item');


        System.assertEquals(1,programOfferingsResult[0].Checkout_Cart_Items_Count__c,'Then Total Checkout Cart Item Count Value should be equal to the number of related Cart Item');

      }
    }

    @isTest
    private static void afterDeleteCartItemTest() {
      System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
        Test.startTest();
        List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
        for(Account acc : accounts){
          acc.RecordTypeId = ACCT_UNIV_DEP_ID;
          acc.Organization_Unit_Level__c = '2';
        }
        insert accounts;

        List<Contact> contacts = TestDataFactory.createTestContactRecords(1);
        insert contacts;

        List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(10,accounts[0].Id);
        insert terms;

        List<Product_Request__c> prodRequest = TestDataFactory.createTestProductRequestRecords(1);
        insert prodRequest;

        List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(10,accounts[0].Id,prodRequest[0].Id);
        insert courses;

        List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(10,courses,terms);
        insert courseOfferings;

        List<hed__Program_Plan__c> programPlans = TestDataFactory.createTestProgramPlanRecords(10);
        insert programPlans;

        List<Program_Offering__c> programOffs = TestDataFactory.createTestProgramOfferingRecords(10,programPlans);
        insert programOffs;

        WebStore testWebStore = new WebStore(Name='CCE', DefaultLanguage='en_US');
        insert testWebStore;

        WebCart cart = new WebCart(Name='Cart', AccountId = accounts[0].Id , Status__c = 'Checkout', WebStoreId = testWebStore.Id);
        insert cart;

        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery');
        insert cartDeliveryGroup;

        CartItem cartItem1 = new CartItem(CartId=cart.Id, Name='TestProductCourse', Course_Offering__c=courseOfferings[0].id, CartDeliveryGroupId=cartDeliveryGroup.Id);
        insert cartItem1;

        CartItem cartItem2 = new CartItem(CartId=cart.Id, Name='TestProductProgram', Program_Offering__c=programOffs[0].id, CartDeliveryGroupId=cartDeliveryGroup.Id);
        insert cartItem2;

        Id courseOfferId = courseOfferings[0].Id;
        Id programOfferId = programOffs[0].Id;

        List<CartItem> cartItem1List = [SELECT Id FROM CartItem WHERE Course_Offering__c = :courseOfferId];
        List<CartItem> cartItem2List = [SELECT Id FROM CartItem WHERE Program_Offering__c = :programOfferId];

        delete cartItem1List;
        delete cartItem2List;
        Test.stopTest();

        List<hed__Course_Offering__c> courseOfferingsResult = [SELECT Id, Checkout_Cart_Items_Count__c FROM hed__Course_Offering__c
                                                               WHERE Id = :courseOfferId];


        List<Program_Offering__c> programOfferingsResult = [SELECT Id, Checkout_Cart_Items_Count__c FROM Program_Offering__c
                                                               WHERE Id = :programOfferId];

        System.assertEquals(0,courseOfferingsResult[0].Checkout_Cart_Items_Count__c,'Then Total Checkout Cart Item Count Value should be equal to the number of related Cart Item');

        System.assertEquals(0,programOfferingsResult[0].Checkout_Cart_Items_Count__c,'Then Total Checkout Cart Item Count Value should be equal to the number of related Cart Item');
      }
    }
}