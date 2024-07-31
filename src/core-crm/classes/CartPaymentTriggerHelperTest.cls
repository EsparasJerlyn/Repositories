/**
 * @description CartPaymentTriggerHelper Test Class
 * @see CartPaymentTriggerHelper
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------|
      | roy.nino.s.regala              | June 27, 2022         | DEPP-3252              | Created file                               |
      | kenneth.f.alsay                | June 21, 2024         | DEPP-9221              | Updated OPE Catalogue to QUT Experience    |
*/

@isTest
public with sharing class CartPaymentTriggerHelperTest {
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();
    private static User currentUser = TestDataFactory.createUserRecords(1, 'QUTeX').iterator().next();

    @testSetup
    static void setupMethod() {
        Test.startTest();
        TestDataFactoryUser.generateUserSystemAdministrator();
        Test.stopTest();
        final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
        //create account
        List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
        accounts[0].RecordTypeId = ACCT_UNIV_DEP_ID;
        accounts[0].Organization_Unit_Level__c = '2';
        insert accounts;
  
        //run this bloack as system admin
        System.runAs(PORTAL_SYS_ADMIN) {
            //Create account
            Account portalAccount1 = new Account(
            Name = 'TestAccount',
            OwnerId = PORTAL_SYS_ADMIN.Id
            );
            insert portalAccount1;

            //Create contact
            Contact contact1 = new Contact(
            FirstName = 'portalUser',
            Lastname = 'Testing',
            AccountId = portalAccount1.Id,
            Email = System.now().millisecond() + 'portalUser@test.com'
            );
            insert contact1;

            WebStore testWebStore = new WebStore(
            Name = 'Study',
            DefaultLanguage = 'en_US'
            );
            insert testWebStore;

            //Create user
            User portalUser = TestDataFactory.createPortalUserRecords(
                1,
                'QUT Experience',
                contact1.Id
                )
                .iterator()
                .next();
            Database.insert(portalUser);

            List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(
            1,
            accounts[0].Id
            );
            insert terms;

            List<Product_Request__c> prodRequest = TestDataFactory.createTestProductRequestRecords(
            1
            );
            insert prodRequest;

            List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(
            1,
            accounts[0].Id,
            prodRequest[0].Id
            );
            insert courses;

            List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(
                1,
                courses,
                terms
            );
            insert courseOfferings;

            List<hed__Program_Plan__c> programPlans = TestDataFactory.createTestProgramPlanRecords(
            1
            );
            insert programPlans;

            List<Program_Offering__c> programOffs = TestDataFactory.createTestProgramOfferingRecords(
            1,
            programPlans
            );
            insert programOffs;

            List<hed__Course_Offering__c> childOffering = TestDataFactory.createTestCourseOfferingRecord(
                1,
                courses,
                terms
            );
            childOffering[0].Program_Offering__c = programOffs[0].Id;
            insert childOffering;

            Pricebook2 priceBook = new Pricebook2(
            isActive = true,
            id = Test.getStandardPricebookId()
            );
            update pricebook;

            Product2 product = [SELECT Id FROM Product2 LIMIT 1];

            PricebookEntry priceBookEntry = new PricebookEntry(
            pricebook2id = priceBook.Id,
            UnitPrice = 123,
            product2Id = product.id
            );
            insert priceBookEntry;
        }
    }

    @isTest
    static void testBlankToInvoice() {
        final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
        System.runAs(PORTAL_SYS_ADMIN) {
            User portalUser = [     SELECT Id FROM User 
                                    WHERE Profile.Name = 'QUT Experience' 
                                    AND Email = 'testPortaluser@mailinator.com' 
                                    AND IsActive = TRUE 
                                    LIMIT 1];
            Account portalAccount1 = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
            WebStore testWebStore = [SELECT Id FROM WebStore LIMIT 1];

            List<CartItem> cartItemsToInsert = new List<CartItem>();
            Cart_Payment__c cartPayment = new Cart_Payment__c();
            insert cartPayment;
            WebCart cart = new WebCart( Name = 'Cart', AccountId = portalAccount1.Id, Status = 'Active', Status__c = 'Active',
            WebStoreId = testWebStore.Id, OwnerId = portalUser.Id
            );
            insert cart;

            cart.Cart_Payment__c = cartPayment.Id;
            update cart;

            CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(
            CartId = cart.Id,
            Name = 'Default Delivery'
            );
            insert cartDeliveryGroup;

            List<hed__Course_Offering__c> courseOfferings = new List<hed__Course_Offering__c>([SELECT Id FROM hed__Course_Offering__c LIMIT 1 ]);

            PriceBookEntry pbEntry = [SELECT Id, Product2Id, UnitPrice FROM PriceBookEntry LIMIT 1];

            CartItemHelper.CartItemDetails details;
            for(Integer i = 0; i < 100 ; i++){
                details = new CartItemHelper.CartItemDetails();
                details.offeringId = courseOfferings[0].Id;
                details.newWebCartId = cart.Id;
                details.pbEntry = pbEntry;
                details.prescribedProgram = false;
                details.cartDeliveryGroupId = cartDeliveryGroup.Id;
                cartItemsToInsert.add(CartItemHelper.createCartItem(details));
            }
            Test.startTest();
            insert cartItemsToInsert;
            cartPayment.Payment_Status__c = 'Invoiced';
            update cartPayment;
            Test.stopTest();
            System.assert(![SELECT ID FROM hed__Course_Enrollment__c LIMIT 100].isEmpty(),'No Course Connection Created');
        }
    }

    @isTest
    static void testProgramOfferingWithChild() {
        final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
        System.runAs(PORTAL_SYS_ADMIN) {
            User portalUser = [     SELECT Id FROM User 
                                    WHERE Profile.Name = 'QUT Experience' 
                                    AND Email = 'testPortaluser@mailinator.com' 
                                    AND IsActive = TRUE 
                                    LIMIT 1];

            Account portalAccount1 = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
            WebStore testWebStore = [SELECT Id FROM WebStore LIMIT 1];

            List<CartItem> cartItemsToInsert = new List<CartItem>();
            Cart_Payment__c cartPayment = new Cart_Payment__c();
            insert cartPayment;
            WebCart cart = new WebCart( Name = 'Cart', AccountId = portalAccount1.Id, Status = 'Active', Status__c = 'Active',
            WebStoreId = testWebStore.Id, OwnerId = portalUser.Id
            );
            insert cart;

            cart.Cart_Payment__c = cartPayment.Id;
            update cart;
            CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(
            CartId = cart.Id,
            Name = 'Default Delivery'
            );
            insert cartDeliveryGroup;

            List<Program_Offering__c> programOffering = new List<Program_Offering__c>([SELECT Id FROM Program_Offering__c LIMIT 1 ]);

            PriceBookEntry pbEntry = [SELECT Id, Product2Id, UnitPrice FROM PriceBookEntry LIMIT 1];

            CartItemHelper.CartItemDetails details;
            for(Integer i = 0; i < 100 ; i++){
                details = new CartItemHelper.CartItemDetails();
                details.offeringId = programOffering[0].Id;
                details.newWebCartId = cart.Id;
                details.pbEntry = pbEntry;
                details.prescribedProgram = true;
                details.cartDeliveryGroupId = cartDeliveryGroup.Id;
                cartItemsToInsert.add(CartItemHelper.createCartItem(details));
            }
            Test.startTest();
            insert cartItemsToInsert;
            cartPayment.Payment_Status__c = 'Invoiced';
            update cartPayment;
            Test.stopTest();
            System.assert(![SELECT ID FROM hed__Course_Enrollment__c LIMIT 100].isEmpty(),'No Course Connection Created');
        }
    }

    @isTest
    static void testBlankToPayNow() {
        final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
        System.runAs(PORTAL_SYS_ADMIN) {
            User portalUser = [     SELECT Id FROM User 
                                    WHERE Profile.Name = 'QUT Experience' 
                                    AND Email = 'testPortaluser@mailinator.com' 
                                    AND IsActive = TRUE 
                                    LIMIT 1];
            Account portalAccount1 = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
            WebStore testWebStore = [SELECT Id FROM WebStore LIMIT 1];

            List<CartItem> cartItemsToInsert = new List<CartItem>();
            Cart_Payment__c cartPayment = new Cart_Payment__c();
            insert cartPayment;
            WebCart cart = new WebCart( Name = 'Cart', AccountId = portalAccount1.Id, Status = 'Active', Status__c = 'Active',
            WebStoreId = testWebStore.Id, OwnerId = portalUser.Id
            );
            insert cart;

            cart.Cart_Payment__c = cartPayment.Id;
            update cart;

            CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(
            CartId = cart.Id,
            Name = 'Default Delivery'
            );
            insert cartDeliveryGroup;

            List<hed__Course_Offering__c> courseOfferings = new List<hed__Course_Offering__c>([SELECT Id FROM hed__Course_Offering__c LIMIT 1 ]);

            PriceBookEntry pbEntry = [SELECT Id, Product2Id, UnitPrice FROM PriceBookEntry LIMIT 1];

            CartItemHelper.CartItemDetails details;
            for(Integer i = 0; i < 100 ; i++){
                details = new CartItemHelper.CartItemDetails();
                details.offeringId = courseOfferings[0].Id;
                details.newWebCartId = cart.Id;
                details.pbEntry = pbEntry;
                details.prescribedProgram = false;
                details.cartDeliveryGroupId = cartDeliveryGroup.Id;
                cartItemsToInsert.add(CartItemHelper.createCartItem(details));
            }
            Test.startTest();
            insert cartItemsToInsert;
            cartPayment.Payment_Status__c = 'Approved';
            update cartPayment;
            Test.stopTest();
            System.assert(![SELECT ID FROM hed__Course_Enrollment__c LIMIT 100].isEmpty(),'No Course Connection Created');
        }
    }


    @isTest
    static void testInvoiceToPayNow() {
        final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
        System.runAs(PORTAL_SYS_ADMIN) {
            User portalUser = [     SELECT Id FROM User 
                                    WHERE Profile.Name = 'QUT Experience' 
                                    AND Email = 'testPortaluser@mailinator.com' 
                                    AND IsActive = TRUE 
                                    LIMIT 1];
            Account portalAccount1 = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
            WebStore testWebStore = [SELECT Id FROM WebStore LIMIT 1];

            List<CartItem> cartItemsToInsert = new List<CartItem>();
            Cart_Payment__c cartPayment = new Cart_Payment__c();
            insert cartPayment;
            WebCart cart = new WebCart( Name = 'Cart', AccountId = portalAccount1.Id, Status = 'Active', Status__c = 'Active',
            WebStoreId = testWebStore.Id, OwnerId = portalUser.Id
            );
            insert cart;

            cart.Cart_Payment__c = cartPayment.Id;
            update cart;

            CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(
            CartId = cart.Id,
            Name = 'Default Delivery'
            );
            insert cartDeliveryGroup;

            List<hed__Course_Offering__c> courseOfferings = new List<hed__Course_Offering__c>([SELECT Id FROM hed__Course_Offering__c LIMIT 1 ]);

            PriceBookEntry pbEntry = [SELECT Id, Product2Id, UnitPrice FROM PriceBookEntry LIMIT 1];

            CartItemHelper.CartItemDetails details;
            for(Integer i = 0; i < 100 ; i++){
                details = new CartItemHelper.CartItemDetails();
                details.offeringId = courseOfferings[0].Id;
                details.newWebCartId = cart.Id;
                details.pbEntry = pbEntry;
                details.prescribedProgram = false;
                details.cartDeliveryGroupId = cartDeliveryGroup.Id;
                cartItemsToInsert.add(CartItemHelper.createCartItem(details));
            }
            Test.startTest();
            insert cartItemsToInsert;
            cartPayment.Payment_Status__c = 'Invoiced';
            update cartPayment;
            cartPayment.Payment_Status__c = 'Approved';
            update cartPayment;
            Test.stopTest();
            System.assert(![SELECT ID FROM hed__Course_Enrollment__c LIMIT 100].isEmpty(),'No Course Connection Created');
        }
    }
}
