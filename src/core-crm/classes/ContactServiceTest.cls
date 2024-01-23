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
      | julie.jane.alegre              | Sept 21, 2023         | DEPP-6667              | Add methods to check related | 
      |                                |                       |                        | records to contact           | 
 */
@IsTest
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
//PMD ApexUnitTestClassShouldHaveRunAs is bypassed for service class methods 
//because these methods are reusable, test method is mocked, and user access tests are performed on the caller
public class ContactServiceTest {
    @IsTest
    public static void getExistingContactEmailDuplicatesForWorkEmailInputFlowNoDuplicateEmailTest() {
        Test.startTest();

        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
        contactList[0].Work_Email__c = 'test@test.com';
        contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
        ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);

        Boolean isNotExistWorkEmail = ContactService.getExistingContactEmailDuplicatesForWorkEmailInputFlow(
            'test1234@test.com'
        );
        System.assertEquals(
            isNotExistWorkEmail,
            false,
            'Work email is unqiue across the organization'
        );

        Test.stopTest();
    }

    @IsTest
    public static void getExistingContactEmailDuplicatesForWorkEmailInputFlowDuplicateEmailTest() {
        Test.startTest();
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
        contactList[0].Work_Email__c = 'test@test.com';
        contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
        ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);

        Boolean isExistWorkEmail = ContactService.getExistingContactEmailDuplicatesForWorkEmailInputFlow(
            'test@test.com'
        );
        System.assertEquals(
            !isExistWorkEmail,
            true,
            'Work email must be unqiue across the organization'
        );
        Test.stopTest();
    }

    @IsTest
    public static void getExistingContactEmailDuplicatesForWorkEmailInputFlowTestError() {
        Test.startTest();
        Boolean isExist;
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        try {
            isExist = ContactService.getExistingContactEmailDuplicatesForWorkEmailInputFlow('test');
        } catch (Exception e) {
            System.assert(
                e != null,
                'Error in ContactCtrl in get Existing Contact Duplicates for Work Email'
            );
        }

        Test.stopTest();
    }

    @IsTest
    public static void mapExistingCasesToContactTest() {
        Test.startTest();
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new CasesDAOMock());
        List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
        ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);
        List<Case> caseList = TestDataFactory.createTestCaseRecords(1, null, contactList);
        CasesDAO.newInstance().insertRecords(caseList, false, AccessLevel.USER_MODE);
        System.assert(
            !ContactService.mapExistingCasesToContact(
                    new Set<Id>{ contactList[0].Id },
                    AccessLevel.USER_MODE
                )
                .keySet()
                .isEmpty(),
            'No cases related to contact.'
        );
        Test.stopTest();
    }

    @IsTest
    public static void mapExistingMarketingInteractionToContactTest() {
        Test.startTest();
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new CasesDAOMock());
        List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
        ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);
        List<Marketing_Interaction__c> marketingInteractionList = TestDataFactory.createMarketingInteractionRecords(
            contactList[0].Id,
            1,
            'QTAC'
        );
        MarketingInteractionsDAO.newInstance()
            .insertRecords(marketingInteractionList, false, AccessLevel.USER_MODE);
        System.assert(
            ContactService.mapExistingMarketingInteractionToContact(
                    new Set<Id>{ contactList[0].Id },
                    AccessLevel.USER_MODE
                )
                .keySet()
                .isEmpty(),
            'No Marketing Interactions related to contact.'
        );
        Test.stopTest();
    }

    @IsTest
    public static void mapExisitngApplicationsToContactTest() {
        Test.startTest();
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new ApplicationsDAOMock());
        List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
        ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);
        List<hed__Application__c> applicationList = TestDataFactory.createApplicationRecords(
            contactList[0].Id,
            ApplicationsDAO.QTAC_RECTYPE_ID,
            1
        );
        ApplicationsDAO.newInstance().insertRecords(applicationList, false, AccessLevel.USER_MODE);
        System.assert(
            !ContactService.mapExisitngApplicationsToContact(
                    new Set<Id>{ contactList[0].Id },
                    AccessLevel.USER_MODE
                )
                .keySet()
                .isEmpty(),
            'There are other applications related to contact.'
        );
        Test.stopTest();
    }

    @IsTest
    public static void mapExisitngApplicationsToContactInActiveQTACTest() {
        Test.startTest();
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new ApplicationsDAOMock());
        List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
        ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);
        List<hed__Application__c> applicationList = TestDataFactory.createApplicationRecords(
            contactList[0].Id,
            ApplicationsDAO.QTAC_RECTYPE_ID,
            1
        );

        for(hed__Application__c application : applicationList){
            application.Is_Active__c = false;
        }

        ApplicationsDAO.newInstance().insertRecords(applicationList, false, AccessLevel.USER_MODE);
        System.assert(
            ContactService.mapExisitngApplicationsToContact(
                    new Set<Id>{ contactList[0].Id },
                    AccessLevel.USER_MODE
                )
                .keySet()
                .isEmpty(),
            'There are no other applications related to contact.'
        );
        Test.stopTest();
    }

    @IsTest
    private static void isContactTest() {
        Test.startTest();
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new LeadsDAOMock());

        System.assert(
            ContactService.isContact(
                ContactsDAO.newInstance()
                        .insertRecords(
                            new List<Contact>{ new Contact(LastName = 'Test') },
                            true,
                            AccessLevel.USER_MODE
                        )[0]
                    .Id
            ),
            'Id must be contact'
        );
        System.assert(
            !ContactService.isContact(
                LeadsDAO.newInstance()
                        .insertRecords(
                            new List<Lead>{ new Lead(LastName = 'Test') },
                            true,
                            AccessLevel.USER_MODE
                        )[0]
                    .Id
            ),
            'Id must not be contact'
        );
        Test.stopTest();
    }
}
