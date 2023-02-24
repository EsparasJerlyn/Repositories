/**
 * @description Tests Controller Class for CCECorporateUserCtrl
 * @see CCECorporateUserCtrl
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.karl.munoz            | August 12, 2022       | DEPP-3488              | Created file                 | 
      | eccarius.karl.munoz            | September 13, 2022    | DEPP-4096              | Added test methods           |  
      | eugene.andrew.abuan            | February 10, 2023     | DEPP-4991              | Removed Test Classes that has|
      |                                |                       |                        | error with future callouts   | 
 
 */
@isTest
public with sharing class CCECorporateUserCtrlTest {

    private static final String CATEGORY_CCE = 'Corporate Portal';
    private static final String CATEGORY_OPE = 'Product Catalogue';

    @testSetup
    static void makeData(){
        TestDataFactory.generateTestUsers();
        System.runAs(TestDataFactory.getProgramAdminUser()){
            Account account = new Account();
            account.Name = 'Test Account';
            account.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Organization').getRecordTypeId();
            insert account;

            Contact contact = new Contact();
            contact.FirstName = 'Test Fname';
            contact.LastName = 'Test Lname';
            contact.email = 'test@email.com';
            contact.Work_Email__c = 'test@workemail.com';
            contact.hed__Preferred_Email__c = 'Alternate Email';
            contact.hed__AlternateEmail__c = 'test@email.com';
            contact.Registered_Email__c = 'test@email.com';
            contact.AccountId = account.Id;
            insert contact;

            BuyerGroup bg = new BuyerGroup();
            bg.Name = 'OPE BuyerGroup';
            insert bg;
        }
    }

    @isTest
    static void enableOPEWithExistingTest(){
        System.runAs(TestDataFactory.getProgramAdminUser()){
            Contact contact = [SELECT Id FROM Contact LIMIT 1];
            Test.startTest();
            CCECorporateUserCtrl.CorporateUserDetails enableResponse = CCECorporateUserCtrl.enablePortalUser(contact.Id, CATEGORY_OPE);
            String response;
            if(enableResponse.userId != null){
                enableResponse = CCECorporateUserCtrl.enablePortalUser(contact.Id, CATEGORY_OPE);
            }
            if(enableResponse.userId != null){
                response = CCECorporateUserCtrl.disableCCECorporateUser(contact.Id);
            }
            Test.stopTest();
            System.assertEquals(true, enableResponse.isSuccess, 'Enable and disable cce user failed.');
        }
    }
    @isTest
    static void enableOPEWithExistingCCETest(){
        System.runAs(TestDataFactory.getProgramAdminUser()){
            Contact contact = [SELECT Id FROM Contact LIMIT 1];
            Test.startTest();
            CCECorporateUserCtrl.CorporateUserDetails enableResponse = CCECorporateUserCtrl.enablePortalUser(contact.Id, CATEGORY_CCE);
            String response;
            if(enableResponse.userId != null){
                enableResponse = CCECorporateUserCtrl.enablePortalUser(contact.Id, CATEGORY_OPE);
            }
            Test.stopTest();
            System.assertEquals(true, enableResponse.isSuccess, 'Enable and disable cce user failed.');
        }
    }

    @isTest
    static void enableCCECorporateUserForOPETest(){
        System.runAs(TestDataFactory.getProgramAdminUser()){
            Contact contact = [SELECT Id, FirstName, LastName, Registered_Email__c FROM Contact LIMIT 1];
            Test.startTest();
            Id enableResponse = CCECorporateUserCtrl.enableCCECorporateUserForOPE(contact.Id, contact.FirstName, contact.LastName, contact.Registered_Email__c);
            String response;
            if(enableResponse != null){
                response = CCECorporateUserCtrl.disableCCECorporateUser(contact.Id);
            }
            Test.stopTest();
            System.assertEquals('Success', response, 'Enable and disable user failed.');
        }
     }

    @isTest
    static void createExtManagedAcctTest(){ 
        System.runAs(TestDataFactory.getProgramAdminUser()){
            Contact contact = [SELECT Id, FirstName, LastName, Registered_Email__c, AccountId, hed__Primary_Organization__c, hed__Primary_Organization__r.Name FROM Contact LIMIT 1];
            Test.startTest();
            Id enableResponse = CCECorporateUserCtrl.enableCCECorporateUserForOPE(contact.Id, contact.FirstName, contact.LastName, contact.Registered_Email__c);
            String extManageAcct = CCECorporateUserCtrl.createExtManagedAcct(contact.AccountId, contact.hed__Primary_Organization__c, contact.hed__Primary_Organization__r.Name, enableResponse);
            Test.stopTest();
            System.assertEquals('Success', extManageAcct, 'Enable and disable user failed.');
        }
     }

}
