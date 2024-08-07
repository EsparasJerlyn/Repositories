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
        TestDataFactoryUser.generateUserQUTESB();
    }

    @isTest
    static void parseProgEnrollBreachNameTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {    

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
            System.assertEquals(parser.getProgramEnrollmentBreachCriteria().getBreachStatus(), ProgramEnrollmentBreachesDAO.STATUSES_FOR_PROGRAM_ENROLLMENT_BREACH, 'Status shoul be set to Breach Statuses');
        }
    }

    @isTest
    static void parseProgEnrollBreachHiddenCriteriaTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

            Test.startTest();
            ELCProgramEnrollmentBreachParser parser = new ELCProgramEnrollmentBreachParser(new Engagement_List_Criteria__c(), Date.today());
            Test.stopTest();

            System.assert(parser.getProgramEnrollmentBreachCriteria().isEmpty(), 'No Criteria should be parsed.'); 
        }
    }

    @isTest
    static void parseprocessKeyDateOffsetsTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Date executionDate = Date.today();
            Date execDateLower = executionDate.addDays(-1);
            Date execDateUpper = executionDate.addDays(-10);

            Test.startTest();
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            engagementListCriteria.Key_Date__c = 'Breach Start Date';
            engagementListCriteria.Key_Date_Offset_Lower_Boundary__c = 1;
            engagementListCriteria.Key_Date_Offset_Upper_Boundary__c = 10;

            ELCProgramEnrollmentBreachParser parser = new ELCProgramEnrollmentBreachParser(engagementListCriteria, executionDate);
            Test.stopTest();

            System.assertEquals(
                DateTime.newInstance(execDateLower.year(), execDateLower.month(), execDateLower.day()).format('YYYY-MM-dd'),
                DynamicQueryService.convertDatetoDateString(parser.getProgramEnrollmentBreachCriteria().getBreachDateFrom()), 
                'Incorrect Key Date Offset Lower'
            );

            System.assertEquals(
                DateTime.newInstance(execDateUpper.year(), execDateUpper.month(), execDateUpper.day()).format('YYYY-MM-dd'),
                DynamicQueryService.convertDatetoDateString(parser.getProgramEnrollmentBreachCriteria().getBreachDateTo()), 
                'Incorrect Key Date Offset Upper'
            );

        }
    }

}