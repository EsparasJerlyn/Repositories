/**
 * @description Test class for ServiceAppointmentTriggerHelper
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                            |
      |--------------------------------|-----------------------|------------------------|-----------------------------------------------------------|
      | arsenio.jr.dayrit              | November 23, 2023     | DEPP-7264              | Created file                                              | 
      | nicole.genon                   | November 24, 2023     | DEPP-7259              | Added Test classes                                        |
      | kenneth.f.alsay                | November 30, 2023     | DEPP-7265              | Added test methods for existing lead and contact matching |
      | arsenio.jr.dayrit              | December 12, 2023     | DEPP-7357              | Update Test method                                        |
      | kenneth.f.alsay                | December 27, 2023     | DEPP-7357              | Removed unused variable                                   |
      | sebastianne.k.trias            | June 20, 2024         | DEPP-8474              | Removed SA Opt In Functionality                           |
 */
@isTest
public with sharing class ServiceAppointmentTriggerHelperTest {
    private static final String TEST_ACCOUNT_NAME = 'TestAccount0';
    private static final List<String> FIELDS = new List<String>{'Appointment_Email__c', 'Web_Email__c', 'SchedStartTime','SchedEndTime', 'WorkTypeId', 'Description', 'First_Name__c', 'Last_Name__c', 'Mobile_Locale__c', 'Mobile_No_Locale__c', 'Appointment_Topic__c', 'Status', 'GUID__c'};
    private static final String FIRSTNAME = 'TestfirstName';
    private static final String LASTNAME = 'Testlastname';
    private static final String BIRTHDAY = '2000-06-28';

    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactoryUser.generateUserFutureStudentAgentDomestic();
        TestDataFactoryUser.generateUserFutureStudentAgentInternational();
        Test.stopTest();
        // create lead
        List<Lead> newLead = TestDataFactory.createTestLeadRecords(0,1);
        LeadsDAO.newInstance().insertRecords(newLead, true, AccessLevel.SYSTEM_MODE);

        List<Account> accList = TestDataFactory.createTestAccountRecords(1);
        AccountsDAO.newInstance().insertRecords(accList, false, AccessLevel.SYSTEM_MODE);

        List<Contact> conList = TestDataFactory.createTestContactRecords(1);
        ContactsDAO.newInstance().insertRecords(conList, false, AccessLevel.SYSTEM_MODE);

        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
        	List<WorkType> workTypes = TestDataFactory.createTestWorkTypeRecords();
        	WorkTypesDAO.newInstance().insertRecords(workTypes, false, AccessLevel.SYSTEM_MODE);
        }


    }

    @isTest
    private static void sendEmailOnDomesticServiceAppointmentCreation() {

        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
            Test.startTest();

            List<WorkType> workTypeIds = WorkTypesDAO.newInstance().getWorkTypesBySetNames(new Set<String> {WorkTypesDAO.DOMESTIC_WORK_TYPE},AccessLevel.SYSTEM_MODE);
            List<Account> accList = AccountsDAO.newInstance().getAccountBySetNamesWithLimit(new Set<String> {TEST_ACCOUNT_NAME},1);
            List<ServiceAppointment> serviceAppList = TestDataFactory.createTestServiceAppointmentRecords(1,accList.get(0).Id);

            for(ServiceAppointment ap : serviceAppList){
                ap.Web_Email__c = 'nicolesample@mailinator.com';
                ap.Web_First_Name__c = 'Austin';
                ap.Web_Last_Name__c = 'Brisbane';
                ap.SchedStartTime = DateTime.Now().AddDays(1);
                ap.SchedEndTime = DateTime.Now().AddDays(3);
                ap.WorkTypeId = workTypeIds.get(0).Id;
                ap.description = 'This is an inquiry on QUT student enrolment.';
                ap.Status = 'Scheduled';
                ap.Appointment_Topic__c = 'My enrolment';
            }

            ServiceAppointmentsDAO.newInstance().insertRecords(serviceAppList, false, AccessLevel.USER_MODE);

            Test.stopTest();

            List<ServiceAppointment> insertedAppointment = ServiceAppointmentsDAO.newInstance().getServiceAppointmentByAppointmentEmail('nicolesample@mailinator.com',AccessLevel.SYSTEM_MODE);

            System.assert(insertedAppointment.get(0).Appointment_Email__c.equals('nicolesample@mailinator.com'), 'Appointment Email is not null. Email is sent to the user.');
        }
    }

    @isTest
    private static void updateContactLinkedtoServiceAppointment(){
        
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentInternational) {
            Test.startTest();
            List<Contact> newContacts = TestDataFactory.createTestContactRecords(1);
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
            newContacts[0].hed__Citizenship_Status__c = 'International';
            update newContacts;

            List<Account> newAccounts = new List<Account>();
            newAccounts.add(TestDataFactory.createTestAccount(false));
            newAccounts[0].RecordTypeId = AccountsDAO.ACCT_UNIV_DEP_ID;
            AccountsDAO.newInstance().insertRecords(newAccounts, false, AccessLevel.SYSTEM_MODE);
			Test.stopTest();
            // the insertion of Service Appointment record is excluded in the startTest() and stopTest() because the trigger is dependent with asynchronous process from Contact trigger
            // to get the value of related marketing segmentation record of contact

            List<ServiceAppointment> serviceAppointmentList = TestDataFactory.createTestServiceAppointmentRecords(1, newAccounts[0].Id);
            ServiceAppointmentsDAO.newInstance().insertRecords(serviceAppointmentList, false, AccessLevel.SYSTEM_MODE);

            serviceAppointmentList[0].Contact__c = newContacts[0].Id;
            serviceAppointmentList[0].Email = 'testContact@mailinator.com';
            serviceAppointmentList[0].Web_Mobile_Locale__c = 'Australia (+61)';
            serviceAppointmentList[0].Web_Mobile_No_Locale__c = '11111';
            serviceAppointmentList[0].My_Citizenship_Status__c = 'International Student';
            serviceAppointmentList[0].My_Country_Of_Citizenship__c = 'Afghanistan';
            serviceAppointmentList[0].My_Country_Of_Residency__c = 'Afghanistan';
            ServiceAppointmentsDAO.newInstance().updateRecords(serviceAppointmentList, false, AccessLevel.SYSTEM_MODE);

            List<Contact> updatedContact = [SELECT Id, Email, ContactMobile_Locale__c, Mobile_No_Locale__c FROM Contact];
            List<Marketing_Segmentation__c> updatedMarketingSeg = MarketingSegmentationsDAO.newInstance().getMarketingSegmentationByContactOrLead(new Set<Id>{newContacts[0].Id}, new Set<Id>(), AccessLevel.SYSTEM_MODE);
            List<ServiceAppointment> serviceAppList = [SELECT Id,Email,Mobile_Locale__c,Mobile_No_Locale__c, My_Citizenship_Status__c, My_Country_Of_Citizenship__c, My_Country_Of_Residency__c FROM ServiceAppointment];
            
            System.assertEquals(serviceAppList[0].Email, updatedContact[0].Email, 'Email should be populated');
            System.assertEquals(serviceAppList[0].Mobile_Locale__c, updatedContact[0].ContactMobile_Locale__c, 'ContactMobile_Locale__c should be populated');
            System.assertEquals(serviceAppList[0].Mobile_No_Locale__c, updatedContact[0].Mobile_No_Locale__c, 'Mobile_No_Locale__c should be populated');
            System.assertEquals(serviceAppList[0].My_Citizenship_Status__c, updatedMarketingSeg[0].My_Citizenship_Status__c, 'My_Citizenship_Status__c should be populated');
            System.assertEquals(serviceAppList[0].My_Country_Of_Citizenship__c, updatedMarketingSeg[0].My_Country_Of_Citizenship__c, 'My_Country_Of_Citizenship__c should be populated');
            System.assertEquals(serviceAppList[0].My_Country_Of_Residency__c, updatedMarketingSeg[0].My_Country_Of_Residency__c, 'My_Country_Of_Residency__c should be populated');
        }
    }

    @isTest
    private static void updateLeadLinkedtoServiceAppointment(){
        
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentInternational) {
            List<Lead> leadList = LeadsDAO.newInstance().getLeadsWithLimit(1);
            List<Marketing_Segmentation__c> marSegList = MarketingSegmentationsDAO.newInstance().getMarketingSegmentationByLeadIds(new Set<Id>{leadList[0].Id},AccessLevel.SYSTEM_MODE);
            List<Marketing_Segmentation__c> marsSegToUpdate = new List<Marketing_Segmentation__c>();
            marsSegToUpdate.add(new Marketing_Segmentation__c(Id = marSegList[0].Id, My_Citizenship_Status__c = 'International Student'));
            MarketingSegmentationsDAO.newInstance().updateRecords(marsSegToUpdate,true,AccessLevel.SYSTEM_MODE);
            
            leadList = LeadsDAO.newInstance().getLeadsWithLimit(1);

            List<Account> newAccounts = new List<Account>();
            newAccounts.add(TestDataFactory.createTestAccount(false));
            newAccounts[0].RecordTypeId = AccountsDAO.ACCT_UNIV_DEP_ID;
            AccountsDAO.newInstance().insertRecords(newAccounts, false, AccessLevel.SYSTEM_MODE);

            Test.startTest();
            List<ServiceAppointment> serviceAppointmentList = TestDataFactory.createTestServiceAppointmentRecords(1, newAccounts[0].Id);
            ServiceAppointmentsDAO.newInstance().insertRecords(serviceAppointmentList, false, AccessLevel.SYSTEM_MODE);

            serviceAppointmentList[0].LeadId__c = leadList[0].Id;
            serviceAppointmentList[0].Email = 'testLead@mailinator.com';
            serviceAppointmentList[0].Web_Mobile_Locale__c = 'Australia (+61)';
            serviceAppointmentList[0].Web_Mobile_No_Locale__c = '11111';
            serviceAppointmentList[0].My_Citizenship_Status__c = 'International Student';
            serviceAppointmentList[0].My_Country_Of_Citizenship__c = 'Afghanistan';
            serviceAppointmentList[0].My_Country_Of_Residency__c = 'Afghanistan';
            ServiceAppointmentsDAO.newInstance().updateRecords(serviceAppointmentList, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();

        
            List<Lead> updatedLead = [SELECT Id, Email, LeadMobile_Locale__c, Mobile_No_Locale__c FROM Lead];
            List<Marketing_Segmentation__c> updatedMarketingSeg = MarketingSegmentationsDAO.newInstance().getMarketingSegmentationByContactOrLead(new Set<Id>(), new Set<Id>{leadList[0].Id}, AccessLevel.SYSTEM_MODE);
            List<ServiceAppointment> serviceAppList = [SELECT Id,Email,Mobile_Locale__c,Mobile_No_Locale__c, My_Citizenship_Status__c, My_Country_Of_Citizenship__c, My_Country_Of_Residency__c FROM ServiceAppointment];

            System.assertEquals(serviceAppList[0].Email, updatedLead[0].Email, 'Email should be populated');
            System.assertEquals(serviceAppList[0].Mobile_Locale__c, updatedLead[0].LeadMobile_Locale__c, 'LeadMobile_Locale__c should be populated');
            System.assertEquals(serviceAppList[0].Mobile_No_Locale__c, updatedLead[0].Mobile_No_Locale__c, 'Mobile_No_Locale__c should be populated');
            System.assertEquals(serviceAppList[0].My_Citizenship_Status__c, updatedMarketingSeg[0].My_Citizenship_Status__c, 'My_Citizenship_Status__c should be populated');
            System.assertEquals(serviceAppList[0].My_Country_Of_Citizenship__c, updatedMarketingSeg[0].My_Country_Of_Citizenship__c, 'My_Country_Of_Citizenship__c should be populated');
            System.assertEquals(serviceAppList[0].My_Country_Of_Residency__c, updatedMarketingSeg[0].My_Country_Of_Residency__c, 'My_Country_Of_Residency__c should be populated');
        }

    }

    private static List<Lead> createTestLeadRecords(Integer startAtCount, Integer endBeforeCount) {
        List<Lead> newLeads = new List<Lead>();
        for (Integer i = startAtCount; i < endBeforeCount; i++) {
            newLeads.add(
                new Lead(
                    FirstName = FIRSTNAME,
                    LastName = LASTNAME + i,
                    Company = 'Learner' + i
                )
            );
        }
        return newLeads;
    }

    @isTest
    private static void sendEmailAfterUpdateCancellationOrReschedule() {

        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {

            Test.startTest();

            List<WorkType> workTypeIds = WorkTypesDAO.newInstance().getWorkTypesBySetNames(new Set<String> {WorkTypesDAO.DOMESTIC_WORK_TYPE},AccessLevel.SYSTEM_MODE);
            List<Account> accList = AccountsDAO.newInstance().getAccountBySetNamesWithLimit(new Set<String> {TEST_ACCOUNT_NAME},1);

            List<ServiceAppointment> serviceAppList = TestDataFactory.createTestServiceAppointmentRecords(2,accList.get(0).Id);

            for(ServiceAppointment ap : serviceAppList){
                ap.Web_Email__c = 'nicolesample@mailinator.com';
                ap.Web_First_Name__c = 'Austin';
                ap.Web_Last_Name__c = 'Brisbane';
                ap.Status = 'Scheduled';
                ap.SchedStartTime = DateTime.Now().AddDays(1);
                ap.SchedEndTime = DateTime.Now().AddDays(3);
                ap.WorkTypeId = workTypeIds.get(0).Id;
                ap.description = 'This is an inquiry on QUT student enrolment.';
                ap.Appointment_Topic__c = 'My enrolment';
            }

            ServiceAppointmentsDAO.newInstance().insertRecords(serviceAppList, false, AccessLevel.USER_MODE);

            List<ServiceAppointment> serviceAppointments = ServiceAppointmentsDAO.newInstance().getServiceAppointmentsBySetIds(new Set<Id> {serviceAppList[0].Id, serviceAppList[1].Id}, FIELDS, AccessLevel.SYSTEM_MODE);
            serviceAppointments[0].Status = 'Cancelled';
            serviceAppointments[1].SchedStartTime = DateTime.now().addDays(2);
            
            Database.SaveResult[] srList = Database.update(serviceAppointments);
            
            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record was not updated.');
            }

            Test.stopTest();
            
            System.assert(serviceAppList.get(0).Id != null, 'Email is sent to the user');

            List<ServiceAppointment> insertedAppointment = ServiceAppointmentsDAO.newInstance().getServiceAppointmentByAppointmentEmail('nicolesample@mailinator.com',AccessLevel.SYSTEM_MODE);

            System.assert(insertedAppointment.get(0).Appointment_Email__c.equals('nicolesample@mailinator.com'), 'Appointment Email is not null. Email is sent to the user.');
        }
    }    
    
    @isTest
    private static void testAppointmentEmailMatchToContactEmail() {
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
            Test.startTest();
            List<Account> newAccounts = new List<Account>();
            newAccounts.add(TestDataFactory.createTestAccount(false));
            newAccounts[0].RecordTypeId = AccountsDAO.ACCT_UNIV_DEP_ID;
            AccountsDAO.newInstance().insertRecords(newAccounts, false, AccessLevel.SYSTEM_MODE);
            
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].Email = '1testmail@mail.test';
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);
            
            List<ServiceAppointment> serviceAppointmentList = TestDataFactory.createTestServiceAppointmentRecords(1, newAccounts[0].Id);
            serviceAppointmentList[0].Email = '1testmail@mail.test';
            serviceAppointmentList[0].Contact__c = null;
            serviceAppointmentList[0].Web_Mobile_Locale__c = 'Australia (+61)';
            serviceAppointmentList[0].Web_Mobile_No_Locale__c = '11111';
            serviceAppointmentList[0].My_Citizenship_Status__c = 'International Student';
            serviceAppointmentList[0].My_Country_Of_Citizenship__c = 'Afghanistan';
            serviceAppointmentList[0].My_Country_Of_Residency__c = 'Afghanistan';
            ServiceAppointmentsDAO.newInstance().insertRecords(serviceAppointmentList, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();
                    
            List<ServiceAppointment> appointmentRecordList = [SELECT Id, Contact__c FROM ServiceAppointment WHERE Email = '1testmail@mail.test' WITH USER_MODE LIMIT 1];
            System.assert(appointmentRecordList[0].Contact__c !=null, 'Service Appointment is not link to existing contact.');            
        }
    }
    
    @isTest
    private static void testAppointmentEmailMatchToLeadEmail() {
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
            Test.startTest();
            
            List<Lead> leadList = TestDataFactory.createTestLeadRecords(6,7);
            LeadsDAO.newInstance().insertRecords(leadList, true, AccessLevel.USER_MODE);
            
            List<Account> newAccounts = new List<Account>();
            newAccounts.add(TestDataFactory.createTestAccount(false));
            newAccounts[0].RecordTypeId = AccountsDAO.ACCT_UNIV_DEP_ID;
            AccountsDAO.newInstance().insertRecords(newAccounts, false, AccessLevel.SYSTEM_MODE);
            
            List<ServiceAppointment> serviceAppointmentList = TestDataFactory.createTestServiceAppointmentRecords(1, newAccounts[0].Id);
            serviceAppointmentList[0].Email = '6testmail@mail.test';
            serviceAppointmentList[0].Web_Mobile_Locale__c = 'Australia (+61)';
            serviceAppointmentList[0].Web_Mobile_No_Locale__c = '11111';
            serviceAppointmentList[0].My_Citizenship_Status__c = 'International Student';
            serviceAppointmentList[0].My_Country_Of_Citizenship__c = 'Afghanistan';
            serviceAppointmentList[0].My_Country_Of_Residency__c = 'Afghanistan';
            ServiceAppointmentsDAO.newInstance().insertRecords(serviceAppointmentList, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();
                    
            List<ServiceAppointment> appointmentRecordList = [SELECT Id, LeadId__c FROM ServiceAppointment WHERE Email = '6testmail@mail.test' WITH USER_MODE LIMIT 1];
            System.assert(appointmentRecordList[0].LeadId__c !=null, 'Service Appointment is not link to existing lead.');
        }
    } 

    @isTest
    private static void generateGUIDTest() {
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
            List<Account> accList = AccountsDAO.newInstance().getAccountBySetNamesWithLimit(new Set<String> {TEST_ACCOUNT_NAME},1);
            List<ServiceAppointment> newItems = TestDataFactory.createTestServiceAppointmentRecords(200, accList.get(0).Id);
            Test.startTest();
            ServiceAppointmentTriggerHelper.generateGUID(newItems);
            Test.stopTest();
            for(ServiceAppointment newItem : newItems) {
                System.assert(newItem.GUID__c != null, 'Failed to generate GUID for a record.');
            }
        }
    }
}