/**
 * @description Test Class for Set IER Primary Contact and Lead
 *
 * @see ../flows/Set_IER_Primary_Contact_and_Lead
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | roy.nino.s.regala         | May 19, 2022          | DEPP-1517    | Created file                                |
      |                           |                       |              |                                             | 
      |                           |                       |              |                                             | 
*/
@isTest
private class SetIERPrimaryContactandLeadFlowTest{

    public static final Id PERSON = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
        .get('Person')
        .getRecordTypeId();

    @testSetup
  static void testSetup() {
        Test.startTest();
        TestDataFactoryUser.generateUserQUTMarketingCloud();
        Test.stopTest();
        System.runAs(TestDataFactoryUser.selectUserQUTMarketingCloud){
          List<Contact> cons = TestDataFactory.createTestContactRecords(1);
              cons[0].RecordTypeId = PERSON;
              cons[0].FirstName = 'Contact FN 4';
              cons[0].LastName = 'Contact LN 4';
              cons[0].Email = 'test@email.com';
              cons[0].Work_Email__c = 'test_work@email.com';
              cons[0].QUT_Staff_Email__c = 'test_staff@email.com';
              cons[0].QUT_Learner_Email__c = 'test_learner@email.com';
              cons[0].hed__Preferred_Email__c = 'Alternate Email';
              cons[0].hed__AlternateEmail__c = 'test@email.com';
          insert cons;

          et4ae5__Automated_Send__c triggerSend = new et4ae5__Automated_Send__c(Name = 'et4ae5__Automated_Send__c');
          insert triggerSend;
        }
  }

  @isTest
  static void parentPersonContactAsPrimaryTest(){
    System.runAs(TestDataFactoryUser.selectUserQUTMarketingCloud){
    test.startTest();
      List<Contact> contacts = new List<Contact>([SELECT Id,Parent_Person_Contact__c FROM Contact WHERE Parent_Person_Contact__c != null limit 1]);
      List<et4ae5__Automated_Send__c> triggerSend = [SELECT Id FROM et4ae5__Automated_Send__c LIMIT 1];
      et4ae5__IndividualEmailResult__c  IER = new et4ae5__IndividualEmailResult__c(Name = 'test email name', et4ae5__Contact__c= contacts[0].id,et4ae5__TriggeredSendDefinition__c = triggerSend[0].Id);
      insert IER;

      system.assert(![SELECT Id FROM et4ae5__IndividualEmailResult__c WHERE Primary_Contact__c =: contacts[0].Parent_Person_Contact__c].isEmpty(), 'parent personal contact was not copied');
      test.stopTest();
    }
  }

  @isTest
  static void parentContactAsPrimaryTest(){
    System.runAs(TestDataFactoryUser.selectUserQUTMarketingCloud){
      test.startTest();
      List<Contact> contacts = new List<Contact>([SELECT Id,Parent_Person_Contact__c FROM Contact WHERE Parent_Person_Contact__c = NULL AND RecordTypeId =:PERSON limit 1]);
      List<et4ae5__Automated_Send__c> triggerSend = [SELECT Id FROM et4ae5__Automated_Send__c LIMIT 1];
      et4ae5__IndividualEmailResult__c  IER = new et4ae5__IndividualEmailResult__c(Name = 'test email name', et4ae5__Contact__c= contacts[0].id,et4ae5__TriggeredSendDefinition__c = triggerSend[0].Id);
      insert IER;

      system.assert(![SELECT Id FROM et4ae5__IndividualEmailResult__c WHERE Primary_Contact__c =: contacts[0].Id].isEmpty(), 'parent personal contact was not copied');
      test.stopTest();
    } 
  }


  @isTest
  static void parentPersonLeadAsPrimaryTest(){
    System.runAs(TestDataFactoryUser.selectUserQUTMarketingCloud){
      test.startTest();
      List<Account> accs = TestDataFactory.createTestAccountRecords(1);
      insert accs;
      List<Contact> contacts = new List<Contact>([SELECT Id,Parent_Person_Lead__c FROM Contact  limit 1]);
      List<Lead> leads = TestDataFactory.createTestLeadRecords(1);
      insert leads;
      contacts[0].Parent_Person_Lead__c = leads[0].Id;
      update contacts;
      List<et4ae5__Automated_Send__c> triggerSend = [SELECT Id FROM et4ae5__Automated_Send__c LIMIT 1];
      et4ae5__IndividualEmailResult__c  IER = new et4ae5__IndividualEmailResult__c(Name = 'test email name', et4ae5__Contact__c= contacts[0].id,et4ae5__TriggeredSendDefinition__c = triggerSend[0].Id);
      insert IER;

      system.assert(![SELECT Id FROM et4ae5__IndividualEmailResult__c WHERE Primary_Lead__c =: contacts[0].Parent_Person_Lead__c].isEmpty(), 'parent personal lead was not copied');
      test.stopTest();
    }
  }

  @isTest
  static void parentLeadAsPrimaryTest(){
    System.runAs(TestDataFactoryUser.selectUserQUTMarketingCloud){
      test.startTest();
      List<Account> accs = TestDataFactory.createTestAccountRecords(1);
      insert accs;
      List<Lead> leads = TestDataFactory.createTestLeadRecords(1);
      insert leads;
      List<et4ae5__Automated_Send__c> triggerSend = [SELECT Id FROM et4ae5__Automated_Send__c LIMIT 1];
      et4ae5__IndividualEmailResult__c  IER = new et4ae5__IndividualEmailResult__c(Name = 'test email name', et4ae5__Lead__c= leads[0].id,et4ae5__TriggeredSendDefinition__c = triggerSend[0].Id);
      insert IER;

      system.assert(![SELECT Id FROM et4ae5__IndividualEmailResult__c WHERE Primary_Lead__c =: leads[0].Id].isEmpty(), 'parent  lead was not copied');
      test.stopTest();
    }
  }

  
}