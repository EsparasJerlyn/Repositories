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
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });
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
}
