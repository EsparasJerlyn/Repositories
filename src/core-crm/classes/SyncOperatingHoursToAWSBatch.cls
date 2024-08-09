/**
 * @description Batch class to Sync Operating Hours to AWS every 12AM
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | john.aldric.s.seril   	       | Jul. 24, 2024         | DEPP-9834              | Created file                 | 
 */
public class SyncOperatingHoursToAWSBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
	/**
     * @description to Sync Operating Hours to AWS
     * @param bc - BatchableContext
     * @return query - filtered query of Operating Hours records
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return OperatingHoursDAO.newInstance().queryLocatorGetVoiceOperatingHours();
    }
    
    /**
     * @description Method to execute the batch
     * @param bc - BatchableContext
     * @param operatingHours - List of Operating Hours with related Time Slot
     */
    public void execute(
        Database.BatchableContext bc,
        List<OperatingHours> operatingHours
    ) {
        try {
            AmazonHttpCallout.responseStatus callOutStatus = AmazonHttpCallout.syncToAWSCallout(operatingHours);	
            if(!calloutStatus.successCallout.isEmpty()){
                OperatingHoursDAO.newInstance().updateRecords(calloutStatus.successCallout, false, AccessLevel.SYSTEM_MODE); 
            }
                     
        } catch (Exception e) {
            // prettier-ignore
            NebulaLoggerService.logExceptionDetails('Exception caught in SyncOperatingHoursToAWSBatch.cls',e);
        }    
    }

    // prettier-ignore
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext bc) {}
}