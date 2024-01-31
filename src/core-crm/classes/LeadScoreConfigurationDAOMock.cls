/**
 * @description Mock DAO Class for Nurture Track Configuration Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | neil.s.h.lesidan               | August 30, 2023       | DEPP-5835              | Created file                 |
      | eccarius.munoz                 | October 05, 2023      | DEPP-5866              | Added getLeadScoreConfig     |
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

    public List<Lead_Score_Configuration__c> getLeadScoreConfigsById(
        Set<Id> leadScoreConfigIds, 
        List<String> fields, 
        AccessLevel accessLevel
    ) {
        List<Lead_Score_Configuration__c> leadScoreConfigList = new List<Lead_Score_Configuration__c>();

        for (Lead_Score_Configuration__c record : leadScoreConfiguration.values()) {
            if (leadScoreConfigIds.contains(record.Id)) {
                leadScoreConfigList.add(record);
            }
        }

        return leadScoreConfigList;
    }

    public List<Lead_Score_Configuration__c> getLeadScoreConfigByRecordTypeIds(AccessLevel accessLevel, Set<Id> recordTypes) {
        List<Lead_Score_Configuration__c> leadScoreConfigList = new List<Lead_Score_Configuration__c>();

        for (Lead_Score_Configuration__c record : leadScoreConfiguration.values()) {
            String leadScoreConfigString = '';
            Lead_Score_Configuration__c leadScoreConfigTemp = new Lead_Score_Configuration__c();

            if(record.Parent_Category__c != null && recordTypes.contains(record.RecordTypeId)){
                
                //construct JSON record with parent inner fields
                leadScoreConfigString = '{"attributes":{"type":"Lead_Score_Configuration__c","url":"/services/data/v56.0/sobjects/Lead_Score_Configuration__c/'+record.Id+'"},' +
                '"Id":"'+record.Id+'","CreatedDate":"'+String.valueOf(System.today())+'","Parent_Category__c":"'+record.Parent_Category__c+'",'+
                '"Parent_Category__r":'+JSON.serialize(leadScoreConfiguration.get(record.Parent_Category__c))+'}';

                leadScoreConfigTemp = (Lead_Score_Configuration__c)JSON.deserialize(leadScoreConfigString,Lead_Score_Configuration__c.class);
                leadScoreConfigTemp.Name = record.Name;
                leadScoreConfigTemp.RecordTypeId = record.RecordTypeId;
                leadScoreConfigTemp.Domestic_International__c = record.Domestic_International__c;
                leadScoreConfigTemp.Study_Level__c = record.Study_Level__c;
                leadScoreConfigTemp.Description__c = record.Description__c;
                leadScoreConfigTemp.Score_Allocation__c = record.Score_Allocation__c;
                leadScoreConfigTemp.Time_Limit_Months__c = record.Time_Limit_Months__c;
                leadScoreConfigTemp.Max_Score__c = record.Max_Score__c;
                leadScoreConfigList.add(leadScoreConfigTemp);

            }else if(recordTypes.contains(record.RecordTypeId)){
                leadScoreConfigList.add(record);
            }
        }

        return leadScoreConfigList;
    }

    public Database.QueryLocator queryLocatorLeadScoreConfigByIds(Set<Id> leadScoreConfigIds) {
        return null;
    }

    public List<Lead_Score_Configuration__c> getCategoryLeadScoreConfigsById(
        Set<Id> leadScoreConfigIds, 
        List<String> fields, 
        AccessLevel accessLevel
    ) {
        List<Lead_Score_Configuration__c> leadScoreConfigList = new List<Lead_Score_Configuration__c>();
        for (Lead_Score_Configuration__c record : leadScoreConfiguration.values()) {
            if (leadScoreConfigIds.contains(record.Id)) {
                leadScoreConfigList.add(record);
            }
        }
        return leadScoreConfigList;
    }

} 