/**
 * @description Tests the Donation Cause Update - Custom Validation Flow
 *
 * @see Donation_Cause_Update_Custom_Validation_Flow
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
            Test.startTest();
            List<Donation_Cause__c> donationCauseList = TestDataFactory.createDonationCauseRecords(100);
            for(Donation_Cause__c donationCause : donationCauseList){
                donationCause.Is_For_Public_Giving__c = 'Yes';
                donationCause.QA_Completed__c = true;
                donationCause.QUT_Giving_Publish_Start_Date__c = Date.today();
            }
            DonationCausesDAO.newInstance().insertRecords(donationCauseList, false, AccessLevel.USER_MODE);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void checkProductDescription(){
        System.runAs(TestDataFactory.getAdvancementManager()){
            List<Donation_Cause__c> donationCauseList = DonationCausesDAO.newInstance().getDonationCauseByNameStart('Test Donation', AccessLevel.USER_MODE);
            Set<Id> donationCauseIdSet = (new Map<Id,SObject>(donationCauseList)).keySet();
            List<Product2> products = ProductsDAO.newInstance().getProductByDonationCauseId(donationCauseIdSet, AccessLevel.USER_MODE);
            
            Test.startTest();
            for(Product2 product : products){
				product.Description__c = '';
            	product.Title_Image_URL__c = 'test.com';
            }

            for(Donation_Cause__c donationCause : donationCauseList){
                donationCause.Ready_For_Publishing__c = true;
            }
            
            ProductsDAO.newInstance().updateRecords(products, false, AccessLevel.USER_MODE);
            DonationCausesDAO.newInstance().updateRecords(donationCauseList, false, AccessLevel.USER_MODE);
            
            List<Donation_Cause__c> donationCauseToCheck = DonationCausesDAO.newInstance().getDonationCausesBySetRecordIds(donationCauseIdSet, AccessLevel.USER_MODE);
            for(Donation_Cause__c donationCause : donationCauseToCheck){
                System.Assert(donationCause.Ready_For_Publishing__c == false, 'Donation cause was updated.');
            }
            Test.stopTest();
		}
    }
    
    @isTest
    public static void checkProductTitleImageURL(){
        System.runAs(TestDataFactory.getAdvancementManager()){
            List<Donation_Cause__c> donationCauseList = DonationCausesDAO.newInstance().getDonationCauseByNameStart('Test Donation', AccessLevel.USER_MODE);
            Set<Id> donationCauseIdSet = (new Map<Id,SObject>(donationCauseList)).keySet();
            List<Product2> products = ProductsDAO.newInstance().getProductByDonationCauseId(donationCauseIdSet, AccessLevel.USER_MODE);
            
            Test.startTest();
            for(Product2 product : products){
				product.Description__c = 'Test Description';
            }

            for(Donation_Cause__c donationCause : donationCauseList){
                donationCause.Ready_For_Publishing__c = true;
            }
            
            ProductsDAO.newInstance().updateRecords(products, false, AccessLevel.USER_MODE);
            DonationCausesDAO.newInstance().updateRecords(donationCauseList, false, AccessLevel.USER_MODE);
            
            List<Donation_Cause__c> donationCauseToCheck = DonationCausesDAO.newInstance().getDonationCausesBySetRecordIds(donationCauseIdSet, AccessLevel.USER_MODE);
            for(Donation_Cause__c donationCause : donationCauseToCheck){
                System.Assert(donationCause.Ready_For_Publishing__c == false, 'Donation cause was updated.');
            }
            Test.stopTest();
		}
    }
    
    @isTest
    public static void checkProductSection1Heading(){
        System.runAs(TestDataFactory.getAdvancementManager()){
            List<Donation_Cause__c> donationCauseList = DonationCausesDAO.newInstance().getDonationCauseByNameStart('Test Donation', AccessLevel.USER_MODE);
            Set<Id> donationCauseIdSet = (new Map<Id,SObject>(donationCauseList)).keySet();
            List<Product2> products = ProductsDAO.newInstance().getProductByDonationCauseId(donationCauseIdSet, AccessLevel.USER_MODE);
            
            Test.startTest();
            for(Product2 product : products){
				product.Description__c = 'Test Description';
                product.Title_Image_URL__c = 'imageurl.com';
                product.Has_Detail_Page__c = true;
                product.Section_1_Content__c = 'Test Content';
            }
		
            for(Donation_Cause__c donationCause : donationCauseList){
                donationCause.Ready_For_Publishing__c = true;
            }
            
            ProductsDAO.newInstance().updateRecords(products, false, AccessLevel.USER_MODE);
            DonationCausesDAO.newInstance().updateRecords(donationCauseList, false, AccessLevel.USER_MODE);
            
            List<Donation_Cause__c> donationCauseToCheck = DonationCausesDAO.newInstance().getDonationCausesBySetRecordIds(donationCauseIdSet, AccessLevel.USER_MODE);
            for(Donation_Cause__c donationCause : donationCauseToCheck){
                System.Assert(donationCause.Ready_For_Publishing__c == false, 'Donation cause was updated.');
            }
            Test.stopTest();
		}
    }
    
    @isTest
    public static void checkProductSection1Content(){
        System.runAs(TestDataFactory.getAdvancementManager()){
            List<Donation_Cause__c> donationCauseList = DonationCausesDAO.newInstance().getDonationCauseByNameStart('Test Donation', AccessLevel.USER_MODE);
            Set<Id> donationCauseIdSet = (new Map<Id,SObject>(donationCauseList)).keySet();
            List<Product2> products = ProductsDAO.newInstance().getProductByDonationCauseId(donationCauseIdSet, AccessLevel.USER_MODE);
            
            Test.startTest();
            for(Product2 product : products){
				product.Description__c = 'Test Description';
                product.Title_Image_URL__c = 'imageurl.com';
                product.Has_Detail_Page__c = true;
                product.Section_1_Heading__c = 'Test Heading';
            }
            
            for(Donation_Cause__c donationCause : donationCauseList){
                donationCause.Ready_For_Publishing__c = true;
            }
		
            ProductsDAO.newInstance().updateRecords(products, false, AccessLevel.USER_MODE);
            DonationCausesDAO.newInstance().updateRecords(donationCauseList, false, AccessLevel.USER_MODE);
            
            List<Donation_Cause__c> donationCauseToCheck = DonationCausesDAO.newInstance().getDonationCausesBySetRecordIds(donationCauseIdSet, AccessLevel.USER_MODE);
            for(Donation_Cause__c donationCause : donationCauseToCheck){
                System.Assert(donationCause.Ready_For_Publishing__c == false, 'Donation cause was updated.');
            }
            Test.stopTest();
		}
    }
}