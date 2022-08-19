/**
 * @description Test Class for RegistrationMatchingHelper
 * @see ..RegistrationMatchingHelper
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | roy.nino.s.regala         | August 15, 2022       | DEPP-3568            | Created file                 |
 */
@isTest
public with sharing class RegistrationMatchingHelperTest {
  public static final Id PERSON = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
    .get('Person')
    .getRecordTypeId();

  @testSetup
  public static void setupMethod() {
    Test.startTest();
    TestDataFactory.generateTestUsers();
    Test.stopTest();
    List<Contact> conList = new List<Contact>();
    conList.add(
        new Contact(
            FirstName = 'FirstName Test',
            LastName = 'LastName Test',
            Email = 'personalEmail@email.com',
            Birthdate = Date.Today(),
            Registered_Email__c = 'personalEmail@email.com',
            QUT_Learner_Email__c = 'learnerEmail@email.com',
            QUT_Staff_Email__c = 'staffEmail@email.com',
            Work_Email__c = 'workEmail@email.com',
            hed__Preferred_Email__c = 'Alternate Email',
            hed__AlternateEmail__c = 'personalEmail@email.com',
            RecordTypeId = PERSON
        )
    );

    insert conList;

  }

  @isTest
  static void registerUserNoMatchTest() {
    final User PORTAL_SYS_ADMIN = TestDataFactory.getPortalSysAdminUser();
    
    List<RegistrationMatchingHelper.ContactMatchingResponse> responseList = new List<RegistrationMatchingHelper.ContactMatchingResponse>();
    List<Contact> contactToValidateList = new List<Contact>();
    Contact contactToValidate = new Contact(
        FirstName = 'Mistmatch',
        LastName = 'Mistmatch',
        Registered_Email__c = 'misMatch@email.com',
        Birthdate = Date.Today() 
    );
    contactToValidateList.add(contactToValidate);
    String contactString = JSON.serialize(contactToValidateList);
    Test.startTest();
    System.runAs(PORTAL_SYS_ADMIN){
        responseList = RegistrationMatchingHelper.validateContactMatching(contactString);
        system.assert(!responseList[0].isPartialMatch, 'is partial match');
        system.assert(!responseList[0].isEmailMatch, 'email match');
    }
    Test.stopTest();
  }

  @isTest
  static void registerUserOnlyEmail() {
    final User PORTAL_SYS_ADMIN = TestDataFactory.getPortalSysAdminUser();
    
    List<RegistrationMatchingHelper.ContactMatchingResponse> responseList = new List<RegistrationMatchingHelper.ContactMatchingResponse>();
    List<Contact> contactToValidateList = new List<Contact>();
    Contact contactToValidate = new Contact(
        FirstName = 'Mistmatch',
        LastName = 'Mistmatch',
        Registered_Email__c = 'personalEmail@email.com',
        Birthdate = Date.Today() - 1
    );
    contactToValidateList.add(contactToValidate);
    String contactString = JSON.serialize(contactToValidateList);
    Test.startTest();
    System.runAs(PORTAL_SYS_ADMIN){
        responseList = RegistrationMatchingHelper.validateContactMatching(contactString);
        system.assert(responseList[0].isPartialMatch, 'is not partial match');
        system.assert(responseList[0].isEmailMatch, 'email did not match');
    }
    Test.stopTest();
  }

  @isTest
  static void registerUserOnlyLearnerEmail() {
    final User PORTAL_SYS_ADMIN = TestDataFactory.getPortalSysAdminUser();
    
    List<RegistrationMatchingHelper.ContactMatchingResponse> responseList = new List<RegistrationMatchingHelper.ContactMatchingResponse>();
    List<Contact> contactToValidateList = new List<Contact>();
    Contact contactToValidate = new Contact(
        FirstName = 'Mistmatch',
        LastName = 'Mistmatch',
        Registered_Email__c = 'learnerEmail@email.com',
        Birthdate = Date.Today() - 1
    );
    contactToValidateList.add(contactToValidate);
    String contactString = JSON.serialize(contactToValidateList);
    Test.startTest();
    System.runAs(PORTAL_SYS_ADMIN){
        responseList = RegistrationMatchingHelper.validateContactMatching(contactString);
        system.assert(responseList[0].isPartialMatch, 'is not partial match');
        system.assert(responseList[0].isEmailMatch, 'email did not match');
    }
    Test.stopTest();
  }

  @isTest
  static void registerUserOnlyStaffEmail() {
    final User PORTAL_SYS_ADMIN = TestDataFactory.getPortalSysAdminUser();
    
    List<RegistrationMatchingHelper.ContactMatchingResponse> responseList = new List<RegistrationMatchingHelper.ContactMatchingResponse>();
    List<Contact> contactToValidateList = new List<Contact>();
    Contact contactToValidate = new Contact(
        FirstName = 'Mistmatch',
        LastName = 'Mistmatch',
        Registered_Email__c = 'staffEmail@email.com',
        Birthdate = Date.Today() - 1
    );
    contactToValidateList.add(contactToValidate);
    String contactString = JSON.serialize(contactToValidateList);
    Test.startTest();
    System.runAs(PORTAL_SYS_ADMIN){
        responseList = RegistrationMatchingHelper.validateContactMatching(contactString);
        system.assert(responseList[0].isPartialMatch, 'is not partial match');
        system.assert(responseList[0].isEmailMatch, 'email did not match');
    }
    Test.stopTest();
  }

  @isTest
  static void registerUserOnlyWorkEmail() {
    final User PORTAL_SYS_ADMIN = TestDataFactory.getPortalSysAdminUser();
    
    List<RegistrationMatchingHelper.ContactMatchingResponse> responseList = new List<RegistrationMatchingHelper.ContactMatchingResponse>();
    List<Contact> contactToValidateList = new List<Contact>();
    Contact contactToValidate = new Contact(
        FirstName = 'Mistmatch',
        LastName = 'Mistmatch',
        Registered_Email__c = 'workEmail@email.com',
        Birthdate = Date.Today() - 1
    );
    contactToValidateList.add(contactToValidate);
    String contactString = JSON.serialize(contactToValidateList);
    Test.startTest();
    System.runAs(PORTAL_SYS_ADMIN){
        responseList = RegistrationMatchingHelper.validateContactMatching(contactString);
        system.assert(responseList[0].isPartialMatch, 'is not partial match');
        system.assert(responseList[0].isEmailMatch, 'email did not match');
    }
    Test.stopTest();
  }

  @isTest
  static void registerOnlyDetailsMatch() {
    final User PORTAL_SYS_ADMIN = TestDataFactory.getPortalSysAdminUser();
    
    List<RegistrationMatchingHelper.ContactMatchingResponse> responseList = new List<RegistrationMatchingHelper.ContactMatchingResponse>();
    List<Contact> contactToValidateList = new List<Contact>();
    Contact contactToValidate = new Contact(
        FirstName = 'FirstName Test',
        LastName = 'LastName Test',
        Registered_Email__c = 'mismatchEmail@email.com',
        Birthdate = Date.Today()
    );
    contactToValidateList.add(contactToValidate);
    String contactString = JSON.serialize(contactToValidateList);
    Test.startTest();
    System.runAs(PORTAL_SYS_ADMIN){
        responseList = RegistrationMatchingHelper.validateContactMatching(contactString);
        system.assert(responseList[0].isPartialMatch, 'is not partial match');
        system.assert(!responseList[0].isEmailMatch, 'email matched');
    }
    Test.stopTest();
  }

  @isTest
  static void registerAllMatch() {
    final User PORTAL_SYS_ADMIN = TestDataFactory.getPortalSysAdminUser();
    
    List<RegistrationMatchingHelper.ContactMatchingResponse> responseList = new List<RegistrationMatchingHelper.ContactMatchingResponse>();
    List<Contact> contactToValidateList = new List<Contact>();
    Contact contactToValidate = new Contact(
        FirstName = 'FirstName Test',
        LastName = 'LastName Test',
        Registered_Email__c = 'learnerEmail@email.com',
        Birthdate = Date.Today()
    );
    contactToValidateList.add(contactToValidate);
    String contactString = JSON.serialize(contactToValidateList);
    Test.startTest();
    System.runAs(PORTAL_SYS_ADMIN){
        responseList = RegistrationMatchingHelper.validateContactMatching(contactString);
        system.assert(!responseList[0].isPartialMatch, 'is partial match');
        system.assert(responseList[0].isEmailMatch, 'email matched');
    }
    Test.stopTest();
  }
}