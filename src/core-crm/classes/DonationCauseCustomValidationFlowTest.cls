/**
 * @description Tests the Donation Cause Custom Validation Flow
 *
 * @see Donation_Cause_Custom_Validation_Flow
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA        | Change Summary                  |
      |---------------------------|-----------------------|-------------|---------------------------------|
      | kenneth.f.alsay           | March 27, 2024        | DEPP-8209   | Created file                    | 
      |                           |                       |             |                                 |
*/
@isTest
public class DonationCauseCustomValidationFlowTest {
    // * Description: This method is used to create initial data for the test methods
    @TestSetup
    public static void testSetup(){
        TestDataFactory.generateTestUsers(
            new List<String>{ 'QUT_Advancement_Manager'}
        );
        System.runAs(TestDataFactory.getAdvancementManager()){
            List<Donation_Cause__c> donationCauseList = TestDataFactory.createDonationCauseRecords(1);
            donationCauseList[0].Is_For_Public_Giving__c = 'Yes';
            donationCauseList[0].QA_Completed__c = true;
            donationCauseList[0].QUT_Giving_Publish_Start_Date__c = Date.today();
            DonationCausesDAO.newInstance().insertRecords(donationCauseList, false, AccessLevel.USER_MODE);
        }
    }
    
    @isTest
    public static void checkProductDescription(){
        System.runAs(TestDataFactory.getAdvancementManager()){
            List<Donation_Cause__c> donationCauseList = DonationCausesDAO.newInstance().getDonationCauseByNameStart('Test Donation', AccessLevel.USER_MODE);
            List<Product2> products = ProductsDAO.newInstance().getProductByDonationCauseId(new Set<Id>{ donationCauseList[0].Id }, AccessLevel.USER_MODE);
            
            Test.startTest();
            products[0].Description__c = '';
            products[0].Title_Image_URL__c = 'test.com';
		
            donationCauseList[0].Ready_For_Publishing__c = true;
            ProductsDAO.newInstance().updateRecords(products, false, AccessLevel.USER_MODE);
            DonationCausesDAO.newInstance().updateRecords(donationCauseList, false, AccessLevel.USER_MODE);
            
            List<Donation_Cause__c> donationCauseToCheck = DonationCausesDAO.newInstance().getDonationCausesBySetRecordIds(new Set<Id> {donationCauseList[0].Id}, AccessLevel.USER_MODE);
            System.Assert(donationCauseToCheck[0].Ready_For_Publishing__c == false, 'Donation cause was updated.');
            Test.stopTest();
		}
    }
    
    @isTest
    public static void checkProductTitleImageURL(){
        System.runAs(TestDataFactory.getAdvancementManager()){
            List<Donation_Cause__c> donationCauseList = DonationCausesDAO.newInstance().getDonationCauseByNameStart('Test Donation', AccessLevel.USER_MODE);
            List<Product2> products = ProductsDAO.newInstance().getProductByDonationCauseId(new Set<Id>{ donationCauseList[0].Id }, AccessLevel.USER_MODE);
            
            Test.startTest();
            products[0].Description__c = 'Test Description';
		
            donationCauseList[0].Ready_For_Publishing__c = true;
            ProductsDAO.newInstance().updateRecords(products, false, AccessLevel.USER_MODE);
            DonationCausesDAO.newInstance().updateRecords(donationCauseList, false, AccessLevel.USER_MODE);
            
            List<Donation_Cause__c> donationCauseToCheck = DonationCausesDAO.newInstance().getDonationCausesBySetRecordIds(new Set<Id> {donationCauseList[0].Id}, AccessLevel.USER_MODE);
            System.Assert(donationCauseToCheck[0].Ready_For_Publishing__c == false, 'Donation cause was updated.');
            Test.stopTest();
		}
    }
    
    @isTest
    public static void checkProductSection1Heading(){
        System.runAs(TestDataFactory.getAdvancementManager()){
            List<Donation_Cause__c> donationCauseList = DonationCausesDAO.newInstance().getDonationCauseByNameStart('Test Donation', AccessLevel.USER_MODE);
            List<Product2> products = ProductsDAO.newInstance().getProductByDonationCauseId(new Set<Id>{ donationCauseList[0].Id }, AccessLevel.USER_MODE);
            
            Test.startTest();
            products[0].Description__c = 'Test Description';
            products[0].Title_Image_URL__c = 'imageurl.com';
            products[0].Has_Detail_Page__c = true;
            products[0].Section_1_Heading__c = '';
			products[0].Section_1_Content__c = 'Test Content';
		
            donationCauseList[0].Ready_For_Publishing__c = true;
            ProductsDAO.newInstance().updateRecords(products, false, AccessLevel.USER_MODE);
            DonationCausesDAO.newInstance().updateRecords(donationCauseList, false, AccessLevel.USER_MODE);
            
            List<Donation_Cause__c> donationCauseToCheck = DonationCausesDAO.newInstance().getDonationCausesBySetRecordIds(new Set<Id> {donationCauseList[0].Id}, AccessLevel.USER_MODE);
            System.Assert(donationCauseToCheck[0].Ready_For_Publishing__c == false, 'Donation cause was updated.');
            Test.stopTest();
		}
    }
    
    @isTest
    public static void checkProductSection1Content(){
        System.runAs(TestDataFactory.getAdvancementManager()){
            List<Donation_Cause__c> donationCauseList = DonationCausesDAO.newInstance().getDonationCauseByNameStart('Test Donation', AccessLevel.USER_MODE);
            List<Product2> products = ProductsDAO.newInstance().getProductByDonationCauseId(new Set<Id>{ donationCauseList[0].Id }, AccessLevel.USER_MODE);
            
            Test.startTest();
            products[0].Description__c = 'Test Description';
            products[0].Title_Image_URL__c = 'imageurl.com';
            products[0].Has_Detail_Page__c = true;
            products[0].Section_1_Heading__c = 'Test Heading';
			products[0].Section_1_Content__c = '';
		
            donationCauseList[0].Ready_For_Publishing__c = true;
            ProductsDAO.newInstance().updateRecords(products, false, AccessLevel.USER_MODE);
            DonationCausesDAO.newInstance().updateRecords(donationCauseList, false, AccessLevel.USER_MODE);
            
            List<Donation_Cause__c> donationCauseToCheck = DonationCausesDAO.newInstance().getDonationCausesBySetRecordIds(new Set<Id> {donationCauseList[0].Id}, AccessLevel.USER_MODE);
            System.Assert(donationCauseToCheck[0].Ready_For_Publishing__c == false, 'Donation cause was updated.');
            Test.stopTest();
		}
    }
}