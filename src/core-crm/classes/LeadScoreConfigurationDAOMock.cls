/**
 * @description Mock DAO Class for Nurture Track Configuration Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | neil.s.h.lesidan               | August 30, 2023       | DEPP-5835              | Created file                 |
 */
@isTest
public inherited sharing class LeadScoreConfigurationDAOMock extends DmlBaseMock implements ILeadScoreConfigurationDAO {
    public Map<Id, Lead_Score_Configuration__c> leadScoreConfiguration;

    public LeadScoreConfigurationDAOMock() {
        super(new Map<Id, Lead_Score_Configuration__c>(), Schema.Lead_Score_Configuration__c.SObjectType);
        this.leadScoreConfiguration = (Map<Id, Lead_Score_Configuration__c>) super.records;
    }

    public Schema.SObjectType getSObjectType() {
        return Lead_Score_Configuration__c.SObjectType;
    }

    public List<Lead_Score_Configuration__c> getLeadScoreConfigByCitizenshipStudyLvl(
        String citizenshipStatus,
        String primaryStudyLevel
    ) {
        List<Lead_Score_Configuration__c> leadScoreConfigList = new List<Lead_Score_Configuration__c>();

        for (Lead_Score_Configuration__c record : leadScoreConfiguration.values()) {
            if (record.Domestic_International__c == citizenshipStatus &&
                record.Study_Level__c == primaryStudyLevel)
            {
                leadScoreConfigList.add(record);
            }
        }

        return leadScoreConfigList;
    }

}