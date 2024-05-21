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
    public static void executeContactMatchingBatch(List<Contact_Matching_Staging__c> newItems) {
        try {
            for (Contact_Matching_Staging__c conMatchingStaging : newItems) {
                // Set the batch process status to 'Insert'
                conMatchingStaging.Batch_Process__c = ContactMatchingStagingsDAO.INSERT_PROCESS;
            }

            List<AsyncApexJob> jobs = AsyncApexJobsDAO.newInstance()
                .getRunningJobsByNameAndIdExemption(
                    new Set<String>{ 'ContactMatchingStagingBatch' },
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );

            if (jobs.isEmpty()) {
                Database.executeBatch(new ContactMatchingStagingBatch());
            }
        } catch (Exception e) {
            NebulaLoggerService.logExceptionDetails(
                'Exception caught in method executeContactMatchingBatch in class ContactMatchingStagingTriggerHelper.',
                e
            );
        }
    }
}
