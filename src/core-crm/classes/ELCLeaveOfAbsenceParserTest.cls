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
        TestDataFactoryUser.generateUserQUTESB();
    }

    @isTest
    static void parseLOAIsOnLeaveTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {    

            Test.startTest();
            Date executionDate = Date.today();
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            engagementListCriteria.Is_On_Leave_of_Absence__c = 'Yes';
            
            ELCLeaveOfAbsenceParser parser = new ELCLeaveOfAbsenceParser(engagementListCriteria, executionDate);
            Test.stopTest();

            System.assertEquals(parser.getLeaveOfAbsencesCriteria().getIsOnLeave(), true, 'Is On Leave should not be false');
        }
    }

    @isTest
    static void parseLOAIsNotOnLeaveTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {    

            Test.startTest();
            Date executionDate = Date.today();
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            engagementListCriteria.Is_On_Leave_of_Absence__c = 'No';
            
            ELCLeaveOfAbsenceParser parser = new ELCLeaveOfAbsenceParser(engagementListCriteria, executionDate);
            Test.stopTest();

            System.assertEquals(parser.getLeaveOfAbsencesCriteria().getIsOnLeave(), false, 'Is On Leave should not be false');
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
            engagementListCriteria.Key_Date__c = 'Leave of Absence End Date';
            engagementListCriteria.Key_Date_Offset_Lower_Boundary__c = 1;
            engagementListCriteria.Key_Date_Offset_Upper_Boundary__c = 10;

            ELCLeaveOfAbsenceParser parser = new ELCLeaveOfAbsenceParser(engagementListCriteria, executionDate);
            Test.stopTest();

            System.assertEquals(
                DateTime.newInstance(execDateLower.year(), execDateLower.month(), execDateLower.day()).format('YYYY-MM-dd'),
                DynamicQueryService.convertDatetoDateString(parser.getLeaveOfAbsencesCriteria().getEndDateFrom()), 
                'Incorrect Key Date Offset Lower'
            );
            System.assertEquals(
                DateTime.newInstance(execDateUpper.year(), execDateUpper.month(), execDateUpper.day()).format('YYYY-MM-dd'),
                DynamicQueryService.convertDatetoDateString(parser.getLeaveOfAbsencesCriteria().getEndDateTo()), 
                'Incorrect Key Date Offset Upper'
            );
        }
    }
}