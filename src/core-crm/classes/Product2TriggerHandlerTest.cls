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
      | arsenio.jr.dayrit              | June 10, 2022         | DEPP-3021              | Added Method for Published   |
      | eugene.andrew.abuan            | July 31, 2022         | DEPP-3534              | Added Method for Do not Show Start Date |
      | eugene.andrew.abuan            | August 19, 2022       | DEPP-2665              | Added SOA and Tailored in after update  |

 */
@isTest
public with sharing class Product2TriggerHandlerTest {
  private static final String RT_ACTIVITY = System.Label.RT_ProductRequest_Activity;
  private static final Id RT_ACTIVITY_ID =  Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(RT_ACTIVITY).getRecordTypeId();
  private static final string RT_PROGRAM = System.Label.RT_ProductRequest_Program;
  private static final Id RT_PROGRAM_ID =  Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(RT_PROGRAM).getRecordTypeId();
  private static final string C_ACTIVITY = System.Label.RT_ProductRequest_Activity;
  private static final Id C_ACTIVITY_ID = Schema.SObjectType.hed__Course__c.getRecordTypeInfosByDeveloperName().get(C_ACTIVITY).getRecordTypeId();
  private static final string PP_PROGRAM = System.Label.RT_ProgramPlan_Program;
  private static Id opeProgPlanId = Schema.SObjectType.hed__Program_Plan__c.getRecordTypeInfosByDeveloperName().get(PP_PROGRAM).getRecordTypeId();
  private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
  private static Id cceProdSpecId = Schema.SObjectType.Product_Specification__c.getRecordTypeInfosByDeveloperName().get('CCE').getRecordTypeId();
  private static Id opeProdSpecId = Schema.SObjectType.Product_Specification__c.getRecordTypeInfosByDeveloperName().get('OPE').getRecordTypeId();

  private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
    .get(ACCT_UNIV_DEP)
    .getRecordTypeId();

  private static final Id BUSINESS_ACC_RECTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
  .get('Business_Organization')
  .getRecordTypeId();

  public static final Id FACULTY_RECTYPEID = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName()
    .get('Faculty')
    .getRecordTypeId();

    private static final Id STUDENT_RECTYPEID = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName()
    .get('Student')
    .getRecordTypeId();


  @testSetup
  static void setupMethod() {
    Test.startTest();
    TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    Test.stopTest();

    System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
      WebStore testWebStore = new WebStore(Name='CCE', DefaultLanguage='en_US');
      insert testWebStore;

      Integer accCounter = 0;
      List<Account> accounts = TestDataFactory.createTestAccountRecords(2);
      for (Account account : accounts) {
        if(accCounter == 0){
          account.RecordTypeId = ACCT_UNIV_DEP_ID;
          account.Organization_Unit_Level__c = '2';
        }
        if(accCounter == 1){
          account.RecordTypeId = BUSINESS_ACC_RECTYPEID;
        }
        accCounter++;

      }
      insert accounts;

      List<Contact> contacts = TestDataFactory.createTestContactRecords(10);
      contacts[0].Contact_Image__c = 'test';
      insert contacts;

      List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(
        10,
        accounts[0].Id
      );
      insert terms;

      List<Product_Request__c> prodRequest = TestDataFactory.createTestProductRequestRecords(1);
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
          courseConnection.RecordTypeId = STUDENT_RECTYPEID;
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

      ProductCatalog prodCatalogCCE = new ProductCatalog(Name = 'CCE Catalog');
      insert prodCatalogCCE;

      ProductCategory prodCategTTE = new ProductCategory(
        Name = 'Tailored Executive Education',
        CatalogId = prodCatalogCCE.Id
        );
      insert prodCategTTE;
      
    }
  }

  @IsTest
  private static void validateFacilConImageTest() {
    final User PROGRAM_ADMIN = TestDataFactoryUser.selectUserQUTeXProgramAdministrator;
    DmlException expectedException;
    System.runAs(PROGRAM_ADMIN) {
      Test.startTest();
      List<Product2> prod2List = [
        SELECT Id, Ready_for_publishing__c
        FROM Product2
        WHERE CreatedById = :PROGRAM_ADMIN.Id AND Ready_for_publishing__c = 'No'
        AND Course__c != null
      ];
      for (Product2 prod2 : prod2List) {
        prod2.Ready_for_publishing__c = 'Yes';
        prod2.QA_Review_Completed__c = 'Yes';
        prod2.Publishing_Start_date__c = Date.today().AddDays(-1);
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
  private static void decomissonProduct() {
    final User PROGRAM_ADMIN = TestDataFactoryUser.selectUserQUTeXProgramAdministrator;
    System.runAs(PROGRAM_ADMIN) {
      List<Product2> prod2List = [
        SELECT Id, Decommission_Product__c,
        End_Date__c, 
        Publishing_End_date__c, 
        Decommission_Reason__c
        FROM Product2
        WHERE
          CreatedById = :PROGRAM_ADMIN.Id
          AND QA_Review_Completed__c = 'Yes'
      ];
      for (Product2 prod2 : prod2List) {
        prod2.Publishing_End_date__c = Date.Today();
        prod2.Decommission_Product__c = true;
        prod2.Decommission_Reason__c = 'test';
        prod2.End_Date__c = Date.today();
      }
      Test.startTest();
      update prod2List;
      system.assert(![SELECT Id FROM Product2 WHERE IsActive = false And End_Date__c = Today].isEmpty(),'product wasnt deactivated');
      system.assert(![SELECT Id FROM Product_Request__c WHERE Product_Request_Status__c = 'Completed'].isEmpty(),'product request wasnt completed');
      Test.stopTest();

    }

  }

  @IsTest
  private static void includeProductToStoreCCETest() {
    final User PROGRAM_ADMIN = TestDataFactoryUser.selectUserQUTeXProgramAdministrator;
    System.runAs(PROGRAM_ADMIN) {
      Test.startTest();

      List<Account> accBusinessOrg = [SELECT Id 
                                      FROM Account 
                                      WHERE RecordTypeId =: BUSINESS_ACC_RECTYPEID
                                      AND CreatedById = :PROGRAM_ADMIN.Id];

      List<Account> accUniv = [SELECT Id 
                               FROM Account 
                               WHERE RecordTypeId =: ACCT_UNIV_DEP_ID];

      List<Contact> con = [SELECT Id FROM Contact WHERE CreatedById = :PROGRAM_ADMIN.Id];

      List<Opportunity> oppList = TestDataFactory.createClosedWonOpportunities(10,accBusinessOrg[0].Id,con[0].Id);
      insert oppList;

      List<Product_Specification__c> prodSpecList = TestDataFactory.retrieveCCEProductSpecifications();

      List<Product_Request__c> ccePRequest = TestDataFactory.createTestProductRequestRecords(1,prodSpecList[0].Id);
      for(Product_Request__c pr : ccePRequest){
          pr.RecordTypeId = RT_ACTIVITY_ID;        
      }
      insert ccePRequest;

      List<hed__Course__c> cceCourse = TestDataFactory.createTestCourseRecords(10,accUniv[0].Id,ccePRequest[0].Id);
      Integer cceCCounter = 0;
      for(hed__Course__c cceC : cceCourse){
        cceC.Name = 'Test Course ' + String.valueOf(cceCCounter);
        cceCCounter++;
      }
      insert cceCourse;

      Integer cceProdCounter = 0;
      List<Product2> cceProducts = TestDataFactory.createTestProductRecords(
        10,
        cceCourse
      );
      for (Product2 cceProd : cceProducts) {
        cceProd.Delivery__c = 'Online Classroom;Online Self-paced;Brisbane Classroom';
        cceProd.Ready_for_publishing__c = 'No';
        cceProd.Available_on_Cart__c = false;
        cceProd.IsActive = true;
        cceProdCounter++;
        if (cceProdCounter > 5) {
          cceProd.Ready_for_publishing__c = 'Yes';
          cceProd.QA_Review_Completed__c = 'Yes';
          cceProd.Publishing_Start_date__c = Date.today().AddDays(-1);
        }
      }
      insert cceProducts;

      List<Product2> prod2ListCCE = [
        SELECT Id, Available_on_Cart__c,Course__c, Product_Category__c
        FROM Product2
        WHERE
          CreatedById = :PROGRAM_ADMIN.Id
          AND Ready_for_publishing__c = 'No'
          AND Available_on_Cart__c = FALSE
          AND Course__r.ProductRequestId__r.Product_Specification__r.Id =: prodSpecList[0].Id
      ];
      for (Product2 prod2 : prod2ListCCE) {
        prod2.Ready_for_publishing__c = 'Yes';
        prod2.QA_Review_Completed__c = 'Yes';
        prod2.Publishing_Start_date__c = Date.today().AddDays(-1);
        prod2.Available_on_Cart__c = true;
        prod2.Product_Category__c = 'Tailored Executive Program';
      }

      update prod2ListCCE;

      Test.stopTest();

      Set<Id> prod2ListIdSet = (new Map<Id, Product2>(prod2ListCCE)).keySet();

      List<CommerceEntitlementProduct> prodEntPolicyList = [
        SELECT ProductId
        FROM CommerceEntitlementProduct
        WHERE ProductId IN :prod2ListIdSet
      ];

      System.assert(
        !prodEntPolicyList.isEmpty(),
        'CommerceEntitlementProduct was not created'
      );
    }
  }

  @IsTest
  private static void includeProductToStoreOPETest() {
    final User PROGRAM_ADMIN = TestDataFactoryUser.selectUserQUTeXProgramAdministrator;
    System.runAs(PROGRAM_ADMIN) {
      Test.startTest();

      List<Account> accBusinessOrg = [SELECT Id 
                                      FROM Account 
                                      WHERE RecordTypeId =: BUSINESS_ACC_RECTYPEID
                                      AND CreatedById = :PROGRAM_ADMIN.Id];

      List<Account> accUniv = [SELECT Id 
                               FROM Account 
                               WHERE RecordTypeId =: ACCT_UNIV_DEP_ID];

      List<Contact> con = [SELECT Id FROM Contact WHERE CreatedById = :PROGRAM_ADMIN.Id];

      List<Opportunity> oppList = TestDataFactory.createTestOpportunityRecords(10,accBusinessOrg[0].Id,con[0].Id);
      insert oppList;

      List<Product_Specification__c> prodSpecList = TestDataFactory.createTestProductSpecsRecords(10,con,oppList);
      for(Integer i = 0 ; i < prodSpecList.size() ; i++){
        prodSpecList[i].RecordTypeId = opeProdSpecId;
        prodSpecList[i].Stage__c = 'Idea';
      }
      insert prodSpecList;

      List<Product_Request__c> opeRequest = TestDataFactory.createTestProductRequestRecords(1,prodSpecList[0].Id);
      for(Product_Request__c pr : opeRequest){
          pr.RecordTypeId = RT_ACTIVITY_ID;        
      }
      insert opeRequest;

      List<hed__Course__c> opeCourse = TestDataFactory.createTestCourseRecords(10,accUniv[0].Id,opeRequest[0].Id);
      Integer opeCounter = 0;
      for(hed__Course__c opeC : opeCourse){
        opeC.Name = 'Test Course ' + String.valueOf(opeCounter);
        opeCounter++;
      }
      insert opeCourse;

      Integer opeProdCounter = 0;
      List<Product2> opeProducts = TestDataFactory.createTestProductRecords(
        10,
        opeCourse
      );
      for (Product2 opeProd : opeProducts) {
        opeProd.Delivery__c = 'Online Classroom;Online Self-paced;Brisbane Classroom';
        opeProd.Ready_for_publishing__c = 'No';
        opeProd.Available_on_Cart__c = false;
        opeProd.IsActive = true;
        opeProdCounter++;
        if (opeProdCounter > 5) {
          opeProd.Ready_for_publishing__c = 'Yes';
          opeProd.QA_Review_Completed__c = 'Yes';
          opeProd.Publishing_Start_date__c = Date.today().AddDays(-1);
        }
      }
      insert opeProducts;

      List<Product2> prod2ListOPE = [
        SELECT Id, Available_on_Cart__c,Course__c, Product_Category__c
        FROM Product2
        WHERE
          CreatedById = :PROGRAM_ADMIN.Id
          AND Ready_for_publishing__c = 'No'
          AND Available_on_Cart__c = FALSE
          AND Course__r.ProductRequestId__r.Product_Specification__r.Id =: prodSpecList[0].Id
      ];
      for (Product2 prod2 : prod2ListOPE) {
        prod2.Ready_for_publishing__c = 'Yes';
        prod2.QA_Review_Completed__c = 'Yes';
        prod2.Publishing_Start_date__c = Date.today().AddDays(-1);
        prod2.Available_on_Cart__c = true;
      }

      update prod2ListOPE;

      Test.stopTest();

      Set<Id> prod2ListIdSet = (new Map<Id, Product2>(prod2ListOPE)).keySet();

      List<CommerceEntitlementProduct> prodEntPolicyList = [
        SELECT ProductId
        FROM CommerceEntitlementProduct
        WHERE ProductId IN :prod2ListIdSet
      ];

      System.assert(
        !prodEntPolicyList.isEmpty(),
        'CommerceEntitlementProduct was not created'
      );
    }
  }

  @IsTest
  private static void courseReleaseToPublishTest() {
    final User PROGRAM_ADMIN = TestDataFactoryUser.selectUserQUTeXProgramAdministrator;
    System.runAs(PROGRAM_ADMIN) {
      Test.startTest();

      List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
      for(Account acc : accounts){
        acc.RecordTypeId = ACCT_UNIV_DEP_ID;
        acc.Organization_Unit_Level__c = '2';
      }
      insert accounts;

      List<Product_Request__c> productRequests = TestDataFactory.createTestProductRequestRecords(1);
      for(Product_Request__c productRequest : productRequests){
        productRequest.RecordTypeId = RT_ACTIVITY_ID;
        productRequest.Product_Request_Status__c = 'Release';
      }
      insert productRequests;

      List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(1, accounts[0].Id, productRequests[0].Id);
      courses[0].RecordTypeId = C_ACTIVITY_ID;
      insert courses;

      List<Product2> prod2List = [
        SELECT Id, Available_on_Cart__c
        FROM Product2
        WHERE
          CreatedById = :PROGRAM_ADMIN.Id
          AND Ready_for_publishing__c = 'Yes'
          AND QA_Review_Completed__c = 'Yes'
          AND Available_on_Cart__c = FALSE
          AND Publishing_Start_date__c != NULL
      ];
      for (Product2 prod2 : prod2List) {
        prod2.Publishing_Start_date__c  = Date.today();
        prod2.Course__c = courses[0].id;
      }
      update prod2List;

      Test.stopTest();

     System.assert(![SELECT Id FROM Product_Request__c WHERE Product_Request_Status__c = 'Published'].isEmpty(), 'no product rquest published');
    }
  }

  @IsTest
  private static void programReleaseToPublishTest() {
    final User PROGRAM_ADMIN = TestDataFactoryUser.selectUserQUTeXProgramAdministrator;
    System.runAs(PROGRAM_ADMIN) {
      Test.startTest();

      List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
      for(Account acc : accounts){
        acc.RecordTypeId = ACCT_UNIV_DEP_ID;
        acc.Organization_Unit_Level__c = '2';
      }
      insert accounts;

      List<Product_Request__c> productRequests = TestDataFactory.createTestProductRequestRecords(1);
      for(Product_Request__c productRequest : productRequests){
        productRequest.RecordTypeId = RT_PROGRAM_ID;
        productRequest.Product_Request_Status__c = 'Release';
      }
      insert productRequests;

      List<hed__Program_Plan__c> programs = TestDataFactory.createTestProgramPlanRecords(1);
      programs[0].RecordTypeId = opeProgPlanId;
      programs[0].Product_Request__c = productRequests[0].id;
      insert programs;



      List<Product2> prod2List = [
        SELECT Id, Available_on_Cart__c
        FROM Product2
        WHERE
          CreatedById = :PROGRAM_ADMIN.Id
          AND Ready_for_publishing__c = 'Yes'
          AND QA_Review_Completed__c = 'Yes'
          AND Available_on_Cart__c = FALSE
          AND Publishing_Start_date__c != NULL
      ];
      for (Product2 prod2 : prod2List) {
        prod2.Publishing_Start_date__c = Date.today();
        prod2.Program_Plan__c = programs[0].id;
      }
      update prod2List;

      Test.stopTest();

      System.assert(![SELECT Id FROM Product_Request__c WHERE Product_Request_Status__c = 'Published'].isEmpty(), 'no product rquest published');
    }
  }

  @IsTest
  private static void validateDoNotShowStartDateTest() {
    System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
      Test.startTest();

      List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
      for(Account acc : accounts){
        acc.RecordTypeId = ACCT_UNIV_DEP_ID;
        acc.Organization_Unit_Level__c = '2';
      }
      insert accounts;

      List<Product_Request__c> productRequests = TestDataFactory.createTestProductRequestRecords(1);
      for(Product_Request__c productRequest : productRequests){
        productRequest.RecordTypeId = RT_PROGRAM_ID;
        productRequest.Product_Request_Status__c = 'Release';
      }
      insert productRequests;

      List<hed__Program_Plan__c> programs = TestDataFactory.createTestProgramPlanRecords(1);
      programs[0].RecordTypeId = opeProgPlanId;
      programs[0].Product_Request__c = productRequests[0].id;
      insert programs;

      Program_Offering__c programOffering = new Program_Offering__c(
        Name = 'Program Offering_Test 1',
        hed_Program_Plan__c = programs[0].Id,
        Delivery_Type__c = 'Online Self-paced',
        hed_Capacity__c = 30,
        Start_Date__c = system.today() + 1,
        Registration_Start_Date__c = system.today() - 1,
        IsActive__c = true
      );
      insert programOffering;

      List<Product2> prod2List = [
        SELECT Id, Available_on_Cart__c
        FROM Product2
        WHERE
           Ready_for_publishing__c = 'Yes'
          AND QA_Review_Completed__c = 'Yes'
          AND Available_on_Cart__c = FALSE
          AND Publishing_Start_date__c != NULL
      ];
      for (Product2 prod2 : prod2List) {
        prod2.Available_on_Cart__c = true;
        prod2.Delivery__c = 'Online Self-paced';
        prod2.Do_not_Show_Start_Date__c = true;
        prod2.Program_Plan__c = programs[0].id;
      }
      update prod2List;

      Test.stopTest();

      System.assert(![SELECT Id FROM Product2 WHERE Id IN: prod2List AND Do_not_Show_Start_Date__c = true].isEmpty(),'updating do not who start date to true failed');
     }
  }
}