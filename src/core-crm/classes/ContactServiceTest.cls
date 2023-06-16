/**
 * @description Controller Class for ContactService
 * @see ../classes/ContactService
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | June 08, 2023         | DEPP-5414              | Created file                 | 
 */
@IsTest
public class ContactServiceTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{'QUT_IE_Partnership_Manager', 'QUT_Website_Integration_User'});
    }

    @IsTest
    public static void getExistingContactEmailDuplicatesForWorkEmailInputFlowNoDuplicateEmailTest(){
        Test.startTest();
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()){
            ImplementationSelector.DAO.setMock(new ContactsDAOMock());
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].Work_Email__c = 'test@test.com';
            contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);

            Boolean isNotExistWorkEmail = ContactService.getExistingContactEmailDuplicatesForWorkEmailInputFlow('test1234@test.com');
            System.assertEquals(isNotExistWorkEmail, false, 'Work email is unqiue across the organization');
        }
        Test.stopTest(); 

    }

    @IsTest
    public static void getExistingContactEmailDuplicatesForWorkEmailInputFlowDuplicateEmailTest(){
        Test.startTest();
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()){
            ImplementationSelector.DAO.setMock(new ContactsDAOMock());
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].Work_Email__c = 'test@test.com';
            contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);

            Boolean isExistWorkEmail = ContactService.getExistingContactEmailDuplicatesForWorkEmailInputFlow('test@test.com');
            System.assertEquals(!isExistWorkEmail, true, 'Work email must be unqiue across the organization');
        }
        Test.stopTest(); 
    }

    @IsTest
    public static void getExistingContactEmailDuplicatesForWorkEmailInputFlowTestError(){
        Test.startTest();
        System.runAs(TestDataFactory.getIntegrationWebsiteUser()){
            Boolean isExist;

            try{
                isExist = ContactService.getExistingContactEmailDuplicatesForWorkEmailInputFlow('test');
            } catch (Exception e){
                System.assert(e !=null, 'Error in ContactCtrl in get Existing Contact Duplicates for Work Email');
            }
        }
        Test.stopTest(); 
    }
}