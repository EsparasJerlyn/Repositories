/**
 * @description Mock DAO Class for Marketing Interaction Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                       |
      |--------------------------------|-----------------------|------------------------|------------------------------------------------------|
      | julie.jane.alegre              | September 18, 2023    | DEPP-6667              | Created file                                         |
 */
@isTest
public inherited sharing class MarketingInteractionsDAOMock extends DmlBaseMock implements IMarketingInteractionsDAO{
    public Map<Id, Marketing_Interaction__c> marketingInteractionMap;

    public Schema.SObjectType getSObjectType() {
        return Marketing_Interaction__c.SObjectType;
    }

    public MarketingInteractionsDAOMock() {
        super(new Map<Id, Marketing_Interaction__c>(), Schema.Marketing_Interaction__c.SObjectType);
        this.marketingInteractionMap = (Map<Id, Marketing_Interaction__c>) super.records;
    }

    public List<Marketing_Interaction__c> getMarketingInteractionByApplicantIds(
        Set<Id> applicantIds,
        AccessLevel accessLevel
    ) {
        List<Marketing_Interaction__c> marketingInteractionList = new List<Marketing_Interaction__c>();
        for (Marketing_Interaction__c record : marketingInteractionMap.values()) {
            if (applicantIds.contains(record.Contact__c)){
                marketingInteractionList.add(record);
            }
        }
        return marketingInteractionList;
    }

    public List<Marketing_Interaction__c> getMarketingInteractionsByContactOrLeadIds(
        Set<Id> recordIds,
        AccessLevel accessLevel
    ) {
        List<Marketing_Interaction__c> marketingInteractionList = new List<Marketing_Interaction__c>();
        for (Marketing_Interaction__c record : marketingInteractionMap.values()) {
            if(recordIds.contains(record.Contact__c) || recordIds.contains(record.Lead__c)){
                marketingInteractionList.add(record);
            }
        }
        return marketingInteractionList;
    }

    public Database.QueryLocator queryLocatorGetMarketingInteractionsByContactOrLeadIds(
        Set<Id> recordIds
    ){
        return null;
    }

}
