/**
 * @description Test Class for ContactUserNameCreated
 *
 * @see ../ContactUserNameCreatedHelper
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                            |
      |---------------------------|-----------------------|--------------|-----------------------------------------------------------|
      | eugene.andrew.abuan       | July 04, 2022         | DEPP-3380    | Created file                                              | 
      |                           |                       |              |                                                           |
*/

@isTest
public with sharing class ContactUserNameCreatedHelperTest {

    private static final Id STUDENT_RECTYPEID = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName()
    .get('Student')
    .getRecordTypeId();
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get(ACCT_UNIV_DEP)
      .getRecordTypeId();


    @testSetup
    static void testSetup() {
      TestDataFactory.generateTestUsers();
    }

    @isTest
    private static void sendEmailOnContact() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            Integer i = 0;
            List<Contact> contacts = TestDataFactory.createTestContactRecords(100);
            for (Contact contact : contacts) {
              contact.Registered_Email__c = 'test' + i + '@mail.com';
              contact.QUT_Student_Username__c = 'U1248792' + i;
              i++;
            }
            insert contacts;

            Study_Store_URL_Settings__c studyStore = new Study_Store_URL_Settings__c(Study_Store_Link__c = 'https://studystorelinktest.com/');
            insert studyStore;
            
            Set<Id> contactIdSet = new Set<Id>();
            for(Contact con : [SELECT Id, QUT_Student_Username__c FROM Contact]){
              contactIdSet.add(con.Id);
            }
            
            String message = ContactUserNameCreatedHelper.sendEmailUsernameCreated(contactIdSet);
            Test.stopTest();
            
            System.assert(message !=null, 'Email is not Sent to the user');
        }
    }
}
