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

      List<Product2> products = TestDataFactory.createTestProductRecords(
        10,
        courses
      );
      for (Product2 prod : products) {
        prod.Delivery__c = 'Online Classroom;Online Self-paced;Brisbane Classroom';
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
        WHERE CreatedById = :currUsr.Id
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
}
