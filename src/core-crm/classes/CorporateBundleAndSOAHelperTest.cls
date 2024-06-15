/**
 * @description Test Class for ContactWithMatchingLeadHelper
 * @see ..ContactWithMatchingLeadHelper
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | Sep 9, 2022           | DEPP-3770              | creates test class           |
 */
@isTest
public with sharing class CorporateBundleAndSOAHelperTest {

     public static final String CCE_CATALOG = 'CCE Catalog';
    public static final String CCE_CATEGORY_QLS = 'QUTeX Learning Solutions'; 
    public static final String CCE_CATEGORY_CB = 'Corporate Bundle';
    private static final String PRODUCT_SPEC_RT = System.Label.RT_ProductSpecification_OPEProgramSpecification;
    private static Id opeProdSpecId = Schema.SObjectType.Product_Specification__c.getRecordTypeInfosByDeveloperName().get(PRODUCT_SPEC_RT).getRecordTypeId();
    private static Id cceProdSpecId = Schema.SObjectType.Product_Specification__c.getRecordTypeInfosByDeveloperName().get('CCE').getRecordTypeId();

    private static final Id ACTIVITY_ID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get('Activity').getRecordTypeId();
    private static final Id ACTIVITY_COURSE_ID = Schema.SObjectType.hed__Course__c.getRecordTypeInfosByDeveloperName().get('Activity').getRecordTypeId();

    private static final Id BUSINESS_ACC_RECTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Business_Organization')
        .getRecordTypeId();

    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get(ACCT_UNIV_DEP)
        .getRecordTypeId();

    private static final Id PR_CORPBUNDLE_RECTYPEID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName()
        .get('Corporate_Bundle')
        .getRecordTypeId();

    public static final Id PR_STANDOFFERARRANGE_RECTYPEID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName()
        .get('Standing_Offer_Arrangement')
        .getRecordTypeId(); 

     @testSetup
     static void testSetup() {
          Test.startTest();
          TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
          TestDataFactoryUser.generateUserSystemAdministrator();
          Test.stopTest();
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){

               WebStore testWebStore = new WebStore(Name='CCE', DefaultLanguage='en_US');
               insert testWebStore;
     
               ProductCatalog prodCatalog = new ProductCatalog(Name = 'CCE Catalog');
               insert prodCatalog;
     
               ProductCategory prodCategCB = new ProductCategory(
               Name = CCE_CATEGORY_CB,
               CatalogId = prodCatalog.Id
               );
               insert prodCategCB;

               Account account = new Account();
               account.Name = 'Test Business Org Account';
               account.RecordTypeId = BUSINESS_ACC_RECTYPEID;
               insert account;

               List<Account> offeringAccount = TestDataFactory.createTestAccountRecords(1);
               for(Account acc : offeringAccount){
                    acc.RecordTypeId = ACCT_UNIV_DEP_ID;
                    acc.Organization_Unit_Level__c = '2';
               }
               insert offeringAccount;

               Contact contact = new Contact();
               contact.FirstName = 'Test Partner User Contact';
               contact.LastName = 'Test Lname';
               contact.email = 'testcorporateuser@email.com';
               contact.Registered_Email__c = 'registeredtest@email.com';
               contact.AccountId = account.Id;
               insert contact;
               
               List<AccountContactRelation> acrList = new List<AccountContactRelation>([
                    SELECT ContactId 
                    FROM AccountContactRelation 
                    WHERE AccountId =: account.Id
                    AND IsActive = true
                    LIMIT 1
               ]);

               if(acrList.isEmpty()){
                    AccountContactRelation acr = new AccountContactRelation(
                         ContactId = contact.Id,
                         AccountId = account.Id
                    );

                    insert acr;
               }

               List<Contact> conList = new List<Contact>();
               conList.add(contact);

               List<Opportunity> opp = TestDataFactory.createClosedWonOpportunities(1,account.Id,contact.Id);
               insert opp;

               Pricebook2 priceBook;
               pricebook = new Pricebook2(isActive = true, id = Test.getStandardPricebookId());
               update pricebook;

               List<Product_Specification__c> prodSpecList = TestDataFactory.retrieveCCEProductSpecifications();

               List<Product_Request__c> cbRequest = TestDataFactory.createTestProductRequestRecords(1,prodSpecList[0].Id);
               for(Product_Request__c pr : cbRequest){
                    pr.RecordTypeId = PR_CORPBUNDLE_RECTYPEID;        
               }
               insert cbRequest;
               
               List<Asset> assetInsert = new List<Asset>();
               assetInsert.add(new Asset(
                    Name='Corporate Bundle',
                    AccountId = account.Id,
                    Product_Request__c = cbRequest[0].Id
               ));
               insert assetInsert;
               
               List<BuyerGroup> bgToInsertList = new List<BuyerGroup>();
               bgToInsertList.add(new BuyerGroup(
                    Name = 'Corporate Bundle - ' + account.Name,
                    Product_Request__c = cbRequest[0].Id
               ));
               insert bgToInsertList;

               List<Product_Request__c> courseRequest = TestDataFactory.createTestProductRequestRecords(1,prodSpecList[0].Id);
               for(Product_Request__c pr : courseRequest){
                    pr.RecordTypeId = ACTIVITY_ID;        
               }
               insert courseRequest;

               List<hed__Course__c> courses = new List<hed__Course__c>();
               for(Product_Request__c prC: courseRequest){
               courses.addAll(TestDataFactory.createTestCourseRecords(1,offeringAccount[0].Id,prC.Id));
               }
     
               for(hed__Course__c c: courses){
               c.RecordTypeId = ACTIVITY_COURSE_ID;
               }
               insert courses;

               List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(1, offeringAccount[0].Id);
    
               insert terms;
     
               List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(1, courses, terms);
               insert courseOfferings;
          }

          System.runAs(TestDataFactoryUser.selectUserSystemAdministrator){
               Contact con = [SELECT Id,Registered_Email__c,LastName,FirstName FROM Contact WHERE Registered_Email__c =: 'registeredtest@email.com' Limit 1];
               Profile profile = [SELECT Id FROM Profile WHERE Name = 'Corporate Partner' LIMIT 1];
               User commerceUser = new User();
               commerceUser.IsActive = true;
               commerceUser.Username = contact.Registered_Email__c + '.cce';
               commerceUser.Email = con.Registered_Email__c;
               commerceUser.LastName = con.LastName;
               commerceUser.FirstName = con.FirstName;
               commerceUser.ContactId = con.Id;
               commerceUser.alias = con.FirstName.substring(0, 1) + con.LastName.substring(0, 2);
               commerceUser.LanguageLocaleKey = 'en_US';
               commerceUser.localesidkey = 'en_AU';
               commerceUser.emailEncodingKey = 'UTF-8';
               commerceUser.timeZoneSidKey = 'Australia/Brisbane';
               commerceUser.profileId = profile.Id;

               insert commerceUser;
          }
     }

     @isTest
     private static void getCorporateUserTest(){
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
               Pricebook2 pricebookRecord = [
                    SELECT Id 
                    FROM Pricebook2
                    WHERE Name LIKE 'Corporate Bundle%'
                    LIMIT 1
               ];

               Test.startTest();
               System.assert(!CorporateBundleAndSOAHelper.getCorporateUser(pricebookRecord.Id).isEmpty(), 'No Corporate user retrieved');
               Test.stopTest();
          }
     }

     @isTest
     private static void createCCEWebCartTest(){
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
               User corporateUser = [
                    SELECT Id, AccountId, Contact.hed__Primary_Organization__c
                    FROM User 
                    WHERE Contact.FirstName = 'Test Partner User Contact' 
               ];

               Test.startTest();
               System.assert(CorporateBundleAndSOAHelper.createCCEWebCart(corporateUser) != null, 'No Web Cart record partially created');
               Test.stopTest();
          }
     }

     @isTest
     private static void checkCreditAvailabilityTest(){
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){

               Pricebook2 pricebookRecord = [
                    SELECT Id
                    FROM Pricebook2
                    WHERE Name Like 'Corporate%'
               ];

               Product2 productToInsert = new Product2(
                    IsActive = true,
                    Name = 'Test Asset Product'
               );

               insert productToInsert;

               List<PricebookEntry> pbEToInsert = new List<PricebookEntry>();

               Pricebook2 standardPriceBook = [
                    SELECT Id
                    FROM Pricebook2
                    WHERE IsStandard = true
               ];
               pbEToInsert.add(new PricebookEntry(Pricebook2Id = standardPriceBook.Id, UnitPrice = 12, Product2Id = productToInsert.Id));
               pbEToInsert.add(new PricebookEntry(Pricebook2Id = pricebookRecord.Id, UnitPrice = 12, Product2Id = productToInsert.Id ));

               insert pbEToInsert;
               Test.startTest();
               System.assert(!CorporateBundleAndSOAHelper.checkCreditAvailability(
                    String.valueOf(pbEToInsert[1].Id),
                    String.valueOf([SELECT Id FROM Asset LIMIT 1].Id)),'Asset is available');
               Test.stopTest();
          }
     }


     @isTest
     private static void getAssetTest(){
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){

               Pricebook2 pricebookRecord = [
                    SELECT Id
                    FROM Pricebook2
                    WHERE Name Like 'Corporate%'
               ];

               Product2 productToInsert = new Product2(
                    IsActive = true,
                    Name = 'Test Asset Product'
               );

               insert productToInsert;

               List<PricebookEntry> pbEToInsert = new List<PricebookEntry>();

               Pricebook2 standardPriceBook = [
                    SELECT Id
                    FROM Pricebook2
                    WHERE IsStandard = true
               ];
               pbEToInsert.add(new PricebookEntry(Pricebook2Id = standardPriceBook.Id, UnitPrice = 12, Product2Id = productToInsert.Id));
               pbEToInsert.add(new PricebookEntry(Pricebook2Id = pricebookRecord.Id, UnitPrice = 12, Product2Id = productToInsert.Id ));

               insert pbEToInsert;

               List<String> pbEntryIds = new List<String>();
               for(PricebookEntry pbe: pbEToInsert){
                    pbEntryIds.add(pbe.Id);
               }
               Test.startTest();
               System.assert(!CorporateBundleAndSOAHelper.getAsset(pbEntryIds).keySet().isEmpty(), 'no asset against the pricebook retrieved');
               Test.stopTest();
          }
     }

     @isTest
     private static void createProductLedgerRecordsTest(){
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
               
               hed__Course_Offering__c courseOffering = [
                    SELECT Id 
                    FROM hed__Course_Offering__c
                    LIMIT 1
               ];

               List<hed__Course_Enrollment__c> courseConList = new List<hed__Course_Enrollment__c>();
               hed__Course_Enrollment__c courseCon = new hed__Course_Enrollment__c(
                    Amount__c = 123,
                    hed__Course_Offering__c = courseOffering.Id
               );

               insert courseCon;

               courseConList.add(courseCon);

               Test.startTest();
               CorporateBundleAndSOAHelper.createProductLedgerRecords([SELECT Id FROM Asset LIMIT 1].Id,courseConList);
               System.assert(![SELECT Id FROM Product_Ledger__c LIMIT 1].isEmpty(), 'no ledger created against the course connection');
               Test.stopTest();
          }
          
     }

     @isTest
     private static void createAffiliationRecordsWithoutCartTest(){
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){

               hed__Course_Offering__c courseOffering = [
                    SELECT Id 
                    FROM hed__Course_Offering__c
                    LIMIT 1
               ];

               List<hed__Course_Enrollment__c> courseConList = new List<hed__Course_Enrollment__c>();
               hed__Course_Enrollment__c courseCon = new hed__Course_Enrollment__c(
                    Amount__c = 123,
                    hed__Course_Offering__c = courseOffering.Id
               );

               insert courseCon;

               courseConList.add(courseCon);

               Test.startTest();
               CorporateBundleAndSOAHelper.createAffiliationRecords(courseConList);
               System.assert(![SELECT Id FROM hed__Affiliation__c LIMIT 1].isEmpty(), 'no affiliation created');
               Test.stopTest();
          }
     }

}