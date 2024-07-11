/**
 * @description Interface for Qualtrics Survey DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | arsenio.jr.dayrit              | May 20, 2024          | DEPP-8821              | Created file
      | eugene.andrew.abuan            | May 24, 2024          | DEPP-8822              | Added getQSByOwnerId          |
 */
public interface IQualtricsSurveysDAO extends DmlInterface {
     List<Qualtrics_Survey__c> getQualitricsSurveysBySetIds(Set<Id> qualtricSurveyId, AccessLevel accessLevel);
     List<Qualtrics_Survey__c> getQualitricsSurveysByOwnerId(Set<Id> ownerId, AccessLevel accessLevel);
}