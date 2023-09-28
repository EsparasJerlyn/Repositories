/**
 * @description Test class for LeadsDAOTest
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                    |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file                                                      |
      | mark.j.mahilum                 | June 26, 2023         | DEPP-5846              | Added new test method                                             |
      | roy.nino.s.regala              | Aug 09, 2023          | DEPP-5677              | added new test method                                             |
      | mark.j.mahilum                 | Aug 23, 2023          | DEPP-6215              | Added new test method coverage for getLeadsCalculatedCadenceByIds |
      | neil.s.h.lesidan               | Sept 20, 2023         | DEPP-6478              | Added getLeadByEmailOrNameTest                                    |
      | arsenio.jr.dayrit              | Sept 22,2023          | DEPP-6720              | added new test method getLeadsByCaseMobile                        |
 */
@isTest
public with sharing class LeadsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator', 'QUT_Domestic_Future_Student_Agent' });
    }

    @isTest
    static void getExistingUnconvertedLeadsByEmailTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Lead> leadList = LeadsDAO.newInstance()
                .getExistingUnconvertedLeadsByEmail(
                    new Set<String>(),
                    new Set<Id>(),
                    'SYSTEM_MODE'
                );
            System.assert(leadList.isEmpty(), 'leadList should not be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getLeadsWithLimitTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Lead> leadList = LeadsDAO.newInstance().getLeadsWithLimit(1);
            System.assert(leadList.isEmpty(), 'leadList should not be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new LeadsDAO().getSObjectType() == Lead.SObjectType,
                'SObject is not Lead'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getExistingUnconvertedLeadsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Lead> leadList = LeadsDAO.newInstance()
                .getExistingUnconvertedLeads(
                    new Set<String>(),
                    'SYSTEM_MODE'
                );
            System.assert(leadList.isEmpty(), 'leadList should not be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getLearnerLeadsByCalculatedCadencesTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getDomesticFutureStudentAgent()) {
            List<Lead> leadList = LeadsDAO.newInstance()
                .getLearnerLeadsByCalculatedCadences(
                    new Set<String>()
                );
            System.assert(leadList.isEmpty(), 'leadList should not be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getLeadsCalculatedCadenceByIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getDomesticFutureStudentAgent()) {
            List<Lead> leadList = LeadsDAO.newInstance()
                .getLeadsCalculatedCadenceByIds(
                    new Set<String>(),
                    'SYSTEM_MODE'
                );
            System.assert(leadList.isEmpty(), 'leadList should not be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getLeadsByCaseMobileTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getDomesticFutureStudentAgent()) {
            List<Lead> leadList = LeadsDAO.newInstance()
                .getLeadsByCaseMobile(
                    new Set<String>(),
                    AccessLevel.USER_MODE
                );
            System.assert(leadList.isEmpty(), 'leadList should not be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getLeadByEmailOrNameTest() {
        Test.startTest();
        List<Lead> objList = TestDataFactory.createTestLeadRecords(1);
        objList[0].FirstName = 'firstname';
        objList[0].LastName = 'lastname';
        objList[0].Email = 'firstlast@mail.test';
        objList[0].MobilePhone = '1234567';
        System.runAs(TestDataFactory.getDomesticFutureStudentAgent()) {
            LeadsDAO.QueryParamWrapperEmailOrName leadQueryParam = new LeadsDAO.QueryParamWrapperEmailOrName(
                objList[0].Email, objList[0].FirstName, objList[0].LastName , objList[0].MobilePhone
            );

            List<Lead> leadList = LeadsDAO.newInstance()
                .getLeadByEmailOrName(
                    leadQueryParam,
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(leadList.isEmpty(), 'leadList should not be empty');
        }
        Test.stopTest();
    }
}
