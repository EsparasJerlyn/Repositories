/**
 * @description test class for StudentSanctionsDAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 30, 2023        | DEPP-7984              | Created file
 */
@isTest
private class StudentSanctionsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserQUTESB();
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            System.assert(StudentSanctionsDAO.newInstance() != null, 'StudentSanctionsDAO instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            System.assert(
                new StudentSanctionsDAO().getSObjectType() == Student_Sanction__c.SObjectType,
                'SObject is not Student_Sanction__c'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void queryLocatorGetStudentSanctionsByBatchProcessTest(){
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            System.assert(
                StudentSanctionsDAO.newInstance()
                .queryLocatorGetStudentSanctionsByBatchProcess(
                    new Set<String>{'Insert'}, 
                    AccessLevel.USER_MODE
                ) != null,
                'Return should not be null'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getStudentSanctionsByBatchProcessTest(){
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            System.assert(
                StudentSanctionsDAO.newInstance()
                .getStudentSanctionsByBatchProcess(
                    new Set<String>{'Insert'}, 
                    AccessLevel.USER_MODE
                ).isEmpty(),
                'Return should be empty'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getStudentSanctionsByBatchProcessEmptyTest(){
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            System.assert(
                StudentSanctionsDAO.newInstance()
                .getStudentSanctionsByBatchProcess(
                    new Set<String>(), 
                    AccessLevel.USER_MODE
                ).isEmpty(),
                'Return should be empty'
            );
        }
        Test.stopTest();
    }
}
