/**
 * @description Test Class for TermsDAO
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary                      |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------------|
 *    | eccarius.munoz                 | August 10, 2023       |DEPP-5760               | Created File                        |
 */
@isTest
public with sharing class TermsDaoTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUTeX_Program_Administrator' });
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(TermsDAO.newInstance() != null, 'TermsDAO instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new TermsDAO().getSObjectType() == hed__Term__c.SObjectType,
                'SObject is not hed__Term__c'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getTermRecordByApplicationTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<hed__Term__c> termList = TermsDAO.newInstance()
                .getTermRecordByApplication(
                    new Set<Id>(),
                    'SYSTEM_MODE'
                );
            System.assert(termList.isEmpty(), 'termList should not be empty.');
        }
        Test.stopTest();
    }
}