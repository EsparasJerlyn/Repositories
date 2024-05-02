/**
 * @description Test Class for LeaveOfAbsencesDAO
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
 *    |--------------------------------|-----------------------|------------------------|------------------------------------------------|
 *    | gabriel.p.ventayen             | April 30, 2024        | DEPP-8041              | Created file                                   |
 *    |                                |                       |                        |                                                |
 */
@isTest
public with sharing class LeaveOfAbsencesDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });
    }
    
    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new LeaveOfAbsencesDAO().getSObjectType() == Leave_of_Absence__c.SObjectType,
                'SObject is not Leave_of_Absence__c'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getWhereClauseByCriteriaTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {

            MockIdGenerator mockIdGen = new MockIdGenerator(Contact.SObjectType);
            Id contactId = mockIdGen.getMockId();
            ContactsDAO.Criteria contactCriteria = new ContactsDAO.Criteria();
            contactCriteria.isQUTStudent = true;
            contactCriteria.recordType = ContactsDAO.PERSON_RECORDTYPE;
            contactCriteria.contactIdSet = new Set<Id>{contactId};
            contactCriteria.citizenshipStatus = ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;
            ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria = new ProgramEnrollmentsDAO.Criteria();
            programEnrollmentCriteria.academicStatus = ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED;
            programEnrollmentCriteria.enrollmentStage = ProgramEnrollmentsDAO.ENROLLMENT_STATUS_ADMITTED;
            LeaveOfAbsencesDAO.Criteria leaveOfAbsenceCriteria = new LeaveOfAbsencesDAO.Criteria();
            leaveOfAbsenceCriteria.isOnLeave = true;

            String whereClauseString = LeaveOfAbsencesDAO.newInstance().getWhereClauseByCriteria(leaveOfAbsenceCriteria, programEnrollmentCriteria, contactCriteria);
            String expectedWhereClause = 'WHERE '
                + 'Is_On_Leave__c = ' + leaveOfAbsenceCriteria.isOnLeave + ' '
                + 'AND hed_Program_Enrollment__r.Academic_Status__c = \'' + programEnrollmentCriteria.academicStatus + '\' '
                + 'AND hed_Program_Enrollment__r.Enrollment_Stage__c = \'' + programEnrollmentCriteria.enrollmentStage + '\' '
                + 'AND hed_Program_Enrollment__r.hed__Contact__r.hed__Citizenship_Status__c = \'' + contactCriteria.citizenshipStatus + '\' '
                + 'AND hed_Program_Enrollment__r.hed__Contact__r.QUT_Student__c = ' + contactCriteria.isQUTStudent + ' '
                + 'AND hed_Program_Enrollment__r.hed__Contact__r.RecordType.DeveloperName = \'' + contactCriteria.recordType + '\'';
            System.assertEquals(expectedWhereClause, whereClauseString, 'Incorrect Where Clause');
        }
        Test.stopTest();
    }

    @isTest
    static void getWhereClauseByNoCriteriaTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            ContactsDAO.Criteria contactCriteria = new ContactsDAO.Criteria();
            ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria = new ProgramEnrollmentsDAO.Criteria();
            LeaveOfAbsencesDAO.Criteria leaveOfAbsenceCriteria = new LeaveOfAbsencesDAO.Criteria();
            String whereClauseString = LeaveOfAbsencesDAO.newInstance().getWhereClauseByCriteria(leaveOfAbsenceCriteria, programEnrollmentCriteria, contactCriteria);
            String expectedWhereClause = '';
            System.assertEquals(expectedWhereClause, whereClauseString, 'Incorrect Where Clause');
        }
        Test.stopTest();
    }

    @isTest
    static void getContactQueryByCriteriaTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            String wherClauseString = LeaveOfAbsencesDAO.newInstance()
                .getContactQueryByCriteria(
                    new LeaveOfAbsencesDAO.Criteria(),
                    new ProgramEnrollmentsDAO.Criteria(),
                    new ContactsDAO.Criteria()
                );
            System.assert(wherClauseString != null, 'Contact query by criteria should not be null.');
        }
        Test.stopTest();
    }

    @isTest
    static void getQueryByCriteriaTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            String wherClauseString = LeaveOfAbsencesDAO.newInstance()
                .getQueryByCriteria(
                    new LeaveOfAbsencesDAO.Criteria(),
                    new ProgramEnrollmentsDAO.Criteria(),
                    new ContactsDAO.Criteria()
                );
            System.assert(wherClauseString != null, 'Query by criteria should not be null.');
        }
        Test.stopTest();
    }

    @isTest
    static void findByCriteriaTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Leave_Of_Absence__c> leaveOfAbsenceList = LeaveOfAbsencesDAO.newInstance()
                .findByCriteria(
                    new LeaveOfAbsencesDAO.Criteria(),
                    new ProgramEnrollmentsDAO.Criteria(),
                    new ContactsDAO.Criteria()
                );
            System.assert(leaveOfAbsenceList.isEmpty(), 'leaveOfAbsenceList should not be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void criteriaIsEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            LeaveOfAbsencesDAO.Criteria criteria = new LeaveOfAbsencesDAO.Criteria();
            System.assert(criteria.isEmpty(), 'Criteria should be empty.');
        }
        Test.stopTest();
    }
}