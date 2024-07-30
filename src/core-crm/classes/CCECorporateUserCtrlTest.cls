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
        Test.startTest();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        Test.stopTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
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
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
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
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Contact contact = [SELECT Id FROM Contact LIMIT 1];
            Test.startTest();
            CCECorporateUserCtrl.CorporateUserDetails enableResponse = CCECorporateUserCtrl.enablePortalUser(contact.Id, CATEGORY_CCE);
            if(enableResponse.userId != null){
                enableResponse = CCECorporateUserCtrl.enablePortalUser(contact.Id, CATEGORY_OPE);
            }
            Test.stopTest();
            System.assertEquals(true, enableResponse.isSuccess, 'Enable and disable cce user failed.');
        }
    }

    @isTest
    static void enableCCECorporateUserForOPETest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Contact contact = [SELECT Id, FirstName, LastName, Registered_Email__c FROM Contact LIMIT 1];
            Test.startTest();
            CCECorporateUserCtrl.ContactDetails conDetails = new CCECorporateUserCtrl.ContactDetails();
            conDetails.recordId = contact.Id;
            conDetails.contactFirstName = contact.FirstName;
            conDetails.contactLastName = contact.LastName;
            conDetails.email = contact.Registered_Email__c;
            Id enableResponse = CCECorporateUserCtrl.enableCCECorporateUserForOPE(conDetails);
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
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Contact contact = [SELECT Id, FirstName, LastName, Registered_Email__c, AccountId, hed__Primary_Organization__c, hed__Primary_Organization__r.Name FROM Contact LIMIT 1];
            Test.startTest();
            CCECorporateUserCtrl.ContactDetails conDetails = new CCECorporateUserCtrl.ContactDetails();
            conDetails.recordId = contact.Id;
            conDetails.contactFirstName = contact.FirstName;
            conDetails.contactLastName = contact.LastName;
            conDetails.email = contact.Registered_Email__c;
            Id enableResponse = CCECorporateUserCtrl.enableCCECorporateUserForOPE(conDetails);
            CCECorporateUserCtrl.ExternalAccountDetails extAccDetails = new CCECorporateUserCtrl.ExternalAccountDetails();
            extAccDetails.accountId = contact.AccountId;
            extAccDetails.primaryBusinessAcctId = contact.hed__Primary_Organization__c;
            extAccDetails.accountName = contact.hed__Primary_Organization__r.Name;
            extAccDetails.userId = enableResponse;
            String extManageAcct = CCECorporateUserCtrl.createExtManagedAcct(extAccDetails);
            Test.stopTest();
            System.assertEquals('Success', extManageAcct, 'Enable and disable user failed.');
        }
     }

} 
