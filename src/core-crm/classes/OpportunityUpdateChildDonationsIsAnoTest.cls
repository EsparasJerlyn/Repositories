/**
 * @description Test Class for Opportunity - Update Child Donations Is Anonymous Flow
 *
 * @see ../flows/Opportunity - Update Child Donations Is Anonymous
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | kathleen.caceres@qut.edu.au    | May 21, 2024          | DEPP-8819 & DEPP-8820  | Created file                 | 
 */

 @isTest
 public class OpportunityUpdateChildDonationsIsAnoTest {

     @TestSetup
     static void setupData(){

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


             List<Opportunity> opportunityList = TestDataFactory.createTestOpportunityRecords(
                 2, accountRecord[0].Id, newContacts[0].Id);

             integer countNum = 0;
             for(Opportunity opportunityRecords : opportunityList) {
                 opportunityRecords.Description = 'Test';
                 opportunityRecords.ContactId = newContacts[0].Id;
                 opportunityRecords.Donor_Linkage_Rank__c = 'Low Level of Connection';
                 opportunityRecords.Donor_Interest_Rank__c = 'Unknown or not assessed';
                 opportunityRecords.Donor_Ability_Rank__c = '$250K - $500K';
                 opportunityRecords.Probability_Of_Success__c = '60%';
                 opportunityRecords.Qualification_Summary__c = 'Test';
                 opportunityRecords.Is_Qualified__c = true;
                 opportunityRecords.Solicitation_Sub_Stage__c = 'Agreement';
                 opportunityRecords.Due_Diligence_Summary__c = 'Test';
                 opportunityRecords.Due_Diligence_Completed__c = true;
                 opportunityRecords.Is_Agreement_Signed__c = true;
                 opportunityRecords.StageName = OpportunitiesDAO.SOLICITATION_STAGE;
                 opportunityRecords.Is_Anonymous_Opportunity__c = false;
                    opportunityRecords.RecordTypeId = (countNum == 0) ? OpportunitiesDAO.INDIVIDUAL_GIVING_RECTYPE_ID : OpportunitiesDAO.ORGANISATION_GIVING_RECTYPE_ID;
                 countNum++;
             }

             OpportunitiesDAO.newInstance().insertRecords(opportunityList, false, AccessLevel.USER_MODE);


             List<Designation__c> designationList = TestDataFactory.createDesignationRecords(1, DesignationsDAO.ENDOWNMENT_RECTYPE_ID);

             designationList[0].Endowment_Account_Type__c = 'Perpetual';
             DesignationsDAO.newInstance()
                 .insertRecords(designationList, false, AccessLevel.USER_MODE);


             List<Donation__c> donationList = TestDataFactory.createDonationRecordsWithRecordType(100,DonationsDAO.ENDOWMENT_RECTYPE_ID);
             Integer count = 0;
                 for(Donation__c donation : donationList){
                     donation.Payment_Type__c = 'Payment Plan';
                     donation.Stage__c = 'Proposed';
                     donation.Total_Amount__c = 1000;
                     donation.To_Designation__c = designationList[0].Id;
                     donation.Opportunity__c = (count < 51) ? opportunityList[0].Id : opportunityList[1].Id;
                     donation.Contact__c = (count < 51) ? opportunityList[0].Contact__c : opportunityList[1].Contact__c;
                     donation.Is_Anonymous_Donation__c = false;
                     count ++;
                 }
                 DonationsDAO.newInstance().insertRecords(donationList, false, AccessLevel.USER_MODE);
             }
     }


      @isTest
      private static void checkIsAnonymousIndividualOpportunityTest(){
           System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {

          Test.startTest();
            List<Opportunity> parentOpp = OpportunitiesDAO.newInstance().getOpportunityByRecordTypeIds(
                new Set<Id>{OpportunitiesDAO.INDIVIDUAL_GIVING_RECTYPE_ID}, AccessLevel.USER_MODE);

            parentOpp[0].Is_Anonymous_Opportunity__c = true;
            OpportunitiesDAO.newInstance().updateRecords(parentOpp, false, AccessLevel.USER_MODE);

            List<Donation__c> indvChildDonations = DonationsDAO.newInstance().getDonationsByOpportunityIds(
                (new Map<Id,SObject>(parentOpp)).keySet(), AccessLevel.USER_MODE);
            for(Donation__c indvDonation : indvChildDonations){
                System.assertEquals(true, indvdonation.Is_Anonymous_Donation__c, 'Child Donation should be updated');
            }
            Test.stopTest();
          }
     }


      @isTest
      private static void checkIsAnonymousOrganisationOpportunityTest(){
           System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
             Test.startTest();
             List<Opportunity> parentOpp = OpportunitiesDAO.newInstance().getOpportunityByRecordTypeIds(
                 new Set<Id>{OpportunitiesDAO.ORGANISATION_GIVING_RECTYPE_ID}, AccessLevel.USER_MODE);

             parentOpp[0].Is_Anonymous_Opportunity__c = true;
             OpportunitiesDAO.newInstance().updateRecords(parentOpp, false, AccessLevel.USER_MODE);

             List<Donation__c> orgChildDonations = DonationsDAO.newInstance().getDonationsByOpportunityIds(
                 (new Map<Id,SObject>(parentOpp)).keySet(), AccessLevel.USER_MODE);
             for(Donation__c orgDonation : orgChildDonations){
                 System.assertEquals(true, orgDonation.Is_Anonymous_Donation__c, 'Child Donation should be updated');
             }
             Test.stopTest();
           }
      }

 }