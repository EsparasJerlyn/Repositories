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

            Engagement_List_Configuration__c elcRec = new Engagement_List_Configuration__c();
            elcRec.Qualtrics_Instrument_Id__c = 'test';
            elcRec.Instrument__c = 'test';
            insert elcRec;

            List<Case> cases = new List<Case>();
            Case caseRec = new Case();
            caseRec.RecordTypeId = CasesDAO.OUTREACH_RECTYPE_ID;
            caseRec.Case_Type__c = CasesDAO.CASE_TYPE_STUDENT_SUCCESS_RETENTION;
            caseRec.Engagement_List_Configuration__c = elcRec.Id;
            cases.add(caseRec);
            CasesDAO.newInstance().insertRecords(cases, true, AccessLevel.USER_MODE);

            List<Case> caseList = [SELECT Id, Engagement_List_Configuration__r.Qualtrics_Instrument_Id__c, Qualtrics_Survey__c FROM Case WHERE Id = :cases[0].Id];
            System.enqueueJob(new OutreachCasePostCreationQueuable(caseList));
            List<Qualtrics_Survey__c> qualtricsSurveyList = [SELECT Id, In_Progress_Survey_URL__c, Distribution_List__c FROM Qualtrics_Survey__c];

            // Enqueue the queueable class
            Test.startTest();
            System.enqueueJob(new QualtricsSurveyCalloutQueuable(qualtricsSurveyList));
            Test.stopTest();
            List<Qualtrics_Survey__c> updatedQualtricsSurveyList = [SELECT Id, In_Progress_Survey_URL__c, Distribution_List__c FROM Qualtrics_Survey__c];

            System.assert(!String.isBlank(updatedQualtricsSurveyList[0].In_Progress_Survey_URL__c), ' In Progress Survey URL did not update');
            System.assert(!String.isBlank(updatedQualtricsSurveyList[0].Distribution_List__c), ' In Distribution List did not update');
            
        }
    }
}