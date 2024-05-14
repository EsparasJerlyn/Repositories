/**
 * @description Test Class for AttachmentsDAO
 *
 * @author Accenture
 *
  * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
 *    |--------------------------------|-----------------------|------------------------|------------------------------------------------|
 *    | arsenio.jr.dayrit              | May 13, 2024          | DEPP-8743              | Created file                                   |
 *    |                                |                       |                        |                                                |
 */
@isTest
public with sharing class AttachmentsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator', 'QUT_ESB'});
    }
    
    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new AttachmentsDAO().getSObjectType() == Attachment.SObjectType,
                'SObject is not Attachment'
            );
        }
        Test.stopTest();
    }
    @isTest
    static void findByNameEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            List<Attachment> attachmentList = AttachmentsDAO.newInstance()
            .findByName(null);
            System.assert(attachmentList.isEmpty(), 'Attachment list should be empty.');
        }
        Test.stopTest();
    }
    @isTest
    static void findByNameTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            List<Attachment> attachmentList = AttachmentsDAO.newInstance()
            .findByName('Test');
            System.assert(attachmentList.isEmpty(), 'Attachment list should be empty.');
        }
        Test.stopTest();
    }
}