/**
 * @description Controller Class for setupRegistration LWC
 *
 * @see ../lwc/setupRegistration
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                   |
      |---------------------------|-----------------------|----------------------|-----------------------------    -|
      | angelika.j.s.galang       | January 21, 2022      | DEPP-1396            | Created file                     |
      | john.bo.a.pineda          | February 02, 2022     | DEPP-1532            | Update Answer to Related Answer  |
      |                           |                       |                      |                                  |
 */
public with sharing class SetupRegistrationCtrl {
  /**
   * @description queries questions, answers, and questionnaire for registration
   * @param productRequestId - id of product request
   * @return registrationDataList - questions, answers, and questionnaire lists wrapped
   */
  @AuraEnabled(cacheable=true)
  public static RegistrationData getRegistrationData(String productRequestId) {
    RegistrationData registrationDataList = new RegistrationData();
    registrationDataList.questionList = new List<Question__c>(
      [
        SELECT
          Id,
          Dropdown_Options__c,
          Label__c,
          Mandatory_Response__c,
          Message__c,
          Type__c,
          (
            SELECT Id, Name, Question__c, Questionnaire__c, Sequence__c
            FROM Related_Answers__r
          )
        FROM Question__c
      ]
    );
    registrationDataList.questionnaireList = new List<Questionnaire__c>(
      [
        SELECT Id, Name, Questionnaire_Type__c
        FROM Questionnaire__c
        WHERE Parent_Record_ID__c = :productRequestId
      ]
    );
    return registrationDataList;
  }

  /**
   * @description gets custom layout from metadata
   * @param objApiName - api name of object
   * @param forOpe - specifies if layout if for OPE
   * @return layout metadata
   */
  @AuraEnabled(cacheable=true)
  public static List<Field_Layout_Setting__mdt> getQuestionLayout(
    String objApiName,
    Boolean forOpe
  ) {
    return CustomCreateEditRecordCtrl.getLayoutMapping(objApiName, forOpe);
  }

  /**
   * @description updates list of answers
   * @param answers - list of answers
   */
  @AuraEnabled
  public static void updateAnswerSequences(List<Related_Answer__c> answers) {
    if (!answers.isEmpty()) {
      update answers;
    }
  }

  /**
   * @description wrapper that contains the list of questions, answers and questionnaires
   */
  public class RegistrationData {
    @AuraEnabled
    public List<Question__c> questionList;
    @AuraEnabled
    public List<Questionnaire__c> questionnaireList;
  }
}
