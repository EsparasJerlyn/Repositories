/**
 * @description This class controls the LWC component for generating and canceling previews.
 * @history
 *    | Developer                 | Date         | JIRA        | Change Summary                                  |
 *    |---------------------------|--------------|-------------|------------------------------------------------|
 *    | alexander.cadalin         | May 22, 2024 | DEPP-7535   | Created File                                   |
 */
public with sharing class OutreachCampaignPreviewController {
    @AuraEnabled
    public static void processPreview(String recordId, String dateInput) {
        Engagement_List_Criteria__c criteria = EngagementListCriteriasDAO.newinstance().getEntryCriteriaById(recordId, AccessLevel.USER_MODE);
        Date executionDate = Date.valueOf(dateInput);
        OutreachCampaignService.updatePreviewStatus(
            new Engagement_List_Criteria__c(Id = criteria.Id), 
            EngagementListCriteriasDAO.IN_PROGRESS_PREVIEW_STATUS
        );
        OutreachCampaignService.deleteFinalAttachment(criteria);
        OutreachCampaignService.executePreviewBatch(criteria, executionDate);
    }

    @AuraEnabled
    public static void cancelPreview(String recordId) {
        Engagement_List_Criteria__c criteria = EngagementListCriteriasDAO.newinstance().getEntryCriteriaById(recordId, AccessLevel.USER_MODE);
        OutreachCampaignService.abortJob(criteria);
        OutreachCampaignService.deleteTempAttachments(criteria);
        OutreachCampaignService.deleteFinalAttachment(criteria);
        OutreachCampaignService.updatePreviewStatus(
            new Engagement_List_Criteria__c(Id = criteria.Id), 
            EngagementListCriteriasDAO.NOT_GENERATED_PREVIEW_STATUS
        );
    }
}