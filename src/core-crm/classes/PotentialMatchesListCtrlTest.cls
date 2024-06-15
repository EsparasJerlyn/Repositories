/**
 * @description Test Class for PotentialMatchesListCtrl
 *
 * @see PotentialMatchesListCtrl
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                    |
      |--------------------------------|-----------------------|------------------------|---------------------------------------------------|
      | neil.s.h.lesidan               | September 20, 2023    | DEPP-6478              | Created file                                      |
      | neil.s.h.lesidan               | November 23, 2023     | DEPP-7280              | Include Service Appointment in Potential Matches  |
 */
@isTest
private class PotentialMatchesListCtrlTest {
    private static final String FIRSTNAME = 'first';
    private static final String LASTNAME = 'last';
    private static final String EMAIL = 'firstlast@mail.test';
    private static final String PHONE = '1234567';

    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactoryUser.generateUserFutureStudentAgentDomestic();
        TestDataFactoryUser.generateUserFutureStudentSuperTeamLeaderDomestic();
        Test.stopTest();
        List<WorkType> workTypes = TestDataFactory.createTestWorkTypeRecords();
        System.runAs(TestDataFactoryUser.selectUserFutureStudentSuperTeamLeaderDomestic){
            WorkTypesDAO.newInstance().insertRecords(workTypes, false, AccessLevel.USER_MODE);
        }
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
            List<Account> accList = TestDataFactory.createTestAccountRecords(1);
            AccountsDAO.newInstance().insertRecords(accList, false, AccessLevel.USER_MODE);

            List<ServiceAppointment> serviceAppList = TestDataFactory.createTestServiceAppointmentRecords(1, accList[0].Id);

            for (ServiceAppointment ap : serviceAppList) {
                ap.Email = Email;
                ap.SchedStartTime = DateTime.Now().AddDays(1);
                ap.SchedEndTime = DateTime.Now().AddDays(3);
                ap.WorkTypeId = workTypes[0].Id;
                ap.description = 'This is an inquiry on QUT student enrolment.';
                ap.Status = 'Scheduled';
                ap.Appointment_Topic__c = 'My enrolment';
            }

            ServiceAppointmentsDAO.newInstance().insertRecords(serviceAppList, false, AccessLevel.USER_MODE);

            List<Case> cases = new List<Case>();
            cases.add(
                new Case(
                    Status = 'New',
                    Subject = 'Test Case',
                    SuppliedEmail = EMAIL,
                    Description = 'Test Case Description',
                    Origin = 'Email',
                    SuppliedPhone = PHONE
                )
            );

            CasesDAO.newInstance().insertRecords(cases, false, AccessLevel.SYSTEM_MODE);

            List<Contact> conList = TestDataFactory.createTestContactRecords(1, ContactsDAO.CITIZENSHIP_STATUS_DOMESTIC);
            conList[0].FirstName = FIRSTNAME;
            conList[0].LastName = LASTNAME;
            conList[0].Email = EMAIL;
            conList[0].MobilePhone = PHONE;
            ContactsDAO.newInstance().insertRecords(conList, false, AccessLevel.SYSTEM_MODE);

