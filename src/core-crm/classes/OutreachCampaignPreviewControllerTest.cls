/**
 * @description This is the test class for OutreachCampaignPreviewController
 * @history
 *    | Developer                 | Date         | JIRA        | Change Summary                                  |
 *    |---------------------------|--------------|-------------|------------------------------------------------|
 *    | alexander.cadalin         | Jun 03, 2024 | DEPP-7535   | Created File                                   |
 */
@isTest
public class OutreachCampaignPreviewControllerTest {
	@testSetup
    static void setup() {
        Test.startTest();
        TestDataFactoryUser.generateUserStudentSuccessOutreachManager();
        Test.stopTest();
        User userOutreachManager = TestDataFactoryUser.selectUserStudentSuccessOutreachManager;
        Date executionDateBase = Date.today();
        Date executionDateStart = executionDateBase - 30;
        Date executionDateEnd = executionDateBase + 30;
        System.runAs(userOutreachManager){
            Engagement_List_Configuration__c elconf = new Engagement_List_Configuration__c(
                Name = 'Preview Test Configuration',
                Engagement_List_Configuration_Status__c = 'Active',
                Start_Date__c = executionDateStart,
                End_Date__c = executionDateEnd
            );
            List<Engagement_List_Configuration__c> elconfs = new List<Engagement_List_Configuration__c>{elconf};
            EngagementListConfigurationsDAO.newInstance().insertRecords(
                elconfs,
                false,
                AccessLevel.USER_MODE
            );
            Engagement_List_Criteria__c elcrit = new Engagement_List_Criteria__c(
                RecordTypeId = EngagementListCriteriasDAO.RECORD_TYPE_ID_ENTRY_CRITERIA,
                Engagement_List_Criteria_Title__c = 'Preview Test Criteria',
                Engagement_List_Configuration__c = elconfs[0].Id,
                Status__c = 'Draft',
                Start_Date__c = executionDateStart,
                End_Date__c = executionDateEnd
            );
            EngagementListCriteriasDAO.newInstance().insertRecords(
                new List<Engagement_List_Criteria__c>{elcrit},
                false,
                AccessLevel.USER_MODE
            );
            
            System.debug([SELECT Id FROM Engagement_List_Configuration__c].size());
            System.debug([SELECT Id FROM Engagement_List_Criteria__c].size());
        }
    }
    
    @isTest
    private static void testProcessPreview() {
        System.runAs(TestDataFactoryUser.selectUserStudentSuccessOutreachManager){
        	Date executionDate = Date.today();
            String dateInput = executionDate.year() + '-' + executionDate.month() + '-' + executionDate.day();
            List<Engagement_List_Criteria__c> elcrits = [SELECT Id FROM Engagement_List_Criteria__c];
            OutreachCampaignPreviewController.processPreview(elcrits[0].Id, dateInput);
            Engagement_List_Criteria__c elcrit = EngagementListCriteriasDAO.newInstance().getEntryCriteriaById(
                elcrits[0].Id, 
                AccessLevel.USER_MODE
            );
            System.assert(elcrit.Preview_Status__c != 'Not Generated', 'The preview was not generated.');
        }
    }
    
    @isTest
    private static void testCancelPreview() {
        System.runAs(TestDataFactoryUser.selectUserStudentSuccessOutreachManager){
        	Date executionDate = Date.today();
            String dateInput = executionDate.year() + '-' + executionDate.month() + '-' + executionDate.day();
            List<Engagement_List_Criteria__c> elcrits = [SELECT Id FROM Engagement_List_Criteria__c];
            OutreachCampaignPreviewController.cancelPreview(elcrits[0].Id);
            Engagement_List_Criteria__c elcrit = EngagementListCriteriasDAO.newInstance().getEntryCriteriaById(
                elcrits[0].Id, 
                AccessLevel.USER_MODE
            );
            System.assert(elcrit.Preview_Status__c == 'Not Generated', 'The preview was not cancelled.');
        }
    }
}