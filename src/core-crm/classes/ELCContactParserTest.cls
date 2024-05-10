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
    
    @TestSetup
    static void setupMethod(){
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_ESB' });
    }

    @isTest
    static void parseContactCitizenshipStatusTest() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {

            Test.startTest();
            String citizenshipStatus = ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;
            Date executionDate = Date.today();
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            engagementListCriteria.Citizenship_Status__c = citizenshipStatus;

            ELCContactParser parser = new ELCContactParser(engagementListCriteria, executionDate);
            Test.stopTest();

            System.assertEquals(parser.getContactCriteria().getCitizenshipStatus(), citizenshipStatus, 'Incorrect Citizenship Status.');

        }
    }

    @isTest
    static void parseContactHiddenCriteriaTest() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {

            Test.startTest();
            Date executionDate = Date.today();
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            String citizenshipStatus = ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;

            ELCContactParser parser = new ELCContactParser(engagementListCriteria, executionDate);
            Test.stopTest();

            System.assertEquals(parser.getContactCriteria().getRecordType(), ContactsDAO.PERSON_RECORDTYPE , 'Incorrect Contact record type'); 
            System.assertEquals(parser.getContactCriteria().getIsQUTStudent(), true, 'Contact is not set as QUT student');

        }
    }
}