/**
 * @description Mock DAO Class for Qualtrics Survey Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                              |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------|
      | arsenio.jr.dayrit              |  May 20, 2024         | DEPP-8821              | Created file                                                |
 */
@isTest
public inherited sharing class QualtricsSurveysDAOMock extends DmlBaseMock implements IQualtricsSurveysDAO {
    public Map<Id, Qualtrics_Survey__c> qualtricsSurveyMap;

    public Schema.SObjectType getSObjectType() {
        return Qualtrics_Survey__c.SObjectType;
    }

    public QualtricsSurveysDAOMock() {
        super(new Map<Id, Qualtrics_Survey__c>(), Schema.Qualtrics_Survey__c.SObjectType);
        this.qualtricsSurveyMap = (Map<Id, Qualtrics_Survey__c>) super.records;
    }

    public List<Qualtrics_Survey__c> getQualitricsSurveysBySetIds(
        Set<Id> qualtricSurveyId,
        AccessLevel accessLevel
    ) {
        List<Qualtrics_Survey__c> qualtricsSurveyList = new List<Qualtrics_Survey__c>();

        for (Qualtrics_Survey__c record : qualtricsSurveyMap.values()) {
            if (qualtricSurveyId.contains(record.Id)) {
                qualtricsSurveyList.add(record);
            }
        }
        return qualtricsSurveyList;
    }


    public List<Qualtrics_Survey__c> getQualitricsSurveysByOwnerId(
        Set<Id> ownerId,
        AccessLevel accessLevel
    ) {
        List<Qualtrics_Survey__c> qualtricsSurveyList = new List<Qualtrics_Survey__c>();

        for (Qualtrics_Survey__c record : qualtricsSurveyMap.values()) {
            if (ownerId.contains(record.OwnerId)) {
                qualtricsSurveyList.add(record);
            }
        }
        return qualtricsSurveyList;
    }

} 
