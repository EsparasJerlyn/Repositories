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
            
            QualtricsSurveyService.enqueueQualtricsSurveyToProcess(caseList);
            List<Qualtrics_Survey__c> qualtricsSurveyList = [SELECT Id, Case__c FROM Qualtrics_Survey__c];
            List<Case> caseListUpdated = [SELECT Id, Engagement_List_Configuration__r.Qualtrics_Instrument_Id__c, Qualtrics_Survey__c FROM Case WHERE Id = :cases[0].Id];
            Test.stopTest();

            System.assertEquals(1, qualtricsSurveyList.size(), ' No Qualtrics Survey record created.');
            System.assertEquals(caseListUpdated[0].Qualtrics_Survey__c, qualtricsSurveyList[0].Id, ' No Qualtrics Survey record created.');
        } 
    }
}