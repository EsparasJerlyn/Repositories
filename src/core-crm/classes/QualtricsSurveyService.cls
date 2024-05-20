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
        List<Qualtrics_Survey__c> qualtricList = new List<Qualtrics_Survey__c>();

        for(Case caseRec : caseList){
            if(!String.isBlank(caseRec.Engagement_List_Configuration__r.Qualtrics_Instrument_Id__c)){
                Qualtrics_Survey__c qualtricsSurvey = new Qualtrics_Survey__c();
                qualtricsSurvey.Case__c = caseRec.Id;
                qualtricList.add(qualtricsSurvey);
            }
        }
        QualtricsSurveysDAO.newInstance().insertRecords(qualtricList, false, AccessLevel.SYSTEM_MODE);
    }
}