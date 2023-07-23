/**
 * @description Test Class CourseConnectionDAO
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------|
      | mark.j.mahilum                 | July 21, 2023         | DEPP-5799              | Created File                               |
 */
@isTest
public with sharing class CourseConnectionsDAOTest {
    
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });
    }
    
    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new CourseConnectionsDAO().getSObjectType() == hed__Course_Enrollment__c.SObjectType,
                'SObject is not hed__Course_Enrollment__c'
            );
        }
        Test.stopTest();
    }


    @isTest
    static void getCourseConnectionByPEContactIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<hed__Course_Enrollment__c> courseConnectionList = CourseConnectionsDAO.newInstance()
                .getCourseConnectionByPEContactIds(
                    new Set<Id>(),
                    'SYSTEM_MODE'
                );
            System.assert(courseConnectionList.isEmpty(), 'courseConnectionList should not be empty.');
        }
        Test.stopTest();
    }
}