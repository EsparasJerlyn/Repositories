/**
 * @description Test class for ServiceAppointmentTriggerHandler
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                    |
      |--------------------------------|-----------------------|------------------------|-----------------------------------|
      | arsenio.jr.dayrit       	   | November 23, 2023     | DEPP-7264              | Created file                      | 
      | nicole.genon                   | November 23, 2023     | DEPP-7259              | Added test classes                |
      | arsenio.jr.dayrit       	   | November 12, 2023     | DEPP-7357              | Update Test method                |
 */
@isTest
public with sharing class ServiceAppointmentTriggerHandlerTest {
    private static final String QUT_WORK_TYPE = 'QUT team';
    private static final String TEST_ACCOUNT_NAME = 'TestAccount0';
    private static final List<String> FIELDS = new List<String>{'Appointment_Email__c', 'Web_Email__c', 'SchedStartTime', 'WorkTypeId', 'Description', 'First_Name__c', 'Last_Name__c', 'Mobile_Locale__c', 'Mobile_No_Locale__c', 'Appointment_Topic__c', 'Status'};
    
    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactory.generateTestUsers(new List<String>{'QUT_Domestic_Future_Student_Agent','QUT_International_Future_Student_Agent'});
     
        List<Account> accList = TestDataFactory.createTestAccountRecords(1);
        AccountsDAO.newInstance().insertRecords(accList, false, AccessLevel.SYSTEM_MODE);

        System.runAs(TestDataFactory.getDomesticFutureStudentAgent()) {
        	List<WorkType> workTypes = TestDataFactory.createTestWorkTypeRecords();
        	WorkTypesDAO.newInstance().insertRecords(workTypes, false, AccessLevel.SYSTEM_MODE);
        }
        
        System.runAs(TestDataFactory.getInternationalFutureStudentAgent()) {
        	List<WorkType> workTypesInt = TestDataFactory.createTestWorkTypeRecords();
        	WorkTypesDAO.newInstance().insertRecords(workTypesInt, false, AccessLevel.SYSTEM_MODE);
        }

        Test.stopTest();

    }

    @isTest
    private static void updateContactLeadLinkedtoServiceAppointmentBeforeInsertTest(){
        
        System.runAs(TestDataFactory.getInternationalFutureStudentAgent()) {
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
            serviceAppointmentList[0].Marketing_Consent__c = true;
            serviceAppointmentList[0].My_Citizenship_Status__c = 'International Student';
            serviceAppointmentList[0].My_Country_Of_Citizenship__c = 'Afghanistan';
            serviceAppointmentList[0].My_Country_Of_Residency__c = 'Afghanistan';
            ServiceAppointmentsDAO.newInstance().updateRecords(serviceAppointmentList, false, AccessLevel.SYSTEM_MODE);

            List<Contact> updatedContact = [SELECT Id, Email, Email_Opt_In_DateTime__c,ContactMobile_Locale__c, Mobile_No_Locale__c FROM Contact];
            List<Marketing_Segmentation__c> updatedMarketingSeg = MarketingSegmentationsDAO.newInstance().getMarketingSegmentationByContactOrLead(new Set<Id>{newContacts[0].Id}, new Set<Id>(), AccessLevel.SYSTEM_MODE);
            List<ServiceAppointment> serviceAppList = [SELECT Id,Email,Mobile_Locale__c,Mobile_No_Locale__c, My_Citizenship_Status__c, My_Country_Of_Citizenship__c, My_Country_Of_Residency__c FROM ServiceAppointment];

            System.assertEquals(serviceAppList[0].Email, updatedContact[0].Email, 'Email should be populated');
            System.assert(updatedContact[0].Email_Opt_In_DateTime__c != null, 'Email_Opt_In_DateTime__c should be populated');
            System.assertEquals(serviceAppList[0].Mobile_Locale__c, updatedContact[0].ContactMobile_Locale__c, 'ContactMobile_Locale__c should be populated');
            System.assertEquals(serviceAppList[0].Mobile_No_Locale__c, updatedContact[0].Mobile_No_Locale__c, 'Mobile_No_Locale__c should be populated');
            System.assertEquals(serviceAppList[0].My_Citizenship_Status__c, updatedMarketingSeg[0].My_Citizenship_Status__c, 'My_Citizenship_Status__c should be populated');
            System.assertEquals(serviceAppList[0].My_Country_Of_Citizenship__c, updatedMarketingSeg[0].My_Country_Of_Citizenship__c, 'My_Country_Of_Citizenship__c should be populated');
            System.assertEquals(serviceAppList[0].My_Country_Of_Residency__c, updatedMarketingSeg[0].My_Country_Of_Residency__c, 'My_Country_Of_Residency__c should be populated');
        }
    }

    @isTest
    private static void sendEmailOnInternationalServiceAppointmentCreation() {
        System.runAs(TestDataFactory.getInternationalFutureStudentAgent()) {
            Test.startTest();

            List<WorkType> workTypeIds = WorkTypesDAO.newInstance().getWorkTypesBySetNames(new Set<String> {WorkTypesDAO.INTERNATIONAL_WORK_TYPE},AccessLevel.SYSTEM_MODE);
            List<Account> accList = AccountsDAO.newInstance().getAccountBySetNamesWithLimit(new Set<String> {TEST_ACCOUNT_NAME},1);
            List<ServiceAppointment> serviceAppList = TestDataFactory.createTestServiceAppointmentRecords(1,accList.get(0).Id);

            for(ServiceAppointment ap : serviceAppList){
                ap.Web_Email__c = 'nicolesample@mailinator.com';
                ap.Web_First_Name__c = 'Austin';
                ap.Web_Last_Name__c = 'Brisbane';
                ap.SchedStartTime = DateTime.Now().AddDays(4);
                ap.SchedEndTime = DateTime.Now().AddDays(6);
                ap.WorkTypeId = workTypeIds.get(0).Id;
                ap.description = 'This is an inquiry on QUT student enrolment.';
                ap.Status = 'Scheduled';
                ap.Appointment_Topic__c = 'My enrolment';
            }

            ServiceAppointmentsDAO.newInstance().insertRecords(serviceAppList, false, AccessLevel.USER_MODE);

            Test.stopTest();
            
            System.assert(serviceAppList.get(0).Id != null, 'Email is sent to the user');

            List<ServiceAppointment> insertedAppointment = ServiceAppointmentsDAO.newInstance().getServiceAppointmentsBySetIds(new Set<Id> {serviceAppList.get(0).Id},FIELDS,AccessLevel.SYSTEM_MODE);

            System.assert(insertedAppointment.get(0).Appointment_Email__c.equals(insertedAppointment.get(0).Web_Email__c), 'Appointment Email is not null. Email is sent to the user.');
        }
    }

    @isTest
    private static void sendEmailOnDomesticServiceAppointmentCreation() {
        System.runAs(TestDataFactory.getDomesticFutureStudentAgent()) {
            Test.startTest();

            List<WorkType> workTypeIds = WorkTypesDAO.newInstance().getWorkTypesBySetNames(new Set<String> {WorkTypesDAO.DOMESTIC_WORK_TYPE},AccessLevel.SYSTEM_MODE);
            List<Account> accList = AccountsDAO.newInstance().getAccountBySetNamesWithLimit(new Set<String> {TEST_ACCOUNT_NAME},1);
            List<ServiceAppointment> serviceAppList = TestDataFactory.createTestServiceAppointmentRecords(1,accList.get(0).Id);

            for(ServiceAppointment ap : serviceAppList){
                ap.Web_Email__c = 'nicolesample@mailinator.com';
                ap.Web_First_Name__c = 'Austin';
                ap.Web_Last_Name__c = 'Brisbane';
                ap.SchedStartTime = DateTime.Now().AddDays(4);
                ap.SchedEndTime = DateTime.Now().AddDays(6);
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
    private static void sendEmailOnInternationalServiceAppointmentCreation48hours() {
        System.runAs(TestDataFactory.getInternationalFutureStudentAgent()) {
            Test.startTest();

            List<WorkType> workTypeIds = WorkTypesDAO.newInstance().getWorkTypesBySetNames(new Set<String> {WorkTypesDAO.INTERNATIONAL_WORK_TYPE},AccessLevel.SYSTEM_MODE);
            List<Account> accList = AccountsDAO.newInstance().getAccountBySetNamesWithLimit(new Set<String> {TEST_ACCOUNT_NAME},1);
            List<ServiceAppointment> serviceAppList = TestDataFactory.createTestServiceAppointmentRecords(1,accList.get(0).Id);

            for(ServiceAppointment ap : serviceAppList){
                ap.Web_Email__c = 'nicolesample@mailinator.com';
                ap.Web_First_Name__c = 'Austin';
                ap.Web_Last_Name__c = 'Brisbane';
                ap.SchedStartTime = DateTime.Now().AddDays(2);
                ap.SchedEndTime = DateTime.Now().AddDays(4);
                ap.WorkTypeId = workTypeIds.get(0).Id;
                ap.description = 'This is an inquiry on QUT student enrolment.';
                ap.Status = 'Scheduled';
                ap.Appointment_Topic__c = 'My enrolment';
            }

            ServiceAppointmentsDAO.newInstance().insertRecords(serviceAppList, false, AccessLevel.USER_MODE);

            Test.stopTest();
            
            System.assert(serviceAppList.get(0).Id != null, 'Email is sent to the user');

            List<ServiceAppointment> insertedAppointment = ServiceAppointmentsDAO.newInstance().getServiceAppointmentsBySetIds(new Set<Id> {serviceAppList.get(0).Id},FIELDS,AccessLevel.SYSTEM_MODE);

            Long timeDifferenceInMilliseconds = insertedAppointment.get(0).SchedStartTime.getTime() - DateTime.now().getTime();
            Integer hoursDifference = (Integer)Math.floor(timeDifferenceInMilliseconds / (1000 * 60 * 60));

            System.assert(insertedAppointment.get(0).Appointment_Email__c.equals(insertedAppointment.get(0).Web_Email__c), 'Appointment Email is not null. Email is sent to the user.');
            System.assert(hoursDifference < 48, 'Service Appointment is less than 48 hours.');
        }
    }

    @isTest
    private static void sendEmailOnDomesticServiceAppointmentCreation24hours() {
        System.runAs(TestDataFactory.getDomesticFutureStudentAgent()) {
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

            System.assert(serviceAppList.get(0).Id != null, 'Email is sent to the user');

            List<ServiceAppointment> insertedAppointment = ServiceAppointmentsDAO.newInstance().getServiceAppointmentsBySetIds(new Set<Id> {serviceAppList.get(0).Id},FIELDS,AccessLevel.SYSTEM_MODE);

            Long timeDifferenceInMilliseconds = insertedAppointment.get(0).SchedStartTime.getTime() - DateTime.now().getTime();
            Integer hoursDifference = (Integer)Math.floor(timeDifferenceInMilliseconds / (1000 * 60 * 60));

            System.assert(insertedAppointment.get(0).Appointment_Email__c.equals(insertedAppointment.get(0).Web_Email__c), 'Appointment Email is not null. Email is sent to the user.');
            System.assert(hoursDifference < 24, 'Service Appointment is less than 24 hours.');
        }
    }

    @isTest
    private static void sendEmailOnInternationalAfterUpdateReschedule() {

        System.runAs(TestDataFactory.getInternationalFutureStudentAgent()) {

            Test.startTest();

            List<WorkType> workTypeIds = WorkTypesDAO.newInstance().getWorkTypesBySetNames(new Set<String> {WorkTypesDAO.INTERNATIONAL_WORK_TYPE},AccessLevel.SYSTEM_MODE);
            List<Account> accList = AccountsDAO.newInstance().getAccountBySetNamesWithLimit(new Set<String> {TEST_ACCOUNT_NAME},1);

            List<ServiceAppointment> serviceAppList = TestDataFactory.createTestServiceAppointmentRecords(1,accList.get(0).Id);

            for(ServiceAppointment ap : serviceAppList){
                ap.Web_Email__c = 'nicolesample@mailinator.com';
                ap.Web_First_Name__c = 'Austin';
                ap.Web_Last_Name__c = 'Brisbane';
                ap.Status = 'Scheduled';
                ap.SchedStartTime = DateTime.Now().AddDays(1);
                ap.SchedEndTime = DateTime.Now().AddDays(3);
                ap.WorkTypeId = workTypeIds.get(0).Id;
                ap.description = 'This is an inquiry on QUT student enrolment.';
                ap.Status = 'Scheduled';
                ap.Appointment_Topic__c = 'My enrolment';
            }

            ServiceAppointmentsDAO.newInstance().insertRecords(serviceAppList, false, AccessLevel.USER_MODE);

            Map<Id,ServiceAppointment> oldRecords = new Map<Id,ServiceAppointment>(ServiceAppointmentsDAO.newInstance().getServiceAppointmentsBySetIds(new Set<Id> {serviceAppList.get(0).Id},FIELDS,AccessLevel.SYSTEM_MODE));
            List<ServiceAppointment> serviceAppointment = ServiceAppointmentsDAO.newInstance().getServiceAppointmentsBySetIds(new Set<Id> {serviceAppList.get(0).Id},FIELDS,AccessLevel.SYSTEM_MODE);
            serviceAppointment.get(0).SchedStartTime = DateTime.Now().AddDays(2);

            Database.SaveResult[] srList = Database.update(serviceAppointment);
            
            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record was not updated.');
            }

            List<ServiceAppointment> newItems = ServiceAppointmentsDAO.newInstance().getServiceAppointmentsBySetIds(new Set<Id> {serviceAppList.get(0).Id},FIELDS,AccessLevel.SYSTEM_MODE);

            Test.stopTest();

            System.assert(!newItems.get(0).SchedStartTime.isSameDay(oldRecords.get(serviceAppList.get(0).Id).SchedStartTime), 'Service Appointment is rescheduled.');
        }
    }

    @isTest
    private static void sendEmailOnDomesticAfterUpdateReschedule() {

        System.runAs(TestDataFactory.getDomesticFutureStudentAgent()) {

            Test.startTest();

            List<WorkType> workTypeIds = WorkTypesDAO.newInstance().getWorkTypesBySetNames(new Set<String> {WorkTypesDAO.DOMESTIC_WORK_TYPE},AccessLevel.SYSTEM_MODE);
            List<Account> accList = AccountsDAO.newInstance().getAccountBySetNamesWithLimit(new Set<String> {TEST_ACCOUNT_NAME},1);

            List<ServiceAppointment> serviceAppList = TestDataFactory.createTestServiceAppointmentRecords(1,accList.get(0).Id);

            for(ServiceAppointment ap : serviceAppList){
                ap.Web_Email__c = 'nicolesample@mailinator.com';
                ap.Web_First_Name__c = 'Austin';
                ap.Web_Last_Name__c = 'Brisbane';
                ap.Status = 'Scheduled';
                ap.SchedStartTime = DateTime.Now().AddDays(1);
                ap.SchedEndTime = DateTime.Now().AddDays(3);
                ap.WorkTypeId = workTypeIds.get(0).Id;
                ap.description = 'This is an inquiry on QUT student enrolment.';
                ap.Status = 'Scheduled';
                ap.Appointment_Topic__c = 'My enrolment';
            }

            ServiceAppointmentsDAO.newInstance().insertRecords(serviceAppList, false, AccessLevel.USER_MODE);

            Map<Id,ServiceAppointment> oldRecords = new Map<Id,ServiceAppointment>(ServiceAppointmentsDAO.newInstance().getServiceAppointmentsBySetIds(new Set<Id> {serviceAppList.get(0).Id},FIELDS,AccessLevel.SYSTEM_MODE));
            List<ServiceAppointment> serviceAppointment = ServiceAppointmentsDAO.newInstance().getServiceAppointmentsBySetIds(new Set<Id> {serviceAppList.get(0).Id},FIELDS,AccessLevel.SYSTEM_MODE);
            serviceAppointment.get(0).SchedStartTime = DateTime.Now().AddDays(2);

            Database.SaveResult[] srList = Database.update(serviceAppointment);
            
            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record was not updated.');
            }

            List<ServiceAppointment> newItems = ServiceAppointmentsDAO.newInstance().getServiceAppointmentsBySetIds(new Set<Id> {serviceAppList.get(0).Id},FIELDS,AccessLevel.SYSTEM_MODE);

            Test.stopTest();

            System.assert(!newItems.get(0).SchedStartTime.isSameDay(oldRecords.get(serviceAppList.get(0).Id).SchedStartTime), 'Service Appointment is rescheduled.');
        }
    }

    @isTest
    private static void sendEmailOnInternationalAfterUpdateCancellation() {

        System.runAs(TestDataFactory.getInternationalFutureStudentAgent()) {

            Test.startTest();

            List<WorkType> workTypeIds = WorkTypesDAO.newInstance().getWorkTypesBySetNames(new Set<String> {WorkTypesDAO.INTERNATIONAL_WORK_TYPE},AccessLevel.SYSTEM_MODE);
            List<Account> accList = AccountsDAO.newInstance().getAccountBySetNamesWithLimit(new Set<String> {TEST_ACCOUNT_NAME},1);

            List<ServiceAppointment> serviceAppList = TestDataFactory.createTestServiceAppointmentRecords(1,accList.get(0).Id);

            for(ServiceAppointment ap : serviceAppList){
                ap.Web_Email__c = 'nicolesample@mailinator.com';
                ap.Web_First_Name__c = 'Austin';
                ap.Web_Last_Name__c = 'Brisbane';
                ap.Status = 'Scheduled';
                ap.SchedStartTime = DateTime.Now().AddDays(1);
                ap.SchedEndTime = DateTime.Now().AddDays(3);
                ap.WorkTypeId = workTypeIds.get(0).Id;
                ap.description = 'This is an inquiry on QUT student enrolment.';
                ap.Status = 'Scheduled';
                ap.Appointment_Topic__c = 'My enrolment';
            }

            ServiceAppointmentsDAO.newInstance().insertRecords(serviceAppList, false, AccessLevel.USER_MODE);

            Map<Id,ServiceAppointment> oldRecords = new Map<Id,ServiceAppointment>(ServiceAppointmentsDAO.newInstance().getServiceAppointmentsBySetIds(new Set<Id> {serviceAppList.get(0).Id},FIELDS,AccessLevel.SYSTEM_MODE));
            List<ServiceAppointment> serviceAppointment = ServiceAppointmentsDAO.newInstance().getServiceAppointmentsBySetIds(new Set<Id> {serviceAppList.get(0).Id},FIELDS,AccessLevel.SYSTEM_MODE);
            serviceAppointment.get(0).Status = 'Cancelled';

            Database.SaveResult[] srList = Database.update(serviceAppointment);
            
            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record was not updated.');
            }

            List<ServiceAppointment> newItems = ServiceAppointmentsDAO.newInstance().getServiceAppointmentsBySetIds(new Set<Id> {serviceAppList.get(0).Id},FIELDS,AccessLevel.SYSTEM_MODE);

            Test.stopTest();

            System.assert(!newItems.get(0).Status.equals(oldRecords.get(serviceAppList.get(0).Id).Status), 'Service Appointment is Cancelled.');
            System.assert(newItems.get(0).Status.equals('Cancelled'), 'Service Appointment is Cancelled.');
        }
    }

    @isTest
    private static void sendEmailOnDomesticAfterUpdateCancellation() {

        System.runAs(TestDataFactory.getDomesticFutureStudentAgent()) {

            Test.startTest();

            List<WorkType> workTypeIds = WorkTypesDAO.newInstance().getWorkTypesBySetNames(new Set<String> {WorkTypesDAO.DOMESTIC_WORK_TYPE},AccessLevel.SYSTEM_MODE);
            List<Account> accList = AccountsDAO.newInstance().getAccountBySetNamesWithLimit(new Set<String> {TEST_ACCOUNT_NAME},1);

            List<ServiceAppointment> serviceAppList = TestDataFactory.createTestServiceAppointmentRecords(1,accList.get(0).Id);

            for(ServiceAppointment ap : serviceAppList){
                ap.Web_Email__c = 'nicolesample@mailinator.com';
                ap.Web_First_Name__c = 'Austin';
                ap.Web_Last_Name__c = 'Brisbane';
                ap.Status = 'Scheduled';
                ap.SchedStartTime = DateTime.Now().AddDays(1);
                ap.SchedEndTime = DateTime.Now().AddDays(3);
                ap.WorkTypeId = workTypeIds.get(0).Id;
                ap.description = 'This is an inquiry on QUT student enrolment.';
                ap.Status = 'Scheduled';
                ap.Appointment_Topic__c = 'My enrolment';
            }

            ServiceAppointmentsDAO.newInstance().insertRecords(serviceAppList, false, AccessLevel.USER_MODE);

            Map<Id,ServiceAppointment> oldRecords = new Map<Id,ServiceAppointment>(ServiceAppointmentsDAO.newInstance().getServiceAppointmentsBySetIds(new Set<Id> {serviceAppList.get(0).Id},FIELDS,AccessLevel.SYSTEM_MODE));
            List<ServiceAppointment> serviceAppointment = ServiceAppointmentsDAO.newInstance().getServiceAppointmentsBySetIds(new Set<Id> {serviceAppList.get(0).Id},FIELDS,AccessLevel.SYSTEM_MODE);
            serviceAppointment.get(0).Status = 'Cancelled';

            Database.SaveResult[] srList = Database.update(serviceAppointment);
            
            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record was not updated.');
            }

            List<ServiceAppointment> newItems = ServiceAppointmentsDAO.newInstance().getServiceAppointmentsBySetIds(new Set<Id> {serviceAppList.get(0).Id},FIELDS,AccessLevel.SYSTEM_MODE);

            Test.stopTest();

            System.assert(!newItems.get(0).Status.equals(oldRecords.get(serviceAppList.get(0).Id).Status), 'Service Appointment is Cancelled.');
            System.assert(newItems.get(0).Status.equals('Cancelled'), 'Service Appointment is Cancelled.');
        }
    }

    @isTest
    private static void sendEmailFailureOnServiceAppointmentCreation() {
        System.runAs(TestDataFactory.getInternationalFutureStudentAgent()) {
            Test.startTest();

            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
            msg.setSubject('Mock Test');

            ServiceAppointmentService.sendEmail(new List<Messaging.SingleEmailMessage> {msg});

            Test.stopTest();

            System.assert(msg != null,'Single Email Message is not empty');
        }
    }

    private static void generateGUIDTest() {
        System.runAs(TestDataFactory.getDomesticFutureStudentAgent()) {
            List<Account> accList = AccountsDAO.newInstance().getAccountBySetNamesWithLimit(new Set<String> {TEST_ACCOUNT_NAME},1);
            List<ServiceAppointment> newItems = TestDataFactory.createTestServiceAppointmentRecords(200, accList.get(0).Id);
            Test.startTest();
            ServiceAppointmentsDAO.newInstance().insertRecords(newItems, true, AccessLevel.USER_MODE);
            Test.stopTest();
            for(ServiceAppointment newItem : newItems) {
                System.assert(newItem.GUID__c != null, 'Failed to generate GUID for a record.');
            }
        }
    }

    private static void generateGUIDBeforeUpdateTest() {
        System.runAs(TestDataFactory.getDomesticFutureStudentAgent()) {
            List<Account> accList = AccountsDAO.newInstance().getAccountBySetNamesWithLimit(new Set<String> {TEST_ACCOUNT_NAME},1);
            List<ServiceAppointment> newItems = TestDataFactory.createTestServiceAppointmentRecords(200, accList.get(0).Id);
            for(ServiceAppointment serviceApp : newItems ){
                serviceApp.GUID__c = 'Test';
            }
            ServiceAppointmentsDAO.newInstance().insertRecords(newItems, true, AccessLevel.USER_MODE);
            Test.startTest();
            List<ServiceAppointment> serviceAppToUpdateList = new List<ServiceAppointment>(); 
            for(ServiceAppointment serviceAppToUpdate : newItems ){
                serviceAppToUpdate.GUID__c = null;
                serviceAppToUpdateList.add(serviceAppToUpdate);
            }
            ServiceAppointmentsDAO.newInstance().updateRecords(serviceAppToUpdateList, true, AccessLevel.USER_MODE);
            Test.stopTest();
            for(ServiceAppointment newItem : newItems) {
                System.assert(newItem.GUID__c != null, 'Failed to generate GUID for a record.');
            }
        }
    }
}
