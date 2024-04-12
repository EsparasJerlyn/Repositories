/**
 * @description Test class for DocumentsDAO. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | July 10, 2023         | DEPP-5483              | Created file                 |                                                     |
 */
@isTest
public with sharing class DocumentsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'Industry_Operations_Manager' });
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getOperationsManager()) {
            System.assert(DocumentsDAO.newInstance() != null, 'DocumentsDAO instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getOperationsManager()) {
            System.assert(
                new DocumentsDAO().getSObjectType() == Document__c.SObjectType,
                'SObject is not Document__c'
            );
        }
        Test.stopTest();
    }
}