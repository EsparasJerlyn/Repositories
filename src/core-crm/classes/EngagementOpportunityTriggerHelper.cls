/**
 * @description helper class for EngagementOpportunityTriggerHelper
 * @see EngagementOpportunityTriggerHelper
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                           |
 *    |--------------------------------|-----------------------|------------------------|----------------------------------------------------------|
 *    | nicole.genon                   | December 18, 2023     | DEPP-6949              | Created file                                             |
 */
public with sharing class EngagementOpportunityTriggerHelper {

    /**
     * @description Create List__c record based on newly created Engagement_Opportunity__c
     *
     * @param newItems  List of new Engagement Opportunity records
     */
    public static void createListRecordOnEngagementOpportunityCreation(List<Engagement_Opportunity__c> newItems) {

        List<List__c> listRecords = new List<List__c>();

        for(Engagement_Opportunity__c rec : newItems){
            List__c newList = new List__c();
            newList.Engagement_Opportunity__c = rec.Id;
            newList.RecordTypeId = ListsDAO.ENGAGEMENT_OPPORTUNITY_RECTYPE_ID;
            newList.List_Name__c = rec.Engagement_Opportunity_Name__c;
            newList.List_Purpose__c = rec.Summary__c;
            newList.Stage__c = 'In Progress';

            listRecords.add(newList);
        }

        if(!listRecords.isEmpty()){
            ListsDAO.newInstance().insertRecords(listRecords, false, AccessLevel.SYSTEM_MODE);
        }
    }
}