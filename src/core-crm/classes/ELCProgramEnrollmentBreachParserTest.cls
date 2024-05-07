/**
 * @description Test class for ELCProgramEnrollmentBreachParser
 * @ELCProgramEnrollmentBreachParser
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | May 2, 2024           | DEPP-7528              | Created file                 |
 */
@isTest
public with sharing class ELCProgramEnrollmentBreachParserTest {
    @TestSetup
    static void setupMethod(){
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_ESB' });
    }

    @isTest
    static void parseProgEnrollBreachNameTest() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {    

            Breach__c breach = new Breach__c(
                Name = 'Breach Test 01'
            );
            insert breach;         
            
            Test.startTest();
            Date executionDate = Date.today();
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            engagementListCriteria.Breach__c = breach.Id;
            
            ELCProgramEnrollmentBreachParser parser = new ELCProgramEnrollmentBreachParser(engagementListCriteria, executionDate);
            Test.stopTest();

            System.assertEquals(parser.getProgramEnrollmentBreachCriteria().getBreach(), breach.Id, 'Incorrect Breach Id assigned');
        }
    }

    @isTest
    static void parseProgEnrollBreachHiddenCriteriaTest() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {

            Test.startTest();
            Date executionDate = Date.today();
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();

            ELCProgramEnrollmentBreachParser parser = new ELCProgramEnrollmentBreachParser(engagementListCriteria, executionDate);
            Test.stopTest();

            System.assertEquals(parser.getProgramEnrollmentBreachCriteria().getBreachStatus(), ProgramEnrollmentBreachesDAO.STATUSES_FOR_PROGRAM_ENROLLMENT_BREACH, 'Status shoul be set to Breach Statuses');
        }
    }

    @isTest
    static void parseprocessKeyDateOffsetsTest() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            Date executionDate = Date.today();
            Date execDateLower = executionDate.addDays(-10);
            Date execDateUpper = executionDate.addDays(10);

            Test.startTest();
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            engagementListCriteria.Key_Date__c = 'Breach Start Date';
            engagementListCriteria.Key_Date_Offset_Lower_Boundary__c = -10;
            engagementListCriteria.Key_Date_Offset_Upper_Boundary__c = 10;

            ELCProgramEnrollmentBreachParser parser = new ELCProgramEnrollmentBreachParser(engagementListCriteria, executionDate);
            Test.stopTest();

            System.assertEquals(parser.getProgramEnrollmentBreachCriteria().getExecutionDate(), executionDate, 'Incorrect Execution Date');
            System.assertEquals(parser.getProgramEnrollmentBreachCriteria().getBreachDateFrom(), DateTime.newInstance(execDateLower.year(), execDateLower.month(), execDateLower.day()).format('YYYY-MM-dd'), 'Incorrect Key Date Offset Lower');
            System.assertEquals(parser.getProgramEnrollmentBreachCriteria().getBreachDateTo(), DateTime.newInstance(execDateUpper.year(), execDateUpper.month(), execDateUpper.day()).format('YYYY-MM-dd'), 'Incorrect Key Date Offset Upper');
        }
    }
}