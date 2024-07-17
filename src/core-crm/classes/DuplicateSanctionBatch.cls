/**
 * Implements a batch process for handling duplicate student sanctions.
 * This batch class queries student sanctions to be processed, calls an external service to handle duplicates,
 * and recursively executes itself if there are more sanctions to be processed.
 * It prevents concurrent executions by checking for running jobs with the same name.
 * 
 * This batch class is database batchable, allows callouts, and maintains state.
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                                        								|
 *    |---------------------------|-----------------------|--------------|------------------------------------------------------------------------------------------------------|
 *    | roy.nino.s.regala         | April 16, 2024        | DEPP-7984    | Created File
*/ 
public inherited sharing class DuplicateSanctionBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {

    // Variable to track the total number of student sanctions processed
    private Integer total = 0;

    /**
     * Start method for the batch process.
     * Retrieves student sanctions to be processed and prevents concurrent executions by checking for running jobs.
     * 
     * @param bc The batchable context.
     * @return A query locator for retrieving student sanctions to be processed.
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Check for running jobs with the same name and job ID exemption
        List<AsyncApexJob> jobs = AsyncApexJobsDAO.newInstance().getRunningJobsByNameAndIdExemption(
            new Set<String>{'DuplicateSanctionBatch'},
            new Set<Id>{bc.getJobId()},
            AccessLevel.SYSTEM_MODE
        );

        // If there are running jobs, return an empty to prevent the batch from starting
        if (!jobs.isEmpty()) {
            return Database.getQueryLocator('SELECT Id FROM Student_Sanction__c WHERE Id = null');
        }

        // Retrieve student sanctions to be processed by batch process
        return StudentSanctionsDAO.newInstance().queryLocatorGetStudentSanctionsByBatchProcess(
            new Set<String>{StudentSanctionsDAO.INSERT_PROCESS},
            AccessLevel.USER_MODE
        );
    }

    /**
     * Execute method for processing student sanctions.
     * Calls an external service to handle duplicate sanctions and updates the total count.
     * 
     * @param bc The batchable context.
     * @param studentSanctions The list of student sanctions to be processed.
     */
    public void execute(Database.BatchableContext bc, List<Student_Sanction__c> studentSanctions) {
        // Increment the total count by the number of student sanctions processed
        total = total + studentSanctions.size();
        // Call an external service to handle duplicate sanctions
        DuplicateSanctionManager.callOutESBSAMSRefreshStudent(studentSanctions);
    }

    /**
     * Finish method for finalizing the batch process.
     * Checks for any remaining student sanctions to be processed and recursively executes the batch if needed.
     * Logs the total number of student sanctions processed.
     * 
     * @param bc The batchable context.
     */
    public void finish(Database.BatchableContext bc) {
        // Retrieve student sanctions that still need to be processed
        List<Student_Sanction__c> sanctionsToBeProcessed = StudentSanctionsDAO.newInstance()
            .getStudentSanctionsByBatchProcess(
                new Set<String>{StudentSanctionsDAO.INSERT_PROCESS},
                AccessLevel.USER_MODE
            );

        List<AsyncApexJob> jobs = AsyncApexJobsDAO.newInstance().getRunningJobsByNameAndIdExemption(
            new Set<String>{'DuplicateSanctionBatch'},
            new Set<Id>(),
            AccessLevel.SYSTEM_MODE
        );
        
        // Check if there are no running jobs and there are remaining sanctions to be processed
        if (jobs.isEmpty() && !sanctionsToBeProcessed.isEmpty()) {
            Contact_Matching_Service_Configuration__mdt cmsConfig = ConMatchingServiceConfigurationsDAO.newInstance()
                .getInstanceByDeveloperName(ConMatchingServiceConfigurationsDAO.STUDENT_SANCTION_BATCH);
            // Recursively execute the batch process for remaining sanctions
            Database.executeBatch(new DuplicateSanctionBatch(), (Integer)cmsConfig.Size__c);
        }

        // Log the total number of student sanctions processed
        Logger.info('Total number of Student Sanctions processed: ' + total);
        // Save the log if there are buffered log messages
        if (Logger.getBufferSize() > 0) {
            Logger.saveLog();
        }
    }
}
