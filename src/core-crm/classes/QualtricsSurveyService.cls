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
 *    | eugene.andrew.abuan            | May 22, 2024          | DEPP-8822              | Added process for after update|
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
        QualtricsSurveysDAO.newInstance().insertRecords(qualtricsSurveyMap.values(), false, AccessLevel.USER_MODE);
        
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

    /**
   * @description method that will call the queueable class when the In Progress Survey URL has been populated
   * @param newList - List of new Qualtrics_Survey__c
   * @param oldMap - Map of Qualtrics_Survey__c.Trigger.old
   * return void
   */
    public static void checkInProgressSurveyURL(List<Qualtrics_Survey__c> newList , Map<Id , Qualtrics_Survey__c> oldMap ){
        
        List<Qualtrics_Survey__c> qualtricsSurveyList = new List<Qualtrics_Survey__c>();

        for(Qualtrics_Survey__c qs : newList ){

            Qualtrics_Survey__c oldQs = oldMap.get(qs.Id);
            // Check if In_Progress_Survey_URL__c field is populated and was not previously populated
            if(String.isNotBlank(qs.In_Progress_Survey_URL__c) && String.isBlank(oldQs.In_Progress_Survey_URL__c)){
                qualtricsSurveyList.add(qs);
            }
        }

        if(!qualtricsSurveyList.isEmpty()){
            QualtricsSurveyCalloutQueuable executeQueueable = new QualtricsSurveyCalloutQueuable(qualtricsSurveyList , 'checkInProgressSurveyURL');
            System.enqueueJob(executeQueueable);
        }
    }

}