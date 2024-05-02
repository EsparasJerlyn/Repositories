/**
 * @description Test class for ELCLeaveOfAbsenceParser
 * @ELCLeaveOfAbsenceParser
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | May 2, 2024           | DEPP-7528              | Created file                 |
 */
@isTest
public with sharing class ELCLeaveOfAbsenceParserTest {
    @TestSetup
    static void setupMethod(){
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_ESB' });
    }

    @isTest
    static void parseLOAIsOnLeaveTest() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {    

            Test.startTest();
            Date executionDate = Date.today();
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            engagementListCriteria.Is_On_Leave_of_Absence__c = 'Yes';
            
            ELCLeaveOfAbsenceParser parser = new ELCLeaveOfAbsenceParser(engagementListCriteria, executionDate);
            Test.stopTest();

            System.assertEquals(parser.getLeaveOfAbsencesCriteria().isOnLeave, true, 'Is On Leave should not be false');
        }
    }

    @isTest
    static void parseLOAIsNotOnLeaveTest() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {    

            Test.startTest();
            Date executionDate = Date.today();
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            engagementListCriteria.Is_On_Leave_of_Absence__c = 'No';
            
            ELCLeaveOfAbsenceParser parser = new ELCLeaveOfAbsenceParser(engagementListCriteria, executionDate);
            Test.stopTest();

            System.assertEquals(parser.getLeaveOfAbsencesCriteria().isOnLeave, false, 'Is On Leave should not be false');
        }
    }

    

}