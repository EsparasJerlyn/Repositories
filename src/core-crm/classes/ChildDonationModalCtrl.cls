/**
 * @description Controller Class for LWC childDonationModalCtrl
 * @see ../lwc/childDonationModalCtrl
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                                |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------------------------|
      | neil.s.h.lesidan               | April 30, 2024        | DEPP-8610              | Created file                                                                  |
      |                                |                       | DEPP-8570              |                                                                               |
      |                                |                       | DEPP-8682              |                                                                               |
      | neil.s.h.lesidan               | April 30, 2024        | DEPP-8595              | Change method name to upsertDonationChild                                     |
      |                                |                       | DEPP-8632              | Change method name to getDonationsByRecordTypeParentId                        |
      |                                |                       | DEPP-8720              |                                                                               |
      |                                |                       | DEPP-8596              |                                                                               |
      |                                |                       | DEPP-8621              |                                                                               |
      |                                |                       | DEPP-8721              |                                                                               |
      |                                |                       |                        |                                                                               |
 */
public with sharing class ChildDonationModalCtrl {
    /**
     * @description Fetches the Donations with record type Pledge that are connected to Parent Donation
     * @param parentDonation Record Id of Donation Object
     * @param recordType String Record type
     * @return Records of List<Donation__c>
    */
    @AuraEnabled
    public static List<Donation__c>  getDonationsByRecordTypeParentId(Id parentDonation, String recordType) {
        Id recordTypeId;
        if (recordType == DonationsDAO.ENDOWMENT_INSTALMENT_RECTYPE_NAME) {
            recordTypeId = DonationsDAO.ENDOWMENT_INSTALMENT_RECTYPE_ID;
        } else if (recordType == DonationsDAO.PLEDGE_INSTALMENT_RECTYPE_NAME) {
            recordTypeId = DonationsDAO.PLEDGE_INSTALMENT_RECTYPE_ID;
        } else if (recordType == DonationsDAO.PLEDGE_DESIGNATION_SPLIT_RECTYPE_NAME) {
            recordTypeId = DonationsDAO.PLEDGE_DESIGNATION_SPLIT_RECTYPE_ID;
        }

        List<Donation__c> donationsList = DonationsDAO.newInstance().getDonationsByParentIdRecordType(
            new Set<Id>{parentDonation},
            recordTypeId,
            AccessLevel.USER_MODE
        );

        return donationsList;
    }

    /**
     * @description Create Child Donations Record type Endownment Instalment
     * @param donationsList List of Donation Object
     * @param recordType String Record type
     * @return Records of List<Donation__c>
    */
    @AuraEnabled
    public static List<Donation__c> upsertDonationChild(List<Donation__c> donationsList, String recordType) {
        if (!String.isEmpty(recordType) && !String.isBlank(recordType)) {
            for (Donation__c donation : donationsList) {
                if (recordType == DonationsDAO.ENDOWMENT_INSTALMENT_RECTYPE_NAME) {
                    donation.RecordTypeId = DonationsDAO.ENDOWMENT_INSTALMENT_RECTYPE_ID;
                } else if (recordType == DonationsDAO.PLEDGE_INSTALMENT_RECTYPE_NAME) {
                    donation.RecordTypeId = DonationsDAO.PLEDGE_INSTALMENT_RECTYPE_ID;
                } else if (recordType == DonationsDAO.PLEDGE_DESIGNATION_SPLIT_RECTYPE_NAME) {
                    donation.RecordTypeId = DonationsDAO.PLEDGE_DESIGNATION_SPLIT_RECTYPE_ID;
                }
            }

            List<Database.UpsertResult> databaseResult = DonationsDAO.newInstance().upsertRecords(donationsList, false, AccessLevel.USER_MODE);

            for (Database.UpsertResult result : databaseResult) {
                if (!result.isSuccess()) {
                    Logger.error('Error in Upsert Donation').setDatabaseResult(result);
                }
            }

            if (Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }

        return donationsList;
    }
}