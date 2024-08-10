/**
 * @description Controller class for List__c Object
 * @see ../lwc/engagementOpportunityDetails
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                  |
 *    |--------------------------------|-----------------------|------------------------|---------------------------------|
 *    | ryan.j.a.dela.cruz             | February 2, 2024      | DEPP-6950              | Created file                    |
 *    |                                |                       |                        |                                 |
 */
public with sharing class ListsCtrl {
    
    /**
     * Finds the List record Id by the Engagement Opportunity Id.
     * @param engagementOpportunityIdString The string representation of the Engagement Opportunity Id.
     * @return The Id of the List record related to the provided Engagement Opportunity Id.
     */
    @AuraEnabled(cacheable=true)
    public static Id findListRecordIdByEngagementOpportunityId(
        String engagementOpportunityIdString
    ) {
        // Return null if the string is empty
        if (String.isBlank(engagementOpportunityIdString)) {
            return null;
        }

        Id engagementOpportunityId = (Id) engagementOpportunityIdString;

        // Retrieve list records by related Engagement Opportunity Ids
        List<List__c> listRecords = ListsDAO.newInstance()
            .getListRecordsByRelatedEngagementOpportunitySetIds(
                new Set<Id>{ engagementOpportunityId },
                AccessLevel.USER_MODE
            );

        // Return the Id of the first record (One engagement = one list)
        if (listRecords != null && !listRecords.isEmpty()) {
            return listRecords[0].Id;
        }

        // Return null if no records are found
        return null;
    }
}
