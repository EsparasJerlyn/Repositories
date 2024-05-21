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
    static void findAttachmentsByNameEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            List<Attachment> attachmentList = AttachmentsDAO.newInstance()
            .findAttachmentsByName(null, AccessLevel.USER_MODE);
            System.assert(attachmentList.isEmpty(), 'Attachment list should be empty.');
        }
        Test.stopTest();
    }
    @isTest
    static void findAttachmentsByNameTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            
            List<Contact> contactListCreated = TestDataFactory.createTestContactRecords(1);
            contactListCreated[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            contactListCreated[0].QUT_Student__c = true;
            ContactsDAO.newInstance().insertRecords(contactListCreated,true,AccessLevel.USER_MODE);

            Blob b = Blob.valueOf('Test Data');
            List<Attachment> attachList = new List<Attachment>();
            Attachment attach = new Attachment();
            attach.Name = 'Test';
            attach.Body = b;
            attach.ParentId = contactListCreated[0].Id;
            attachList.add(attach);

            AttachmentsDAO.newInstance().insertRecords(attachList,true,AccessLevel.USER_MODE);

            List<Attachment> attachmentList = AttachmentsDAO.newInstance()
            .findAttachmentsByName('Test', AccessLevel.USER_MODE);
            System.assertEquals(attachList.size(),attachmentList.size(), 'Attachment list should not be empty.');
        }
        Test.stopTest();
    }
}