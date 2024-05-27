/**
 * @description Interface for Qualtrics Survey DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | arsenio.jr.dayrit              | May 20, 2024          | DEPP-8821              | Created file
 */
public interface IQualtricsSurveysDAO extends DmlInterface {
     List<Qualtrics_Survey__c> getQualitricsSurveysBySetIds(Set<Id> qualtricSurveyId, AccessLevel accessLevel);
}