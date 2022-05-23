/** 
 * @description Test class for ProductCtrl
 * @see ../classes ProductCtrl
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                             |
      |---------------------------|-----------------------|----------------------|--------------------------------------------|
      | eugene.andrew.abuan       | May 02, 2022          | DEPP-1269            | Created File                               |
      | eugene.andrew.abuan       | May 20, 2022          | DEPP-1979            | Added methods for filters                  |

      
 */
@isTest(SeeAllData=false)
public with sharing class ProductCtrlTest {
  private static final string STUDENT_RT = System.Label.RT_CourseConnection_Student;
  private static final String RT_PRODUCT_REQ = System.Label.RT_ProductRequest_Activity;
  private static final Id OPE_ACTIVITY_RECQ = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(RT_PRODUCT_REQ).getRecordTypeId();
  private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
  private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();
  public static final Id FACULTY_RECTYPEID = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get('Faculty').getRecordTypeId();
  private static User currentUser = TestDataFactory.createUserRecords(1,'QUTeX').iterator().next();
  private static string prPROGRAM = System.Label.RT_ProductRequest_Program;
  private static Id opeProgProdReqId = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(prPROGRAM).getRecordTypeId();
  
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

      List<Contact> contacts = TestDataFactory.createTestContactRecords(1);
      insert contacts;

      List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(10,accounts[0].Id);
      insert terms;

      List<Product_Request__c> prodRequest = TestDataFactory.createTestProductRequestRecords(1);
      prodRequest[0].RecordTypeId = OPE_ACTIVITY_RECQ;
      insert prodRequest;

      List<Product_Request__c> prodRequestPrescribedProgram = TestDataFactory.createTestProductRequestRecords(1);
      prodRequestPrescribedProgram[0].RecordTypeId = opeProgProdReqId;
      prodRequestPrescribedProgram[0].OPE_Program_Plan_Type__c = 'Prescribed Program';
      insert prodRequestPrescribedProgram;

      List<hed__Program_Plan__c> programPlans = TestDataFactory.createTestProgramPlanRecords(1);
      programPlans[0].Product_Request__c = prodRequestPrescribedProgram[0].Id;
      insert programPlans;

      Program_Offering__c programOffering = new Program_Offering__c(
        Name = 'Program Offering_Test 1',
        hed_Program_Plan__c = programPlans[0].Id,
        Delivery_Type__c = 'Online Classroom',
        hed_Capacity__c = 30,
        Start_Date__c = system.today() + 1,
        Registration_Start_Date__c = system.today() + 1,
        IsActive__c = true
       );
      insert programOffering;

      List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(10,accounts[0].Id,prodRequest[0].Id);
      insert courses;

      List<Product2> singleProducts = TestDataFactory.createTestProductRecords(10,courses);
      for (Product2 sProd : singleProducts) {
        sProd.Delivery__c = 'Online Classroom;Online Self-paced;Brisbane Classroom';
        sProd.Study_Area__c	= 'Engineering';
        sProd.Product_Type__c = 'Short Course';
        sProd.Available_on_Cart__c = TRUE;
      }
      insert singleProducts;

      List<Product2> prodProgProducts = TestDataFactory.createTestProductRecords(50);
      for (Product2 presProd : prodProgProducts) {
        presProd.Delivery__c = 'Online Classroom;Online Self-paced;Brisbane Classroom';
        presProd.Study_Area__c	= 'Engineering';
        presProd.Product_Type__c = 'Short Course';
        presProd.Program_Plan__c = programPlans[0].Id;
        presProd.Available_on_Cart__c = TRUE;
      }
      insert prodProgProducts;

      Pricebook2 pricebook = new Pricebook2(
        isActive = true,
        id = Test.getStandardPricebookId()
      );
      update pricebook;

      List<PricebookEntry> priceBookEntryList = new List<PricebookEntry>();
      for (Product2 singleProdPBEntry : singleProducts) {
        PricebookEntry priceBookEntry = new PricebookEntry();
        priceBookEntry.pricebook2id = pricebook.Id;
        priceBookEntry.UnitPrice = 12;
        priceBookEntry.product2Id = singleProdPBEntry.Id;
        priceBookEntry.isActive = true;
        priceBookEntryList.add(priceBookEntry);
      }

      for (Product2 presProgProdPBEntry : prodProgProducts) {
        PricebookEntry priceBookEntry = new PricebookEntry();
        priceBookEntry.pricebook2id = pricebook.Id;
        priceBookEntry.UnitPrice = 12;
        priceBookEntry.product2Id = presProgProdPBEntry.Id;
        priceBookEntry.isActive = true;
        priceBookEntryList.add(priceBookEntry);
      }
      insert priceBookEntryList;

      List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(10,courses,terms);
      for (hed__Course_Offering__c cOffering : courseOfferings) {
        cOffering.Registration_Start_Date__c = system.today() + 2;
        cOffering.IsActive__c = true;
        cOffering.Delivery_Type__c = 'Online Classroom';
      }
      insert courseOfferings;

      List<hed__Course_Enrollment__c> courseConnections = TestDataFactory.createTestCourseConnectionRecord(10,contacts[0].Id,courseOfferings);
      for (hed__Course_Enrollment__c courseConnection : courseConnections) {
        courseConnection.RecordTypeId = FACULTY_RECTYPEID;
      }
      insert courseConnections;

      ProductCatalog prodCatalog = new ProductCatalog(Name = 'Study Catalog');
      insert prodCatalog;
      ProductCategory prodCateg = new ProductCategory(Name = 'Products',CatalogId = prodCatalog.Id);
      insert prodCateg;
      CommerceEntitlementPolicy commEntPolicy = new CommerceEntitlementPolicy(Name = 'OPE Entitlement');
      insert commEntPolicy;

      Test.stopTest();
    }
  }
    
    @isTest
    static void getProductsTest() {
      User currUsr = [ SELECT Id FROM User
        WHERE Profile.Name = 'QUTeX' AND Email = 'testuser@mailinator.com'
        LIMIT 1
      ];
  
      System.runAs(currUsr) {
		    List<Product2> p = new List<Product2>();
        p=[SELECT Id, Delivery__c FROM Product2];
        List<String> productId = new List<String>();
        for( Product2 product : p){
            productId.add(product.Id);
        }

        Test.startTest();
        ProductCtrl.ProductData getProd =  new ProductCtrl.ProductData();
        getProd = ProductCtrl.getProducts(productId);
        Test.stopTest();
  
        System.assert( getProd != null,'Successfully retrieved Products');
      }
    }

    @isTest
    static void getFilterSearchKeyTest(){
      User currUsr = [ SELECT Id FROM User
      WHERE Profile.Name = 'QUTeX' AND Email = 'testuser@mailinator.com'
      LIMIT 1
    ];

    System.runAs(currUsr) {
      List<Product2> p = new List<Product2>();
      p=[SELECT Id, Delivery__c FROM Product2];
      List<String> productId = new List<String>();
      for( Product2 product : p){
          productId.add(product.Id);
      }

      Test.startTest();
      ProductCtrl.FilterWrapper var = new ProductCtrl.FilterWrapper();
      var.searchKey = 'Test';
      var.studyArea = new List<String>();
      var.deliveryType = new List<String>();
      var.productType = new List<String>();
      var.minUnitPrice = 0;
      var.maxUnitPrice = 5000;
      ProductCtrl.FilterData getFilterProd = ProductCtrl.getFilteredProducts(productId , var);
      Test.stopTest();

      System.assert( getFilterProd != null,'No Products were found with Search key as filter');
    }
  }


    @isTest
    static void getFilterStudyAreaTest(){
      User currUsr = [ SELECT Id FROM User
      WHERE Profile.Name = 'QUTeX' AND Email = 'testuser@mailinator.com'
      LIMIT 1
    ];

    System.runAs(currUsr) {
      List<Product2> p = new List<Product2>();
      p=[SELECT Id, Delivery__c FROM Product2];
      List<String> productId = new List<String>();
      for( Product2 product : p){
          productId.add(product.Id);
      }

      Test.startTest();
      ProductCtrl.FilterWrapper var = new ProductCtrl.FilterWrapper();
      var.searchKey = '';
      var.studyArea = new List<String>{'Engineering'};
      var.deliveryType = new List<String>();
      var.productType = new List<String>();
      ProductCtrl.FilterData getFilterProd = ProductCtrl.getFilteredProducts(productId , var);
      Test.stopTest();

      System.assert( getFilterProd != null,'No Products were found with Study Area as filter');
    }
  }

      @isTest
    static void getFilterDeliveryTest(){
      User currUsr = [ SELECT Id FROM User
      WHERE Profile.Name = 'QUTeX' AND Email = 'testuser@mailinator.com'
      LIMIT 1
    ];

    System.runAs(currUsr) {
      List<Product2> p = new List<Product2>();
      p=[SELECT Id, Delivery__c FROM Product2];
      List<String> productId = new List<String>();
      for( Product2 product : p){
          productId.add(product.Id);
      }

      Test.startTest();
      ProductCtrl.FilterWrapper var = new ProductCtrl.FilterWrapper();
      var.searchKey = '';
      var.studyArea = new List<String>();
      var.deliveryType = new List<String>{'Online Classroom'};
      var.productType = new List<String>();

      ProductCtrl.FilterData getFilterProd = ProductCtrl.getFilteredProducts(productId , var);
      Test.stopTest();

      System.assert( getFilterProd != null,'No Products were found with Delivery Type as filter');
    }
  }

    @isTest
    static void getFilterProductTypeTest(){
      User currUsr = [ SELECT Id FROM User
      WHERE Profile.Name = 'QUTeX' AND Email = 'testuser@mailinator.com'
      LIMIT 1
    ];

    System.runAs(currUsr) {
      List<Product2> p = new List<Product2>();
      p=[SELECT Id, Delivery__c FROM Product2];
      List<String> productId = new List<String>();
      for( Product2 product : p){
          productId.add(product.Id);
      }

      Test.startTest();
      ProductCtrl.FilterWrapper var = new ProductCtrl.FilterWrapper();
      var.searchKey = '';
      var.studyArea = new List<String>();
      var.deliveryType = new List<String>();
      var.productType = new List<String>{'Short Course'};

      ProductCtrl.FilterData getFilterProd = ProductCtrl.getFilteredProducts(productId , var);
      Test.stopTest();

      System.assert( getFilterProd != null,'No Products were found with Short Course as filter');
    }
  }

   @isTest
    static void getFilterDateTest(){
      User currUsr = [ SELECT Id FROM User
      WHERE Profile.Name = 'QUTeX' AND Email = 'testuser@mailinator.com'
      LIMIT 1
    ];

    System.runAs(currUsr) {
      List<Product2> p = new List<Product2>();
      p=[SELECT Id, Delivery__c FROM Product2];
      List<String> productId = new List<String>();
      for( Product2 product : p){
          productId.add(product.Id);
      }

      Test.startTest();
      ProductCtrl.FilterWrapper var = new ProductCtrl.FilterWrapper();
      Date dToday = Date.today();
      Date dTodayMinus3 = dToday -3;
      Date dTodayPlus10 = dToday + 10;
      var.searchKey = '';
      var.studyArea = new List<String>();
      var.deliveryType = new List<String>();
      var.productType = new List<String>();
      var.minUnitPrice = 3;
      var.startDate = dTodayMinus3.day() + '/' + dToday.month() + '/'+ dToday.year() ;
      var.endDate =  dTodayPlus10.day() + '/' + dToday.month() + '/' + dToday.year();

      ProductCtrl.FilterData getFilterProd = ProductCtrl.getFilteredProducts(productId , var);

      Test.stopTest();

      System.assert( getFilterProd != null,'No Products were found with Date as Filter');
    }
  }

    @isTest
    static void getFilterPriceDateComboTest(){
      User currUsr = [ SELECT Id FROM User
      WHERE Profile.Name = 'QUTeX' AND Email = 'testuser@mailinator.com'
      LIMIT 1
    ];

    System.runAs(currUsr) {
      List<Product2> p = new List<Product2>();
      p=[SELECT Id, Delivery__c FROM Product2];
      List<String> productId = new List<String>();
      for( Product2 product : p){
          productId.add(product.Id);
      }

      Test.startTest();
      ProductCtrl.FilterWrapper var = new ProductCtrl.FilterWrapper();
      Date dToday = Date.today();
      Date dTodayMinus3 = dToday -3;
      Date dTodayPlus10 = dToday + 10;
      var.searchKey = '';
      var.studyArea = new List<String>();
      var.deliveryType = new List<String>();
      var.productType = new List<String>();
      var.minUnitPrice = 3;
      var.maxUnitPrice = 15;
      var.startDate = dTodayMinus3.day() + '/' + dToday.month() + '/'+ dToday.year() ;
      var.endDate =  dTodayPlus10.day() + '/' + dToday.month() + '/' + dToday.year();

      ProductCtrl.FilterData getFilterProd = ProductCtrl.getFilteredProducts(productId , var);

      Test.stopTest();

      System.assert( getFilterProd != null,'No Products were found with Date and Price as filter');
    }
  }
}