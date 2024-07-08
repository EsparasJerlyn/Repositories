/**
 * @description Test class for ELCCourseConnectionParser
 * @ELCCourseConnectionParser
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | May 2, 2024           | DEPP-7528              | Created file                 |
 */
@isTest
public with sharing class ELCCourseConnectionParserTest {
    @TestSetup
    static void setupMethod(){
        TestDataFactoryUser.generateUserQUTESB();
    }

    @isTest
    static void parseCourseConnCourseGradeTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {            
            
            Test.startTest();
            Date executionDate = Date.today();
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            engagementListCriteria.Course_Grade__c = '100';
            
            ELCCourseConnectionParser parser = new ELCCourseConnectionParser(engagementListCriteria, executionDate);
            Test.stopTest();

            System.assertEquals(parser.getCourseConnectionCriteria().getCourseGrade(), '100', 'Incorrect Course Grade');
            System.assertEquals(parser.getCourseConnectionCriteria().getStatus(), ELCCourseConnectionParser.ENROLLMENT_STATUS_FOR_OUTREACH, 'Status should be set to Outreach');
        }
    }

    @isTest
    static void parseNoCourseConnCriteriaTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

            Test.startTest();
            ELCCourseConnectionParser parser = new ELCCourseConnectionParser(new Engagement_List_Criteria__c(), Date.today());
            Test.stopTest();

            System.assert(parser.getCourseConnectionCriteria().isEmpty(), 'No Criteria should be parsed.'); 

        }
    }
}