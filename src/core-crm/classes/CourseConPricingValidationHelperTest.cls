/**
 * @description test class for courseconnectionpricingvalidationhelper
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
 *    |--------------------------------|-----------------------|------------------------|--------------------------------------------|
 *    | roy.nino.s.regala              | Sep 19, 2023          | DEPP-6714              | created file                               |
 */
@isTest
public with sharing class CourseConPricingValidationHelperTest {
    @testSetup
    static void setupMethod() {
        Test.startTest();
        TestDataFactoryUser.generateUserQUTCorporatePartnerUser();
        TestDataFactoryUser.generateUserSystemAdministrator();
        Test.stopTest();
        
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            User corporateUser = TestDataFactoryUser.selectUserQUTCorporatePartnerUser;
            WebStore testWebStore = new WebStore(Name = 'Study', DefaultLanguage = 'en_US');

            WebStoresDAO.newInstance()
                .insertRecords(new List<WebStore>{ testWebStore }, true, AccessLevel.SYSTEM_MODE);

            WebCart cart = TestDataFactory.createWebCart(
                corporateUser.AccountId,
                corporateUser.Id,
                testWebStore.Id
            );

            WebCartsDAO.newInstance()
                .insertRecords(new List<WebCart>{ cart }, true, AccessLevel.USER_MODE);

            CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(
                CartId = cart.Id,
                Name = 'Default Delivery'
            );

            CartDeliveryGroupsDAO.newInstance()
                .insertRecords(
                    new List<CartDeliveryGroup>{ cartDeliveryGroup },
                    true,
                    AccessLevel.USER_MODE
                );

            Product2 testProduct = new Product2(Name = 'Test Product');

            ProductsDAO.newInstance()
                .insertRecords(new List<Product2>{ testProduct }, true, AccessLevel.USER_MODE);

            Pricebook2 standardPricebok = new Pricebook2(
                isActive = true,
                id = Test.getStandardPricebookId()
            );

            Pricebook2 alumniPricebook = new Pricebook2(isActive = true, Name = 'Alumni');

            Pricebook2 learnerPricebook = new Pricebook2(isActive = true, Name = 'Current Learner');

            Pricebook2 staffPricebook = new Pricebook2(isActive = true, Name = 'Current Staff');

            PricebooksDAO.newInstance()
                .upsertRecords(
                    new List<Pricebook2>{
                        standardPricebok,
                        alumniPricebook,
                        learnerPricebook,
                        staffPricebook
                    },
                    true,
                    AccessLevel.USER_MODE
                );

            PricebookEntry standardPricebookEntry = new PricebookEntry(
                pricebook2id = standardPricebok.Id,
                UnitPrice = 120,
                product2Id = testProduct.id
            );

            PricebookEntry alumniPricebookEntry = new PricebookEntry(
                pricebook2id = alumniPricebook.Id,
                UnitPrice = 121,
                product2Id = testProduct.id
            );

            PricebookEntry learnerPricebookEntry = new PricebookEntry(
                pricebook2id = learnerPricebook.Id,
                UnitPrice = 122,
                product2Id = testProduct.id
            );

            PricebookEntry staffPricebookEntry = new PricebookEntry(
                pricebook2id = staffPricebook.Id,
                UnitPrice = 123,
                product2Id = testProduct.id
            );

            PricebookEntriesDAO.newInstance()
                .insertRecords(
                    new List<PricebookEntry>{
                        standardPricebookEntry,
                        alumniPricebookEntry,
                        learnerPricebookEntry,
                        staffPricebookEntry
                    },
                    true,
                    AccessLevel.USER_MODE
                );

            CartItem alumniCartItem = new CartItem(
                CartId = cart.Id,
                CartDeliveryGroupId = cartDeliveryGroup.Id,
                Name = 'Alumni Cart Item',
                Pricebook_Entry_ID__c = alumniPricebookEntry.Id,
                Quantity = 1,
                TotalPrice = alumniPricebookEntry.UnitPrice,
                Type = 'Product'
            );

            CartItem learnerCartItem = new CartItem(
                CartId = cart.Id,
                CartDeliveryGroupId = cartDeliveryGroup.Id,
                Name = 'Learner Cart Item',
                Pricebook_Entry_ID__c = learnerPricebookEntry.Id,
                Quantity = 1,
                TotalPrice = learnerPricebookEntry.UnitPrice,
                Type = 'Product'
            );

            CartItem staffCartItem = new CartItem(
                CartId = cart.Id,
                CartDeliveryGroupId = cartDeliveryGroup.Id,
                Name = 'Staff Cart Item',
                Pricebook_Entry_ID__c = staffPricebookEntry.Id,
                Quantity = 1,
                TotalPrice = staffPricebookEntry.UnitPrice,
                Type = 'Product'
            );

            CartItem cartItem = new CartItem(
                CartId = cart.Id,
                CartDeliveryGroupId = cartDeliveryGroup.Id,
                Name = 'Cart Item',
                Quantity = 1,
                TotalPrice = 100,
                Type = 'Product'
            );

            CartItemsDAO.newInstance()
                .insertRecords(
                    new List<CartItem>{ alumniCartItem, learnerCartItem, staffCartItem, cartItem },
                    true,
                    AccessLevel.USER_MODE
                );
        }

    }

    @isTest
    static void testAlumiUnsuccessfulVerification() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);

            List<CartItem> alumniCartItem = CartItemsDAO.newInstance()
                .getCartItemsByCartItemName(
                    new Set<String>{ 'Alumni Cart Item' },
                    AccessLevel.SYSTEM_MODE
                );

            hed__Course_Enrollment__c courseCon = new hed__Course_Enrollment__c(
                hed__Contact__c = contactList[0].Id,
                Cart_Item__c = alumniCartItem[0].Id,
                hed__Status__c = 'Active'
            );

            CourseConnectionsDAO.newInstance()
                .insertRecords(
                    new List<hed__Course_Enrollment__c>{ courseCon },
                    true,
                    AccessLevel.USER_MODE
                );

            System.assert(
                CourseConnectionsDAO.newInstance()
                        .getActiveCourseConnectionsBySetContactIds(
                            new Set<String>{ contactList[0].Id },
                            AccessLevel.USER_MODE
                        )[0]
                    .Pricing_Validation__c == 'Unsuccessful',
                'Course Connection is Successful'
            );
        }
    }

    @isTest
    static void testAlumiSuccessfulVerification() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            contactList[0].Alumni_Verified__c = true;
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);

            List<CartItem> alumniCartItem = CartItemsDAO.newInstance()
                .getCartItemsByCartItemName(
                    new Set<String>{ 'Alumni Cart Item' },
                    AccessLevel.SYSTEM_MODE
                );

            hed__Course_Enrollment__c courseCon = new hed__Course_Enrollment__c(
                hed__Contact__c = contactList[0].Id,
                Cart_Item__c = alumniCartItem[0].Id,
                hed__Status__c = 'Active'
            );

            CourseConnectionsDAO.newInstance()
                .insertRecords(
                    new List<hed__Course_Enrollment__c>{ courseCon },
                    true,
                    AccessLevel.USER_MODE
                );

            System.assert(
                CourseConnectionsDAO.newInstance()
                        .getActiveCourseConnectionsBySetContactIds(
                            new Set<String>{ contactList[0].Id },
                            AccessLevel.USER_MODE
                        )[0]
                    .Pricing_Validation__c == 'Successful',
                'Course Connection is Unsuccessful'
            );
        }
    }

    @isTest
    static void testAlumniUnsuccessfulVerificationToCompleted() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);

            List<CartItem> alumniCartItem = CartItemsDAO.newInstance()
                .getCartItemsByCartItemName(
                    new Set<String>{ 'Alumni Cart Item' },
                    AccessLevel.SYSTEM_MODE
                );

            hed__Course_Enrollment__c courseCon = new hed__Course_Enrollment__c(
                hed__Contact__c = contactList[0].Id,
                Cart_Item__c = alumniCartItem[0].Id,
                hed__Status__c = 'Active'
            );

            CourseConnectionsDAO.newInstance()
                .insertRecords(
                    new List<hed__Course_Enrollment__c>{ courseCon },
                    true,
                    AccessLevel.USER_MODE
                );

            courseCon = new hed__Course_Enrollment__c(
                Id = courseCon.Id,
                hed__Status__c = 'Completed'
            );

            CourseConnectionsDAO.newInstance()
                .updateRecords(
                    new List<hed__Course_Enrollment__c>{ courseCon },
                    true,
                    AccessLevel.USER_MODE
                );

            System.assert(
                ContactsDAO.newInstance()
                        .getPersonContactsBySetIds(
                            new Set<Id>{ contactList[0].Id },
                            AccessLevel.USER_MODE
                        )[0]
                    .Alumni_Verified__c == true,
                'Alumni_Verified__c is false'
            );
        }
    }

    @isTest
    static void testStaffUnsuccessfulVerification() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);

            List<CartItem> staffCartItem = CartItemsDAO.newInstance()
                .getCartItemsByCartItemName(
                    new Set<String>{ 'Staff Cart Item' },
                    AccessLevel.SYSTEM_MODE
                );

            hed__Course_Enrollment__c courseCon = new hed__Course_Enrollment__c(
                hed__Contact__c = contactList[0].Id,
                Cart_Item__c = staffCartItem[0].Id,
                hed__Status__c = 'Active'
            );

            CourseConnectionsDAO.newInstance()
                .insertRecords(
                    new List<hed__Course_Enrollment__c>{ courseCon },
                    true,
                    AccessLevel.USER_MODE
                );
            System.assert(
                CourseConnectionsDAO.newInstance()
                        .getActiveCourseConnectionsBySetContactIds(
                            new Set<String>{ contactList[0].Id },
                            AccessLevel.USER_MODE
                        )[0]
                    .Pricing_Validation__c == 'Unsuccessful',
                'Course Connection is Successful'
            );
        }
    }

    @isTest
    static void testStaffSuccessfulVerification() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            contactList[0].Staff_Verified__c = true;
            contactList[0].IsStaff_Active__c = true;
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);

            List<CartItem> staffCartItem = CartItemsDAO.newInstance()
                .getCartItemsByCartItemName(
                    new Set<String>{ 'Staff Cart Item' },
                    AccessLevel.SYSTEM_MODE
                );

            hed__Course_Enrollment__c courseCon = new hed__Course_Enrollment__c(
                hed__Contact__c = contactList[0].Id,
                Cart_Item__c = staffCartItem[0].Id,
                hed__Status__c = 'Active'
            );

            CourseConnectionsDAO.newInstance()
                .insertRecords(
                    new List<hed__Course_Enrollment__c>{ courseCon },
                    true,
                    AccessLevel.USER_MODE
                );

            System.assert(
                CourseConnectionsDAO.newInstance()
                        .getActiveCourseConnectionsBySetContactIds(
                            new Set<String>{ contactList[0].Id },
                            AccessLevel.USER_MODE
                        )[0]
                    .Pricing_Validation__c == 'Successful',
                'Course Connection is Unsuccessful'
            );
        }
    }

    @isTest
    static void testLearnerUnsuccessfulVerification() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);

            List<CartItem> learnerCartItem = CartItemsDAO.newInstance()
                .getCartItemsByCartItemName(
                    new Set<String>{ 'Learner Cart Item' },
                    AccessLevel.SYSTEM_MODE
                );

            hed__Course_Enrollment__c courseCon = new hed__Course_Enrollment__c(
                hed__Contact__c = contactList[0].Id,
                Cart_Item__c = learnerCartItem[0].Id,
                hed__Status__c = 'Active'
            );

            CourseConnectionsDAO.newInstance()
                .insertRecords(
                    new List<hed__Course_Enrollment__c>{ courseCon },
                    true,
                    AccessLevel.USER_MODE
                );

            System.assert(
                CourseConnectionsDAO.newInstance()
                        .getActiveCourseConnectionsBySetContactIds(
                            new Set<String>{ contactList[0].Id },
                            AccessLevel.USER_MODE
                        )[0]
                    .Pricing_Validation__c == 'Unsuccessful',
                'Course Connection is Successful'
            );

            System.assert(
                ContactsDAO.newInstance()
                        .getPersonContactsBySetIds(
                            new Set<Id>{ contactList[0].Id },
                            AccessLevel.USER_MODE
                        )[0]
                    .Current_Learner_Verified__c == true,
                'Current_Learner_Verified__c is false'
            );
        }
    }

    @isTest
    static void testLearnerSuccessfulVerification() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            contactList[0].Current_Learner_Verified__c = true;
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);

            List<CartItem> learnerCartItem = CartItemsDAO.newInstance()
                .getCartItemsByCartItemName(
                    new Set<String>{ 'Learner Cart Item' },
                    AccessLevel.SYSTEM_MODE
                );

            hed__Course_Enrollment__c courseCon = new hed__Course_Enrollment__c(
                hed__Contact__c = contactList[0].Id,
                Cart_Item__c = learnerCartItem[0].Id,
                hed__Status__c = 'Active'
            );

            CourseConnectionsDAO.newInstance()
                .insertRecords(
                    new List<hed__Course_Enrollment__c>{ courseCon },
                    true,
                    AccessLevel.USER_MODE
                );

            System.assert(
                CourseConnectionsDAO.newInstance()
                        .getActiveCourseConnectionsBySetContactIds(
                            new Set<String>{ contactList[0].Id },
                            AccessLevel.USER_MODE
                        )[0]
                    .Pricing_Validation__c == 'Successful',
                'Course Connection is Unsuccessful'
            );
        }
    }

    @isTest
    static void testLearnerUnsuccessfulVerificationInactive() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            contactList[0].Current_Learner_Verified__c = true;
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);

            List<CartItem> learnerCartItem = CartItemsDAO.newInstance()
                .getCartItemsByCartItemName(
                    new Set<String>{ 'Learner Cart Item' },
                    AccessLevel.SYSTEM_MODE
                );

            hed__Course_Enrollment__c courseCon = new hed__Course_Enrollment__c(
                hed__Contact__c = contactList[0].Id,
                Cart_Item__c = learnerCartItem[0].Id,
                hed__Status__c = 'Active'
            );

            CourseConnectionsDAO.newInstance()
                .insertRecords(
                    new List<hed__Course_Enrollment__c>{ courseCon },
                    true,
                    AccessLevel.USER_MODE
                );

            courseCon = new hed__Course_Enrollment__c(
                Id = courseCon.Id,
                hed__Status__c = 'Completed'
            );

            CourseConnectionsDAO.newInstance()
                .updateRecords(
                    new List<hed__Course_Enrollment__c>{ courseCon },
                    true,
                    AccessLevel.USER_MODE
                );

            System.assert(
                ContactsDAO.newInstance()
                        .getPersonContactsBySetIds(
                            new Set<Id>{ contactList[0].Id },
                            AccessLevel.USER_MODE
                        )[0]
                    .Current_Learner_Verified__c == false,
                'Current_Learner_Verified__c is true'
            );
        }
    }

    @isTest
    static void testWithoutPricing() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);

            List<CartItem> learnerCartItem = CartItemsDAO.newInstance()
                .getCartItemsByCartItemName(
                    new Set<String>{ 'Cart Item' },
                    AccessLevel.SYSTEM_MODE
                );

            hed__Course_Enrollment__c courseCon = new hed__Course_Enrollment__c(
                hed__Contact__c = contactList[0].Id,
                Cart_Item__c = learnerCartItem[0].Id,
                hed__Status__c = 'Active'
            );

            System.assert(
                !CourseConnectionsDAO.newInstance()
                    .insertRecords(
                        new List<hed__Course_Enrollment__c>{ courseCon },
                        true,
                        AccessLevel.USER_MODE
                    )
                    .isEmpty(),
                'Course connection failed to insert'
            );
        }
    }
}
