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
      | eugene.andrew.abuan            | March 18, 2024        | DEPP-8211              | Added Active Stage           |
      | nicole.genon                   | March 20, 2024        | DEPP-8212              | Added Archived Stage         |
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
            List<Donation_Cause__c> donationCausesToUpdate = new List<Donation_Cause__c>();

            for (Donation_Cause__c dc : donationCausesList) {
                if (isForPublish(dc)) {
                    buildDonationCausesWithNewStage(
                        donationCausesToUpdate,
                        dc,
                        DonationCausesDAO.DC_PUBLISHED
                    );
                }
                
                if (isForArchived(dc)) {
                    buildDonationCausesWithNewStage(
                        donationCausesToUpdate,
                        dc,
                        DonationCausesDAO.DC_ARCHIVED
                    );
                }

                if(isForActive(dc)){
                    buildDonationCausesWithNewStage(
                        donationCausesToUpdate,
                        dc,
                        DonationCausesDAO.DC_ACTIVE
                    );
                }
            }

            if (!donationCausesToUpdate.isEmpty()) {
                DonationCausesDAO.newInstance()
                    .updateRecords(donationCausesToUpdate, false, AccessLevel.SYSTEM_MODE);
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
            dc.Stage__c != DonationCausesDAO.DC_ARCHIVED;
    }

    private boolean isForActive(Donation_Cause__c dc){
        return dc.Activation_Start_Date__c <= System.today() &&
            dc.Activation_End_Date__c > System.today() &&
            ( dc.Ready_For_Publishing__c == false ||
            dc.QUT_Giving_Publish_Start_Date__c == null ||
            dc.QUT_Giving_Publish_Start_Date__c > System.today() ||
            dc.QUT_Giving_Publish_End_Date__c < System.today()
            ) &&
            dc.Stage__c != DonationCausesDAO.DC_ACTIVE &&
            dc.Stage__c != DonationCausesDAO.DC_ARCHIVED;
    }

    private boolean isForArchived(Donation_Cause__c dc) {
        return (dc.Archived_Date__c <= System.today() ||
            dc.Activation_End_Date__c <= System.today()) &&
            dc.Stage__c != DonationCausesDAO.DC_ARCHIVED;
    }

    private void buildDonationCausesWithNewStage(
        List<Donation_Cause__c> donationCausesToUpdate,
        Donation_Cause__c dc,
        String stage
    ) {
        donationCausesToUpdate.add(new Donation_Cause__c(Id = dc.Id, Stage__c = stage));
    }

    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext bc) {
    }
}