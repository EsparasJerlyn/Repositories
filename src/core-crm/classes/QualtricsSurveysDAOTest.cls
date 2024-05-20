/**
 * @description Test Class for QualtricsSurveysDAO
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary                      |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------------|
 *    | arsenio.jr.dayrit              |  May 20, 2024         | DEPP-8821              | Created file
 */
@isTest
public with sharing class QualtricsSurveysDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{  'QUT_ESB' });
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            System.assert(QualtricsSurveysDAO.newInstance() != null, 'QualtricsSurveysDAO instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            System.assert(
                new QualtricsSurveysDAO().getSObjectType() == Qualtrics_Survey__c.SObjectType,
                'SObject is not Qualtrics_Survey__c'
            );
        }
        Test.stopTest();
    }

} 