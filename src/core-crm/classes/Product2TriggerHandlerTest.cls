/**
 * @description Test Class for Product2TriggerHandler
 * @see ..Product2TriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | john.bo.a.pineda               | May 3, 2022           | DEPP-2403              | Created file                 |
      | john.bo.a.pineda               | May 13, 2022          | DEPP-2591              | Updated to load to Store     |
      |                                |                       |                        |                              |
 */
@isTest(SeeAllData=false)
public with sharing class Product2TriggerHandlerTest {
  private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
  private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
    .get(ACCT_UNIV_DEP)
    .getRecordTypeId();
  public static final Id FACULTY_RECTYPEID = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName()
    .get('Faculty')
    .getRecordTypeId();

  private static User currentUser = TestDataFactory.createUserRecords(
      1,
      'QUTeX'
    )
    .iterator()
    .next();

  @testSetup
  static void setupMethod() {
    System.runAs(currentUser) {
      Test.startTest();
      List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
      for (Account account : accounts) {
        account.RecordTypeId = ACCT_UNIV_DEP_ID;
        account.Organization_Unit_Level__c = '2';
      }
      insert accounts;

      List<Contact> contacts = TestDataFactory.createTestContactRecords(2);
      contacts[0].Contact_Image__c = 'test';
      insert contacts;

      List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(
        10,
        accounts[0].Id
      );
      insert terms;

      List<Product_Request__c> prodRequest = TestDataFactory.createTestProductRequestRecords(
        1
      );
      insert prodRequest;

      List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(
        10,
        accounts[0].Id,
        prodRequest[0].Id
      );
      insert courses;

      Integer prodCounter = 0;
      List<Product2> products = TestDataFactory.createTestProductRecords(
        10,
        courses
      );
      for (Product2 prod : products) {
        prod.Delivery__c = 'Online Classroom;Online Self-paced;Brisbane Classroom';
        prod.Ready_for_publishing__c = 'No';
        prod.Available_on_Cart__c = false;
        prod.IsActive = true;
        prodCounter++;
        if (prodCounter > 5) {
          prod.Ready_for_publishing__c = 'Yes';
          prod.QA_Review_Completed__c = 'Yes';
          prod.Publishing_Start_date__c = Date.today().AddDays(-1);
        }
      }
      insert products;

      Pricebook2 pricebook = new Pricebook2(
        isActive = true,
        id = Test.getStandardPricebookId()
      );
      update pricebook;

      List<PricebookEntry> priceBookEntryList = new List<PricebookEntry>();
      for (Product2 prodPBEntry : products) {
        PricebookEntry priceBookEntry = new PricebookEntry();
        priceBookEntry.pricebook2id = pricebook.Id;
        priceBookEntry.UnitPrice = 12;
        priceBookEntry.product2Id = prodPBEntry.Id;
        priceBookEntry.isActive = true;
        priceBookEntryList.add(priceBookEntry);
      }
      insert priceBookEntryList;

      List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(
        10,
        courses,
        terms
      );
      for (hed__Course_Offering__c cOffering : courseOfferings) {
        cOffering.Registration_Start_Date__c = system.today() + 2;
        cOffering.IsActive__c = true;
        cOffering.Delivery_Type__c = 'Online Classroom';
      }
      insert courseOfferings;

      List<hed__Course_Enrollment__c> courseConnections = TestDataFactory.createTestCourseConnectionRecord(
        10,
        contacts[0].Id,
        courseOfferings
      );
      Integer cConCounter = 0;
      for (hed__Course_Enrollment__c courseConnection : courseConnections) {
        courseConnection.RecordTypeId = FACULTY_RECTYPEID;
        cConCounter++;
        if (cConCounter > 5) {
          courseConnection.hed__Contact__c = contacts[1].Id;
        }
      }
      insert courseConnections;

      ProductCatalog prodCatalog = new ProductCatalog(Name = 'Study Catalog');
      insert prodCatalog;

      ProductCategory prodCateg = new ProductCategory(
        Name = 'Products',
        CatalogId = prodCatalog.Id
      );
      insert prodCateg;

      CommerceEntitlementPolicy commEntPolicy = new CommerceEntitlementPolicy(
        Name = 'OPE Entitlement'
      );
      insert commEntPolicy;

      Test.stopTest();
    }
  }

  @IsTest
  private static void validateFacilConImageTest() {
    User currUsr = [
      SELECT Id
      FROM User
      WHERE Profile.Name = 'QUTeX' AND Email = 'testuser@mailinator.com'
      LIMIT 1
    ];

    DmlException expectedException;
    System.runAs(currUsr) {
      Test.startTest();
      List<Product2> prod2List = [
        SELECT Id, Ready_for_publishing__c
        FROM Product2
        WHERE CreatedById = :currUsr.Id AND Ready_for_publishing__c = 'No'
      ];
      for (Product2 prod2 : prod2List) {
        prod2.Ready_for_publishing__c = 'Yes';
      }

      try {
        update prod2List;
      } catch (DmlException d) {
        expectedException = d;
      }

      Test.stopTest();
      System.assertNotEquals(
        null,
        expectedException,
        'The record should be validated'
      );
    }
  }

  @IsTest
  private static void includeProductToStoreTest() {
    User currUsr = [
      SELECT Id
      FROM User
      WHERE Profile.Name = 'QUTeX' AND Email = 'testuser@mailinator.com'
      LIMIT 1
    ];

    DmlException expectedException;
    System.runAs(currUsr) {
      Test.startTest();
      List<Product2> prod2List = [
        SELECT Id, Available_on_Cart__c
        FROM Product2
        WHERE
          CreatedById = :currUsr.Id
          AND Ready_for_publishing__c = 'Yes'
          AND QA_Review_Completed__c = 'Yes'
          AND Available_on_Cart__c = FALSE
          AND Publishing_Start_date__c != NULL
      ];
      for (Product2 prod2 : prod2List) {
        prod2.Available_on_Cart__c = true;
      }

      update prod2List;

      Test.stopTest();

      Set<Id> prod2ListIdSet = (new Map<Id, Product2>(prod2List)).keySet();

      Id prodCategoryId = [
        SELECT Id
        FROM ProductCategory
        WHERE Name = 'Products'
        LIMIT 1
      ]
      .Id;

      Id entPolicyId = [
        SELECT Id
        FROM CommerceEntitlementPolicy
        WHERE Name = 'OPE Entitlement'
        LIMIT 1
      ]
      .Id;

      List<ProductCategoryProduct> prodCategProdList = [
        SELECT ProductId
        FROM ProductCategoryProduct
        WHERE
          ProductCategoryId = :prodCategoryId
          AND ProductId IN :prod2ListIdSet
      ];

      List<CommerceEntitlementProduct> prodEntPolicyList = [
        SELECT ProductId
        FROM CommerceEntitlementProduct
        WHERE PolicyId = :entPolicyId AND ProductId IN :prod2ListIdSet
      ];

      System.assert(
        prodCategProdList.size() > 0,
        'ProductCategoryProduct was created'
      );

      System.assert(
        prodEntPolicyList.size() > 0,
        'CommerceEntitlementProduct was created'
      );
    }
  }
}
