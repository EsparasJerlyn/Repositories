/**
 * @description Test Class ApplicationsDAO
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------|
      | mark.j.mahilum                 | June 19, 2023         | DEPP-5846              | Created File                               |
      | mark.j.mahilum                 | July 03, 2023         | DEPP-5961              | Added method getApplicationsByLeadIds      |
 */
@isTest
public with sharing class ApplicationsDAOTest {
    
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });
    }

    @isTest
    static void getApplicationsBySetIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<hed__Application__c> applicationList = ApplicationsDAO.newInstance()
                .getApplicationsBySetIds(
                    new Set<Id>(),
                    'SYSTEM_MODE'
                );
            System.assert(applicationList.isEmpty(), 'applicationList should not be empty.');
        }
        Test.stopTest();
    }
    
    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new ApplicationsDAO().getSObjectType() == hed__Application__c.SObjectType,
                'SObject is not hed__Application__c'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getApplicationsByLeadIds() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<hed__Application__c> applicationList = ApplicationsDAO.newInstance()
                .getApplicationsByLeadIds(
                    new Set<Id>(),
                    'SYSTEM_MODE'
                );
            System.assert(applicationList.isEmpty(), 'applicationList should not be empty.');
        }
        Test.stopTest();
    }
}