/**
 * @description Test Class for MainNavigationMenuAccountCtrl
 * @see ../classes/MainNavigationMenuAccountCtrl
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                 | Change Summary              |
      |--------------------------------|-----------------------|----------------------|-----------------------------|
      | eccarius.karl.munoz            | February 1, 2023      | DEPP-5113            | Created  Test Class         | 
      |                                |                       |                      |                             | 
 */
@isTest
public with sharing class MainNavigationMenuAccountCtrlTest {

    private static final Id BUSINESS_ACC_RECTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Organization').getRecordTypeId();

    @testSetup 
    static void setupMethod() {
        Test.startTest();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        TestDataFactoryUser.generateUserQUTCorporatePartnerUser();
        Test.stopTest();
    }

    @isTest
    public static void getAllChildAccounts(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){

            Account parentAccount = new Account();
            parentAccount.RecordTypeId = BUSINESS_ACC_RECTYPEID;
            parentAccount.Name = 'Parent Account';
            insert parentAccount;

            Integer counter = 0;
            List<Account> childAccounts = TestDataFactory.createTestAccountRecords(2);
            for (Account account : childAccounts) {
            	account.RecordTypeId = BUSINESS_ACC_RECTYPEID;
                account.Name = counter + ' Account for Child Account Test';
                account.ParentId = parentAccount.Id;
                counter = counter + 1;
            }   
            insert childAccounts;

            Contact contact = new Contact();
            contact.FirstName = 'Test Fname';
            contact.LastName = 'Test Lname';
            contact.email = 'test@email.com';
            contact.Work_Email__c = 'test@workemail.com';
            contact.hed__Preferred_Email__c = 'Alternate Email';
            contact.hed__AlternateEmail__c = 'test@email.com';
            contact.Registered_Email__c = 'test@email.com';
            contact.AccountId = parentAccount.Id;
            insert contact;

            Test.startTest();

            BuyerGroup bg = new BuyerGroup();
            bg.Name = 'OPE BuyerGroup';
            insert bg;

            CCECorporateUserCtrl.enablePortalUser(contact.Id, 'Corporate Portal');
            User user = [SELECT Name, Username FROM User WHERE ContactId =: contact.Id LIMIT 1];

            System.runAs(TestDataFactoryUser.selectUserQUTCorporatePartnerUser){
                Id selectedId;
                MainNavigationMenuAccountCtrl.UserAccountOptionWrapper getAcct = MainNavigationMenuAccountCtrl.getAllRelatedBusinessAccountOfUser(user.Id, selectedId);
                System.assert(!getAcct.accountOptions.isEmpty(), 'No acccount names retrieve');
            }
            
            Test.stopTest();
        }
    }
}