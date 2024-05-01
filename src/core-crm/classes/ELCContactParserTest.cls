/**
 * @description Test class for ELCContactParser
 * @ELCContactParser
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | May 2, 2024           | DEPP-7528              | Created file                 |
 */
@isTest
public with sharing class ELCContactParserTest {
    
    @testSetup static void setupMethod() {
        TestDataFactory.generateTestUsers();
    }

    @isTest
    static void setBodyValuesTest() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            
            String citizenshipStatus = ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;
            Date executionDate = Date.today();
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            engagementListCriteria.Citizenship_Status__c = citizenshipStatus;

            Test.startTest();
            ELCParser parser = new ELCParser(engagementListCriteria, executionDate);
            Test.stopTest();

            //Checking on the criterions 
            System.assertEquals(parser.getContactCriteria().citizenshipStatus, citizenshipStatus, 'Incorrect Citizenship Status.');
            System.assertEquals(parser.getContactCriteria().recordType, ContactsDAO.PERSON_RECORDTYPE , 'Incorrect Contact record type'); 
            System.assertEquals(parser.getContactCriteria().isQUTStudent, true, 'Contact is not set as QUT student');

        }
    }
}