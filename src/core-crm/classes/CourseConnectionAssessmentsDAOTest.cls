/**
 * @description Test Class for CourseConnectionAssessmentsDAO
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
public with sharing class CourseConnectionAssessmentsDAOTest {

    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator'});
    }
    
    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new CourseConnectionAssessmentsDAO().getSObjectType() == Course_Connection_Assessment__c.SObjectType,
                'SObject is not Course_Connection_Assessment__c'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getWhereClauseByCriteriaTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            String whereClauseString = CourseConnectionAssessmentsDAO.newInstance()
                .getWhereClauseByCriteria(
                    new CourseConnectionAssessmentsDAO.Criteria(),
                    new CourseConnectionsDAO.Criteria(), 
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
            String whereClauseString = CourseConnectionAssessmentsDAO.newInstance()
                .getWhereClauseByCriteria(
                    new CourseConnectionAssessmentsDAO.Criteria(),
                    new CourseConnectionsDAO.Criteria(), 
                    new ProgramEnrollmentsDAO.Criteria(), 
                    new ContactsDAO.Criteria()
                );
            String expectedWhereClause = '';
            System.assertEquals(expectedWhereClause, whereClauseString, 'Incorrect Where Clause');
        }
        Test.stopTest();
    }

    @isTest
    static void getQueryByCriteriaTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            String whereClauseString = CourseConnectionAssessmentsDAO.newInstance()
                .getQueryByCriteria(
                    new CourseConnectionAssessmentsDAO.Criteria(),
                    new CourseConnectionsDAO.Criteria(), 
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
            List<Course_Connection_Assessment__c> courseConnectionAssessmentList = CourseConnectionAssessmentsDAO.newInstance()
                .findByCriteria(
                    new CourseConnectionAssessmentsDAO.Criteria(),
                    new CourseConnectionsDAO.Criteria(), 
                    new ProgramEnrollmentsDAO.Criteria(), 
                    new ContactsDAO.Criteria()
                );
            System.assert(courseConnectionAssessmentList.isEmpty(), 'courseConnectionAssessmentList should not be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void criteriaIsEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            CourseConnectionAssessmentsDAO.Criteria criteria = new CourseConnectionAssessmentsDAO.Criteria();
            System.assert(criteria.isEmpty(), 'Criteria should be empty.');
        }
        Test.stopTest();
    }
}
