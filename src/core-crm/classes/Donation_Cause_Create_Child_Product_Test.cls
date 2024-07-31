/**
 * @description test class for Donation_Cause_Create_Child_Product Flow
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | kathleen.mae.caceres           | March, 20, 2024       | DEPP-8201              | Created file                 | 
 */
@isTest
private class Donation_Cause_Create_Child_Product_Test {
    public static final String DC_PUBLICGIVING = 'Yes';
    
    @testSetup
    static void setupData() {
        Test.startTest();
        TestDataFactoryUser.generateUserDonorEngagementManager();
        Test.stopTest();

        Donation_Cause_Code_Auto_Number__c donationCauseCodeAutoNum = DonationCauseCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
        donationCauseCodeAutoNum.Donation_Cause__c = 1;
        DonationCauseCodeAutoNumbersDAO.newInstance().upsertRecords(
            new List<Donation_Cause_Code_Auto_Number__c>{donationCauseCodeAutoNum}, 
            false, 
            AccessLevel.USER_MODE
        );
    }

    @isTest
    private static void forPublicGivingOnUpdate() {
        System.runAs(TestDataFactoryUser.selectUserDonorEngagementManager) {
            List<Donation_Cause__c> donationCauseList = TestDataFactory.createDonationCauseRecords(
                100
            );

            DonationCausesDAO.newInstance()
                .insertRecords(donationCauseList, false, AccessLevel.USER_MODE);

            for (Donation_Cause__c updateDC : donationCauseList) {
                updateDC.Is_For_Public_Giving__c = DC_PUBLICGIVING;
            }

            Test.startTest();
            DonationCausesDAO.newInstance()
                .updateRecords(donationCauseList, false, AccessLevel.USER_MODE);
            Test.stopTest();

            for (
                Donation_Cause__c eachDC : DonationCausesDAO.newInstance()
                    .getDonationCausesBySetRecordIds(
                        (new Map <Id, Donation_Cause__c>(donationCauseList)).keySet(),
                         AccessLevel.USER_MODE
                )
             ) {
                system.assert(!eachDC.Products__r.isEmpty(), 'Products should be created');   
            }
        }
    }
    
    @isTest
    private static void forPublicGivingOnInsert (){
        System.runAs(TestDataFactoryUser.selectUserDonorEngagementManager) {
            List<Donation_Cause__c> donationCauseList = TestDataFactory.createDonationCauseRecords(
                100
            );
	
            List<Donation_Cause__c> insertDC = new List <Donation_Cause__c> ();
            for (integer i = 0; i < donationCauseList.size(); i++)  {
			insertDC.add(
                new Donation_Cause__c(
                    Name = 'Test' + i,
                    Is_For_Public_Giving__c = 'Yes',
                    Donation_Cause_Description__c = 'Test_Desc' + i,
                    Activation_Start_Date__c = System.today()
                )
            );
            } 
            
            Test.startTest();
            DonationCausesDAO.newInstance()
                .insertRecords(insertDC, false, AccessLevel.USER_MODE);
            Test.stopTest();
            
            for (
                Donation_Cause__c eachDC : DonationCausesDAO.newInstance()
                    .getDonationCausesBySetRecordIds(
                        (new Map <Id, Donation_Cause__c>(insertDC)).keySet(),
                         AccessLevel.USER_MODE
                )
             ) {
                system.assert(!eachDC.Products__r.isEmpty(), 'Products should be created');   
            }
    }
    }
}