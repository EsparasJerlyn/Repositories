/**
 * @description Helper class all EngagementListCriteriaTrigger
 *
 * @author Accenture
 *
* @history
*     | Developer                 | Date                  | JIRA                | Change Summary                                                   |
      |---------------------------|-----------------------|---------------------|------------------------------------------------------------------|
      | roy.nino.s.regala         | May 27, 2024          | DEPP-8745           | Created file                                                     |
*/
public with sharing class EngagementListCriteriaTriggerHelper {
    /**
     * @description Performs fast field updates and validation on a list of Engagement_List_Criteria__c records.
     *              Handles updates to specific fields and performs validation.
     *              Additionally, it does cross-object logic
     *              This should be used in Before Insert/Update only
     * @param newItems List of new Engagement_List_Criteria__c records being processed.
     * @param oldItems Map of old Engagement_List_Criteria__c records for comparison, keyed by record Id.
     */
    public void fastFieldUpdateAndValidation(
        List<Engagement_List_Criteria__c> newItems,
        Map<Id, Engagement_List_Criteria__c> oldItems
    ) {
        // Set to collect criteria names that need their preview results reset
        Set<String> potentialAttachmentNames = new Set<String>();

        // Loop through the engagement criteria records
        // Add any methods here to only use 1 for loop
        for (Engagement_List_Criteria__c criteria : newItems) {
            // Check if the old items map is not null (trigger is on before update)
            // Do before updates inside this condition
            if (oldItems != null) {
                // Update fields and collect criteria names for further processing
                resetPreviewResult(criteria, oldItems.get(criteria.Id), potentialAttachmentNames);
            }
        }

        // Perform additional cross-object logic
        if (!potentialAttachmentNames.isEmpty()) {
            //delete attachment records if any criteria names need their preview results reset
            deleteAttachmentRecords(potentialAttachmentNames);
        }
    }

    /**
     * @description Resets the preview result for the given criteria if certain fields are updated.
     * @param criteria The new Engagement_List_Criteria__c record being processed.
     * @param oldCriteria The old Engagement_List_Criteria__c record for comparison.
     * @param potentialAttachmentNames Set of attachments name to be deleted for further processing.
     */
    private void resetPreviewResult(
        Engagement_List_Criteria__c criteria,
        Engagement_List_Criteria__c oldCriteria,
        Set<String> potentialAttachmentNames
    ) {
        // Check if any of the specified fields are updated
        if (
            ObjectFieldService.isOneOftheFieldsUpdated(
                EngagementListCriteriasDAO.CRITERIA_FIELDS,
                criteria,
                oldCriteria
            )
        ) {
            // Reset the preview status and result attachment ID
            criteria.Preview_Status__c = EngagementListCriteriasDAO.NOT_GENERATED_PREVIEW_STATUS;
            criteria.Preview_Result_Attachment_Id__c = null;
            // Add the criteria name + csv name format to the set for further processing
            potentialAttachmentNames.add(criteria.Name + '_Temp_Preview_Result.csv');
            potentialAttachmentNames.add(criteria.Name + '_Preview_Result.csv');
        }
    }

    /**
     * @description Deletes attachment records based on the given set of criteria names.
     * @param potentialAttachmentNames Set of attachments name to be deleted for further processing.
     */
    private void deleteAttachmentRecords(Set<String> potentialAttachmentNames) {
        // Get attachments to delete by their names
        List<Attachment> attachmentsToDelete = AttachmentsDAO.newInstance()
            .findAttachmentsByNames(potentialAttachmentNames, AccessLevel.SYSTEM_MODE);

        // Delete all related attachment records if any are found
        if (!attachmentsToDelete.isEmpty()) {
            AttachmentsDAO.newInstance()
                .deleteRecords(attachmentsToDelete, true, AccessLevel.SYSTEM_MODE);
        }
    }
}
