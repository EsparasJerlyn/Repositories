/**
 * @description Test class for EmployeeSelfRegistration Ctrl
 *
 * @see ../lwc/productDetailsDisplay
 * 
 * @author Accenture
 *      
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                                         |
      |---------------------------|-----------------------|----------------------|--------------------------------------------------------|
      | eugene.andrew.abuan       | July 27, 2022         | DEPP-2730            | Created file                                           |
      | alexander.cadalin         | Sep 29, 2022          | DEPP-4464            | Changed assertion to match new logic                   | 
*/
@isTest
public with sharing class EmployeeSelfRegistrationCtrlTest {
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();

    
    @testSetup
    static void makeData(){
        TestDataFactory.generateTestUsers();
    }

    @isTest
    private static void sendEmployeeRegistrationEmailTest()
    {
        final User PORTAL_SYS_ADMIN = TestDataFactory.getPortalSysAdminUser();
        System.runAs ( PORTAL_SYS_ADMIN ) {

            //Create account
            Account portalAccount1 = new Account(
            Name = 'TestAccount',
            OwnerId = PORTAL_SYS_ADMIN.Id
            );
            Database.insert(portalAccount1);

            //Create contact
            Contact contact1 = new Contact(
            FirstName = 'Test',
            Lastname = 'McTesty',
            AccountId = portalAccount1.Id,
            Work_Email__c = System.now().millisecond() + 'test@test.com',
            hed__Preferred_Email__c = 'Alternate Email',
            hed__AlternateEmail__c = 'testqtest@emailemail.com'
            );
            Database.insert(contact1);

            //Create user
            User portalUser = TestDataFactory.createPortalUserRecords(1,'Corporate Partner User',contact1.Id).iterator().next();
            Database.insert(portalUser);

            List<Account> accounts;
            List<hed__Term__c> terms;
            List<Product_Request__c> prodRequest;
            List<hed__Course__c> courses;
            List<hed__Program_Plan__c> programPlans;
            List<Program_Offering__c> programOfferings;
            List<Product2> products;


            accounts = TestDataFactory.createTestAccountRecords(1);
            for(Account acc : accounts){
                acc.RecordTypeId = ACCT_UNIV_DEP_ID;
                acc.Organization_Unit_Level__c = '2';
            }
            insert accounts;
            terms = TestDataFactory.createTestTermRecords(25,accounts[0].Id);
            insert terms;
            prodRequest = TestDataFactory.createTestProductRequestRecords(1);
            insert prodRequest;
            programPlans = TestDataFactory.createTestProgramPlanRecords(25);
            insert programPlans;
            programOfferings = TestDataFactory.createTestProgramOfferingRecords(25, programPlans);
            for(Program_Offering__c pOffering : programOfferings){
                pOffering.Name = 'Program Offering_Test 1';
                pOffering.hed_Program_Plan__c = programPlans[0].Id;
                pOffering.Delivery_Type__c = 'Online Classroom';
                pOffering.hed_Capacity__c = 30;
                pOffering.Start_Date__c = system.today() + 1;
                pOffering.Registration_Start_Date__c = system.today() - 1;
                pOffering.IsActive__c = true;
            }
            insert programOfferings;
            courses = TestDataFactory.createTestCourseRecords(10,accounts[0].Id,prodRequest[0].Id);
            insert courses;
            products = TestDataFactory.createTestProductRecords(10,courses);
            for (Product2 pProd : products) {
                pProd.Delivery__c = 'Online Classroom;Online Self-paced;Brisbane Classroom';
                pProd.Available_on_Cart__c = true;
            }
            insert products;

            EmployeeSelfRegistrationForm__c employeeSelfRegistrationSettings = new EmployeeSelfRegistrationForm__c(EmployeeSelfRegistrationLink__c = 'https://qut.tfaforms.net/f/employee-self-registration-form-dev');
            insert employeeSelfRegistrationSettings;
            
            Test.startTest();
            EmployeeSelfRegistrationCtrl.SelfRegistrationParams selfRegistrationParams = new EmployeeSelfRegistrationCtrl.SelfRegistrationParams();
            selfRegistrationParams.userId = portalUser.Id;
            selfRegistrationParams.productId = products[0].Id;
            selfRegistrationParams.selectedOffering = programOfferings[0].Id;
            selfRegistrationParams.pricebookEntryId = '';

            String email = EmployeeSelfRegistrationCtrl.sendEmployeeRegistrationEmail(selfRegistrationParams, accounts[0].Id);
            System.assertEquals(email, 'success', 'No email has been sent');
            Test.stopTest();
        }
    }
}