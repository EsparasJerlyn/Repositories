/**
 * @description Tests the Product Details Controller Test Class
 *
 * @see ProductDetailsCtrl
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA      | Change Summary                                     |
      |---------------------------|-----------------------|-----------|----------------------------------------------------|
      | roy.nino.s.regala         | December 10, 2021     | DEPP116   | Created file                                       | 
      | roy.nino.s.regala         | December 27, 2021     | DEPP1028  | Added testmethod for insertLearnerInfo             |
	  | roy.nino.s.regala         | February 04, 2022     | DEPP213   | Added testmethod for insert Expression of Interest |
*/
@isTest(SeeAllData=false)
private class ProductDetailsCtrlTest {
    private static User  currentUser = TestDataFactory.createUserRecords(1,'QUTeX').iterator().next();
    @testSetup static void setupMethod() {
       List<Account> accounts;
       List<hed__Term__c> terms;
       List<Product_Request__c> prodRequest;
       List<hed__Course_Offering__c> courseOfferings;
       List<hed__Course__c> courses;
       List<Product2> products;
       Pricebook2 priceBook;
       PricebookEntry priceBookEntry;
        
       accounts = TestDataFactory.createTestAccountRecords(100);
       insert accounts;
       List<Contact> contacts = TestDataFactory.createTestContactRecords(1);
       contacts[0].Email = 'testemailuserqut@email.com';
       insert contacts;
       terms = TestDataFactory.createTestTermRecords(50,accounts[0].Id);
       insert terms;
       prodRequest = TestDataFactory.createTestProductRequestRecords(1);
       insert prodRequest;
       courses = TestDataFactory.createTestCourseRecords(50,accounts[0].Id,prodRequest[0].Id);
       insert courses;
       products = TestDataFactory.createTestProductRecords(50,courses);
       insert products;
       pricebook = new Pricebook2(isActive = true, id = Test.getStandardPricebookId());
       update pricebook;
       priceBookEntry = new PricebookEntry(pricebook2id = pricebook.Id, UnitPrice = 12, product2Id = products[0].Id, isActive = true);
       insert priceBookEntry;
       courseOfferings = TestDataFactory.createTestCourseOfferingRecord(50,courses,terms);
       insert courseOfferings;
       
    }

    @isTest
    static void testGetProductRelatedRecords()
    {
        Test.startTest();
        System.runAs(currentUser)
        {
            ProductDetailsCtrl.ProductDetailsData getProductDetails = new ProductDetailsCtrl.ProductDetailsData();
            getProductDetails = ProductDetailsCtrl.getProductRelatedRecords([SELECT Id FROM Product2 LIMIT 1].Id);
            System.assert(!getProductDetails.courseOfferingList.isEmpty(),'no courseofferings found');
            //System.assert(!getProductDetails.priceBookEntryList.isEmpty(),'no pricebookentries found');
        }
        Test.stopTest();
    }

    @isTest
    static void testGetProductRelatedRecordsNegative()
    {
        boolean hasError = false;
        Test.startTest();
        System.runAs(currentUser)
        {
            Product2 singleProduct = TestDataFactory.createTestInActiveProductRecords(1).iterator().next();
            insert singleProduct;
            ProductDetailsCtrl.ProductDetailsData getProductDetails = new ProductDetailsCtrl.ProductDetailsData();
            getProductDetails = ProductDetailsCtrl.getProductRelatedRecords(singleProduct.Id);
            System.assert(getProductDetails.courseOfferingList.isEmpty(),'has courseofferings found');
            System.assert(getProductDetails.priceBookEntryList.isEmpty(),'has pricebookentries found');
        }
        Test.stopTest();
    }

    @isTest
    static void testGetProductRelatedRecordsError()
    {
        boolean hasError = false;
        Test.startTest();
        System.runAs(currentUser)
        {
            ProductDetailsCtrl.ProductDetailsData getProductDetails = new ProductDetailsCtrl.ProductDetailsData();
            try{
                getProductDetails = ProductDetailsCtrl.getProductRelatedRecords(null);
            }catch(Exception e){
                hasError = true;
            }
            System.assert(hasError,'has no error');
        }
        Test.stopTest();
    }

    @isTest
    static void testInsertLearnerInfo()
    {
        List<hed__Course_Offering__c> courseOffering = new List<hed__Course_Offering__c>([SELECT Id FROM hed__Course_Offering__c LIMIT 1]);
        List<Contact> contacts = TestDataFactory.createTestContactRecords(100);
        Test.startTest();
        System.runAs(currentUser)
        {  
            ProductDetailsCtrl.WrapperClass wrappedData = new ProductDetailsCtrl.WrapperClass();
            wrappedData.courseOfferingId = courseOffering[0].Id;

            ProductDetailsCtrl.insertLearnerInfo(contacts,wrappedData);
            System.assert(![SELECT ID FROM Contact].isEmpty(),'has no contacts created');
            System.assert(![SELECT ID FROM hed__Course_Enrollment__c].isEmpty(),'has no contact enrollement created');
        }
        Test.stopTest();
    }

