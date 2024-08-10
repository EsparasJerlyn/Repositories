/**
 * @description test class for Donation Stage Update flow
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                           |
      |--------------------------------|-----------------------|------------------------|----------------------------------------------------------|
      | kenneth.f.alsay                | April 23, 2024        | DEPP-8528              | Created file                                             |
      | nicole.genon                   | May 2, 2024           | DEPP-8673              | Added stageToCompletedPartPaidEndowmentTest,             |
      |                                |                       |                        | stageToCompletedPartPaidHasAcceptedStageEndowmentTest,   |
      |                                |                       |                        | stageToCompletedPartPaidPledgeTest,                      |
      |                                |                       |                        | stageToCompletedPartPaidHasAcceptedStagePledgeTest       |
      | nicole.genon                   | May 6, 2024           | DEPP-8606              | stageToCancelledHasCompletedStagePledgeTest              |
      |                                |                       |                        | stageToCancelledPledgeTest                               |
      | kenneth.f.alsay                | May 6, 2024           | DEPP-8520              | Added stageToCancelledCauseTest                          |
      | jerlyn.esparas                 | May 7, 2024           | DEPP-8564              | Added stageToCancelledChildDonationTest                  |
      |                                                                                 | stageToCancelledHasCompletedStageEndowmentTest           |
                                                                                          stageToCancelledEndowmentTest                            |
 */
@isTest
public class DonationStageUpdateFlowTest {
	@testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactoryUser.generateUserAdvancementManager();
        Test.stopTest();

        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            List<Account> accountRecord = TestDataFactory.createTestAccountRecordsWithRecordType(1, AccountsDAO.ACCT_UNIV_DEP_ID);
            accountRecord[0].Organization_Unit_Level__c ='2';
            accountRecord[0].End_Date__c = null;
            AccountsDAO.newInstance().insertRecords(accountRecord, false, AccessLevel.SYSTEM_MODE);

            List<Contact> newContacts = TestDataFactory.createTestContactRecords(1);
            newContacts[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            newContacts[0].AccountId = accountRecord[0].Id;
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);

            List<Opportunity> individualOpportunityRecords = TestDataFactory.createTestOpportunityRecords(
                    1,'OppTest',OpportunitiesDAO.INDIVIDUAL_GIVING_RECTYPE_ID);

            individualOpportunityRecords[0].Description = 'Test';
            individualOpportunityRecords[0].ContactId = newContacts[0].Id;
            individualOpportunityRecords[0].Contact__c = newContacts[0].Id;
            individualOpportunityRecords[0].Donor_Linkage_Rank__c = 'Low Level of Connection';
            individualOpportunityRecords[0].Donor_Interest_Rank__c = 'Unknown or not assessed';
            individualOpportunityRecords[0].Donor_Ability_Rank__c = '$250K - $500K';
            individualOpportunityRecords[0].Probability_Of_Success__c = '60%';
            individualOpportunityRecords[0].Qualification_Summary__c = 'Test';
            individualOpportunityRecords[0].Is_Qualified__c = true;
            individualOpportunityRecords[0].Solicitation_Sub_Stage__c = 'Agreement';
            individualOpportunityRecords[0].Due_Diligence_Summary__c = 'Test';
            individualOpportunityRecords[0].Due_Diligence_Completed__c = true;
            individualOpportunityRecords[0].Is_Agreement_Signed__c = true;
            individualOpportunityRecords[0].StageName = OpportunitiesDAO.SOLICITATION_STAGE;

            OpportunitiesDAO.newInstance().insertRecords(individualOpportunityRecords, false, AccessLevel.USER_MODE);

            List<Designation__c> designationList = TestDataFactory.createDesignationRecords(1, DesignationsDAO.ENDOWNMENT_RECTYPE_ID);

            designationList[0].Endowment_Account_Type__c = 'Perpetual';
            DesignationsDAO.newInstance()
                .insertRecords(designationList, false, AccessLevel.USER_MODE);

            List<Donation__c> donationList = TestDataFactory.createDonationRecordsWithRecordType(1,DonationsDAO.ENDOWMENT_RECTYPE_ID);
            for(Donation__c donation : donationList){
                donation.Payment_Type__c = 'Payment Plan';
                donation.Stage__c = 'Accepted';
                donation.Total_Amount__c = 1000;
                donation.To_Designation__c = designationList[0].Id;
                donation.Opportunity__c = individualOpportunityRecords[0].Id;
                donation.Contact__c = individualOpportunityRecords[0].Contact__c;
            }
            DonationsDAO.newInstance().insertRecords(donationList, false, AccessLevel.USER_MODE);

