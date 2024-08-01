/**
 * @description Test class for DonationCauseTriggerHandler.cls
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | March 20, 2023        | DEPP-8200              | Created file                 |
 */
@isTest
public with sharing class DonationCauseTriggerHandlerTest {
	@testSetup
    static void setup() {
        TestDataFactoryUser.generateUserDonorEngagementManager();
        Donation_Cause_Code_Auto_Number__c donationCauseCodeAutoNum = DonationCauseCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
        donationCauseCodeAutoNum.Donation_Cause__c = 1;
        DonationCauseCodeAutoNumbersDAO.newInstance().upsertRecords(
            new List<Donation_Cause_Code_Auto_Number__c>{donationCauseCodeAutoNum}, 
            false, 
            AccessLevel.USER_MODE
            );
    }
    
    @isTest
    private static void createDonationCauseCodeTest() {
        System.runAs(TestDataFactoryUser.selectUserDonorEngagementManager) {
            Test.startTest();
            List<Donation_Cause__c> donationCauseList = TestDataFactory.createDonationCauseRecords(100);

            DonationCausesDAO.newInstance().insertRecords(donationCauseList, false, AccessLevel.USER_MODE);

            Donation_Cause_Code_Auto_Number__c donationCauseCodeAutoNum = DonationCauseCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
            Test.stopTest();

            Integer count = 1;

            for (Donation_Cause__c dc : DonationCausesDAO.newInstance().getDonationCausesBySetRecordIds(
                        (new Map<Id, Donation_Cause__c>(donationCauseList)).keySet(),AccessLevel.USER_MODE)
            ) {
                System.assert(String.isNotBlank(dc.Donation_Cause_Code__c), 'Blank ADVDC code on record.');
                System.assertEquals('ADVDC:' + String.valueOf(count).leftPad(5, '0'), dc.Donation_Cause_Code__c,'Incorrect ADVDC Code');
                count++;
            }
            System.assertEquals(101, donationCauseCodeAutoNum.Donation_Cause__c, 'Incorrect latest ADVDC code auto-number value.');

        }
    }
}