            List<Lead> leadList = TestDataFactory.createTestLeadRecords(1);
            leadList[0].FirstName = FIRSTNAME;
            leadList[0].LastName = LASTNAME;
            leadList[0].Email = EMAIL;
            leadList[0].MobilePhone = PHONE;
            LeadsDAO.newInstance().insertRecords(leadList, false, AccessLevel.SYSTEM_MODE);
        }
    }

    @isTest
    private static void testGetPossibleMatchEnquery() {
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
            Test.startTest();

            List<Case> caseList = CasesDAO.newInstance().getCaseBySuppliedEmail(EMAIL, AccessLevel.USER_MODE);

            String caseId = '';
            if (!caseList.isEmpty()) {
                caseId = caseList[0].Id;
            }

            Map<String, List<SObject>> possibleMatchList = PotentialMatchesListCtrl.getPossibleMatchEnquery(caseId, 'Case');

            Test.stopTest();

            System.assertNotEquals(0, possibleMatchList.get('Contact').size(), 'Contact array should not be empty');
            System.assertNotEquals(0, possibleMatchList.get('Lead').size(), 'Lead array should not be empty');
        }
    }

    @isTest
    private static void testPossibleMatchServiceAppointmentContactLead() { // DEPP-7280 AC-1 and AC-2
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
            Test.startTest();

            List<ServiceAppointment> serviceAppointmentList = ServiceAppointmentsDAO.newInstance().getServiceAppointmentByEmail(EMAIL, AccessLevel.SYSTEM_MODE);

            String serviceAppointmentId = '';
            if (!serviceAppointmentList.isEmpty()) {
                serviceAppointmentId = serviceAppointmentList[0].Id;
            }

            Map<String, List<SObject>> possibleMatchList = PotentialMatchesListCtrl.getPossibleMatchEnquery(serviceAppointmentId, 'ServiceAppointment');

            Test.stopTest();

            System.assertNotEquals(0, possibleMatchList.get('Contact').size(), 'Contact array should not be empty');
            System.assertNotEquals(0, possibleMatchList.get('Lead').size(), 'Lead array should not be empty');
        }
    }

    @isTest
    private static void testLinkToCaseContact() {
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
            Test.startTest();

            List<Case> caseList = CasesDAO.newInstance().getCaseBySuppliedEmail(EMAIL, AccessLevel.USER_MODE);
            ContactsDAO.QueryParamWrapperEmailOrName contactQueryParam = new ContactsDAO.QueryParamWrapperEmailOrName(
                EMAIL, '', '', PHONE
            );

            List<SObject> contactList =  ContactsDAO.newInstance().getPersonContactsByEmailOrName(contactQueryParam, AccessLevel.USER_MODE);
            String contactId = '';
            String caseId = '';

            if (!contactList.isEmpty()) {
                contactId = contactList[0].Id;
            }

            if (!caseList.isEmpty()) {
                caseId = caseList[0].Id;
            }

            Boolean updatedCase = PotentialMatchesListCtrl.linkToObject(caseId, contactId, 'Contact', 'Case');

            Test.stopTest();

            System.assertNotEquals(false, updatedCase, 'Updating Case Contact is not successful');
        }
    }

    @isTest
    private static void testLinkToServiceAppointmentContact() { // DEPP-7280 AC-5 Contact
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
            Test.startTest();

            List<ServiceAppointment> serviceAppointmentList = ServiceAppointmentsDAO.newInstance().getServiceAppointmentByEmail(EMAIL, AccessLevel.SYSTEM_MODE);
            ContactsDAO.QueryParamWrapperEmailOrName contactQueryParam = new ContactsDAO.QueryParamWrapperEmailOrName(
                EMAIL, '', '', PHONE
            );

            List<SObject> contactList =  ContactsDAO.newInstance().getPersonContactsByEmailOrName(contactQueryParam, AccessLevel.USER_MODE);
            String contactId = '';
            String serviceAppointmentId = '';

            if (!contactList.isEmpty()) {
                contactId = contactList[0].Id;
            }

            if (!serviceAppointmentList.isEmpty()) {
                serviceAppointmentId = serviceAppointmentList[0].Id;
            }

            Boolean updatedupdatePotentialMatches = PotentialMatchesListCtrl.linkToObject(serviceAppointmentId, contactId, 'Contact', 'ServiceAppointment');

            Test.stopTest();

            System.assertNotEquals(false, updatedupdatePotentialMatches, 'Updating Service Appointment Contact is not successful');
        }
    }

    @isTest
    private static void testLinkToServiceAppointmentLead() { // DEPP-7280 AC-5 Lead
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
            Test.startTest();

            List<ServiceAppointment> serviceAppointmentList = ServiceAppointmentsDAO.newInstance().getServiceAppointmentByEmail(EMAIL, AccessLevel.SYSTEM_MODE);
            LeadsDAO.QueryParamWrapperEmailOrName leadQueryParam = new LeadsDAO.QueryParamWrapperEmailOrName(
                EMAIL, '', '', PHONE
            );

            List<SObject> leadList = LeadsDAO.newInstance().getLeadByEmailOrName(leadQueryParam, true, AccessLevel.USER_MODE);
            String leadId = '';
            String serviceAppointmentId = '';

            if (!leadList.isEmpty()) {
                leadId = leadList[0].Id;
            }

            if (!serviceAppointmentList.isEmpty()) {
                serviceAppointmentId = serviceAppointmentList[0].Id;
            }

            Boolean updatedupdatePotentialMatches = PotentialMatchesListCtrl.linkToObject(serviceAppointmentId, leadId, 'Lead', 'ServiceAppointment');

            Test.stopTest();

            System.assertNotEquals(false, updatedupdatePotentialMatches, 'Updating Service Appointment Lead is not successful');
        }
    }

    @isTest
    private static void testLinkToCaseLead() {
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
            Test.startTest();

            List<Case> caseList = CasesDAO.newInstance().getCaseBySuppliedEmail(EMAIL, AccessLevel.USER_MODE);
            LeadsDAO.QueryParamWrapperEmailOrName leadQueryParam = new LeadsDAO.QueryParamWrapperEmailOrName(
                EMAIL, '', '', ''
            );

            List<SObject> leadList =  LeadsDAO.newInstance().getLeadByEmailOrName(leadQueryParam, true, AccessLevel.USER_MODE);

            String leadId = '';
            String caseId = '';

            if (!leadList.isEmpty()) {
                leadId = leadList[0].Id;
            }

            if (!caseList.isEmpty()) {
                caseId = caseList[0].Id;
            }

            Boolean updatedCase = PotentialMatchesListCtrl.linkToObject(caseId, leadId, 'Lead', 'Case');

            Test.stopTest();

            System.assertNotEquals(false, updatedCase, 'Updating Case Lead is not successful');
        }
    }

    @isTest
    private static void testLinkToCaseLeadFailed() {
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
            Test.startTest();

            Boolean updatedCase = PotentialMatchesListCtrl.linkToObject('', '', '', '');

            Test.stopTest();

            System.assertEquals(false, updatedCase, 'Updating Case Contact/Lead successful');
        }
    }
}