/**
 * @description Mock DAO Class for Lead_Score_Detail__c object
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary                      |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------------|
 *    | julie.jane.alegre              | August 31, 2023       |DEPP-5965               | Created File                        |
 *    | eccarius.munoz                 | October 04, 2023      |DEPP-5866               | Added method to get by con/lead     |
 */
@isTest
public inherited sharing class LeadScoreDetailsDAOMock extends DmlBaseMock implements ILeadScoreDetailsDAO{
    public Map<Id, Lead_Score_Detail__c> leadScoreDetailsMap;

    public LeadScoreDetailsDAOMock() {
        super(new Map<Id, Lead_Score_Detail__c>(), Schema.Lead_Score_Detail__c.SObjectType);
        this.leadScoreDetailsMap = (Map<Id, Lead_Score_Detail__c>) super.records;
    }

    public Schema.SObjectType getSObjectType() {
        return Lead_Score_Detail__c.SObjectType;
    }

    public List<Lead_Score_Detail__c> getLeadScoreDetailWithLimit(
        Integer recordsCount
    ) {
        List<Lead_Score_Detail__c> leadScoreDetailList = new List<Lead_Score_Detail__c>();
        for (Lead_Score_Detail__c record : leadScoreDetailsMap.values()) {
            leadScoreDetailList.add(record);
            if (leadScoreDetailList.size() == recordsCount) {
                break;
            }
        }
        return leadScoreDetailList;
    }

    public List<Lead_Score_Detail__c> getLeadScoreDetailsByCitizenshipAndStudyLevel(
        Set<String> citizenshipStatusSet,
        Set<String> primaryStudyLevelSet,
        AccessLevel accessLevel
    ) {
        List<Lead_Score_Detail__c> leadScoreDetailList = new List<Lead_Score_Detail__c>();

        for (Lead_Score_Detail__c record : leadScoreDetailsMap.values()) {
            if (
                citizenshipStatusSet.contains(record.Domestic_International__c) ||
                primaryStudyLevelSet.contains(record.Study_Level__c)
            ) {
                leadScoreDetailList.add(record);
            }
        }

        return leadScoreDetailList;
    }

    public List<Lead_Score_Detail__c> getLeadScoreDetailsByContactOrLeadId(
        Set<Id> contactLeadIdSet,
        AccessLevel accessLevel
    ) {
        List<Lead_Score_Detail__c> leadScoreDetailList = new List<Lead_Score_Detail__c>();

        for (Lead_Score_Detail__c record : leadScoreDetailsMap.values()) {
            if (
                contactLeadIdSet.contains(record.Lead__c) ||
                contactLeadIdSet.contains(record.Contact__c)
            ) {
                leadScoreDetailList.add(record);
            }
        }

        return leadScoreDetailList;
    }

    public Database.QueryLocator getLeadScoreDetailsWithContactOrLead() {
        return null;
    }
    
}
