/**
 * @description Batch class to update the QUT_Applicant__c field of Contact based from condition
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | sebastianne.k.trias            | March 28, 2024        | DEPP-8382              | Created file                 |
 */
public class ApplicantFlagBatch implements Database.Batchable<sObject> {
    /**
     * @description to update contact QUT_Applicant__c field
     * @param bc - BatchableContext
     * @return query - filtered query of hed__Application__c records
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {

        return ApplicationsDAO.newInstance().queryApplicationsByPastIntakeDateAndActiveApplicants('SYSTEM_MODE');

    }
    /**
     * @description Method to execute the batch
     * @param bc - BatchableContext
     * @param applicationsList - Lists of Applications record from start method
     */
    public void execute(
        Database.BatchableContext bc,
        List<hed__Application__c> applicationsList
    ) {
        try {

            Set<Id> contactIds = new Set<Id>();
            for(hed__Application__c app : applicationsList){
                contactIds.add(app.hed__Applicant__c);
            }
            ContactPersonaFlagsService.updateContactApplicantFlag(contactIds);

        } catch (Exception e) {
            NebulaLoggerService.logExceptionDetails('Exception caught in ApplicantFlagBatch.cls',e);
            throw e;
        }
    }

    public void finish(Database.BatchableContext bc) {} //NOPMD
}