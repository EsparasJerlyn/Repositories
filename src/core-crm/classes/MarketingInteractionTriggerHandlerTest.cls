/**
 * @description Test Class for MarketingInteractionTriggerHandler
 * @see MarketingInteractionTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer                | Date                  | JIRA                   | Change Summary               |
      |--------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz           | October 09, 2023      | DEPP-5866              | Created file                 |
 */
@isTest
public with sharing class MarketingInteractionTriggerHandlerTest {

    @TestSetup
    static void makeData(){
        Test.startTest();
        TestDataFactoryUser.generateUserQUTESB();
        Test.stopTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB){

            List<Contact> contactList =TestDataFactory.createTestContactRecords(1, ContactsDAO.CITIZENSHIP_STATUS_DOMESTIC);
            ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.SYSTEM_MODE);       
        
        }
    }
    
    @isTest
    public static void testInsertMarketingInteraction() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();

            List<Contact> contactList = ContactsDAO.newInstance().getPersonContactsWithLimit(1);
            List<Marketing_Interaction__c> marketingIntList = TestDataFactory.createMarketingInteractionRecords(contactList[0].Id, 1, '');
            MarketingInteractionsDAO.newInstance().insertRecords(marketingIntList, true, AccessLevel.SYSTEM_MODE);

            Test.stopTest();
            System.assert(marketingIntList[0].Id != null, 'The record was not successfully inserted.');
        }
    }

    @isTest
    public static void testUpdateMarketingInteraction() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();

            List<Contact> contactList = ContactsDAO.newInstance().getPersonContactsWithLimit(1);
            List<Marketing_Interaction__c> marketingIntList = TestDataFactory.createMarketingInteractionRecords(contactList[0].Id, 1, '');
            MarketingInteractionsDAO.newInstance().insertRecords(marketingIntList, true, AccessLevel.SYSTEM_MODE);

            List<Marketing_Interaction__c> newMktInteractionList = MarketingInteractionsDAO.newInstance().getMarketingInteractionsByContactOrLeadIds(new Set<Id>{contactList[0].Id}, AccessLevel.SYSTEM_MODE);
            List<Marketing_Interaction__c> mktgListToUpdate = new List<Marketing_Interaction__c>();
            for(Marketing_Interaction__c mktgInt : newMktInteractionList){
                mktgInt.Lead_Source_Category__c = 'Event';
                mktgListToUpdate.add(mktgInt);
            }
            MarketingInteractionsDAO.newInstance().updateRecords(mktgListToUpdate, true, AccessLevel.SYSTEM_MODE);

            Test.stopTest();
            System.assert(mktgListToUpdate[0].Lead_Source_Category__c == 'Event', 'The record was not successfully updated.');
        }
    }
}