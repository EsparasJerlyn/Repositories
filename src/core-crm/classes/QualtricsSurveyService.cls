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

    public static void enqueueQualtricsSurveyToProcess(List<Case> caseList) {
        Map<Id,Qualtrics_Survey__c> qualtricMap = new Map<Id,Qualtrics_Survey__c>();

        for(Case caseRec : caseList){
            if(!String.isBlank(caseRec.Engagement_List_Configuration__r.Qualtrics_Instrument_Id__c) && caseRec.Qualtrics_Survey__c == null){
                Qualtrics_Survey__c qualtricsSurvey = new Qualtrics_Survey__c();
                qualtricMap.put(caseRec.Id,qualtricsSurvey);
            }
        }
        QualtricsSurveysDAO.newInstance().insertRecords(qualtricMap.values(), false, AccessLevel.SYSTEM_MODE);
        
        If(!qualtricMap.values().isEmpty()){
            updateCaseQualtricsSurvey(qualtricMap);
        }
    }

    private static void updateCaseQualtricsSurvey(Map<Id,Qualtrics_Survey__c> qualtricMap){
        List<Case> caseToUpdate = new List<Case>();
        List<Case> caseList = CasesDAO.newInstance().getCasesByIds(qualtricMap.keySet(), accessLevel.SYSTEM_MODE);
        For(Case cases : caseList){
            if(qualtricMap.containsKey(cases.Id)){
                cases.Qualtrics_Survey__c = qualtricMap.get(cases.Id).Id;
                caseToUpdate.add(cases);
            }
        }
        CasesDAO.newInstance().updateRecords(caseToUpdate, false, AccessLevel.SYSTEM_MODE);
    }

    public static void updateQualtricsSurveyInfo(List<Qualtrics_Survey__c> newItems){

        //requestForQualtricsSurveyInfo(newItems)
    }
}