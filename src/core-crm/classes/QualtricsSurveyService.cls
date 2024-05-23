/**
 * @description Service Class for QualtricsSurveyService class
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
public with sharing class QualtricsSurveyService {
    public static Boolean doQueueableJob = true;
    public static void enqueueQualtricsSurveyToProcess(List<Case> caseList) {
        Map<Id,Qualtrics_Survey__c> qualtricsSurveyMap = new Map<Id,Qualtrics_Survey__c>();

        for(Case caseRec : caseList){
            if(caseRec.Qualtrics_Survey__c == null){
                Qualtrics_Survey__c qualtricsSurvey = new Qualtrics_Survey__c();
                qualtricsSurveyMap.put(caseRec.Id,qualtricsSurvey);
            }
        }
        QualtricsSurveysDAO.newInstance().insertRecords(qualtricsSurveyMap.values(), false, AccessLevel.SYSTEM_MODE);
        
        If(!qualtricsSurveyMap.values().isEmpty()){
            updateCaseQualtricsSurvey(qualtricsSurveyMap);
        }
    }

    private static void updateCaseQualtricsSurvey(Map<Id,Qualtrics_Survey__c> qualtricsSurveyMap){
        List<Case> caseToUpdate = new List<Case>();
        List<Case> caseList = CasesDAO.newInstance().getCasesByIds(qualtricsSurveyMap.keySet(), accessLevel.SYSTEM_MODE);
        For(Case cases : caseList){
            if(qualtricsSurveyMap.containsKey(cases.Id)){
                cases.Qualtrics_Survey__c = qualtricsSurveyMap.get(cases.Id).Id;
                caseToUpdate.add(cases);
            }
        }
        CasesDAO.newInstance().updateRecords(caseToUpdate, false, AccessLevel.SYSTEM_MODE);
        if(doQueueableJob){
            QualtricsSurveyCalloutQueuable queueableCalls = new QualtricsSurveyCalloutQueuable(qualtricsSurveyMap.values(),'QualtricsSurveyService');
            System.enqueueJob(queueableCalls);
        }
    }

    public static void requestForQualtricsSurveyInfo(List<Qualtrics_Survey__c> qualtricsSurvey){

    }
}