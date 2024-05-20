/**
 * @description Service Class for QualtricsSurveyService Test class
 *
 * @see QualtriServeyService
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------|
 *    | arsenio.jr.dayrit              | May 20,2024           | DEPP-8821	            | Created File                  |
 */
@isTest
private class QualtricsSurveyServiceTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Student_Success_Outreach_Manager' });
    }

    @isTest
    private static void enqueueQualtricsSurveyToProcessTest() {
        System.runAs(TestDataFactory.getStudentSuccessOutreachManager()) {
            Test.startTest();

            List<Case> cases = new List<Case>();
            Case caseRec = new Case();
            caseRec.RecordTypeId = CasesDAO.OUTREACH_RECTYPE_ID;
            caseRec.Case_Type__c = CasesDAO.CASE_TYPE_STUDENT_SUCCESS_RETENTION;
            cases.add(caseRec);
            CasesDAO.newInstance().insertRecords(cases, true, AccessLevel.USER_MODE);

            Engagement_List_Configuration__c elcRec = new Engagement_List_Configuration__c();
            elcRec.Qualtrics_Instrument_Id__c = 'test';
            elcRec.Instrument__c = 'test';
            insert elcRec;

            cases[0].Engagement_List_Configuration__c = elcRec.Id;
            CasesDAO.newInstance().updateRecords(cases, true, AccessLevel.USER_MODE);

            List<Case> caseList = [SELECT Id, Engagement_List_Configuration__r.Qualtrics_Instrument_Id__c FROM Case WHERE Id = :cases[0].Id];
            
            QualtricsSurveyService.enqueueQualtricsSurveyToProcess(caseList);
            List<Qualtrics_Survey__c> qs = [SELECT Id, Case__c FROM Qualtrics_Survey__c WHERE Case__c =: cases[0].Id];
            Test.stopTest();

            System.assertEquals(1, qs.size(), ' No Qualtrics Survey record created.');
        } 
    }
}