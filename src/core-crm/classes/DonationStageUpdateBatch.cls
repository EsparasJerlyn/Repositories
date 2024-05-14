/**
 * @description Batch Class to update Donation Stage
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                          |
      |--------------------------------|-----------------------|------------------------|---------------------------------------------------------|
      | kenneth.f.alsay                | April 24, 2024        | DEPP-8528              | Created file                                            |
      | kenneth.f.alsay                | May 6, 2024           | DEPP-8520              | Added updating Cause stage to Cancelled                 |
 */
public class DonationStageUpdateBatch implements Database.Batchable<sObject>{
    /**
     * @description to get Donation for stage update
     * @param bc - BatchableContext
     * @return query - filtered query of Donation records
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return DonationsDAO.newInstance().queryLocatorGetDonationsForStageUpdate();
    }
    
    /**
    * @description Method to execute the batch
    * @param bc - BatchableContext
    * @param donationList - List of Donation Records
    */
    public void execute(Database.BatchableContext bc, List<Donation__c> donationList) {
        try {
            List<Donation__c> donationsToUpdate = new List<Donation__c>();
            
            for (Donation__c donation : donationList) {
                if (isForCauseCompletedRecurring(donation)) {
                    buildDonationWithNewStage(
                        donationsToUpdate,
                        donation,
                        DonationsDAO.COMPLETED_STAGE
                    );
                }
                if (isForCauseCancelledStage(donation)) {
                    buildDonationWithNewStage(
                        donationsToUpdate,
                        donation,
                        DonationsDAO.CANCELLED_STAGE
                    );
                }
            }
            
            if (!donationsToUpdate.isEmpty()) {
                DonationsDAO.newInstance()
                    .updateRecords(donationsToUpdate, false, AccessLevel.SYSTEM_MODE);
            }
        } catch (Exception e) {
            Logger.error(
                'Exception caught in method execute in Apex class DonationStageUpdateBatch.'
            )
            .setExceptionDetails(e);
        } finally {
            if (Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    }

    private boolean isForCauseCompletedRecurring(Donation__c donation) {
        return donation.RecordTypeId == DonationsDAO.CAUSE_RECTYPE_ID &&
            donation.Payment_Type__c == DonationsDAO.RECURRING_PAYMENT_TYPE &&
            donation.Final_Instalment_Date__c <= System.today() &&
            donation.Stage__c != DonationsDAO.COMPLETED_STAGE &&
            donation.Stage__c != DonationsDAO.CANCELLED_STAGE &&
            donation.Stage__c != DonationsDAO.DECLINED_STAGE &&
            donation.Stage__c != DonationsDAO.PROPOSED_STAGE &&
            donation.Stage__c != DonationsDAO.COMPLETED_PART_PAID_STAGE;
    }

    private boolean isForCauseCancelledStage(Donation__c donation) {
        return donation.RecordTypeId == DonationsDAO.CAUSE_RECTYPE_ID &&
            donation.Cancellation_Date__c <= System.today() &&
            donation.Stage__c != DonationsDAO.COMPLETED_STAGE &&
            donation.Stage__c != DonationsDAO.CANCELLED_STAGE &&
            donation.Stage__c != DonationsDAO.DECLINED_STAGE;
    }
    
    private void buildDonationWithNewStage(
        List<Donation__c> donationsToUpdate,
        Donation__c donationRecord,
        String stage
    ) {
        donationsToUpdate.add(new Donation__c(Id = donationRecord.Id, Stage__c = stage));
    }

    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext bc) {
    }
} 