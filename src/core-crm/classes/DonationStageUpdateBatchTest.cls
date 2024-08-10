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
      | kenneth.f.alsay                | May 6, 2024           | DEPP-8520              | Added isForCauseCancelledTest                   |
 */
@isTest
private class DonationStageUpdateBatchTest {
    @testSetup
    static void setupDate() {
        Test.startTest();
        TestDataFactoryUser.generateUserAdvancementManager();
        Test.stopTest();
    }

    @isTest
    private static void isForCauseCompletedRecurringTest() {
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
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

    @isTest
    private static void isForCauseCancelledTest() {
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            List<Designation__c> designationList = TestDataFactory.createDesignationRecords(1, DesignationsDAO.GIVING_TO_CAUSE_RECTYPE_ID);
            DesignationsDAO.newInstance()
                .insertRecords(designationList, false, AccessLevel.USER_MODE);
            
            List<Donation__c> donationList = TestDataFactory.createDonationRecordsWithRecordType(
                100,
                DonationsDAO.CAUSE_RECTYPE_ID
            );

            for(Donation__c donation : donationList){
                donation.Payment_Type__c = DonationsDAO.RECURRING_PAYMENT_TYPE;
                donation.Cancellation_Date__c = System.Today() - 5;
                donation.Stage__c = DonationsDAO.ACCEPTED_STAGE;
                donation.Total_Amount__c = 1000;
                donation.To_Designation__c = designationList[0].Id;
                donation.Cancellation_Reason__c = 'Designation Discontinued';
                donation.Cancellation_Comment__c = 'Test Record';
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
                    DonationsDAO.CANCELLED_STAGE,
                    donation.Stage__c,
                    'Stage should be cancelled.'
                );
            }
        }
    }
} 