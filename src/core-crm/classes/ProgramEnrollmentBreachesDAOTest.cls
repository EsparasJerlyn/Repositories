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
            String whereClauseString = ProgramEnrollmentBreachesDAO.newInstance()
                .getWhereClauseByCriteria(
                    new ProgramEnrollmentBreachesDAO.Criteria(),
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
