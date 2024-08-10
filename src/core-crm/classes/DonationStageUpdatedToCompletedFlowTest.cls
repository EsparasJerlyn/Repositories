/**
* @description test class for Donation Stage Update flow
* 
* @author Accenture
*
* @history
*
*    | Developer Email                | Date                  | JIRA                   | Change Summary                                           |
     |--------------------------------|-----------------------|------------------------|----------------------------------------------------------|
     | kenneth.f.alsay                | May 10, 2024          | DEPP-8566              | Created file                                             |
*/
@isTest
public class DonationStageUpdatedToCompletedFlowTest {
    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactoryUser.generateUserAdvancementManager();
        Test.stopTest();
        
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            //Create Account record
            List<Account> accountRecord = TestDataFactory.createTestAccountRecordsWithRecordType(1, AccountsDAO.ACCT_UNIV_DEP_ID);
            accountRecord[0].Organization_Unit_Level__c ='2';
            accountRecord[0].End_Date__c = null;
            AccountsDAO.newInstance().insertRecords(accountRecord, false, AccessLevel.SYSTEM_MODE);
            
            //Create Contact Record and link to Account
            List<Contact> newContacts = TestDataFactory.createTestContactRecords(1);
            newContacts[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            newContacts[0].AccountId = accountRecord[0].Id;
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);
            
            //Create Opportunity with Individual Giving Record Type and link contact
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
            
            //Create Designation record
            List<Designation__c> designationList = TestDataFactory.createDesignationRecords(1, DesignationsDAO.ENDOWNMENT_RECTYPE_ID);
            
            designationList[0].Endowment_Account_Type__c = 'Perpetual';
            DesignationsDAO.newInstance()
                .insertRecords(designationList, false, AccessLevel.USER_MODE);
            
            //Create Donation record with Endowment record type
            List<Donation__c> endowmentDonationList = TestDataFactory.createDonationRecordsWithRecordType(1,DonationsDAO.ENDOWMENT_RECTYPE_ID);
            for(Donation__c donation : endowmentDonationList){
                donation.Payment_Type__c = 'Payment Plan';
                donation.Stage__c = 'Accepted';
                donation.Total_Amount__c = 1000;
                donation.To_Designation__c = designationList[0].Id;
                donation.Opportunity__c = individualOpportunityRecords[0].Id;
                donation.Contact__c = individualOpportunityRecords[0].Contact__c;
            }
            DonationsDAO.newInstance().insertRecords(endowmentDonationList, false, AccessLevel.USER_MODE);
            
