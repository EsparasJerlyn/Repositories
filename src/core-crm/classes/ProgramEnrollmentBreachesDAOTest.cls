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
}
