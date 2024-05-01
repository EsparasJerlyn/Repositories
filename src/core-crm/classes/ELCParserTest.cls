/**
 * @description Test class for ELCParser
 * @ELCParser
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | julie.jane.alegre              | May 1, 2024           | DEPP-8489              | Created file                 |
 */
@isTest
public with sharing class ELCParserTest {

    @testSetup static void setupMethod() {
        TestDataFactory.generateTestUsers();
    }

    @isTest
    static void setBodyValuesTest() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            
            String citizenshipStatus = ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;
            String academicStatus = 'Showcause';
            String completedCadenceName = 'Domestic Accepted and Admitted';

            Date executionDate = Date.today();
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            engagementListCriteria.Citizenship_Status__c = citizenshipStatus;
            engagementListCriteria.Academic_Status__c = academicStatus;

            Test.startTest();
            ELCParser parser = new ELCParser(engagementListCriteria, executionDate);
            Test.stopTest();
            
            System.assertEquals(parser.getContactCriteria().citizenshipStatus, citizenshipStatus, 'Incorrect Citizenship Status.');
            System.assertEquals(parser.getProgramEnrollmentCriteria().academicStatus, academicStatus, 'Incorrect Academic Status');
        }
    }

}