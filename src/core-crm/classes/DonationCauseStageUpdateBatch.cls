/**
 * @description Batch Class to update Donation Cause Stages
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala   	       | March 14, 2024        | DEPP-8210              | Created file                 | 
 */
public class DonationCauseStageUpdateBatch implements Database.Batchable<sObject> {
    /**
     * @description to get Donation Cause for stage update
     * @param bc - BatchableContext
     * @return query - filtered query of donation cause records
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return DonationCausesDAO.newInstance().queryLocatorGetDonatioCausesForStageUpdate();
    }

    /**
     * @description Method to execute the batch
     * @param bc - BatchableContext
     * @param donationCausesList - List of Donation Cause Records
     */
    public void execute(Database.BatchableContext bc, List<Donation_Cause__c> donationCausesList) {
        try {
            Map<Id, Donation_Cause__c> donationCausesToUpdate = new Map<Id, Donation_Cause__c>();

            for (Donation_Cause__c dc : donationCausesList) {
                if (isForPublish(dc)) {
                    buildDonationCausesWithNewStage(
                        donationCausesToUpdate,
                        dc,
                        DonationCausesDAO.DC_PUBLISHED
                    );
                }
            }

            if (!donationCausesToUpdate.isEmpty()) {
                DonationCausesDAO.newInstance()
                    .updateRecords(donationCausesToUpdate.values(), false, AccessLevel.SYSTEM_MODE);
            }
        } catch (Exception e) {
            Logger.error(
                    'Exception caught in method execute in Apex class DonationCauseStageUpdateBatch.'
                )
                .setExceptionDetails(e);
        } finally {
            if (Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    }

    private boolean isForPublish(Donation_Cause__c dc) {
        return dc.Ready_For_Publishing__c == true &&
            dc.QUT_Giving_Publish_Start_Date__c <= System.today() &&
            dc.QUT_Giving_Publish_End_Date__c > System.today() &&
            dc.Stage__c != DonationCausesDAO.DC_PUBLISHED &&
            dc.Stage__c != DonationCausesDAO.DC_PUBLISHED;
    }

    private void buildDonationCausesWithNewStage(
        Map<Id, Donation_Cause__c> donationCausesToUpdate,
        Donation_Cause__c dc,
        String stage
    ) {
        donationCausesToUpdate.put(dc.Id, new Donation_Cause__c(Id = dc.Id, Stage__c = stage));
    }

    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext bc) {
    }
}
