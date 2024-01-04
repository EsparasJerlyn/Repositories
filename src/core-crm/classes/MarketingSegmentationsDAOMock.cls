/* @description  Mock DAO Class for Marketing Segmentation 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                     |
      |--------------------------------|-----------------------|------------------------|----------------------------------------------------|
      | julie.jane.alegre              | Sept 14, 2023         | DEPP-6679              | Created file                                       |
      | johanna.a.gibas                | Jan 04, 2024          | ApexCRUDViolationFix   | Added method for getExistingMarketingSegmentations |
 */
@isTest
public inherited sharing  class MarketingSegmentationsDAOMock extends DmlBaseMock implements IMarketingSegmentationsDAO{
    public Map<Id, Marketing_Segmentation__c> marketingSegmentationMap;

    public Schema.SObjectType getSObjectType() {
        return Marketing_Segmentation__c.SObjectType;
    }

    public MarketingSegmentationsDAOMock() {
        super(new Map<Id, Marketing_Segmentation__c>(), Schema.Marketing_Segmentation__c.SObjectType);
        this.marketingSegmentationMap = (Map<Id, Marketing_Segmentation__c>) super.records;
    }

    public List<Marketing_Segmentation__c> getMarketingSegmentationByContactIds(
        Set<Id> contactIds,
        AccessLevel accessLevel
    ) {
        List<Marketing_Segmentation__c> marketingSegmentationList = new List<Marketing_Segmentation__c>();

        for (Marketing_Segmentation__c record : marketingSegmentationMap.values()) {
            if (contactIds.contains(record.Contact__c)) {
                marketingSegmentationList.add(record);
            }
        }

        return marketingSegmentationList;
    }

    public List<Marketing_Segmentation__c> getMarketingSegmentationByLeadIds(
        Set<Id> leadIds,
        AccessLevel accessLevel
    ) {
        List<Marketing_Segmentation__c> marketingSegmentationList = new List<Marketing_Segmentation__c>();

        for (Marketing_Segmentation__c record : marketingSegmentationMap.values()) {
            if (leadIds.contains(record.Lead__c)) {
                marketingSegmentationList.add(record);
            }
        }

        return marketingSegmentationList;
    }

    public List<Marketing_Segmentation__c> getMarketingSegmentationByContactOrLead(
        Set<Id> contactIdSet, 
        Set<Id> leadIdSet,
        AccessLevel accessLevel
    ) {
        List<Marketing_Segmentation__c> marketingSegmentationList = new List<Marketing_Segmentation__c>();

        for (Marketing_Segmentation__c record : marketingSegmentationMap.values()) {
            if (leadIdSet.contains(record.Lead__c)) {
                marketingSegmentationList.add(record);
            }
            if (contactIdSet.contains(record.Contact__c)) {
                marketingSegmentationList.add(record);
            }
        }

        return marketingSegmentationList;
    }  

    public List<Marketing_Segmentation__c> getLinkedMarketingSegByContactOrLeadIds(
        Set<Id> recordIds,
        AccessLevel accessLevel
    ) {
        List<Marketing_Segmentation__c> msList = new List<Marketing_Segmentation__c>();
        for(Marketing_Segmentation__c ms : marketingSegmentationMap.values()) {
            if(recordIds.contains(ms.Contact__c) || recordIds.contains(ms.Lead__c)) {
                msList.add(ms);
            }
        }
        return msList;
    }

    public Database.QueryLocator queryLocatorGetMarketingSegmentationsByContactOrLeadIds(
        Set<Id> recordIds
    ){
        return null;
    }

    public List<Marketing_Segmentation__c> getExistingMarketingSegmentations(
        Map<String, Contact> emailToContactMap,
        AccessLevel accessLevel
    ) {
        List<Marketing_Segmentation__c> marketingSegmentationsList = new List<Marketing_Segmentation__c>();
        for (Marketing_Segmentation__c record : marketingSegmentationMap.values()) {
            if (emailToContactMap.containsKey(record.Contact__r.Email) || 
                emailToContactMap.containsKey(record.Contact__r.Work_Email__c) || 
                emailToContactMap.containsKey(record.Contact__r.QUT_Staff_Email__c) || 
                emailToContactMap.containsKey(record.Contact__r.QUT_Learner_Email__c)
                ){
                marketingSegmentationsList.add(record);
            }
        }
        return marketingSegmentationsList;
    }

}