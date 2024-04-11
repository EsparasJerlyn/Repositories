/**
 * @description Batch Class to update Distribution Management Status
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | kenneth.f.alsay      	       | April 11, 2024        | DEPP-8453              | Created file                 |
 */
public class DistributionMgtStatusUpdateBatch implements Database.Batchable<sObject>{
    /**
     * @description to get Distribution Management for stage update
     * @param bc - BatchableContext
     * @return query - filtered query of Distribution Management records
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return DistributionManagementsDAO.newInstance().queryLocatorGetDistributionMgtsForStatusUpdate();
    }
    
    /**
    * @description Method to execute the batch
    * @param bc - BatchableContext
    * @param distMgtToUpdate - List of Distribution Management Records
    */
    public void execute(Database.BatchableContext bc, List<Distribution_Management__c> distributionMgtList) {
        try {
            List<Distribution_Management__c> distMgtToUpdate = new List<Distribution_Management__c>();
            
            for (Distribution_Management__c dm : distributionMgtList) {
                if (isForInactive(dm)) {
                    buildDistributionMgtWithNewStage(
                        distMgtToUpdate,
                        dm,
                        DistributionManagementsDAO.DM_INACTIVE
                    );
                }
            }
            
            if (!distMgtToUpdate.isEmpty()) {
                DistributionManagementsDAO.newInstance()
                    .updateRecords(distMgtToUpdate, false, AccessLevel.SYSTEM_MODE);
            }
        } catch (Exception e) {
            Logger.error(
                'Exception caught in method execute in Apex class DistributionMgtStatusUpdateBatch.'
            )
                .setExceptionDetails(e);
        } finally {
            if (Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    }
    
    private boolean isForInactive(Distribution_Management__c dm) {
        return dm.Status__c == DistributionManagementsDAO.DM_ACTIVE &&
            dm.End_Date__c <= System.today() &&
            dm.Designation__r.RecordTypeID == DesignationsDAO.GIVING_TO_CAUSE_RECTYPE_ID;
    }
    
    private void buildDistributionMgtWithNewStage(
        List<Distribution_Management__c> dmToUpdate,
        Distribution_Management__c dm,
        String status
    ) {
        dmToUpdate.add(new Distribution_Management__c(Id = dm.Id, Status__C = status));
    }

    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext bc) {
    }
}