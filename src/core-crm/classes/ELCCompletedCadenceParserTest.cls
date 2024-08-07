/**
 * @description Test class for ELCCompletedCadenceParser
 * @ELCCompletedCadenceParser
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | May 2, 2024           | DEPP-7528              | Created file                 |
 */
@isTest
public with sharing class ELCCompletedCadenceParserTest {

    @TestSetup
    static void setupMethod(){
        TestDataFactoryUser.generateUserQUTESB();
    }

    @isTest
    static void parseCompletedCadenceTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {            
            
            Test.startTest();
            String completedCadenceName = 'Domestic Accepted and Admitted';
            Date executionDate = Date.today();
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            engagementListCriteria.Completed_Cadence__c = completedCadenceName;
            
            ELCCompletedCadenceParser parser = new ELCCompletedCadenceParser(engagementListCriteria, executionDate);
            Test.stopTest();

            System.assertEquals(parser.getCompletedCadenceCriteria().getCompletedCadence(), completedCadenceName, 'Incorrect Completed Cadence');
            System.assertEquals(parser.getCompletedCadenceCriteria().getStatus(), CompletedCadencesDAO.SUCCESSFUL_STATUS, 'Status should be set to Succesful'); 
        }
    }

    @isTest
    static void parseNoCompletedCadenceCriteriaTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

            Test.startTest();
            ELCCompletedCadenceParser parser = new ELCCompletedCadenceParser(new Engagement_List_Criteria__c(), Date.today());
            Test.stopTest();

            System.assert(parser.getCompletedCadenceCriteria().isEmpty(), 'No Criteria should be parsed.'); 
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
            engagementListCriteria.Key_Date__c = 'Completed Cadence Date';
            engagementListCriteria.Key_Date_Offset_Lower_Boundary__c = 1;
            engagementListCriteria.Key_Date_Offset_Upper_Boundary__c = 10;

            ELCCompletedCadenceParser parser = new ELCCompletedCadenceParser(engagementListCriteria, executionDate);
            Test.stopTest();

            System.assertEquals(
                execDateLower, 
                parser.getCompletedCadenceCriteria().getCompletedCadanceDateFrom(), 
                'Incorrect Key Date Offset Lower'
            );
            System.assertEquals(
                execDateUpper, 
                parser.getCompletedCadenceCriteria().getCompletedCadanceDateTo(), 
                'Incorrect Key Date Offset Upper'
            );
        }
    }
}