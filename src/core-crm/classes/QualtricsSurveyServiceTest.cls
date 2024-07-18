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
 *    | eugene.andrew.abuan            | May 24, 2024          | DEPP-8822              | Added In_Progress_URL test    |
 *    | eccarius.munoz                 | May 28,2024           | DEPP-8840	            | Added test method for callout |
 */
@isTest
private class QualtricsSurveyServiceTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserStudentSuccessOutreachManager();
    }

    @isTest
    private static void enqueueQualtricsSurveyToProcessTest() {
        System.runAs(TestDataFactoryUser.selectUserStudentSuccessOutreachManager) {
            Test.startTest();
            String qualtricInstrumentId = 'test';
            List<Engagement_List_Configuration__c> elcList = new List<Engagement_List_Configuration__c>();
            Engagement_List_Configuration__c elcRec = new Engagement_List_Configuration__c();
            elcRec.Qualtrics_Instrument_Id__c = qualtricInstrumentId;
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
            
            QualtricsSurveyService.enqueueQualtricsSurveyToProcess(caseList);
            List<Case> caseListUpdated = CasesDAO.newInstance().getCasesByIds(new Set<Id>{cases[0].Id},AccessLevel.SYSTEM_MODE);
            Test.stopTest();
            System.assert(!String.isBlank(caseListUpdated[0].Qualtrics_Survey__c), ' No Qualtrics Survey record created.');
            System.Assert.areEqual(qualtricInstrumentId, caseListUpdated[0].Engagement_List_Configuration__r.Qualtrics_Instrument_Id__c, 'Qualtrics Instrument must be populated.');
            
        } 
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records.
    // With this, user access cannot be tested
    private static void checkInProgressSurveyURLPositive(){

        ImplementationSelector.DAO.setMock(new QualtricsSurveysDAOMock());

        List<Qualtrics_Survey__c> qualtricsSurveyInsert = TestDataFactory.createQualtricsSurveyRecord(100);
        QualtricsSurveysDAO.newInstance().insertRecords(qualtricsSurveyInsert, false, AccessLevel.SYSTEM_MODE);
        
        
        List<Qualtrics_Survey__c> newList = new List<Qualtrics_Survey__c>();
        for(Qualtrics_Survey__c qs : qualtricsSurveyInsert){
            Qualtrics_Survey__c qsNew = new Qualtrics_Survey__c();
            qsNew.Id = qs.Id;
            qsNew.In_Progress_Survey_URL__c = 'test URL';
            newList.add(qsNew);
        }

        Map <Id, Qualtrics_Survey__c> oldMap = new Map<Id, Qualtrics_Survey__c>(qualtricsSurveyInsert);

        Test.startTest();
        QualtricsSurveyService.checkInProgressSurveyURL(newList, oldMap);
        Test.stopTest();

        AsyncApexJob jobs = AsyncApexJobsDAO.newInstance().findAsyncApexJobByApexName('QualtricsSurveyCalloutQueuable' ,AccessLevel.SYSTEM_MODE);

        System.assertEquals('QualtricsSurveyCalloutQueuable', jobs.ApexClass.Name , 'QualtricsSurveyCalloutQueuable job should run');
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records.
    // With this, user access cannot be tested
    private static void checkInProgressSurveyURLNegative(){

        ImplementationSelector.DAO.setMock(new QualtricsSurveysDAOMock());

        List<Qualtrics_Survey__c> qualtricsSurveyInsert = TestDataFactory.createQualtricsSurveyRecord(100);
        QualtricsSurveysDAO.newInstance().insertRecords(qualtricsSurveyInsert, false, AccessLevel.SYSTEM_MODE);
        
        
        List<Qualtrics_Survey__c> newList = new List<Qualtrics_Survey__c>();
        for(Qualtrics_Survey__c qs : qualtricsSurveyInsert){
            Qualtrics_Survey__c qsNew = new Qualtrics_Survey__c();
            qsNew.Id = qs.Id;
            qs.In_Progress_Survey_URL__c = 'test URL';
            qsNew.In_Progress_Survey_URL__c = 'test URL Update';
            newList.add(qsNew);
        }

        Map <Id, Qualtrics_Survey__c> oldMap = new Map<Id, Qualtrics_Survey__c>(qualtricsSurveyInsert);

        Test.startTest();
        QualtricsSurveyService.checkInProgressSurveyURL(newList, oldMap);
        Test.stopTest();

        AsyncApexJob jobs = AsyncApexJobsDAO.newInstance().findAsyncApexJobByApexName('QualtricsSurveyCalloutQueuable' ,AccessLevel.SYSTEM_MODE);

        System.assertEquals(null, jobs , 'QualtricsSurveyCalloutQueuable job should not run');
    }

    @isTest
    private static void requestForQualtricsSurveyInfoTest(){        
        
        Boolean hasError = false;
        String errorMessage;

        System.runAs(TestDataFactoryUser.selectUserStudentSuccessOutreachManager){

            ImplementationSelector.DAO.setMock(new QualtricsSurveysDAOMock());

            List<Qualtrics_Survey__c> qualtricSurveyList = new List<Qualtrics_Survey__c>();
            qualtricSurveyList.add(new Qualtrics_Survey__c());
            qualtricSurveyList.add(new Qualtrics_Survey__c());
            QualtricsSurveysDAO.newInstance().insertRecords(qualtricSurveyList, true, AccessLevel.SYSTEM_MODE);
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new ESBProcessSurveyDistributionMock());
            try{

                QualtricsSurveyService.requestForQualtricsSurveyInfo(qualtricSurveyList);
                
            }catch(Exception e){
                hasError = true;
                errorMessage = e.getMessage();
            }
            Test.stopTest();
        }
        
        System.assert(!hasError, 'Error in call out : ' + errorMessage);
    }
}