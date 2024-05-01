/**
 * @description test class for DesignationStageUpdateBatch
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                  |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------|
      | kenneth.f.alsay                | April 24, 2024        | DEPP-8528              | Created file                                    |
 */
@isTest
private class DonationStageUpdateBatchTest {
    @testSetup
    static void setupDate() {
        Test.startTest();
        TestDataFactory.generateTestUsers(new List<String>{'QUT_Advancement_Manager' });
        Test.stopTest();
    }

    @isTest
    private static void isForCompletedRecurringTest() {
        System.runAs(TestDataFactory.getAdvancementManager()) {
            List<Designation__c> designationList = TestDataFactory.createDesignationRecords(1, DesignationsDAO.GIVING_TO_CAUSE_RECTYPE_ID);
            DesignationsDAO.newInstance()
                .insertRecords(designationList, false, AccessLevel.USER_MODE);
            
            List<Donation__c> donationList = TestDataFactory.createDonationRecordsWithRecordType(
                100,
                DonationsDAO.CAUSE_RECTYPE_ID
            );

            for(Donation__c donation : donationList){
                donation.Payment_Type__c = DonationsDAO.RECURRING_PAYMENT_TYPE;
                donation.Final_Instalment_Date__c = System.Today() - 5;
                donation.Stage__c = DonationsDAO.ACCEPTED_STAGE;
                donation.Total_Amount__c = 1000;
                donation.To_Designation__c = designationList[0].Id;
            }

            DonationsDAO.newInstance()
                .insertRecords(donationList, false, AccessLevel.USER_MODE);

            Test.startTest();
            DonationStageUpdateBatch batch = new DonationStageUpdateBatch();
            Database.executeBatch(batch);
            Test.stopTest();

            List<Donation__c> donationsToCheck = DonationsDAO.newInstance().getDonationsBySetRecordIds((new Map<Id,SObject>(donationList)).keySet(), AccessLevel.USER_MODE);
            for(Donation__c donation : donationsToCheck){
                System.assertEquals(
                    DonationsDAO.COMPLETED_STAGE,
                    donation.Stage__c,
                    'Stage should be completed.'
                );
            }
        }
    }
}