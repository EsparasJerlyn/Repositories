/**
 * @description OutreachCasePostCreationQueuable testclass.
 * @see ../class/OutreachCasePostCreationQueuable
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                        |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------------------------------|
 *    | arsenio.jr.dayrit              | May 22, 2024          | DEPP-8821              | Created file                                          |
 */
@isTest
public class OutreachCasePostCreationQueuableTest {

    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserStudentSuccessOutreachManager();
    }

    @isTest
    private static void testExecute() {
        System.runAs(TestDataFactoryUser.selectUserStudentSuccessOutreachManager) {
            List<Engagement_List_Configuration__c> elcList = new List<Engagement_List_Configuration__c>();
            Engagement_List_Configuration__c elcRec = new Engagement_List_Configuration__c();
            elcRec.Qualtrics_Instrument_Id__c = 'test';
            elcRec.Qualtrics_Instrument_Name__c = 'test';
            elcList.add(elcRec);
            EngagementListConfigurationsDAO.newInstance().insertRecords(elcList, true, AccessLevel.USER_MODE);

            List<Case> cases = new List<Case>();
            Case caseRec = new Case();
            caseRec.RecordTypeId = CasesDAO.OUTREACH_RECTYPE_ID;
            caseRec.Case_Type__c = CasesDAO.CASE_TYPE_STUDENT_SUCCESS_RETENTION;
            caseRec.Engagement_List_Configuration__c = elcRec.Id;
            cases.add(caseRec);
            CasesDAO.newInstance().insertRecords(cases, true, AccessLevel.USER_MODE);

            List<Case> caseList = CasesDAO.newInstance().getCasesByIds(new Set<Id>{cases[0].Id},AccessLevel.SYSTEM_MODE);
            QualtricsSurveyService.doQueueableJob = false;
            // Enqueue the queueable class
            Test.startTest();
            System.enqueueJob(new OutreachCasePostCreationQueuable(caseList));
            Test.stopTest();
            List<Case> caseListUpdated = CasesDAO.newInstance().getCasesByIds(new Set<Id>{cases[0].Id},AccessLevel.SYSTEM_MODE);
            System.assert(!String.isBlank(caseListUpdated[0].Qualtrics_Survey__c), ' No Qualtrics Survey record created.');
        }
    }
}