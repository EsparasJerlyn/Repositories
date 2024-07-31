/**
 * @description test class for DonationCauseStageUpdateBatch
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                  |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------|
      | roy.nino.s.regala              | March 15, 2024        | DEPP-8210              | Created file                                    |
      | eugene.andrew.abuan            | March 18, 2024        | DEPP-8211              | Added Active Stage                              |         
      | nicole.genon                   | March 20, 2024        | DEPP-8212              | Added Archived Stage                            |
      | kenneth.f.alsay                | April 1, 2024         | DEPP-8209              | Added field values to pass new validation rules |

 */
@isTest
private class DonationCauseStageUpdateBatchTest {
    @testSetup
    static void setupDate() {
        Test.startTest();
        TestDataFactoryUser.generateUserAdvancementManager();
        Test.stopTest();
    }

    @isTest
    private static void forPublishedBatchTest() {
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            List<Donation_Cause__c> donationCauseList = TestDataFactory.createDonationCauseRecords(
                1
            );

            donationCauseList[0].Ready_For_Publishing__c = true;
            donationCauseList[0].QUT_Giving_Publish_Start_Date__c = System.Today();
            donationCauseList[0].QUT_Giving_Publish_End_Date__c = System.Today() + 1;
            donationCauseList[0].QA_Completed__c = true;

            DonationCausesDAO.newInstance()
                .insertRecords(donationCauseList, false, AccessLevel.USER_MODE);

            Test.startTest();
            DonationCauseStageUpdateBatch batch = new DonationCauseStageUpdateBatch();
            Database.executeBatch(batch);
            Test.stopTest();

            System.assertEquals(
                DonationCausesDAO.DC_PUBLISHED,
                DonationCausesDAO.newInstance()
                        .getDonationCausesBySetRecordIds(new Set<Id>{ donationCauseList[0].Id }, AccessLevel.SYSTEM_MODE)[0]
                    .Stage__c,
                'Stage should be published'
            );
        }
    }

    @isTest
    private static void forActiveBatchTest() {
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            List<Donation_Cause__c> donationCauseList = TestDataFactory.createDonationCauseRecords(
                1
            );
            donationCauseList[0].QUT_Giving_Publish_Start_Date__c = System.Today() + 1;
            donationCauseList[0].Ready_For_Publishing__c = true;
            donationCauseList[0].QUT_Giving_Publish_End_Date__c = System.Today() + 2;
            donationCauseList[0].Activation_End_Date__c = System.Today() + 2;
            donationCauseList[0].QA_Completed__c = true;

            DonationCausesDAO.newInstance()
                .insertRecords(donationCauseList, true, AccessLevel.USER_MODE);
            
            donationCauseList[0].Stage__c = null;

            DonationCausesDAO.newInstance()
                .updateRecords(donationCauseList, true, AccessLevel.USER_MODE);

            Test.startTest();
            DonationCauseStageUpdateBatch batch = new DonationCauseStageUpdateBatch();
            Database.executeBatch(batch);
            Test.stopTest();

            System.assertEquals(
                DonationCausesDAO.DC_ACTIVE,
                DonationCausesDAO.newInstance()
                        .getDonationCausesBySetRecordIds(new Set<Id>{ donationCauseList[0].Id }, AccessLevel.SYSTEM_MODE)[0]
                    .Stage__c,
                'Stage should be Active'
            );
        }
    }

    @isTest
    private static void forArchivedBatchTest() {
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            List<Donation_Cause__c> donationCauseList = TestDataFactory.createDonationCauseRecords(
                1
            );
            donationCauseList[0].Activation_Start_Date__c = System.Today() - 4;
            donationCauseList[0].Archived_Date__c = System.Today() - 1;
            donationCauseList[0].Archived_Comment__c = 'Test';
            donationCauseList[0].Archived_Reason__c = 'Other';
            donationCauseList[0].Activation_End_Date__c = System.Today() - 1;

            DonationCausesDAO.newInstance()
                .insertRecords(donationCauseList, true, AccessLevel.USER_MODE);

            Test.startTest();
            DonationCauseStageUpdateBatch batch = new DonationCauseStageUpdateBatch();
            Database.executeBatch(batch);
            Test.stopTest();

            System.assertEquals(
                DonationCausesDAO.DC_ARCHIVED,
                DonationCausesDAO.newInstance()
                        .getDonationCausesBySetRecordIds(new Set<Id>{ donationCauseList[0].Id }, AccessLevel.SYSTEM_MODE)[0]
                    .Stage__c,
                'Stage should be archived'
            );
        }
    }
}