            List<Donation__c> donationChildList = TestDataFactory.createDonationRecordsWithRecordType(100,DonationsDAO.ENDOWMENT_INSTALMENT_RECTYPE_ID);
            Integer counter = 0;
            for(Donation__c donationChild : donationChildList){
                donationChild.Payment_Type__c = 'Payment Plan';
                donationChild.Total_Amount__c = 5;
                donationChild.To_Designation__c = donationList[0].To_Designation__c;
                donationChild.Contact__c = donationList[0].Contact__c;
                donationChild.Donation_Parent__c = donationList[0].Id;
                donationChild.Instalment_Date__c = System.Today();
                donationChild.Stage__c = (counter < 50)? 'Completed' : 'Cancelled';
                counter++;
            }
            DonationsDAO.newInstance().insertRecords(donationChildList, false, AccessLevel.USER_MODE);

            List<Donation__c> donationPledgeList = TestDataFactory.createDonationRecordsWithRecordType(1,DonationsDAO.PLEDGE_RECTYPE_ID);
            for(Donation__c donation : donationPledgeList){
                donation.Payment_Type__c = 'Payment Plan';
                donation.Stage__c = 'Accepted';
                donation.Total_Amount__c = 1000;
                donation.Opportunity__c = individualOpportunityRecords[0].Id;
                donation.Contact__c = individualOpportunityRecords[0].Contact__c;
            }
            DonationsDAO.newInstance().insertRecords(donationPledgeList, false, AccessLevel.USER_MODE);

