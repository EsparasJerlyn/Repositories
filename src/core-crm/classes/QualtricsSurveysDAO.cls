/**
 * @description DAO Class for Qualtrics Survey Object. Contains soql and constants related to the Qualtrics Survey object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | arsenio.jr.dayrit              |  May 20, 2024         | DEPP-8821              | Created file                 |
 */

 public inherited sharing class QualtricsSurveysDAO extends DmlBase implements IQualtricsSurveysDAO {
    
    public static final String SURVEY_STATUS_SENT = 'Sent';

    public Schema.SObjectType getSObjectType() {
        return Qualtrics_Survey__c.SObjectType;
    }

    public static IQualtricsSurveysDAO newInstance() {
        return (IQualtricsSurveysDAO) ImplementationSelector.DAO.newInstance(Qualtrics_Survey__c.SObjectType);
    }

    public static List<Qualtrics_Survey__c> getQualitricsSurveysBySetIds(Set<Id> qualtricSurveyId, AccessLevel accessLevel) {

        if(qualtricSurveyId.isEmpty()){
            return new List<Qualtrics_Survey__c>();
        }

        return Database.query(
            'SELECT Id, ' +
            'In_Progress_Survey_URL__c, ' +
            'Distribution_List__c ' +
            'FROM Qualtrics_Survey__c ' +
            'WHERE Id IN: qualtricSurveyId' ,
            accessLevel
        );
    }

    public static List<Qualtrics_Survey__c> getQualitricsSurveysByOwnerId(Set<Id> ownerId, AccessLevel accessLevel) {

        if(ownerId.isEmpty()){
            return new List<Qualtrics_Survey__c>();
        }

        return Database.query(
            'SELECT Id, ' +
            'In_Progress_Survey_URL__c, ' +
            'Distribution_List__c ' +
            'FROM Qualtrics_Survey__c ' +
            'WHERE OwnerId IN: ownerId' ,
            accessLevel
        );
    }
    
}