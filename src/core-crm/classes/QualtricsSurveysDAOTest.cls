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
        TestDataFactoryUser.generateUserQUTESB();
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            System.assert(QualtricsSurveysDAO.newInstance() != null, 'QualtricsSurveysDAO instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            System.assert(
                new QualtricsSurveysDAO().getSObjectType() == Qualtrics_Survey__c.SObjectType,
                'SObject is not Qualtrics_Survey__c'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getQualitricsSurveysBySetIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            MockIdGenerator qualtricsSurveyId = new MockIdGenerator(Qualtrics_Survey__c.sObjectType);
            List<Qualtrics_Survey__c> qualtricsSurveyList = QualtricsSurveysDAO.newInstance()
                .getQualitricsSurveysBySetIds(
                    new Set<Id>{qualtricsSurveyId.getMockId()},
                    AccessLevel.USER_MODE
                );
            System.assert(qualtricsSurveyList.isEmpty(), 'Qualtrics Survey list should not be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getQualitricsSurveysBySetIdsEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<Qualtrics_Survey__c> qualtricsSurveyList = QualtricsSurveysDAO.newInstance()
                .getQualitricsSurveysBySetIds(
                    new Set<Id>(),
                    AccessLevel.USER_MODE
                );
            System.assert(qualtricsSurveyList.isEmpty(), 'Qualtrics Survey list must be empty.');
        }
        Test.stopTest();
    }



    @isTest
    static void getQualitricsSurveysByOwnerIdTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<Qualtrics_Survey__c> qualtricsSurveyRecord = TestDataFactory.createQualtricsSurveyRecord(1);
            QualtricsSurveysDAO.newInstance().insertRecords(qualtricsSurveyRecord, true, AccessLevel.SYSTEM_MODE);
            
            List<Qualtrics_Survey__c> qualtricsSurveyList = QualtricsSurveysDAO.newInstance()
                .getQualitricsSurveysByOwnerId(
                    new Set<Id>{TestDataFactoryUser.selectUserQUTESB.Id},
                    AccessLevel.USER_MODE
                );
            System.assertEquals(qualtricsSurveyRecord[0].Id ,qualtricsSurveyList[0].Id , 'Qualtrics Survey should match.');
        }
        Test.stopTest();
    }

    @isTest
    static void getQualitricsSurveysByOwnerIdEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<Qualtrics_Survey__c> qualtricsSurveyList = QualtricsSurveysDAO.newInstance()
                .getQualitricsSurveysByOwnerId(
                    new Set<Id>(),
                    AccessLevel.USER_MODE
                );
            System.assert(qualtricsSurveyList.isEmpty(), 'Qualtrics Survey list must be empty.');
        }
        Test.stopTest();
    }

} 