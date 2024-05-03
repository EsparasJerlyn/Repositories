/**
 * @description Test Class for ProgramEnrollmentBreachesDAO
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
 *    |--------------------------------|-----------------------|------------------------|------------------------------------------------|
 *    | julie.jane.alegre              | April 29, 2024        | DEPP-8041              | Created file                                   |
 *    |                                |                       |                        |                                                |
 */
@isTest
public with sharing class ProgramEnrollmentBreachesDAOTest {

    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });
    }
    
    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new ProgramEnrollmentBreachesDAO().getSObjectType() == Program_Enrollment_Breach__c.SObjectType,
                'SObject is not Program_Enrollment_Breach__c'
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
            contactCriteria.setIsQUTStudent(true);
            contactCriteria.setRecordType(ContactsDAO.PERSON_RECORDTYPE);
            contactCriteria.setContactIdSet(new Set<Id>{contactId});
            contactCriteria.setCitizenshipStatus(ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL);
            ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria = new ProgramEnrollmentsDAO.Criteria();
            programEnrollmentCriteria.academicStatus = ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED;
            programEnrollmentCriteria.enrollmentStage = ProgramEnrollmentsDAO.ENROLLMENT_STATUS_ADMITTED;
            ProgramEnrollmentBreachesDAO.Criteria programEnrollmentBreachCriteria = new ProgramEnrollmentBreachesDAO.Criteria();
            programEnrollmentBreachCriteria.breach = mockIdGen.getMockId();
            programEnrollmentBreachCriteria.breachStatus = ProgramEnrollmentBreachesDAO.STATUSES_FOR_PROGRAM_ENROLLMENT_BREACH;

            String whereClauseString = ProgramEnrollmentBreachesDAO.newInstance().getWhereClauseByCriteria(programEnrollmentBreachCriteria, programEnrollmentCriteria, contactCriteria);
            String expectedWhereClause = 'WHERE '
                + 'Breach_Status__c IN(' + programEnrollmentBreachCriteria.breachStatus + ') '
                + 'AND Breach_Name__c = \'' + programEnrollmentBreachCriteria.breach + '\' '
                + 'AND Program_Enrollment__r.Academic_Status__c = \'' + programEnrollmentCriteria.academicStatus + '\' '
                + 'AND Program_Enrollment__r.Enrollment_Stage__c = \'' + programEnrollmentCriteria.enrollmentStage + '\' '
                + 'AND Program_Enrollment__r.hed__Contact__r.hed__Citizenship_Status__c = \'' + contactCriteria.getCitizenshipStatus() + '\' '
                + 'AND Program_Enrollment__r.hed__Contact__r.QUT_Student__c = ' + contactCriteria.getIsQUTStudent() + ' '
                + 'AND Program_Enrollment__r.hed__Contact__r.RecordType.DeveloperName = \'' + contactCriteria.getRecordType() + '\'';
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
            ProgramEnrollmentBreachesDAO.Criteria programEnrollmentBreachCriteria = new ProgramEnrollmentBreachesDAO.Criteria();
            String whereClauseString = ProgramEnrollmentBreachesDAO.newInstance().getWhereClauseByCriteria(programEnrollmentBreachCriteria, programEnrollmentCriteria, contactCriteria);
            String expectedWhereClause = '';
            System.assertEquals(expectedWhereClause, whereClauseString, 'Incorrect Where Clause');
        }
        Test.stopTest();
    }

    @isTest
    static void getContactQueryByCriteriaTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            String whereClauseString = ProgramEnrollmentBreachesDAO.newInstance()
                .getWhereClauseByCriteria(
                    new ProgramEnrollmentBreachesDAO.Criteria(),
                    new ProgramEnrollmentsDAO.Criteria(), 
                    new ContactsDAO.Criteria()
                );
            System.assert(whereClauseString != null, 'Contact query by criteria should not be null.');
        }
        Test.stopTest();
    }

    @isTest
    static void getQueryByCriteriaTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            String whereClauseString = ProgramEnrollmentBreachesDAO.newInstance()
                .getQueryByCriteria(
                    new ProgramEnrollmentBreachesDAO.Criteria(),
                    new ProgramEnrollmentsDAO.Criteria(), 
                    new ContactsDAO.Criteria()
                );
            System.assert(whereClauseString != null, 'Query by criteria should not be null.');
        }
        Test.stopTest();
    }

    @isTest
    static void findByCriteriaTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Program_Enrollment_Breach__c> programEnrollmentBreachList = ProgramEnrollmentBreachesDAO.newInstance()
                .findByCriteria(
                    new ProgramEnrollmentBreachesDAO.Criteria(),
                    new ProgramEnrollmentsDAO.Criteria(), 
                    new ContactsDAO.Criteria()
                );
            System.assert(programEnrollmentBreachList.isEmpty(), 'programEnrollmentBreachList should not be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void criteriaIsEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            ProgramEnrollmentBreachesDAO.Criteria criteria = new ProgramEnrollmentBreachesDAO.Criteria();
            System.assert(criteria.isEmpty(), 'Criteria should be empty.');
        }
        Test.stopTest();
    }
}
