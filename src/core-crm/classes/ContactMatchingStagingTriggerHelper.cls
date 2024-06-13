/**
 * @description helper class for contact matching staging trigger 
 * @see ContactMatchingStagingTriggerHanlder
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | May 01, 2024          | DEPP-8676              | created file                 |
 */

public inherited sharing class ContactMatchingStagingTriggerHelper {
    
    private static boolean isBatchJobRunning = false;

    /**
     * Processes the given list of new Contact Matching Staging records to identify duplicate existing matching records and execute a batch.
     *
     * @param newItems The list of new Contact Matching Staging records.
     */
    public static void executeContactMatchingBatch(List<Contact_Matching_Staging__c> newItems) {
        try {
            for (Contact_Matching_Staging__c conMatchingStaging : newItems) {
                // Set the batch process status to 'Insert'
                conMatchingStaging.Batch_Process__c = ContactMatchingStagingsDAO.INSERT_PROCESS;
            }

            Contact_Matching_Service_Configuration__mdt cmsConfig = ConMatchingServiceConfigurationsDAO.newInstance()
                .getInstanceByDeveloperName(ConMatchingServiceConfigurationsDAO.CONTACT_MATCHING_STAGING_BATCH);
                
            // if batch is already running
            // or batch is not active 
            // return (skip the soql and dont execute the batch)
            if (isBatchJobRunning || !cmsConfig.IsActive__c) {
                return;
            }
            
            List<AsyncApexJob> jobs = AsyncApexJobsDAO.newInstance()
                .getRunningJobsByNameAndIdExemption(
                    new Set<String>{ ConMatchingServiceConfigurationsDAO.CONTACT_MATCHING_STAGING_BATCH },
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );

            if (jobs.isEmpty()) {
                isBatchJobRunning = true;
                Database.executeBatch(
                    new ContactMatchingStagingBatch(),
                    (Integer) cmsConfig.Size__c
                );
            }
        } catch (Exception e) {
            NebulaLoggerService.logExceptionDetails(
                'Exception caught in method executeContactMatchingBatch in class ContactMatchingStagingTriggerHelper.',
                e
            );
        }
    }
}