            List<Donation__c> donationPledgeChildList = TestDataFactory.createDonationRecordsWithRecordType(100,DonationsDAO.PLEDGE_INSTALMENT_RECTYPE_ID);
            Integer pledgeCounter = 0;
            for(Donation__c donationChild : donationPledgeChildList){
                donationChild.Payment_Type__c = 'Payment Plan';
                donationChild.Total_Amount__c = 5;
                donationChild.Contact__c = donationPledgeList[0].Contact__c;
                donationChild.Donation_Parent__c = donationPledgeList[0].Id;
                donationChild.Instalment_Date__c = System.Today();
                donationChild.Stage__c = (pledgeCounter < 50)? 'Completed' : 'Cancelled';
                pledgeCounter++;
            }
            DonationsDAO.newInstance().insertRecords(donationPledgeChildList, false, AccessLevel.USER_MODE);
        }
    }

    @isTest
    private static void stageToCompletedRecurringCauseTest(){
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
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

    @isTest
    private static void stageToCompletedPartPaidEndowmentTest(){
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            Test.startTest();
            //Get Created Donation Records
            List<Donation__c> donationsToUpdate = DonationsDAO.newInstance().getDonationsBySetRecordTypeIds(new Set<Id>{DonationsDAO.ENDOWMENT_RECTYPE_ID}, AccessLevel.USER_MODE);
            
            //Update Donation Records to meet stage update conditions
            for(Donation__c donation : donationsToUpdate){
                donation.Stage__c = 'Completed - Part Paid';
            }           
            DonationsDAO.newInstance().updateRecords(donationsToUpdate, false, AccessLevel.USER_MODE);
            
            //Check if Stage has been updated
            List<Donation__c> donationsToCheck = DonationsDAO.newInstance().getDonationsBySetRecordIds((new Map<Id,SObject>(donationsToUpdate)).keySet(), AccessLevel.USER_MODE);
            for(Donation__c donation : donationsToCheck){
            	System.assertEquals('Completed - Part Paid', donation.Stage__c, 'Donation record not updated');
            }
            Test.stopTest();
        }
    }

    @isTest
    private static void stageToCompletedPartPaidHasAcceptedStageEndowmentTest(){
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            Test.startTest();
            //Get Created Donation Record
            List<Donation__c> donationsToUpdate = DonationsDAO.newInstance().getDonationsBySetRecordTypeIds(new Set<Id>{DonationsDAO.ENDOWMENT_RECTYPE_ID}, AccessLevel.USER_MODE);

            //Get Child Donation Records
            List<Donation__c> childDonations = DonationsDAO.newInstance().getDonationsBySetDonationParentIds(new Set<Id>{donationsToUpdate[0].Id}, AccessLevel.USER_MODE);

            childDonations[0].Stage__c = 'Accepted';
            DonationsDAO.newInstance().updateRecords(childDonations, false, AccessLevel.USER_MODE);

            //Update Donation Records to meet stage update conditions
            for(Donation__c donation : donationsToUpdate){
                donation.Stage__c = 'Completed - Part Paid';
            }           

            DonationsDAO.newInstance().updateRecords(donationsToUpdate, false, AccessLevel.USER_MODE);

            //Check if Stage has been updated
            List<Donation__c> donationsToCheck = DonationsDAO.newInstance().getDonationsBySetRecordIds((new Map<Id,SObject>(donationsToUpdate)).keySet(), AccessLevel.USER_MODE);
            for(Donation__c donation : donationsToCheck){
            	System.assertNotEquals('Completed - Part Paid', donation.Stage__c, 'Donation record not updated');
            }
            Test.stopTest();
        }
    }

    @isTest
    private static void stageToCompletedPartPaidPledgeTest(){
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            Test.startTest();
            //Get Created Donation Records
            List<Donation__c> donationsToUpdate = DonationsDAO.newInstance().getDonationsBySetRecordTypeIds(new Set<Id>{DonationsDAO.PLEDGE_RECTYPE_ID}, AccessLevel.USER_MODE);
            
            //Update Donation Records to meet stage update conditions
            for(Donation__c donation : donationsToUpdate){
                donation.Stage__c = 'Completed - Part Paid';
            }           
            DonationsDAO.newInstance().updateRecords(donationsToUpdate, false, AccessLevel.USER_MODE);
            
            //Check if Stage has been updated
            List<Donation__c> donationsToCheck = DonationsDAO.newInstance().getDonationsBySetRecordIds((new Map<Id,SObject>(donationsToUpdate)).keySet(), AccessLevel.USER_MODE);
            for(Donation__c donation : donationsToCheck){
            	System.assertEquals('Completed - Part Paid', donation.Stage__c, 'Donation record not updated');
            }
            Test.stopTest();
        }
    }

    @isTest
    private static void stageToCompletedPartPaidHasAcceptedStagePledgeTest(){
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            Test.startTest();
            //Get Created Donation Record
            List<Donation__c> donationsToUpdate = DonationsDAO.newInstance().getDonationsBySetRecordTypeIds(new Set<Id>{DonationsDAO.PLEDGE_RECTYPE_ID}, AccessLevel.USER_MODE);

            //Get Child Donation Records
            List<Donation__c> childDonations = DonationsDAO.newInstance().getDonationsBySetDonationParentIds(new Set<Id>{donationsToUpdate[0].Id}, AccessLevel.USER_MODE);

            childDonations[0].Stage__c = 'Accepted';
            DonationsDAO.newInstance().updateRecords(childDonations, false, AccessLevel.USER_MODE);

            //Update Donation Records to meet stage update conditions
            for(Donation__c donation : donationsToUpdate){
                donation.Stage__c = 'Completed - Part Paid';
            }           

            DonationsDAO.newInstance().updateRecords(donationsToUpdate, false, AccessLevel.USER_MODE);

            //Check if Stage has been updated
            List<Donation__c> donationsToCheck = DonationsDAO.newInstance().getDonationsBySetRecordIds((new Map<Id,SObject>(donationsToUpdate)).keySet(), AccessLevel.USER_MODE);
            for(Donation__c donation : donationsToCheck){
            	System.assertNotEquals('Completed - Part Paid', donation.Stage__c, 'Donation record not updated');
            }
            Test.stopTest();
        }
    }

    @isTest
    private static void stageToCancelledPledgeTest(){
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            Test.startTest();
            
            //Get Created Donation Records
            List<Donation__c> donationsToUpdate = DonationsDAO.newInstance().getDonationsBySetRecordTypeIds(new Set<Id>{DonationsDAO.PLEDGE_RECTYPE_ID}, AccessLevel.USER_MODE);

            //Get Child Donation Records
            List<Donation__c> childDonations = DonationsDAO.newInstance().getDonationsBySetDonationParentIds(new Set<Id>{donationsToUpdate[0].Id}, AccessLevel.USER_MODE);

            for(Donation__c childDon : childDonations){
                childDon.Stage__c = 'Accepted';
            } 
            DonationsDAO.newInstance().updateRecords(childDonations, false, AccessLevel.USER_MODE);

            //Update Donation Records to meet stage update conditions
            for(Donation__c donation : donationsToUpdate){
                donation.Cancellation_Comment__c = 'Test Cancelled Pledge';
                donation.Cancellation_Reason__c = 'Donor Requested Cancellation';
                donation.Stage__c = 'Cancelled';
            }           
            DonationsDAO.newInstance().updateRecords(donationsToUpdate, false, AccessLevel.USER_MODE);

            //Check if Stage has been updated
            List<Donation__c> donationsToCheck = DonationsDAO.newInstance().getDonationsBySetRecordIds((new Map<Id,SObject>(donationsToUpdate)).keySet(), AccessLevel.USER_MODE);
            for(Donation__c donation : donationsToCheck){
            	System.assertEquals('Cancelled', donation.Stage__c, 'Donation record not updated');
            }
            Test.stopTest();
        }
    }

    @isTest
    private static void stageToCancelledHasCompletedStagePledgeTest(){
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            Test.startTest();
            //Get Created Donation Records
            List<Donation__c> donationsToUpdate = DonationsDAO.newInstance().getDonationsBySetRecordTypeIds(new Set<Id>{DonationsDAO.PLEDGE_RECTYPE_ID}, AccessLevel.USER_MODE);

            //Update Donation Records to meet stage update conditions
            for(Donation__c donation : donationsToUpdate){
                donation.Stage__c = 'Cancelled';
            }           
            DonationsDAO.newInstance().updateRecords(donationsToUpdate, false, AccessLevel.USER_MODE);

            //Check if Stage has been updated
            List<Donation__c> donationsToCheck = DonationsDAO.newInstance().getDonationsBySetRecordIds((new Map<Id,SObject>(donationsToUpdate)).keySet(), AccessLevel.USER_MODE);
            for(Donation__c donation : donationsToCheck){
            	System.assertNotEquals('Cancelled', donation.Stage__c, 'Donation record not updated');
            }
            Test.stopTest();
        }
    }
    
    @isTest
    private static void stageToCancelledCauseTest(){
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            //Create 1 Designation Record to add to To_Designation__c field
            List<Designation__c> designationList = TestDataFactory.createDesignationRecords(1, DesignationsDAO.GIVING_TO_CAUSE_RECTYPE_ID);
            DesignationsDAO.newInstance()
                .insertRecords(designationList, false, AccessLevel.USER_MODE);
            
            //Create Donation Records
            List<Donation__c> donationList = TestDataFactory.createDonationRecordsWithRecordType(100,DonationsDAO.CAUSE_RECTYPE_ID);
            for(Donation__c donation : donationList){
                donation.Payment_Type__c = 'Recurring Payment';
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
                donation.Cancellation_Date__c = System.Today();
                donation.Cancellation_Reason__c = 'Designation Discontinued';
                donation.Cancellation_Comment__c = 'Test Record';
            }           
            DonationsDAO.newInstance().updateRecords(donationsToUpdate, false, AccessLevel.USER_MODE);

            //Check if Stage has been updated
            List<Donation__c> donationsToCheck = DonationsDAO.newInstance().getDonationsBySetRecordIds((new Map<Id,SObject>(donationsToUpdate)).keySet(), AccessLevel.USER_MODE);
            for(Donation__c donation : donationsToCheck){
            	System.assertEquals('Cancelled', donation.Stage__c, 'Donation record not updated');
            }
            Test.stopTest();
        }
    }
    
    @isTest
    private static void stageToCancelledCauseWithoutDateTest(){
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            //Create 1 Designation Record to add to To_Designation__c field
            List<Designation__c> designationList = TestDataFactory.createDesignationRecords(1, DesignationsDAO.GIVING_TO_CAUSE_RECTYPE_ID);
            DesignationsDAO.newInstance()
                .insertRecords(designationList, false, AccessLevel.USER_MODE);
            
            //Create Donation Records
            List<Donation__c> donationList = TestDataFactory.createDonationRecordsWithRecordType(100,DonationsDAO.CAUSE_RECTYPE_ID);
            for(Donation__c donation : donationList){
                donation.Payment_Type__c = 'Recurring Payment';
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
                donation.Stage__c = 'Cancelled';
                donation.Cancellation_Reason__c = 'Designation Discontinued';
                donation.Cancellation_Comment__c = 'Test Record';
            }           
            DonationsDAO.newInstance().updateRecords(donationsToUpdate, false, AccessLevel.USER_MODE);

            //Check if Stage has been updated
            List<Donation__c> donationsToCheck = DonationsDAO.newInstance().getDonationsBySetRecordIds((new Map<Id,SObject>(donationsToUpdate)).keySet(), AccessLevel.USER_MODE);
            for(Donation__c donation : donationsToCheck){
            	System.assertEquals(System.Today(), donation.Cancellation_Date__c, 'Donation record not updated');
            }
            Test.stopTest();
        }
    }

    @isTest
    private static void stageToCancelledEndowmentTest(){
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            Test.startTest();
            
            //Get Created Donation Records
            List<Donation__c> donationsToUpdate = DonationsDAO.newInstance().getDonationsBySetRecordTypeIds(new Set<Id>{DonationsDAO.ENDOWMENT_RECTYPE_ID}, AccessLevel.USER_MODE);

            //Get Child Donation Records
            List<Donation__c> childDonations = DonationsDAO.newInstance().getDonationsBySetDonationParentIds(new Set<Id>{donationsToUpdate[0].Id}, AccessLevel.USER_MODE);

            for(Donation__c childDon : childDonations){
                childDon.Stage__c = 'Accepted';
            } 
            DonationsDAO.newInstance().updateRecords(childDonations, false, AccessLevel.USER_MODE);

            //Update Donation Records to meet stage update conditions
            for(Donation__c donation : donationsToUpdate){
                donation.Cancellation_Comment__c = 'Test Cancelled Endowment';
                donation.Cancellation_Reason__c = 'Donor Requested Cancellation';
                donation.Stage__c = 'Cancelled';
            }           
            DonationsDAO.newInstance().updateRecords(donationsToUpdate, false, AccessLevel.USER_MODE);

            //Check if Stage has been updated
            List<Donation__c> donationsToCheck = DonationsDAO.newInstance().getDonationsBySetRecordIds((new Map<Id,SObject>(donationsToUpdate)).keySet(), AccessLevel.USER_MODE);
            for(Donation__c donation : donationsToCheck){
            	System.assertEquals('Cancelled', donation.Stage__c, 'Donation record not updated');
            }
            Test.stopTest();
        }
    }

    @isTest
    private static void stageToCancelledHasCompletedStageEndowmentTest(){
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            Test.startTest();
            //Get Created Donation Records
            List<Donation__c> donationsToUpdate = DonationsDAO.newInstance().getDonationsBySetRecordTypeIds(new Set<Id>{DonationsDAO.ENDOWMENT_RECTYPE_ID}, AccessLevel.USER_MODE);

            //Update Donation Records to meet stage update conditions
            for(Donation__c donation : donationsToUpdate){
                donation.Stage__c = 'Cancelled';
            }           
            DonationsDAO.newInstance().updateRecords(donationsToUpdate, false, AccessLevel.USER_MODE);

            //Check if Stage has been updated
            List<Donation__c> donationsToCheck = DonationsDAO.newInstance().getDonationsBySetRecordIds((new Map<Id,SObject>(donationsToUpdate)).keySet(), AccessLevel.USER_MODE);
            for(Donation__c donation : donationsToCheck){
            	System.assertNotEquals('Cancelled', donation.Stage__c, 'Donation record not updated');
            }
            Test.stopTest();
        }
    }

    @isTest
    private static void stageToCancelledChildDonationTest(){
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            Test.startTest();
            //Get Created Donation Records
            List<Donation__c> donationsToUpdate = DonationsDAO.newInstance().getDonationsBySetRecordTypeIds(new Set<Id>{DonationsDAO.ENDOWMENT_RECTYPE_ID}, AccessLevel.USER_MODE);

            //Get Child Donation Records
            List<Donation__c> childDonations = DonationsDAO.newInstance().getDonationsBySetDonationParentIds(new Set<Id>{donationsToUpdate[0].Id}, AccessLevel.USER_MODE);

            for(Donation__c childDon : childDonations){
                childDon.Stage__c = 'Accepted';
                childDon.Cancellation_Comment__c = 'Test';
                childDon.Cancellation_Reason__c = 'Variation';
            } 
            DonationsDAO.newInstance().updateRecords(childDonations, false, AccessLevel.USER_MODE);

            //Update Donation Records to meet stage update conditions
            for(Donation__c childDonationRecord : donationsToUpdate){
                childDonationRecord.Cancellation_Comment__c = 'Test Cancelled Endowment Child';
                childDonationRecord.Cancellation_Reason__c = 'Donor Requested Cancellation';
                childDonationRecord.Stage__c = 'Cancelled';
            }           
            DonationsDAO.newInstance().updateRecords(donationsToUpdate, false, AccessLevel.USER_MODE);

            //Check if Stage has been updated
            List<Donation__c> donationsToCheck = DonationsDAO.newInstance().getDonationsBySetRecordIds((new Map<Id,SObject>(donationsToUpdate)).keySet(), AccessLevel.USER_MODE);
            for(Donation__c donation : donationsToCheck){
            	System.assertEquals('Cancelled', donation.Stage__c, 'Donation record not updated');
            }
            Test.stopTest();
        }
    }
}