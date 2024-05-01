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
            String whereClauseString = LeaveOfAbsencesDAO.newInstance()
                .getWhereClauseByCriteria(
                    new LeaveOfAbsencesDAO.Criteria(),
                    new ProgramEnrollmentsDAO.Criteria(),
                    new ContactsDAO.Criteria()
                );
            System.assert(whereClauseString != null, 'Where Clause by criteria should not be null.');
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