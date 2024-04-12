/**
 * @description Test Class for DocumentTriggerHandler. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | July 10, 2023         | DEPP-5483              | Created file                 |                                                     |
 */
@isTest
public with sharing class DocumentTriggerHandlerTest {
    @testSetup
    static void setup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'Industry_Operations_Manager' });
    }

    @isTest
    private static void testPlatformEventInsertAndUpdate() {
        System.runAs(testDataFactory.getOperationsManager()) {
            List <IP_Management__c> ipManagementRecords = TestDataFactory.createIPManagement(
                1,
                IPManagementsDAO.PATENT_RECTYPE_ID
            );


            IPManagementsDAO.newInstance()
                .insertRecords(ipManagementRecords, false, AccessLevel.USER_MODE);

            Test.startTest();
            List<Document__c> newDocuments = TestDataFactory.createDocumentsForIPManagement(
                1,
                ipManagementRecords[0].Id,
                DocumentsDAO.STANDARD_RECTYPE_ID
            );

            System.assert(
                DocumentsDAO.newInstance()
                        .insertRecords(newDocuments, false, AccessLevel.USER_MODE)[0]
                    .isSuccess(),
                'Document is not created'
            );

            newDocuments[0].Document_Title__c = 'test update title';

            System.assert(
                DocumentsDAO.newInstance()
                        .updateRecords(newDocuments, false, AccessLevel.USER_MODE)[0]
                    .isSuccess(),
                'Document is not updated'
            );
            Test.stopTest();
        }
    }
}