            //Create Donation record with Pledge record type
            List<Donation__c> pledgeDonationList = TestDataFactory.createDonationRecordsWithRecordType(2,DonationsDAO.PLEDGE_RECTYPE_ID);
            for(Donation__c donation : pledgeDonationList){
                donation.Payment_Type__c = 'Payment Plan';
                donation.Stage__c = 'Accepted';
                donation.Total_Amount__c = 1000;
                donation.To_Designation__c = designationList[0].Id;
                donation.Opportunity__c = individualOpportunityRecords[0].Id;
                donation.Contact__c = individualOpportunityRecords[0].Contact__c;
            }
            DonationsDAO.newInstance().insertRecords(pledgeDonationList, false, AccessLevel.USER_MODE);
        }
    }
    
    @isTest
    private static void parentEndowmentStageUpdateTest(){
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            //Get Endowment Donation record
            List<Donation__c> endowmentDonationsToUpdate = DonationsDAO.newInstance().getDonationsBySetRecordTypeIds(new Set<Id>{DonationsDAO.ENDOWMENT_RECTYPE_ID}, AccessLevel.USER_MODE);
            
            //Create child Donation record with Endowment Instalment record type
            List<Donation__c> donationChildList = TestDataFactory.createDonationRecordsWithRecordType(100,DonationsDAO.ENDOWMENT_INSTALMENT_RECTYPE_ID);
            Integer endowmentInstalmentCount = 0;
            for(Donation__c donationChild : donationChildList){
                donationChild.Payment_Type__c = 'Payment Plan';
                donationChild.Total_Amount__c = 200;
                donationChild.To_Designation__c = endowmentDonationsToUpdate[0].To_Designation__c;
                donationChild.Contact__c = endowmentDonationsToUpdate[0].Contact__c;
                donationChild.Donation_Parent__c = endowmentDonationsToUpdate[0].Id;
                donationChild.Instalment_Date__c = System.Today();
                if(endowmentInstalmentCount==0){
                    donationChild.Stage__c = 'Accepted';
                }else if(endowmentInstalmentCount > 0 && endowmentInstalmentCount < 50){
                    donationChild.Stage__c = 'Completed';
                }else if(endowmentInstalmentCount >= 50){
                    donationChild.Stage__c = 'Cancelled';
                }
                endowmentInstalmentCount++;
            }
            DonationsDAO.newInstance().insertRecords(donationChildList, false, AccessLevel.USER_MODE);
            
            Test.startTest();
            //Update child endowment to trigger flow
            donationChildList[0].Stage__c = 'Completed';
            DonationsDAO.newInstance().updateRecords(new List<Donation__c> {donationChildList[0]}, false, AccessLevel.USER_MODE);
            
            List<Donation__c> donationsToCheck = DonationsDAO.newInstance().getDonationsBySetRecordIds((new Map<Id,SObject>(endowmentDonationsToUpdate)).keySet(), AccessLevel.USER_MODE);

            //Check if parent endowment donation has been updated to completed
            System.assertEquals('Completed', donationsToCheck[0].Stage__c, 'Donation record not updated');
            Test.stopTest();
        }
    }
    
    @isTest
    private static void parentPledgeStageUpdateTest(){
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            //Get Endowment Donation record
            List<Donation__c> pledgeParentList = DonationsDAO.newInstance().getDonationsBySetRecordTypeIds(new Set<Id>{DonationsDAO.PLEDGE_RECTYPE_ID}, AccessLevel.USER_MODE);
            
            //Create child Donation record with Pledge Instalment record type
            List<Donation__c> pledgeInstalmentList = TestDataFactory.createDonationRecordsWithRecordType(100,DonationsDAO.PLEDGE_INSTALMENT_RECTYPE_ID);
            Integer childCount = 0;
            for(Donation__c donationChild : pledgeInstalmentList){
                donationChild.Payment_Type__c = 'Payment Plan';
                donationChild.Total_Amount__c = 200;
                donationChild.To_Designation__c = pledgeParentList[0].To_Designation__c;
                donationChild.Contact__c = pledgeParentList[0].Contact__c;
                donationChild.Donation_Parent__c = pledgeParentList[0].Id;
                donationChild.Instalment_Date__c = System.Today();
                donationChild.Stage__c = (childCount < 1)? 'Accepted' : 'Completed';
                childCount++;
            }
            DonationsDAO.newInstance().insertRecords(pledgeInstalmentList, false, AccessLevel.USER_MODE);
            
            //Create child donation records with Pledge Designation Split record type
			List<Donation__c> pledgeDesignationSplitList = TestDataFactory.createDonationRecordsWithRecordType(100,DonationsDAO.PLEDGE_DESIGNATION_SPLIT_RECTYPE_ID);
            childCount = 0;
            for(Donation__c donationChild : pledgeDesignationSplitList){
                donationChild.Payment_Type__c = 'Payment Plan';
                donationChild.Total_Amount__c = 200;
                donationChild.To_Designation__c = pledgeParentList[1].To_Designation__c;
                donationChild.Contact__c = pledgeParentList[1].Contact__c;
                donationChild.Donation_Parent__c = pledgeParentList[1].Id;
                donationChild.Instalment_Date__c = System.Today();                
                donationChild.Stage__c = (childCount < 1)? 'Accepted' : 'Completed';
                childCount++;
            }
            DonationsDAO.newInstance().insertRecords(pledgeDesignationSplitList, false, AccessLevel.USER_MODE);
            
            Test.startTest();
            
            //Update child records to trigger flow
            pledgeInstalmentList[0].Stage__c = 'Completed';
            pledgeDesignationSplitList[0].Stage__c = 'Completed';
            DonationsDAO.newInstance().updateRecords(new List<Donation__c> {pledgeInstalmentList[0]}, false, AccessLevel.USER_MODE);
            DonationsDAO.newInstance().updateRecords(new List<Donation__c> {pledgeDesignationSplitList[0]}, false, AccessLevel.USER_MODE);
            
            List<Donation__c> donationsToCheck = DonationsDAO.newInstance().getDonationsBySetRecordIds((new Map<Id,SObject>(pledgeParentList)).keySet(), AccessLevel.USER_MODE);
            //Check if parent pledge donation has been updated to completed
            for(Donation__c donationParent : donationsToCheck){
            	System.assertEquals('Completed', donationParent.Stage__c, 'Donation record not updated');
            }
            Test.stopTest();
        }
    }
}