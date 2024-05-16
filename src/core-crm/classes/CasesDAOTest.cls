/**
 * @description Test Class CasesDAO
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                   |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------------|
      | arsenio.jr.dayrit              | September 11, 2023    | DEPP-5652              | Created File                                     |
      | neil.s.h.lesidan               | September 20, 2023    | DEPP-6478              | Added getCaseBySuppliedEmailTest                 |
      | arsenio.jr.dayrit              | September 26, 2023    | DEPP-6720              | added new method getCasesBySuppliedPhoneTest     |
 */
@isTest
public with sharing class CasesDAOTest {

    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new CasesDAO().getSObjectType() == Case.SObjectType,
                'SObject is not Case'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getCasesByContactIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Case> caseList = CasesDAO.newInstance()
                .getCasesByContactIds(
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(caseList.isEmpty(), 'caseList should not be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getCasesByLeadIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Case> caseList = CasesDAO.newInstance()
                .getCasesByLeadIds(
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(caseList.isEmpty(), 'caseList should not be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getCasesByContactOrLeadIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Case> caseList = CasesDAO.newInstance()
                .getCasesByContactOrLeadIds(
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(caseList.isEmpty(), 'caseList should not be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getCaseBySuppliedEmailTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Case> caseList = CasesDAO.newInstance()
                .getCaseBySuppliedEmail(
                    '',
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(caseList.isEmpty(), 'caseList should not be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getCasesBySuppliedPhoneTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Case> caseList = CasesDAO.newInstance()
                .getCasesBySuppliedPhone(
                    new Set<String>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(caseList.isEmpty(), 'caseList should not be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void queryLocatorGetCasesByContactOrLeadIdsTest() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            System.assert(
                CasesDAO.newInstance().queryLocatorGetCasesByContactOrLeadIds(
                    new Set<Id>()
                ) != null,
                'caseList should not be empty.'
            );
            Test.stopTest();
        }
    }

    @isTest
    static void getCasesByStatusAndRecordTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {

            ImplementationSelector.DAO.setMock(new CasesDAOMock());
            Id contactId = new MockIdGenerator(Contact.SObjectType).getMockId();

            List<Case> caseList = new List<Case>();
            caseList.add(
                new Case(
                    RecordTypeId = CasesDAO.INBOUND_ENQUIRY_RECTYPE_ID,
                    Status = CasesDAO.CASE_STATUS_OPEN,
                    Origin = 'Email',
                    ContactId = contactId
                )
            );
            CasesDAO.newInstance().insertRecords(caseList, true, AccessLevel.SYSTEM_MODE);

            List<Case> caseListByStatusAndRecordType = CasesDAO.newInstance()
                .getCasesByStatusAndRecordType(
                    new Set<Id>{contactId},
                    new Set<String>{CasesDAO.CASE_STATUS_OPEN},
                    CasesDAO.INBOUND_ENQUIRY_RECTYPE_ID,
                    AccessLevel.SYSTEM_MODE
                );

            System.assert(!caseListByStatusAndRecordType.isEmpty(), 'caseListByStatusAndRecordType should not be empty.');
        }
        Test.stopTest();
    }

}