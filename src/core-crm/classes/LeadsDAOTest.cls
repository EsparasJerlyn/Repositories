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
      | alexander.cadalin              | November 9, 2023      | DEPP-7212              | Added excludeConverted to getLeadByEmailOrName
 */
@isTest
public with sharing class LeadsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        TestDataFactoryUser.generateUserFutureStudentAgentDomestic();
    }

    @isTest
    static void getExistingUnconvertedLeadsByEmailTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Lead> leadList = LeadsDAO.newInstance()
                .getExistingUnconvertedLeadsByEmail(
                    new Set<String>(),
                    new Set<Id>(),
                    'SYSTEM_MODE'
                );
            System.assert(leadList.isEmpty(), 'leadList should be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getLeadsWithLimitTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Lead> leadList = LeadsDAO.newInstance().getLeadsWithLimit(1);
            System.assert(leadList.isEmpty(), 'leadList should be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
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
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Lead> leadList = LeadsDAO.newInstance()
                .getExistingUnconvertedLeads(
                    new Set<String>(),
                    'SYSTEM_MODE'
                );
            System.assert(leadList.isEmpty(), 'leadList should be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getLearnerLeadsByCalculatedCadencesTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
            List<Lead> leadList = LeadsDAO.newInstance()
                .getLearnerLeadsByCalculatedCadences(
                    new Set<String>()
                );
            System.assert(leadList.isEmpty(), 'leadList should be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getLeadsCalculatedCadenceByIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
            List<Lead> leadList = LeadsDAO.newInstance()
                .getLeadsCalculatedCadenceByIds(
                    new Set<String>(),
                    'SYSTEM_MODE'
                );
            System.assert(leadList.isEmpty(), 'leadList should be empty');
        }
        Test.stopTest(); 
    }

    @isTest
    static void getLeadsByCaseMobileTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
            List<Lead> leadList = LeadsDAO.newInstance()
                .getLeadsByCaseMobile(
                    new Set<String>(),
                    AccessLevel.USER_MODE
                );
            System.assert(leadList.isEmpty(), 'leadList should be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getLeadsByIdSetTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
            List<Lead> leadList = LeadsDAO.newInstance()
                .getLeadsByIdSet(
                    new Set<Id>(),
                    AccessLevel.USER_MODE
                );
            System.assert(leadList.isEmpty(), 'leadList should be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getLeadsByIdSetAndTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
            List<Lead> leadList = LeadsDAO.newInstance()
                .getLeadsByIdSetAndType(
                    new Set<Id>(),
                    '',
                    AccessLevel.USER_MODE
                );
            System.assert(leadList.isEmpty(), 'leadList should be empty');
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
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
            LeadsDAO.QueryParamWrapperEmailOrName leadQueryParam = new LeadsDAO.QueryParamWrapperEmailOrName(
                objList[0].Email, objList[0].FirstName, objList[0].LastName , objList[0].MobilePhone
            );

            List<Lead> leadList = LeadsDAO.newInstance()
                .getLeadByEmailOrName(
                    leadQueryParam,
                    true,
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(leadList.isEmpty(), 'leadList should be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getLeadMobilePhoneByRecordIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
            List<Lead> leadList = LeadsDAO.newInstance()
                .getLeadMobilePhoneByRecordIds(
                    new Set<Id>(),
                    AccessLevel.USER_MODE
                );
            System.assert(leadList.isEmpty(), 'leadList should be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void queryLocatorGetLeadsByIdsTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            System.assert(
                LeadsDAO.newInstance().queryLocatorGetLeadsByIds(
                    new Set<Id>(),
                    ''
                ) != null,
                'leadList should not be empty.'
            );
            Test.stopTest();
        }
    }

    @isTest
    static void getLearnerLeadsByEmailOrWorkEmailTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            List<Lead> leadList = LeadsDAO.newInstance().getLearnerLeadsByEmailOrWorkEmail(
                new Set<String>{'test@mail.test'},
                AccessLevel.USER_MODE
            );
            System.assert(leadList.isEmpty(), 'leadList should be empty.');
            Test.stopTest();
        }
    }

    @isTest
    static void getLearnerLeadsByEmailOrWorkEmailEmptyTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            List<Lead> leadList = LeadsDAO.newInstance().getLearnerLeadsByEmailOrWorkEmail(
                new Set<String>(),
                AccessLevel.USER_MODE
            );
            System.assert(leadList.isEmpty(), 'leadList should be empty.');
            Test.stopTest();
        }
    }

    @isTest
    static void getLearnerLeadsByEmailOrWorkEmailBothEmailSetsTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            List<Lead> leadList = LeadsDAO.newInstance().getLearnerLeadsByEmailOrWorkEmail(
                new Set<String>{'test.email@mail.test'},
                new Set<String>{'test.workm@mail.test'},
                AccessLevel.USER_MODE
            );
            System.assert(leadList.isEmpty(), 'leadList should be empty.');
            Test.stopTest();
        }
    }

    @isTest
    static void getLearnerLeadsByEmailOrWorkEmailBothEmailSetsEmptyTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            List<Lead> leadList = LeadsDAO.newInstance().getLearnerLeadsByEmailOrWorkEmail(
                new Set<String>(),
                new Set<String>(),
                AccessLevel.USER_MODE
            );
            System.assert(leadList.isEmpty(), 'leadList should be empty.');
            Test.stopTest();
        }
    }
    
    @isTest
    static void getUnconvertedLeadsByIdSetTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
            MockIdGenerator leadMock = new MockIdGenerator(Lead.sObjectType);
            List<Lead> leadList = LeadsDAO.newInstance()
                .getUnconvertedLeadsByIdSet(
                    new Set<Id>{leadMock.getMockId()},
                    AccessLevel.USER_MODE
                );
            System.assert(leadList.isEmpty(), 'leadList should be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getUnconvertedLeadsByIdSetEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
            List<Lead> leadList = LeadsDAO.newInstance()
                .getUnconvertedLeadsByIdSet(
                    new Set<Id>(),
                    AccessLevel.USER_MODE
                );
            System.assert(leadList.isEmpty(), 'leadList should be empty');
        }
        Test.stopTest();
    }
}