    @isTest
    static void testInsertLearnerInfoError()
    {
        List<hed__Course_Offering__c> courseOffering = new List<hed__Course_Offering__c>([SELECT Id FROM hed__Course_Offering__c LIMIT 1]);
        List<Contact> contacts = TestDataFactory.createTestContactRecords(1);
        insert contacts;
        boolean hasError = false;
        Test.startTest();
        System.runAs(currentUser)
        {  
            ProductDetailsCtrl.WrapperClass wrappedData = new ProductDetailsCtrl.WrapperClass();
            wrappedData.courseOfferingId = courseOffering[0].Id;
            try{
                ProductDetailsCtrl.insertLearnerInfo(contacts,wrappedData);
            }catch(Exception e){
                hasError = true;
            }
            System.assert(hasError,'has no error');
        }
        Test.stopTest();
    }

    @isTest
    static void testInsertExpressionOfInterest()
    {
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        User portalAccountOwner1 = new User(
        UserRoleId = portalRole.Id,
        ProfileId = profile1.Id,
        Username = System.now().millisecond() + 'Admin1@test.com',
        Alias = 'batman',
        Email='bruce.wayne@wayneenterprises.com',
        EmailEncodingKey='UTF-8',
        Firstname='Bruce',
        Lastname='Wayne',
        LanguageLocaleKey='en_US',
        LocaleSidKey='en_US',
        TimeZoneSidKey='America/Chicago'
        );
        Database.insert(portalAccountOwner1);

        System.runAs ( portalAccountOwner1 ) {
            //Create account
            Account portalAccount1 = new Account(
            Name = 'TestAccount',
            OwnerId = portalAccountOwner1.Id
            );
            Database.insert(portalAccount1);
            
            //Create contact
            Contact contact1 = new Contact(
            FirstName = 'Test',
            Lastname = 'McTesty',
            AccountId = portalAccount1.Id,
            Email = System.now().millisecond() + 'test@test.com'
            );
            Database.insert(contact1);
            
            //Create user
            User portalUser = TestDataFactory.createPortalUserRecords(1,'Corporate Partner User',contact1.Id).iterator().next();
            Database.insert(portalUser);

            Product2 product = [SELECT Id FROM Product2 LIMIT 1];
            Test.startTest();
            
            ProductDetailsCtrl.insertExpressionOfInterest(portalUser.Id,product.Id);
            System.assert(![SELECT Id FROM Expression_of_interest__c].isEmpty(), 'No expression of interest created');
            
            Test.stopTest();
        }

        
    }

    @isTest
    static void testInsertExpressionOfInterestError()
    {
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        User portalAccountOwner1 = new User(
        UserRoleId = portalRole.Id,
        ProfileId = profile1.Id,
        Username = System.now().millisecond() + 'testAdmin2@test.com',
        Alias = 'batman',
        Email='bruce.wayne@wayneenterprises.com',
        EmailEncodingKey='UTF-8',
        Firstname='Bruce',
        Lastname='Wayne',
        LanguageLocaleKey='en_US',
        LocaleSidKey='en_US',
        TimeZoneSidKey='America/Chicago'
        );
        Database.insert(portalAccountOwner1);

        System.runAs ( portalAccountOwner1 ) {
            //Create account
            Account portalAccount1 = new Account(
            Name = 'TestAccount',
            OwnerId = portalAccountOwner1.Id
            );
            Database.insert(portalAccount1);
            
            //Create contact
            Contact contact1 = new Contact(
            FirstName = 'Test',
            Lastname = 'McTesty',
            AccountId = portalAccount1.Id,
            Email = System.now().millisecond() + 'test@test.com'
            );
            Database.insert(contact1);
            
            //Create user
            User portalUser = TestDataFactory.createPortalUserRecords(1,'Corporate Partner User',contact1.Id).iterator().next();
            Database.insert(portalUser);

            Product2 product = [SELECT Id FROM Product2 LIMIT 1];
            boolean hasError = false;
            Test.startTest();
                ProductDetailsCtrl.insertExpressionOfInterest(portalUser.Id,product.Id);
                try{
                    ProductDetailsCtrl.insertExpressionOfInterest(portalUser.Id,product.Id);
                }catch(Exception e){
                    hasError = true;
                }
                System.assert(hasError,'has no error');
            Test.stopTest();
        }

    }


}