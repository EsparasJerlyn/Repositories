/**
 * @description QualtricsSurveyCalloutQueuable testclass.
 * @see ../class/QualtricsSurveyCalloutQueuable
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                        |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------------------------------|
 *    | arsenio.jr.dayrit              | May 22, 2024          | DEPP-8821              | Created file                                          |
 *    | eugene.andrew.abuan            | May 24, 2024          | DEPP-8822              | Added checkInProgressSurveyURL                        |
 */
@isTest
public class QualtricsSurveyCalloutQueuableTest {

    private static final String TEST_TEMPLATE = 'Test Email Template';

    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactoryUser.generateUserQUTESB();
        TestDataFactoryUser.generateUserStudentSuccessOutreachManager();
        Test.stopTest();

        System.runAs(TestDataFactoryUser.selectUserStudentSuccessOutreachManager) {
            List<Account> acc = TestDataFactory.createTestAccountRecords(1);
            acc[0].RecordTypeId = AccountsDAO.ACCT_BUSINESS_ORG_ID;
            AccountsDAO.newInstance().insertRecords(acc, true, AccessLevel.SYSTEM_MODE);
            
            List<Contact> newContacts = TestDataFactory.createTestContactRecords(0,1);
            newContacts[0].AccountId = acc[0].Id;
            ContactsDAO.newInstance().insertRecords(newContacts, true, AccessLevel.SYSTEM_MODE);

            List<EmailTemplate> emailTemplateList = TestDataFactory.createTestEmailTemplateRecords(1,new Map<String,String>{
                TEST_TEMPLATE => 'Test Email Subject1'
            });
            EmailTemplatesDAO.newInstance().insertRecords(emailTemplateList, true, AccessLevel.SYSTEM_MODE);
            
            List<Engagement_List_Configuration__c> engagementListConfig = TestDataFactory.createTestEngagementListConfiguration();
            engagementListConfig[0].Email_Template__c = 'Test Email Template';
            engagementListConfig[0].Communication_Channel__c = 'Email';
            engagementListConfig[0].Qualtrics_Instrument_Id__c = 'test';
            engagementListConfig[0].Qualtrics_Instrument_Name__c = 'test';            
            EngagementsDAO.newInstance().updateRecords(engagementListConfig, true, AccessLevel.SYSTEM_MODE);

            List<Qualtrics_Survey__c> qualtricsSurveyList = TestDataFactory.createQualtricsSurveyRecord(100);
            QualtricsSurveysDAO.newInstance().insertRecords(qualtricsSurveyList, true, AccessLevel.SYSTEM_MODE);

            List<Case> caseList = TestDataFactory.createTestCaseRecords(CasesDAO.OUTREACH_RECTYPE_ID, 'Test', 1);
            caseList[0].Origin = 'Email';
            caseList[0].Engagement_List_Configuration__c = engagementListConfig[0].Id;
            caseList[0].Qualtrics_Survey__c = qualtricsSurveyList[0].Id;
            caseList[0].Case_Type__c = 'Student Success - Retention';
            CasesDAO.newInstance().insertRecords(caseList, true, AccessLevel.SYSTEM_MODE);
        }
    }

    @isTest
    private static void checkInProgressSurveyURL(){
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            // Bypass the trigger to call directly the Queueable method
            BypassTriggers__c bypass = new BypassTriggers__c(Bypass__c = true, SetupOwnerId = UserInfo.getOrganizationId());
            insert bypass;
            
            List<Qualtrics_Survey__c> qualtricsSurveyList = QualtricsSurveysDAO.newInstance().getQualitricsSurveysByOwnerId(
                new Set<ID>{TestDataFactoryUser.selectUserStudentSuccessOutreachManager.Id}, AccessLevel.SYSTEM_MODE
            );
			
            for(Qualtrics_Survey__c qs : qualtricsSurveyList){
                qs.In_Progress_Survey_URL__c = 'Test URL';
            }
            QualtricsSurveysDAO.newInstance().updateRecords(qualtricsSurveyList, true, AccessLevel.SYSTEM_MODE);

            Test.startTest();

            ID jobID = System.enqueueJob(new QualtricsSurveyCalloutQueuable(qualtricsSurveyList,'checkInProgressSurveyURL'));
            AsyncApexJob asyncApexJob = AsyncApexJobsDAO.newInstance().findAsyncApexJobById(jobID, AccessLevel.SYSTEM_MODE);  
            
            Test.stopTest();

            System.assertEquals(jobID, asyncApexJob.Id, 'Async Job Id should Match');

        }
    }
}