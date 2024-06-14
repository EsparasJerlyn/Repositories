/**
 * @description BuyerGroupTriggerHandler Test Class
 * @see BuyerGroupTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------|
      | roy.nino.s.regala              | August 08, 2022       | DEPP-2498              | Created file                               |
      | alexander.cadalin   	         | August 18, 2022       | ST Fix                 | Changed BuyerGroup Name                    |
      | eccarius.karl.munoz  	         | November 17, 2022     | DEPP-4014              | Added validateExistingPublishedBuyerGrp    |
 */
@isTest
public with sharing class BuyerGroupTriggerHelperTest {
  private static final Id SOA_ID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get('Standing_Offer_Arrangement').getRecordTypeId();
  private static final Id ACTIVITY_ID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get('Activity').getRecordTypeId();
  private static final Id ACTIVITY_COURSE_ID = Schema.SObjectType.hed__Course__c.getRecordTypeInfosByDeveloperName().get('Activity').getRecordTypeId();
  private static final Id BUSINESS_ACC_RECTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Organization').getRecordTypeId();
  private static final Id CCE_PROD_SPEC_ID = Schema.SObjectType.Product_Specification__c.getRecordTypeInfosByDeveloperName().get('CCE').getRecordTypeId();
  private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
  private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
    .get(ACCT_UNIV_DEP)
    .getRecordTypeId();
  private static final Id PROGRAM_ID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get('Program').getRecordTypeId();
 
  @testSetup 
  static void setupMethod() {
      Test.startTest();
      TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
      Test.stopTest();

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

      List<Account> accountList = setupBusinessAccounts();
      insert accountList;

      List<Account> accounts = setupUnivDeptAccounts();
      insert accounts;

      List<Contact> conList;
      conList = TestDataFactory.createTestContactRecords(1);
      insert conList;

      List<Opportunity> oppList = TestDataFactory.createClosedWonOpportunities(1, accounts[0].Id, conList.iterator().next()?.Id);
      insert oppList;
      
      List<Product_Specification__c> prodSpecList = TestDataFactory.retrieveCCEProductSpecifications();
      
      List<Product_Request__c> soaRequest = setupSOARequest(prodSpecList);      
      insert soaRequest;
      
      List<BuyerGroup> bgToInsertList = setupBuyerGroup(soaRequest);
      insert bgToInsertList;

      List<Product_Request__c> courseRequest = setupCourseRequest(prodSpecList);
      insert courseRequest;
      
      List<hed__Course__c> courses = setupCourses(courseRequest, accounts);
      insert courses;
      
      List<Product_Request__c> programRequest = setupProgramRequest(prodSpecList);
      insert programRequest;

      
      List<hed__Program_Plan__c> programPlanList = setupProgramPlanList(programRequest);
      insert programPlanList;
      
      List<Related_Product_Request__c> relatedPRInsert = setupRelatedPR(soaRequest, programRequest);      
      insert relatedPRInsert;
      
      List<Associated_Products__c> assocProdList = setupAssocProductList(courses, soaRequest);     
      insert assocProdList;

  }

  @isTest
  private static void buyerGroupValidationErrorTest() {
    
    System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
      List<BuyerGroup> bgList = new List<BuyerGroup>([
        SELECT Id, Ready_for_publishing__c
        FROM BuyerGroup
      ]);
  
      for(BuyerGroup bg: bgList){
        bg.Ready_for_publishing__c = 'Yes';
        bg.Publishing_End_Date__c = Date.Today() + 5;
        bg.Publishing_Start_Date__c = Date.Today();
      }

      Test.startTest();
      try{
        update bgList;
      }catch(Exception e){
        System.assert(e != null, 'No error occured');
      }
      Test.stopTest();
    }
  }

  @isTest
  private static void buyerGroupValidationSuccessTest() {
    
    System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
      List<BuyerGroup> bgList = new List<BuyerGroup>([
        SELECT Id, Ready_for_publishing__c
        FROM BuyerGroup
      ]);

      List<Product2> productList = new List<Product2>([
        SELECT Id, Ready_for_publishing__c,
        Publishing_Start_Date__c, QA_Comments__c,
        QA_Review_Completed__c
        FROM Product2
      ]);

      for(Product2 prod: productList){
        prod.Ready_for_publishing__c = 'Yes';
        prod.Publishing_Start_Date__c = Date.Today();
        prod.Publishing_End_Date__c = null;
        prod.QA_Review_Completed__c = 'Yes';
        prod.QA_Comments__c = 'comments';
        prod.Available_On_Cart__c = true;
        prod.IsActive = true;
      }

      update productList;
      for(BuyerGroup bg: bgList){
        bg.Ready_for_publishing__c = 'Yes';
        bg.Publishing_End_Date__c = Date.Today() + 5;
        bg.Publishing_Start_Date__c = Date.Today();
      }

      Test.startTest();
      update bgList;
      Test.stopTest();

      System.assert(![SELECT Id FROM BuyerGroup WHERE Ready_for_Publishing__c = 'Yes'].isEmpty(),'buyergroup not published');
    }
  }

  @isTest
  private static void decomissionTest() {
    
    System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
      List<BuyerGroup> bgList = new List<BuyerGroup>([
        SELECT Id, Ready_for_publishing__c
        FROM BuyerGroup
      ]);

      List<Product2> productList = new List<Product2>([
        SELECT Id, Ready_for_publishing__c,
        Publishing_Start_Date__c, QA_Comments__c,
        QA_Review_Completed__c
        FROM Product2
      ]);

      for(Product2 prod: productList){
        prod.Ready_for_publishing__c = 'Yes';
        prod.Publishing_Start_Date__c = Date.Today();
        prod.Publishing_End_Date__c = null;
        prod.QA_Review_Completed__c = 'Yes';
        prod.QA_Comments__c = 'comments';
        prod.IsActive = true;
        prod.Available_On_Cart__c = true;
      }

      update productList;

      Test.startTest();
      for(BuyerGroup bg: bgList){
        bg.Ready_for_publishing__c = 'Yes';
        bg.Publishing_End_Date__c = Date.Today() + 5;
        bg.Publishing_Start_Date__c = Date.Today();
      }
      update bgList;

      for(BuyerGroup bg: bgList){
        bg.Decommission__c = true;
        bg.Decommission_Reason__c = 'reason';
        bg.End_Date__c = Date.Today();
      }
      update bgList;
      Test.stopTest();
        
      System.assert(![SELECT Id FROM BuyerGroup WHERE Decommission__c = true].isEmpty(),'buyergroup not decommissioned');
    }
  }

  @isTest
  private static void validateExistingPublishedBuyerGrpTest() {
    System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
      List<BuyerGroup> buyerGroupList = [SELECT Id, Ready_for_publishing__c, Product_Request__c, Primary_Account__c FROM BuyerGroup WHERE Product_Request__c != null LIMIT 1];
      buyerGroupList[0].Ready_for_publishing__c = 'Yes';

      List<Product_Request__c> prodReqs = [SELECT Id FROM Product_Request__c WHERE Id =: buyerGroupList[0].Product_Request__c LIMIT 1];
      for(Product_Request__c p : prodReqs){
          p.Product_Request_Status__c = 'Published';
      }
      update prodReqs;
      
      List<BuyerGroup> publishedBuyerGrps = new List<BuyerGroup>();
      for(BuyerGroup bg : buyerGroupList){
        publishedBuyerGrps.add(
              new BuyerGroup(
                  Name = 'Published Asset', 
                  Primary_Account__c = bg.Primary_Account__c, 
                  Ready_for_Publishing__c = 'Yes', 
                  Product_Request__c = prodReqs[0].Id
              )
          );
      }
      insert publishedBuyerGrps;

      Test.startTest();
      Database.SaveResult[] sr = Database.update(buyerGroupList, false);
      Test.stopTest();
      
      System.assert(!sr[0].isSuccess(), 'There should not be more than 1 active Standing offer Arrangement per Product Specification.');
    }
  }

  //----Setup methods for creation of records needed----//
  private static List<Account> setupBusinessAccounts(){
    List<Account> accountList = TestDataFactory.createTestAccountRecords(2);
    for(Account acc: accountList){
        acc.RecordTypeId = BUSINESS_ACC_RECTYPEID;
    }
    return accountList;
  }

  private static List<Account> setupUnivDeptAccounts(){
    List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
    for(Account acc : accounts){
        acc.RecordTypeId = ACCT_UNIV_DEP_ID;
        acc.Organization_Unit_Level__c = '2';
    }
    return accounts;
  }
  
  private static List<Product_Specification__c> setupProductSpec(List<Contact> conList, List<Opportunity> oppList){
    List<Product_Specification__c> prodSpecList = TestDataFactory.createTestProductSpecsRecords(1, conList, oppList);
    for(Integer i = 0 ; i < prodSpecList.size() ; i++){
        prodSpecList[i].RecordTypeId = CCE_PROD_SPEC_ID;
    }
    return prodSpecList;
  }

  private static List<Product_Request__c> setupSOARequest(List<Product_Specification__c> prodSpecList){
    List<Product_Request__c> soaRequest = TestDataFactory.createTestProductRequestRecords(100, prodSpecList[0].Id);
    for(Product_Request__c pr : soaRequest){
        pr.RecordTypeId = SOA_ID;        
    }
    return soaRequest;
  }

  private static List<BuyerGroup> setupBuyerGroup(List<Product_Request__c> soaRequest){
    List<BuyerGroup> bgToInsertList = new List<BuyerGroup>();
    for(Integer i = 0; i < soaRequest.size(); i++){
      bgToInsertList.add(new BuyerGroup(
        Name = soaRequest[i].Product_Request_Name__c, 
        Product_Request__c = soaRequest[i].Id
      ));
    }
    return bgToInsertList;
  }

  private static List<Product_Request__c> setupCourseRequest(List<Product_Specification__c> prodSpecList){
    List<Product_Request__c> courseRequest = TestDataFactory.createTestProductRequestRecords(100, prodSpecList[0].Id);
    for(Product_Request__c pr : courseRequest){
        pr.RecordTypeId = ACTIVITY_ID;        
    }
    return courseRequest;
  }

  private static List<hed__Course__c> setupCourses(List<Product_Request__c> courseRequest, List<Account> accounts){
    List<hed__Course__c> courses = new List<hed__Course__c>();
    for(Product_Request__c prC: courseRequest){
      courses.addAll(TestDataFactory.createTestCourseRecords(1,accounts[0].Id,prC.Id));
    }

    for(hed__Course__c c: courses){
      c.RecordTypeId = ACTIVITY_COURSE_ID;
    }

    return courses;
  }

  private static List<Product_Request__c> setupProgramRequest(List<Product_Specification__c> prodSpecList){
    List<Product_Request__c> programRequest = TestDataFactory.createTestProductRequestRecords(100,prodSpecList[0].Id);
    for(Product_Request__c progamR:programRequest){
      progamR.RecordTypeId = PROGRAM_ID;
    }
    return programRequest;
  }

  private static List<hed__Program_Plan__c> setupProgramPlanList(List<Product_Request__c> programRequest){
    List<hed__Program_Plan__c> programPlanList = TestDataFactory.createTestProgramPlanRecords(100);
    for(Integer i = 0; i < programRequest.size(); i++){
      programPlanList[i].Product_Request__c = programRequest[i].Id;
    }
    return programPlanList;
  }

  private static List<Related_Product_Request__c> setupRelatedPR(List<Product_Request__c> soaRequest, List<Product_Request__c> programRequest){
    List<Related_Product_Request__c> relatedPRInsert = new List<Related_Product_Request__c>();
    for(Integer i = 0; i < soaRequest.size(); i ++){
      relatedPRInsert.add(new Related_Product_Request__c(Program__c = soaRequest[i].Id, Course__c = programRequest[i].Id));
    }
    return relatedPRInsert;
  }

  private static List<Associated_Products__c> setupAssocProductList(List<hed__Course__c> courses, List<Product_Request__c> soaRequest){
    List<Associated_Products__c> assocProdList = new List<Associated_Products__c>();
    List<Product2> prodList = new List<Product2>([SELECT Id From Product2 WHERE Course__c IN: courses]);
    for(Integer i = 0; i < prodList.size(); i ++){
      assocProdList.add(new Associated_Products__c(Product__c = prodList[i].Id, Product_Request__c = soaRequest[i].Id, IsActive__c = true));
    }
    return assocProdList;
  }
}