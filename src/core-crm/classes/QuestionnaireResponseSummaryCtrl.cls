/**
 * @description Retrieve Questionnaire Response Summary Details
 *
 * @see ../lwc/questionnaireResponseSummary
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | john.bo.a.pineda          | March 14, 2022        | DEPP-1643            | Created file                 |
      |                           |                       |                      |                              |
 */
public with sharing class QuestionnaireResponseSummaryCtrl {
  /**
   * @description Method to check if Email exists
   * @param qrsId - Questionare Response Summary Id
   * @return QuestionnaireResponseSummaryWrapper - returns Questionare Response Summary Details
   */
  @AuraEnabled(cacheable=true)
  public static QuestionnaireResponseSummaryWrapper getQuestionnaireResponseSummaryDetails(
    String qrsId
  ) {
    QuestionnaireResponseSummaryWrapper wrapper = new QuestionnaireResponseSummaryWrapper();

    if (String.isNotBlank(qrsId)) {
      Questionnaire_Response_Summary__c qrs = [
        SELECT
          Id,
          Contact__c,
          Contact__r.Name,
          Application_Status__c,
          Registration_Status__c,
          Questionnaire__r.Questionnaire_Type__c,
          Questionnaire__r.Parent_Record_ID__c
        FROM Questionnaire_Response_Summary__c
        WHERE Id = :qrsId 
        LIMIT 1
      ];

      Id prId = qrs.Questionnaire__r.Parent_Record_ID__c;
      hed__Course__c courseProduct = [
        SELECT Id, Name
        FROM hed__Course__c
        WHERE ProductRequestID__c = :prId
        LIMIT 1
      ];

      wrapper.qrsType = qrs.Questionnaire__r.Questionnaire_Type__c;
      if (String.isNotBlank(qrs.Questionnaire__r.Parent_Record_ID__c)) {
        wrapper.qrsProduct = courseProduct.Name;
        wrapper.qrsProductURL = '/' + qrs.Questionnaire__r.Parent_Record_ID__c;
      }
      if (String.isNotBlank(qrs.Contact__c)) {
        wrapper.qrsContact = qrs.Contact__r.Name;
        wrapper.qrsContactURL = '/' + qrs.Contact__c;
      }
      if (
        qrs.Questionnaire__r.Questionnaire_Type__c == 'Application Questions'
      ) {
        wrapper.qrsStatus = qrs.Application_Status__c;
      } else if (
        qrs.Questionnaire__r.Questionnaire_Type__c == 'Registration Questions'
      ) {
        wrapper.qrsStatus = qrs.Registration_Status__c;
      } else {
        wrapper.qrsStatus = qrs.Registration_Status__c;
      }

      List<Answer__c> ansList = [
        SELECT
          Id,
          Related_Answer__r.Question__c,
          Related_Answer__r.Question__r.Label__c,
          Related_Answer__r.Question__r.Type__c,
          Response__c,
          Related_Answer__r.Sequence__c
        FROM Answer__c
        WHERE Questionnaire_Response_Summary__c = :qrsId
        ORDER BY Related_Answer__r.Sequence__c ASC
      ];

      List<QuestionAnswerWrapper> qaWrapperList = new List<QuestionAnswerWrapper>();
      if (ansList.size() > 0) {
        for (Answer__c ans : ansList) {
          QuestionAnswerWrapper qaWrapper = new QuestionAnswerWrapper();
          qaWrapper.qId = ans.Related_Answer__r.Question__c;
          qaWrapper.question = ans.Related_Answer__r.Question__r.Label__c;
          qaWrapper.aId = ans.Id;
          if(ans.Related_Answer__r.Question__r.Type__c == 'File Upload'){
            qaWrapper.answer = '/' + ans.Response__c;
            qaWrapper.isFile = true;
          }else{
            qaWrapper.answer = ans.Response__c;
            qaWrapper.isFile = false;
          }
          qaWrapper.qaSequence = String.valueOf(
            ans.Related_Answer__r.Sequence__c
          );
          qaWrapperList.add(qaWrapper);
        }
      }

      if (qaWrapperList.size() > 0) {
        wrapper.qaList = qaWrapperList;
      }
    }

    return wrapper;
  }

  /**
   * @description Method to update Query Response Summary Application Status
   * @param qrsId - Questionare Response Summary Id
   * @param qrsStatus - Questionare Response Summary Application Status value
   */
  @AuraEnabled(cacheable=false)
  public static void updateApplicationStatus(String qrsId, String qrsStatus) {
    if (String.isNotBlank(qrsId)) {
      Questionnaire_Response_Summary__c qrs = [
        SELECT Id, Application_Status__c
        FROM Questionnaire_Response_Summary__c
        WHERE Id = :qrsId
        LIMIT 1
      ];

      if (qrs.Application_Status__c == 'Pending') {
        qrs.Application_Status__c = qrsStatus;

        try {
          update qrs;
        } catch (Exception e) {
          System.debug(LoggingLevel.WARN, 'updateApplicationStatus ERROR: ' + e.getMessage());//NOPMD
        }
      }
    }
  }

  /**
   * @description wrapper that contains the Quesionnaire Response Summary list
   */
  public class QuestionnaireResponseSummaryWrapper {
    @AuraEnabled
    public String qrsType;
    @AuraEnabled
    public String qrsProduct;
    @AuraEnabled
    public String qrsProductURL;
    @AuraEnabled
    public String qrsContact;
    @AuraEnabled
    public String qrsContactURL;
    @AuraEnabled
    public String qrsStatus;
    @AuraEnabled
    public List<QuestionAnswerWrapper> qaList;
  }

  /**
   * @description wrapper that contains the Quesionnaire Response Summary Question & Answers
   */
  public class QuestionAnswerWrapper {
    @AuraEnabled
    public String qId;
    @AuraEnabled
    public String question;
    @AuraEnabled
    public String aId;
    @AuraEnabled
    public String answer;
    @AuraEnabled
    public Boolean isFile;
    @AuraEnabled
    public String qaSequence;
  }
}
