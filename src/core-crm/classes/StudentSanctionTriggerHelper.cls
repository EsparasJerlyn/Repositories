/**
 * Handles the processing of duplicate sanctions triggered by changes to the Student Sanction object.
 * This class triggers the execution of a batch job for processing duplicate sanctions if applicable.
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                                        								|
 *    |---------------------------|-----------------------|--------------|------------------------------------------------------------------------------------------------------|
 *    | roy.nino.s.regala         | April 16, 2024        | DEPP-7984    | Created File
 */
public inherited sharing class StudentSanctionTriggerHelper {
    private static boolean isBatchJobRunning = false;

    /**
     * Processes the given list of new student sanction records to identify duplicate sanctions and trigger the execution of a batch job if necessary.
     *
     * @param newItems The list of new student sanction records.
     */
    public static void processDuplicateSanctionIntegration(List<Student_Sanction__c> newItems) {
        try {
            // Flag to determine whether to run the batch job
            Boolean runBatchJob = false;

            // Iterate through the new student sanction records
            for (Student_Sanction__c studentSanction : newItems) {
                // Check if the sanction is valid for processing
                boolean isSanctionValid =
                    String.isNotBlank(studentSanction.Sanction_Code__c) &&
                    studentSanction.Sanction_Code__c.toUpperCase() == 'DUP' &&
                    String.isNotBlank(studentSanction.QUT_Student_ID__c);
                if (isSanctionValid) {
                    // Set the batch process status to 'Insert'
                    studentSanction.Batch_Process__c = 'Insert';
                    // Set the flag to true to run the batch job
                    runBatchJob = true;
                }
            }

            Contact_Matching_Service_Configuration__mdt cmsConfig = ConMatchingServiceConfigurationsDAO.newInstance()
                .getInstanceByDeveloperName(ConMatchingServiceConfigurationsDAO.STUDENT_SANCTION_BATCH);

            // If no batch job needs to be run,
            // or batch is already running
            // or batch job is not active 
            // return (skip the soql and dont execute the batch)
            if (!runBatchJob || isBatchJobRunning || !cmsConfig.IsActive__c) {
                return;
            }

            // Check if there are any existing running jobs for the DuplicateSanctionBatch
            List<AsyncApexJob> jobs = AsyncApexJobsDAO.newInstance()
                .getRunningJobsByNameAndIdExemption(
                    new Set<String>{ ConMatchingServiceConfigurationsDAO.STUDENT_SANCTION_BATCH },
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );

            // If no running jobs exist, execute the batch job
            if (jobs.isEmpty()) {
                isBatchJobRunning = true;
                Database.executeBatch(new DuplicateSanctionBatch(), (Integer) cmsConfig.Size__c);
            }
        } catch (Exception e) {
            NebulaLoggerService.logExceptionDetails(
                'Exception caught in method processDuplicateSanctionIntegration in class StudentSanctionTriggerHelper.',
                e
            );
        }
    }
}
