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

            System.assertEquals(parser.getProgramEnrollmentBreachCriteria().breach, breach.Id, 'Incorrect Breach Id assigned');
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

            System.assertEquals(parser.getProgramEnrollmentBreachCriteria().breachStatus, ProgramEnrollmentBreachesDAO.STATUSES_FOR_PROGRAM_ENROLLMENT_BREACH, 'Status shoul be set to Breach Statuses');
        }
    }
}