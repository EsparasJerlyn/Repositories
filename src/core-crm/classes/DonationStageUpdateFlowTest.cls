/**
 * @description test class for Donation Stage Update flow
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | kenneth.f.alsay                | April 23, 2024        | DEPP-8528              | Created file                 |
 */
@isTest
public class DonationStageUpdateFlowTest {
	@testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactory.generateTestUsers(new List<String>{'QUT_Advancement_Manager' });
        Test.stopTest();
    }
    @isTest
    private static void stageToCompletedRecurringTest(){
        System.runAs(TestDataFactory.getAdvancementManager()) {
            //Create 1 Designation Record to add to To_Designation__c field
            List<Designation__c> designationList = TestDataFactory.createDesignationRecords(1, DesignationsDAO.GIVING_TO_CAUSE_RECTYPE_ID);
            DesignationsDAO.newInstance()
                .insertRecords(designationList, false, AccessLevel.USER_MODE);
            
            //Create Donation Records
            List<Donation__c> donationList = TestDataFactory.createDonationRecordsWithRecordType(100,DonationsDAO.CAUSE_RECTYPE_ID);
            for(Donation__c donation : donationList){
                donation.Payment_Type__c = 'Recurring Payment';
                donation.Final_Instalment_Date__c = System.Today() + 3;
                donation.Stage__c = 'Accepted';
                donation.Total_Amount__c = 1000;
                donation.To_Designation__c = designationList[0].Id;
            }
            DonationsDAO.newInstance().insertRecords(donationList, false, AccessLevel.USER_MODE);
            
            Test.startTest();
            //Get Created Donation Records
            List<Donation__c> donationsToUpdate = DonationsDAO.newInstance().getDonationsBySetRecordIds((new Map<Id,SObject>(donationList)).keySet(), AccessLevel.USER_MODE);

            //Update Donation Records to meet stage update conditions
            for(Donation__c donation : donationsToUpdate){
                donation.Final_Instalment_Date__c = System.Today();
            }           
            DonationsDAO.newInstance().updateRecords(donationsToUpdate, false, AccessLevel.USER_MODE);

            //Check if Stage has been updated
            List<Donation__c> donationsToCheck = DonationsDAO.newInstance().getDonationsBySetRecordIds((new Map<Id,SObject>(donationsToUpdate)).keySet(), AccessLevel.USER_MODE);
            for(Donation__c donation : donationsToCheck){
            	System.assertEquals('Completed', donation.Stage__c, 'Donation record not updated');
            }
            Test.stopTest();
        }
    }
}