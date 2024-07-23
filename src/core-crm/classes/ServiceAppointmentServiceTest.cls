/**
 * @description Test class for ServiceAppointmentService
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                    |
 *    |--------------------------------|-----------------------|------------------------|-----------------------------------|
 *    | nicole.genon                   | December 12, 2023     | DEPP-7259              | Created file                      |
 *    | ryan.j.a.dela.cruz             | December 14, 2023     | DEPP-7259              | Created file                      |
 */
@isTest
public with sharing class ServiceAppointmentServiceTest {
    private static final String QUT_WORK_TYPE = 'QUT team';
    private static final String TEST_ACCOUNT_NAME = 'TestAccount0';
    private static final List<String> FIELDS = new List<String>{'Alteration_URL__c', 'Appointment_Email__c', 'Web_Email__c', 'SchedStartTime', 'WorkTypeId', 'Description', 'First_Name__c', 'Last_Name__c', 'Mobile_Locale__c', 'Mobile_No_Locale__c', 'Appointment_Topic__c', 'Status'};

    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactoryUser.generateUserFutureStudentAgentDomestic();
        TestDataFactoryUser.generateUserFutureStudentAgentInternational();
        Test.stopTest();
     
        List<Account> accList = TestDataFactory.createTestAccountRecords(1);
        AccountsDAO.newInstance().insertRecords(accList, false, AccessLevel.SYSTEM_MODE);

        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
        	List<WorkType> workTypes = TestDataFactory.createTestWorkTypeRecords();
        	WorkTypesDAO.newInstance().insertRecords(workTypes, false, AccessLevel.SYSTEM_MODE);
        }
        
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentInternational) {
        	List<WorkType> workTypesInt = TestDataFactory.createTestWorkTypeRecords();
        	WorkTypesDAO.newInstance().insertRecords(workTypesInt, false, AccessLevel.SYSTEM_MODE);
            List<EmailTemplate> internationalEmailTemplate = TestDataFactory.createTestEmailTemplateRecords(1,new Map<String, String> {'Bookable Appointment - International Confirmation' => 'Appointment Confirmation'});

            for(EmailTemplate template : internationalEmailTemplate){
                template.Name = ServiceAppointmentService.CONFIRMATION_EMAIL_TEMPLATE_MAP.get(WorkTypesDAO.INTERNATIONAL_WORK_TYPE);
            }
            EmailTemplatesDAO.newInstance().insertRecords(internationalEmailTemplate,false, AccessLevel.SYSTEM_MODE);
        }

    }

    @isTest
    private static void sendConfirmationEmailToInternationalServiceAppointmentsTest() {
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentInternational) {
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
            ServiceAppointmentService.sendConfirmationEmailToInternationalServiceAppointments(serviceAppList);

            Test.stopTest();

            System.assert(serviceAppList.get(0).Id != null, 'Email is sent to the user');

            List<ServiceAppointment> insertedAppointment = ServiceAppointmentsDAO.newInstance().getServiceAppointmentsBySetIds(new Set<Id> {serviceAppList.get(0).Id},FIELDS,AccessLevel.SYSTEM_MODE);

            Scheduler_Configuration__mdt schedulerConfig = Scheduler_Configuration__mdt.getInstance('Default');
            if(schedulerConfig.Appointment_Base_URL__c != null){
                System.assert(insertedAppointment.get(0).Alteration_URL__c.contains(schedulerConfig.Appointment_Base_URL__c),'Alteration URL is not empty.');
            }

            System.assert(insertedAppointment.get(0).Appointment_Email__c.equals(insertedAppointment.get(0).Web_Email__c), 'Appointment Email is not null. Email is sent to the user.');
        }
    }

    @isTest
    private static void sendConfirmationEmailToDomesticServiceAppointmentsTest() {
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
            Test.startTest();

            List<WorkType> workTypeIds = WorkTypesDAO.newInstance().getWorkTypesBySetNames(new Set<String> {WorkTypesDAO.DOMESTIC_WORK_TYPE},AccessLevel.SYSTEM_MODE);
            List<Account> accList = AccountsDAO.newInstance().getAccountBySetNamesWithLimit(new Set<String> {TEST_ACCOUNT_NAME},1);
            List<ServiceAppointment> serviceAppList = TestDataFactory.createTestServiceAppointmentRecords(1,accList.get(0).Id);

            for(ServiceAppointment ap : serviceAppList){
                ap.Web_Email__c = 'nicolesample@mailinator.com';
                ap.Web_First_Name__c = 'Austin';
                ap.Web_Last_Name__c = 'Brisbane';
                ap.SchedStartTime = DateTime.Now().Addhours(3);
                ap.SchedEndTime = DateTime.Now().AddDays(3);
                ap.WorkTypeId = workTypeIds.get(0).Id;
                ap.description = 'This is an inquiry on QUT student enrolment.';
                ap.Status = 'Scheduled';
                ap.Appointment_Topic__c = 'My enrolment';
            }

            ServiceAppointmentsDAO.newInstance().insertRecords(serviceAppList, false, AccessLevel.USER_MODE);

            ServiceAppointmentService.sendConfirmationEmailToDomesticServiceAppointments(serviceAppList);

            Test.stopTest();

            System.assert(serviceAppList.get(0).Id != null, 'Email is sent to the user');

            List<ServiceAppointment> insertedAppointment = ServiceAppointmentsDAO.newInstance().getServiceAppointmentsBySetIds(new Set<Id> {serviceAppList.get(0).Id},FIELDS,AccessLevel.SYSTEM_MODE);

            Long timeDifferenceInMilliseconds = insertedAppointment.get(0).SchedStartTime.getTime() - DateTime.now().getTime();
            Integer hoursDifference = (Integer)Math.floor(timeDifferenceInMilliseconds / (1000 * 60 * 60));

            Scheduler_Configuration__mdt schedulerConfig = Scheduler_Configuration__mdt.getInstance('Default');
            if(schedulerConfig.Appointment_Base_URL__c != null){
                System.assert(insertedAppointment.get(0).Alteration_URL__c.contains(schedulerConfig.Appointment_Base_URL__c),'Alteration URL is not empty.');
            }

            System.assert(insertedAppointment.get(0).Appointment_Email__c.equals(insertedAppointment.get(0).Web_Email__c), 'Appointment Email is not null. Email is sent to the user.');
            System.assert(hoursDifference < 24, 'Service Appointment is less than 24 hours.');
        }
    }

    @isTest
    private static void sendEmailAfterServiceAppointmentCancellationTest() {

        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentInternational) {

            Test.startTest();

            List<WorkType> workTypeIds = WorkTypesDAO.newInstance().getWorkTypesBySetNames(new Set<String> {WorkTypesDAO.INTERNATIONAL_WORK_TYPE},AccessLevel.SYSTEM_MODE);
            List<WorkType> workTypeIdsDom = WorkTypesDAO.newInstance().getWorkTypesBySetNames(new Set<String> {WorkTypesDAO.DOMESTIC_WORK_TYPE},AccessLevel.SYSTEM_MODE);
            List<Account> accList = AccountsDAO.newInstance().getAccountBySetNamesWithLimit(new Set<String> {TEST_ACCOUNT_NAME},1);

            List<ServiceAppointment> serviceAppList = TestDataFactory.createTestServiceAppointmentRecords(1,accList.get(0).Id);
            List<ServiceAppointment> serviceAppListDom = TestDataFactory.createTestServiceAppointmentRecords(1,accList.get(0).Id);

            for(ServiceAppointment ap : serviceAppListDom){
                ap.Web_Email__c = 'nicolesample@mailinator.com';
                ap.Web_First_Name__c = 'Austin';
                ap.Web_Last_Name__c = 'Brisbane';
                ap.Status = 'Scheduled';
                ap.SchedStartTime = DateTime.Now().AddDays(1);
                ap.SchedEndTime = DateTime.Now().AddDays(3);
                ap.WorkTypeId = workTypeIdsDom.get(0).Id;
                ap.description = 'This is an inquiry on QUT student enrolment.';
                ap.Status = 'Scheduled';
                ap.Appointment_Topic__c = 'My enrolment';
            }

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
            ServiceAppointmentsDAO.newInstance().insertRecords(serviceAppListDom, false, AccessLevel.USER_MODE);

            Map<Id,ServiceAppointment> oldRecords = new Map<Id,ServiceAppointment>(ServiceAppointmentsDAO.newInstance().getServiceAppointmentsBySetIds(new Set<Id> {serviceAppList.get(0).Id,serviceAppListDom.get(0).Id},FIELDS,AccessLevel.SYSTEM_MODE));
            List<ServiceAppointment> serviceAppointment = ServiceAppointmentsDAO.newInstance().getServiceAppointmentsBySetIds(new Set<Id> {serviceAppList.get(0).Id,serviceAppListDom.get(0).Id},FIELDS,AccessLevel.SYSTEM_MODE);

            for(ServiceAppointment ap : serviceAppointment){
                ap.Status = 'Cancelled';
            }

            Database.SaveResult[] srList = Database.update(serviceAppointment);
            
            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record was not updated.');
            }

            ServiceAppointmentService.sendEmailAfterServiceAppointmentCancellation(serviceAppList,serviceAppListDom);

            List<ServiceAppointment> newItems = ServiceAppointmentsDAO.newInstance().getServiceAppointmentsBySetIds(new Set<Id> {serviceAppList.get(0).Id,serviceAppListDom.get(0).Id},FIELDS,AccessLevel.SYSTEM_MODE);

            Test.stopTest();

            System.assert(!newItems.get(0).Status.equals(oldRecords.get(serviceAppList.get(0).Id).Status), 'Service Appointment is Cancelled.');
            System.assert(newItems.get(0).Status.equals('Cancelled'), 'Service Appointment is Cancelled.');
        }
    }

    @isTest
    private static void sendConfirmationEmailToInternationalServiceAppointmentsFailedTest() {
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentInternational) {
            Test.startTest();

            List<WorkType> workTypeIds = WorkTypesDAO.newInstance().getWorkTypesBySetNames(new Set<String> {WorkTypesDAO.INTERNATIONAL_WORK_TYPE},AccessLevel.SYSTEM_MODE);
            List<Account> accList = AccountsDAO.newInstance().getAccountBySetNamesWithLimit(new Set<String> {TEST_ACCOUNT_NAME},1);

            List<ServiceAppointment> serviceAppList = TestDataFactory.createTestServiceAppointmentRecords(1,accList.get(0).Id);

            for(ServiceAppointment ap : serviceAppList){
                ap.Web_First_Name__c = 'Austin';
                ap.Web_Last_Name__c = 'Brisbane';
                ap.SchedStartTime = Datetime.newInstance(2023, 12, 10, 12, 9, 3);
                ap.SchedEndTime = DateTime.Now().AddDays(4);
                ap.WorkTypeId = workTypeIds.get(0).Id;
                ap.description = 'This is an inquiry on QUT student enrolment.';
                ap.Status = 'Scheduled';
                ap.Appointment_Topic__c = 'My enrolment';
            }

            ServiceAppointmentsDAO.newInstance().insertRecords(serviceAppList, false, AccessLevel.USER_MODE);
            ServiceAppointmentService.sendConfirmationEmailToInternationalServiceAppointments(serviceAppList);

            Test.stopTest();

            List<ServiceAppointment> insertedAppointment = ServiceAppointmentsDAO.newInstance().getServiceAppointmentsBySetIds(new Set<Id> {serviceAppList.get(0).Id},FIELDS,AccessLevel.SYSTEM_MODE);

            System.assert(serviceAppList.get(0).Id != null, 'Email is sent to the user');
            System.assert(insertedAppointment.get(0).Appointment_Email__c == null, 'Appointment Email is null. Email is not sent to the user.');
        }
    }
}
