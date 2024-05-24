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
 */
@isTest
public class QualtricsSurveyCalloutQueuableTest {

    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Student_Success_Outreach_Manager' });
    }

    @isTest
    private static void testExecute() {
        System.runAs(TestDataFactory.getStudentSuccessOutreachManager()) {
            List<Engagement_List_Configuration__c> elcList = new List<Engagement_List_Configuration__c>();
            Engagement_List_Configuration__c elcRec = new Engagement_List_Configuration__c();
            elcRec.Qualtrics_Instrument_Id__c = 'test';
            elcRec.Instrument__c = 'test';
            elcList.add(elcRec);
            EngagementListConfigurationsDAO.newInstance().insertRecords(elcList, true, AccessLevel.USER_MODE);

            List<Case> cases = new List<Case>();
            Case caseRec = new Case();
            caseRec.RecordTypeId = CasesDAO.OUTREACH_RECTYPE_ID;
            caseRec.Case_Type__c = CasesDAO.CASE_TYPE_STUDENT_SUCCESS_RETENTION;
            caseRec.Engagement_List_Configuration__c = elcRec.Id;
            cases.add(caseRec);
            CasesDAO.newInstance().insertRecords(cases, true, AccessLevel.USER_MODE);

            CasesDAO.newInstance().getCasesByIds(new Set<Id>{cases[0].Id},AccessLevel.SYSTEM_MODE);

            List<Qualtrics_Survey__c> qualtricsSurveyList = new List<Qualtrics_Survey__c>();
            Qualtrics_Survey__c qs = new Qualtrics_Survey__c();
            qualtricsSurveyList.add(qs);
            QualtricsSurveysDAO.newInstance().insertRecords(qualtricsSurveyList, true, AccessLevel.SYSTEM_MODE);

            cases[0].Qualtrics_Survey__c = qualtricsSurveyList[0].Id;
            CasesDAO.newInstance().updateRecords(cases, true, AccessLevel.USER_MODE);

            // Enqueue the queueable class
            Test.startTest();
            System.enqueueJob(new QualtricsSurveyCalloutQueuable(qualtricsSurveyList,'QualtricsSurveyService'));
            Test.stopTest();
            List<Qualtrics_Survey__c> updatedQualtricsSurveyList = QualtricsSurveysDAO.newInstance().getQualitricsSurveysBySetIds(new Set<Id>{cases[0].Qualtrics_Survey__c},AccessLevel.SYSTEM_MODE);

            System.assert(!String.isBlank(updatedQualtricsSurveyList[0].In_Progress_Survey_URL__c), ' In Progress Survey URL did not update');
            System.assert(!String.isBlank(updatedQualtricsSurveyList[0].Distribution_List__c), ' In Distribution List did not update');
            
        }
    }
}