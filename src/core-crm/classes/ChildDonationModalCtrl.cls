/**
 * @description Controller Class for LWC childDonationModalCtrl
 * @see ../lwc/childDonationModalCtrl
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                    |
      |--------------------------------|-----------------------|------------------------|---------------------------------------------------|
      | neil.s.h.lesidan               | April 30, 2024        | DEPP-8610              | Created file                                      |
      |                                |                       | DEPP-8570              |                                                   |
      |                                |                       | DEPP-8682              |                                                   |
 */
public with sharing class ChildDonationModalCtrl {

    /**
     * @description Fetches the Donations that are connected to Parent Donation
     * @param parentDonation Record Id of Donation Object
     * @return Records of List<Donation__c>
    */
    @AuraEnabled
    public static List<Donation__c>  getDonationsEndowmentInstalment(Id parentDonation) {
        List<Donation__c> donationsList = DonationsDAO.newInstance().getDonationsByParentIdRecordType(
            new Set<Id>{parentDonation},
            DonationsDAO.ENDOWMENT_INSTALMENT_RECTYPE_ID,
            AccessLevel.USER_MODE
        );

        return donationsList;
    }

    /**
     * @description Create Child Donations Record type Endownment Instalment
     * @param donationsList List of Donation Object
     * @return Records of List<Donation__c>
    */
    @AuraEnabled
    public static List<Donation__c> upsertDonationChildEndownmentInstalment(List<Donation__c> donationsList) {
        for (Donation__c donation : donationsList) {
            donation.RecordTypeId = DonationsDAO.ENDOWMENT_INSTALMENT_RECTYPE_ID;
        }

        List<Database.UpsertResult> databaseResult = DonationsDAO.newInstance().upsertRecords(donationsList,false,AccessLevel.USER_MODE);

        for (Database.UpsertResult result : databaseResult){
            if (!result.isSuccess()){
                Logger.error('Error in Upsert Donation').setDatabaseResult(result);
            }
        }

        if(Logger.getBufferSize() > 0){
            Logger.saveLog();
        }

        return donationsList;
    }
}