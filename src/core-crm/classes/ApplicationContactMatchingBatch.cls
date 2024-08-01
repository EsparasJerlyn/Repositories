/**
 * Implements a batch process for handling application contact matching using processContactMatchingWithKeyChange.
 * This batch class queries the new and updated applications record to be processed
 * It prevents concurrent executions by checking for running jobs with the same name.
 * 
 * This batch class is database batchable and maintains state.
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                                        								|
 *    |---------------------------|-----------------------|--------------|------------------------------------------------------------------------------------------------------|
 *    | mark.j.mahilum            | April 30, 2024        | DEPP-7987    | Created file                                                                                         |
*/ 
public inherited sharing class ApplicationContactMatchingBatch implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {
    // Variable to track the total number of application processed
    private Integer total = 0;

    /**
     * Start method for the batch process.
     * Retrieves applications to be processed and prevents concurrent executions by checking for running jobs.
     * 
     * @param bc The batchable context.
     * @return A query locator for retrieving applications to be processed.
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Check for running jobs with the same name and job ID exemption
        List<AsyncApexJob> jobs = AsyncApexJobsDAO.newInstance().getRunningJobsByNameAndIdExemption(
            new Set<String>{'ApplicationContactMatchingBatch'},
            new Set<Id>{bc.getJobId()},
            AccessLevel.SYSTEM_MODE
        );

        // If there are running jobs, return null to prevent the batch from starting
        if (!jobs.isEmpty()) {
            return Database.getQueryLocator('SELECT Id FROM hed__Application__c WHERE Id = null');
        }

        // Retrieve applications to be processed by batch process
        return ApplicationsDAO.newInstance().queryLocatorGetApplicationsByBatchProcess(
            new Set<String>{'Insert','Update'},
            AccessLevel.USER_MODE
        );
    }

    /**
     * Execute method for processing applications
     * Calls an application service to handle the contact and lead matching logic
     * 
     * @param bc The batchable context.
     * @param List<hed__Application__c> The list of Applications record to be processed.
     */
    public void execute(Database.BatchableContext bc, List<hed__Application__c> applicationList) {
        // Increment the total count by the number of application currently processing
        total = total + applicationList.size();
        //process the application to contact matching 
        ApplicationServiceHelper.executeApplicationContactMatching(applicationList);
    }

    /**
     * Finish method for finalizing the batch process.
     * Checks for any remaining applications to be processed and recursively executes the batch if needed.
     * Logs the total number of applications processed.
     * 
     * @param bc The batchable context.
     */
    public void finish(Database.BatchableContext bc) {
        // Retrieve application records that still need to be processed
        //Include both newly created application record or the updated application record based on application status
        List<hed__Application__c> applicationsToBeProcessed = ApplicationsDAO.newInstance()
            .getApplicationsByBatchProcess(
                new Set<String>{'Insert','Update'},
                AccessLevel.USER_MODE
            );

        List<AsyncApexJob> jobs = AsyncApexJobsDAO.newInstance().getRunningJobsByNameAndIdExemption(
            new Set<String>{'ApplicationContactMatchingBatch'},
            new Set<Id>(),
            AccessLevel.SYSTEM_MODE
        );
        
        // Check if there are no running jobs and there are remaining application to be processed
        if (jobs.isEmpty() && !applicationsToBeProcessed.isEmpty()) {
            Contact_Matching_Service_Configuration__mdt cmsConfig = ConMatchingServiceConfigurationsDAO.newInstance()
                .getInstanceByDeveloperName(ConMatchingServiceConfigurationsDAO.APPLICATION_BATCH);
            // Recursively execute the batch process for remaining application
            Database.executeBatch(new ApplicationContactMatchingBatch(), (Integer)cmsConfig.Size__c);
        }

        // Log the total number of application
        Logger.info('Total number of Application processed: ' + total);
        // Save the log if there are buffered log messages
        if (Logger.getBufferSize() > 0) {
            Logger.saveLog();
        }
    }
}