/**
 * @description Test Class for CasePotentialMatchesListCtrl
 *
 * @see CasePotentialMatchesListCtrl
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                   |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------------|
      | neil.s.h.lesidan               | September 20, 2023    | DEPP-6478              | Created file                                     |
 */
@isTest
private class CasePotentialMatchesListCtrlTest {
    private static final String FIRSTNAME = 'first';
    private static final String LASTNAME = 'last';
    private static final String EMAIL = 'firstlast@mail.test';
    private static final String PHONE = '1234567';

    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });
        System.runAs(TestDataFactory.getProgramAdminUser()) {

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

            List<Contact> conList = TestDataFactory.createTestContactRecords(1);
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
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();

            List<Case> caseList = CasesDAO.newInstance().getCaseBySuppliedEmail(EMAIL, AccessLevel.USER_MODE);

            String caseId = '';
            if (!caseList.isEmpty()) {
                caseId = caseList[0].Id;
            }

            Map<String, List<SObject>> possibleMatchList = CasePotentialMatchesListCtrl.getPossibleMatchEnquery(caseId);

            Test.stopTest();

            System.assertNotEquals(0, possibleMatchList.get('Contact').size(), 'Contact array should not be empty');
            System.assertNotEquals(0, possibleMatchList.get('Lead').size(), 'Lead array should not be empty');
        }
    }

    @isTest
    private static void testLinkToCaseContact() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();

            List<Case> caseList = CasesDAO.newInstance().getCaseBySuppliedEmail(EMAIL, AccessLevel.USER_MODE);
            ContactsDAO.QueryParamWrapperEmailOrName contactQueryParam = new ContactsDAO.QueryParamWrapperEmailOrName(
                EMAIL, '', '', PHONE
            );

            List<SObject> contactList =  ContactsDAO.newInstance().getContactByEmailOrName(contactQueryParam, AccessLevel.USER_MODE);
            String contactId = '';
            String caseId = '';

            if (!contactList.isEmpty()) {
                contactId = contactList[0].Id;
            }

            if (!caseList.isEmpty()) {
                caseId = caseList[0].Id;
            }

            Boolean updatedCase = CasePotentialMatchesListCtrl.linkToCase(caseId, contactId, 'Contact');

            Test.stopTest();

            System.assertNotEquals(false, updatedCase, 'Updating Case Contact is not successful');
        }
    }

    @isTest
    private static void testLinkToCaseLead() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();

            List<Case> caseList = CasesDAO.newInstance().getCaseBySuppliedEmail(EMAIL, AccessLevel.USER_MODE);
            LeadsDAO.QueryParamWrapperEmailOrName leadQueryParam = new LeadsDAO.QueryParamWrapperEmailOrName(
                EMAIL, '', '', ''
            );

            List<SObject> leadList =  LeadsDAO.newInstance().getLeadByEmailOrName(leadQueryParam, AccessLevel.USER_MODE);

            String leadId = '';
            String caseId = '';

            if (!leadList.isEmpty()) {
                leadId = leadList[0].Id;
            }

            if (!caseList.isEmpty()) {
                caseId = caseList[0].Id;
            }

            Boolean updatedCase = CasePotentialMatchesListCtrl.linkToCase(caseId, leadId, 'Lead');

            Test.stopTest();

            System.assertNotEquals(false, updatedCase, 'Updating Case Lead is not successful');
        }
    }

    @isTest
    private static void testLinkToCaseLeadFailed() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();

            Boolean updatedCase = CasePotentialMatchesListCtrl.linkToCase('', '', '');

            Test.stopTest();

            System.assertEquals(false, updatedCase, 'Updating Case Contact/Lead successful');
        }
    }
}