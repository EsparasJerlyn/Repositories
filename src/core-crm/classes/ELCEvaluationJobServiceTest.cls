/**
 * @description Test class for ELCEvaluationScheduler
 *
 * @author Accenture
 * 
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | gabriel.p.ventayen             | May 15, 2024          | DEPP-8490              | Created file                 |
      |                                |                       |                        |                              |
 */

 @isTest
 public with sharing class ELCEvaluationJobServiceTest {
 
     @TestSetup
     static void setupMethod(){
        TestDataFactoryUser.generateUserQUTESB();

        Test.startTest();

        Engagement_List_Configuration__c engagementListConfig = new Engagement_List_Configuration__c();
        engagementListConfig.Engagement_List_Configuration_Status__c = 'Active';
        engagementListConfig.Start_Date__c = Date.today().addDays(-3);
        engagementListConfig.End_Date__c = Date.today().addDays(3);
        insert engagementListConfig;

        Breach__c breach = new Breach__c(
            Name = 'Breach Test 01'
        );
        insert breach; 

        Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
        engagementListCriteria.Engagement_List_Criteria_Title__c = 'Test Title';
        engagementListCriteria.Engagement_List_Configuration__c = engagementListConfig.Id;
        engagementListCriteria.Status__c = 'Active';
        engagementListCriteria.Start_Date__c = Date.today().addDays(-3);
        engagementListCriteria.End_Date__c = Date.today().addDays(3);
        engagementListCriteria.RecordTypeId = EngagementListCriteriasDAO.RECORD_TYPE_ID_ENTRY_CRITERIA;
        engagementListCriteria.Assessment_Priority__c = 'High';
        engagementListCriteria.Failed_To_Submit_Assessment__c = 'Yes';
        engagementListCriteria.Citizenship_Status__c = ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;
        engagementListCriteria.Academic_Status__c = ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE;
        engagementListCriteria.Category_Type__c = 'Graduate Certificate';
        engagementListCriteria.Course_Grade__c = '100';
        engagementListCriteria.Is_On_Leave_of_Absence__c = 'Yes';
        engagementListCriteria.Key_Date__c = EngagementListCriteriasDAO.KEY_DATE_LEAVE_OF_ABSENCE_END_DATE;
        engagementListCriteria.Key_Date_Offset_Lower_Boundary__c = -10;
        engagementListCriteria.Key_Date_Offset_Upper_Boundary__c = 10;
        insert engagementListCriteria;

        Test.stopTest();
     }
     
 
     @isTest
     static void prepareELCEvaluationJobsTest(){
         System.runAs(TestDataFactoryUser.selectUserQUTESB) {

            Test.StartTest();
            List<ELCEvaluationJob> elcEvaluationJobs = ELCEvaluationJobService.prepareELCEvaluationJobs(Date.today());
            Test.stopTest();
                     
            System.assert(elcEvaluationJobs.size() > 0, 'There are no prepared Evaluations Jobs found.');
         }
     }
 }