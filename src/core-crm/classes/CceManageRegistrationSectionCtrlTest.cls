/**
 * @description test class for CceManageRegistrationSectionCtrl
 * @see ../classes/CceManageRegistrationSectionCtrl
 * 
 * @author Accenture
 * 
 * @history
 *  | Developer                 | Date                  | JIRA                 | Change Summary               |
    |---------------------------|-----------------------|----------------------|------------------------------|
    | roy.nino.s.regala         | Aug 01, 2022          | DEPP-2498            | Created file                 | 
    |                           |                       |                      |                              | 
*/
@isTest
public with sharing class CceManageRegistrationSectionCtrlTest {

    private static final Id SOA_ID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get('Standing_Offer_Arrangement').getRecordTypeId();
    private static final Id ACTIVITY_ID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get('Activity').getRecordTypeId();
    private static final Id ACTIVITY_COURSE_ID = Schema.SObjectType.hed__Course__c.getRecordTypeInfosByDeveloperName().get('Activity').getRecordTypeId();
    private static final Id BUSINESS_ACC_RECTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Organization').getRecordTypeId();
    private static Id cceProdSpecId = Schema.SObjectType.Product_Specification__c.getRecordTypeInfosByDeveloperName().get('CCE').getRecordTypeId();
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get(ACCT_UNIV_DEP)
        .getRecordTypeId();
    private static final Id PROGRAM_ID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get('Program').getRecordTypeId();

    @testSetup 
    static void setupMethod() {
        Test.startTest();
        TestDataFactoryUser.generateUserSystemAdministrator();
        Test.stopTest();
        final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;  
        System.runAs(PORTAL_SYS_ADMIN){

            List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
            for(Account acc : accounts){
                acc.RecordTypeId = ACCT_UNIV_DEP_ID;
                acc.Organization_Unit_Level__c = '2';
            }

            List<Account> accountList = TestDataFactory.createTestAccountRecords(2);
    
            for(Account acc: accountList){
                acc.RecordTypeId = BUSINESS_ACC_RECTYPEID;
            }

            //Create account
            Account portalAccount1 = new Account(
            Name = 'TestAccount',
            OwnerId = PORTAL_SYS_ADMIN.Id
            );

            accountList.add(portalAccount1);
            accountList.addAll(accounts);
            insert accountList;

            List<Contact> conList;
            conList = TestDataFactory.createTestContactRecords(1);
            //Create contact
            Contact contact1 = new Contact(
            FirstName = 'portalUser',
            Lastname = 'Testing',
            AccountId = portalAccount1.Id,
            Email = System.now().millisecond() + 'portalUser@test.com'
            );
            conList.add(contact1);
            insert conList;

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
    
            List<Opportunity> oppList = TestDataFactory.createClosedWonOpportunities(1,accounts[0].Id,conList.iterator().next()?.Id);
            insert oppList;
    
            List<Product_Specification__c> prodSpecList = TestDataFactory.retrieveCCEProductSpecifications();
    
            List<Product_Request__c> soaRequest = TestDataFactory.createTestProductRequestRecords(1,prodSpecList[0].Id);
    
            Pricebook2 priceBook;
            pricebook = new Pricebook2(isActive = true, id = Test.getStandardPricebookId());
            update pricebook;
    
            for(Product_Request__c pr : soaRequest){
                pr.RecordTypeId = SOA_ID;        
            }
            insert soaRequest;
    
            List<BuyerGroup> bgToInsertList = new List<BuyerGroup>();
            List<PriceBook2> soaPBList = new List<PriceBook2>();
            List<Id> pbIds  = new List<Id>();
            for(Integer i = 0; i<soaRequest.size();i++){
            bgToInsertList.add(new BuyerGroup(Name ='SOA' + i, Product_Request__c = soaRequest[i].Id));
            }
            
            insert bgToInsertList;
            List<BuyerGroupPriceBook> bgPriceBookList = new List<BuyerGroupPriceBook>([
                SELECT Id, Pricebook2Id
                FROM BuyerGroupPriceBook
                WHERE BuyerGroupId IN: bgToInsertList
            ]);

            for(BuyerGroupPriceBook bgpb: bgPriceBookList){
                pbIds.add(bgPB.Pricebook2Id);
            }
            soaPBList = [SELECT Id FROM Pricebook2 WHERE Id IN: pbIds];

            List<Product_Request__c> courseRequest = TestDataFactory.createTestProductRequestRecords(1,prodSpecList[0].Id);
            for(Product_Request__c pr : courseRequest){
                pr.RecordTypeId = ACTIVITY_ID;        
            }
            insert courseRequest;
    
            List<hed__Course__c> courses = new List<hed__Course__c>();
            for(Product_Request__c prC: courseRequest){
            courses.addAll(TestDataFactory.createTestCourseRecords(1,accounts[0].Id,prC.Id));
            }
    
            for(hed__Course__c c: courses){
            c.RecordTypeId = ACTIVITY_COURSE_ID;
            }
            insert courses;
    
            List<Associated_Products__c> assocProdList = new List<Associated_Products__c>();
    
            List<Product2> prodList = new List<Product2>([SELECT Id From Product2 WHERE Course__c IN: courses]);
    
            for(Integer i = 0; i < prodList.size(); i ++){
            assocProdList.add(new Associated_Products__c(Product__c = prodList[i].Id, Product_Request__c = soaRequest[i].Id, IsActive__c = true));
            }
    
            insert assocProdList;
    
            List<PriceBookEntry> pbEToInsert = new List<PriceBookEntry>();
            List<PriceBookEntry> soaPBEToInsert = new List<PriceBookEntry>();
    
            for(Integer i = 0; i < prodList.size(); i ++){
            pbEToInsert.add(new PricebookEntry(Pricebook2Id = priceBook.Id, UnitPrice = 12, Product2Id = prodList[i].Id));
            soaPBEToInsert.add(new PricebookEntry(Pricebook2Id = soaPBList[0].Id, UnitPrice = 12, Product2Id = prodList[i].Id ));
            }
            insert pbEToInsert;
            insert soaPBEToInsert;
    
            List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(1, accounts[0].Id);
    
            insert terms;
    
            List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(1, courses, terms);
            insert courseOfferings;
    
            Id offeringId = courseOfferings[0].Id;

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

            CartItemHelper.CartItemDetails details = new CartItemHelper.CartItemDetails();
            details.offeringId = offeringId;
            details.newWebCartId = cart.Id;
            details.pbEntry = soaPBEToInsert[0];
            details.prescribedProgram = false;
            details.cartDeliveryGroupId = cartDeliveryGroup.Id;
            cartItemsToInsert.add(CartItemHelper.createCartItem(details));
            insert cartItemsToInsert;
            cartPayment.Payment_Status__c = 'Invoiced';
            update cartPayment;
        }
    }
    
    @isTest
    static void getLearnerDetailsTest(){
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator){
            
            List<Product_Request__c> prList = new List<Product_Request__c>([
                SELECT Id 
                FROM Product_Request__c
                WHERE RecordTypeId =: SOA_ID
            ]);
            System.assert(!CceManageRegistrationSectionCtrl.getLearnerDetails(prList[0].Id).isEmpty(), 'no learners retrieved');
            
        }
        Test.stopTest();
    }

    @isTest
    static void updateLearnersTest(){
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator){
            
            List<hed__Course_Enrollment__c> courseEnrollmentList = new List<hed__Course_Enrollment__c>([
                SELECT Id, hed__Status__c
                FROM hed__Course_Enrollment__c
                LIMIT 1
            ]);
            for(hed__Course_Enrollment__c courseEnrollment: courseEnrollmentList){
                courseEnrollment.hed__Status__c = 'Cancelled';
            }
            CceManageRegistrationSectionCtrl.updateLearners(courseEnrollmentList);
            System.assert(![SELECT Id FROM hed__Course_Enrollment__c WHERE hed__Status__c = 'Cancelled' LIMIT 1].isEmpty(), 'no learners updated');
            
        }
        Test.stopTest();
    }
}