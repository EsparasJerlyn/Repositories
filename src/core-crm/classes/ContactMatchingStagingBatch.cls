/**
 * @description This class implements Database.Batchable interface to process Contact Matching Staging records
 *              in batches. It also implements Database.AllowsCallouts and Database.Stateful interfaces.
 * @author Accenture
 * @history
 *    | Developer               | Date        | JIRA      | Change Summary                                  |
 *    |-------------------------|-------------|-----------|-------------------------------------------------|
 *    | roy.nino.s.regala       | May 01, 2024| DEPP-8676 | Created File                                    |
 */
public inherited sharing class ContactMatchingStagingBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    // Total count of records processed in batches
    private Integer total = 0;

    /**
     * The start method of the batch job.
     *
     * @param bc Database.BatchableContext The batch context.
     * @return Database.QueryLocator The query locator for fetching records to process.
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Check for running jobs with the same name and job ID exemption
        List<AsyncApexJob> jobs = AsyncApexJobsDAO.newInstance()
            .getRunningJobsByNameAndIdExemption(
                new Set<String>{ 'ContactMatchingStagingBatch' },
                new Set<Id>{ bc.getJobId() },
                AccessLevel.SYSTEM_MODE
            );
        // If there are running jobs, return an empty query locator to prevent the batch from starting
        if (!jobs.isEmpty()) {
            return Database.getQueryLocator(
                'SELECT Id FROM Contact_Matching_Staging__c WHERE Id = null'
            );
        }

        // Fetch the Contact Matching Staging records to process
        return ContactMatchingStagingsDAO.newInstance()
            .queryLocatorGetContactMatchingStagingsByBatchProcess(
                new Set<String>{ ContactMatchingStagingsDAO.INSERT_PROCESS },
                AccessLevel.USER_MODE
            );
    }

    /**
     * The execute method of the batch job.
     *
     * @param bc Database.BatchableContext The batch context.
     * @param contactMatchingStagings List<Contact_Matching_Staging__c> The list of records to process.
     */
    public void execute(
        Database.BatchableContext bc,
        List<Contact_Matching_Staging__c> contactMatchingStagings
    ) {
        // Increment the total count of records processed
        total = total + contactMatchingStagings.size();
        // Process the Contact Matching Staging records
        ContactMatchingStagingBatchManager.processContactMatching(contactMatchingStagings);
    }

    /**
     * The finish method of the batch job.
     *
     * @param bc Database.BatchableContext The batch context.
     */
    public void finish(Database.BatchableContext bc) {
        // Fetch Contact Matching Staging records that are yet to be processed
        List<Contact_Matching_Staging__c> conMatchingStagingsToBeProcessed = ContactMatchingStagingsDAO.newInstance()
            .getContactMatchingStagingsByBatchProcess(
                new Set<String>{ ContactMatchingStagingsDAO.INSERT_PROCESS },
                AccessLevel.USER_MODE
            );

        // Check if there are no running jobs and there are records to be processed
        List<AsyncApexJob> jobs = AsyncApexJobsDAO.newInstance()
            .getRunningJobsByNameAndIdExemption(
                new Set<String>{ 'ContactMatchingStagingBatch' },
                new Set<Id>(),
                AccessLevel.SYSTEM_MODE
            );

        if (jobs.isEmpty() && !conMatchingStagingsToBeProcessed.isEmpty()) {
            Contact_Matching_Service_Configuration__mdt cmsConfig = ConMatchingServiceConfigurationsDAO.newInstance()
            .getInstanceByDeveloperName(ConMatchingServiceConfigurationsDAO.CONTACT_MATCHING_STAGING_BATCH);
            // If no running jobs and records to be processed, start a new batch job
            Database.executeBatch(new ContactMatchingStagingBatch(), (Integer)cmsConfig.Size__c);
        }

        // Log the total number of Contact Matching Staging records processed
        Logger.info('Total number of Contact Matching Staging processed: ' + total);

        // Save the log if there are buffered log messages
        if (Logger.getBufferSize() > 0) {
            Logger.saveLog();
        }
    }
}
