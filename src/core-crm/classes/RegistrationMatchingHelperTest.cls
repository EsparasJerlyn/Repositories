/**
 * @description Test Class for RegistrationMatchingHelper
 * @see ..RegistrationMatchingHelper
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                                       |
      |---------------------------|-----------------------|----------------------|------------------------------------------------------|
      | roy.nino.s.regala         | August 15, 2022       | DEPP-3568            | Created file                                         |
      | roy.nino.s.regala         | January 17, 2023      | DEPP-5076            | Updated Logic to prioritize email matching result    | 
 */
@isTest
public with sharing class RegistrationMatchingHelperTest {
  public static final Id PERSON = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
    .get('Person')
    .getRecordTypeId();

  @testSetup
  public static void setupMethod() {
    Test.startTest();
    TestDataFactoryUser.generateUserSystemAdministrator();
    Test.stopTest();
    List<Contact> conList = new List<Contact>();
    conList.add(
        new Contact(
            FirstName = 'FirstName Test',
            LastName = 'LastName Test',
            Email = 'personalEmail@email.com',
            Birthdate = Date.Today().addYears(-15),
            Registered_Email__c = 'personalEmail@email.com',
            QUT_Learner_Email__c = 'learnerEmail@email.com',
            QUT_Staff_Email__c = 'staffEmail@email.com',
            Work_Email__c = 'workEmail@email.com',
            hed__Preferred_Email__c = 'Alternate Email',
            hed__AlternateEmail__c = 'personalEmail@email.com',
            RecordTypeId = PERSON
        )
    );

    conList.add(
        new Contact(
            FirstName = 'FirstName Test No DOB',
            LastName = 'LastName Test No DOB',
            Email = 'personalEmailNoDOB@email.com',
            Registered_Email__c = 'personalEmailNoDOB@email.com',
            QUT_Learner_Email__c = 'learnerEmailNoDOB@email.com',
            QUT_Staff_Email__c = 'staffEmailNoDOB@email.com',
            Work_Email__c = 'workEmailNoDOB@email.com',
            hed__Preferred_Email__c = 'Alternate Email',
            hed__AlternateEmail__c = 'personalEmailNoDOB@email.com',
            RecordTypeId = PERSON
        )
    );

    insert conList;

  }

  @isTest
  static void registerUserNoMatchTest() {
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
    
    List<RegistrationMatchingHelper.ContactMatchingResponse> responseList = new List<RegistrationMatchingHelper.ContactMatchingResponse>();
    List<Contact> contactToValidateList = new List<Contact>();
    Contact contactToValidate = new Contact(
        FirstName = 'Mistmatch',
        LastName = 'Mistmatch',
        Registered_Email__c = 'misMatch@email.com',
        Birthdate = Date.Today().addYears(-15) 
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
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
    
    List<RegistrationMatchingHelper.ContactMatchingResponse> responseList = new List<RegistrationMatchingHelper.ContactMatchingResponse>();
    List<Contact> contactToValidateList = new List<Contact>();
    Contact contactToValidate = new Contact(
        FirstName = 'Mistmatch',
        LastName = 'Mistmatch',
        Registered_Email__c = 'personalEmail@email.com',
        Birthdate = Date.Today().addYears(-15) - 1
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
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
    
    List<RegistrationMatchingHelper.ContactMatchingResponse> responseList = new List<RegistrationMatchingHelper.ContactMatchingResponse>();
    List<Contact> contactToValidateList = new List<Contact>();
    Contact contactToValidate = new Contact(
        FirstName = 'Mistmatch',
        LastName = 'Mistmatch',
        Registered_Email__c = 'learnerEmail@email.com',
        Birthdate = Date.Today().addYears(-15) - 1
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
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
    
    List<RegistrationMatchingHelper.ContactMatchingResponse> responseList = new List<RegistrationMatchingHelper.ContactMatchingResponse>();
    List<Contact> contactToValidateList = new List<Contact>();
    Contact contactToValidate = new Contact(
        FirstName = 'Mistmatch',
        LastName = 'Mistmatch',
        Registered_Email__c = 'staffEmail@email.com',
        Birthdate = Date.Today().addYears(-15) - 1
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
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
    
    List<RegistrationMatchingHelper.ContactMatchingResponse> responseList = new List<RegistrationMatchingHelper.ContactMatchingResponse>();
    List<Contact> contactToValidateList = new List<Contact>();
    Contact contactToValidate = new Contact(
        FirstName = 'Mistmatch',
        LastName = 'Mistmatch',
        Registered_Email__c = 'workEmail@email.com',
        Birthdate = Date.Today().addYears(-15) - 1
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
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
    
    List<RegistrationMatchingHelper.ContactMatchingResponse> responseList = new List<RegistrationMatchingHelper.ContactMatchingResponse>();
    List<Contact> contactToValidateList = new List<Contact>();
    Contact contactToValidate = new Contact(
        FirstName = 'FirstName Test',
        LastName = 'LastName Test',
        Registered_Email__c = 'mismatchEmail@email.com',
        Birthdate = Date.Today().addYears(-15)
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
  static void registerOnlyDetailsMatchNoDOB() {
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
    
    List<RegistrationMatchingHelper.ContactMatchingResponse> responseList = new List<RegistrationMatchingHelper.ContactMatchingResponse>();
    List<Contact> contactToValidateList = new List<Contact>();
    Contact contactToValidate = new Contact(
        FirstName = 'FirstName Test No DOB',
        LastName = 'LastName Test No DOB',
        Registered_Email__c = 'mismatchEmail@email.com'
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
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
    
    List<RegistrationMatchingHelper.ContactMatchingResponse> responseList = new List<RegistrationMatchingHelper.ContactMatchingResponse>();
    List<Contact> contactToValidateList = new List<Contact>();
    Contact contactToValidate = new Contact(
        FirstName = 'FirstName Test',
        LastName = 'LastName Test',
        Registered_Email__c = 'learnerEmail@email.com',
        Birthdate = Date.Today().addYears(-15)
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