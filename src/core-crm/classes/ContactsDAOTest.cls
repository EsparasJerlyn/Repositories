/**
 * @description test class for contactsdao.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                | JIRA                   | Change Summary                            |
 *    |--------------------------------|---------------------|------------------------|-------------------------------------------|
 *    | roy.nino.s.regala              | April 25, 2023      | DEPP-5567              | Created file                              |
 *    | eugene.andrew.abuan            | June 08, 2023       | DEPP-5414              | Added checkWorkEmailFlowInputExist        |
 *    | mark.j.mahilum                 | June 26, 2023       | DEPP-5846              | Added test method for DEPP-5846           |
 *    | arsenio.jr.dayrit              | July 06, 2023       | DEPP-5847              | Added test method for DEPP-5847           |
 *    | roy.nino.s.regala              | Aug 09, 2023        | DEPP-5677              | Added test method for DEPP-5677           |
 *    | roy.nino.s.regala              | Sept 20, 2023       | DEPP-6714              | method getPersonContactsBySetIds          |
 *    | alexander.cadalin              | Sep 22, 2023        | DEPP-6652              | method getContactsForQTACAddressUpdate    |
 *    | neil.s.h.lesidan               | Sep 20, 2023        | DEPP-6478              | Added getPersonContactsByEmailOrNameTest  |
 *    | arsenio.jr.dayrit              | Sept 22,2023        | DEPP-6720              | added getContactByCaseMobile              |
 *    | julie.jane.alegre              | Nov 07, 2023        | DEPP-7152              | Added method getExistingMCPersonaContactsBySetIds|
 *    | sebastianne.k.trias            | Feb 19, 2024        | DEPP-7750              | added getPersonContactsByNameUsingSOSLTest|
 *    | julie.jane.alegre              | May 13, 2024        | DEPP-8490              | Update method getQueryLocatorBySubQueryTest|
 *    | eugene.andrew.abuan            | May 14, 2024        | DEPP-8485              | Added getContactsByStudentId              |

 */
@isTest
private class ContactsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        TestDataFactoryUser.generateUserIndustryPartnershipManager();
        TestDataFactoryUser.generateUserFutureStudentAgentDomestic();
        
    }

    @isTest
    static void getExistingPersonContactsWithMatchingEmailsTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Contact> contactList = ContactsDAO.newInstance()
                .getExistingPersonContactsWithMatchingEmails(
                    new Set<String>(),
                    new Set<Id>(),
                    'SYSTEM_MODE'
                );
            System.assert(contactList.isEmpty(), 'contactList is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getPersonContactsWithLimitTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Contact> contactList = ContactsDAO.newInstance().getPersonContactsWithLimit(1);
            System.assert(contactList.isEmpty(), 'contactList is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(
                new ContactsDAO().getSObjectType() == Contact.SObjectType,
                'SObject is not Contact'
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void checkWorkEmailFlowInputExistTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserIndustryPartnershipManager) {
            List<Contact> contactList = ContactsDAO.newInstance()
                .checkWorkEmailFlowInputExist('test');
            System.Assert(contactList.isEmpty(), 'Contact with same email not found');
        }
        Test.stopTest();
    }

    @isTest
    static void getContactsWithMatchingEmailsTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Contact> contactList = ContactsDAO.newInstance()
                .getContactsWithMatchingEmails(
                    new Set<String>(),
                    'SYSTEM_MODE'
                );
            System.assert(contactList.isEmpty(), 'contactList is not empty');
        }
        Test.stopTest();
    }
    
    @isTest
    static void getContactsWithMatchingApplicationDetailsTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Contact> contactList = ContactsDAO.newInstance()
                .getContactsWithMatchingApplicationDetails(
                    new ContactsDAO.QueryParamWrapper(),
                    'SYSTEM_MODE'
                );
            System.assert(contactList.isEmpty(), 'contactList is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getContactsWithMatchingSamsApplicationsTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Contact> contactList = ContactsDAO.newInstance()
                .getContactsWithMatchingSamsApplications(
                    new ContactsDAO.QueryParamWrapper(),
                    'SYSTEM_MODE'
                );
            System.assert(contactList.isEmpty(), 'contactList is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getContactsByMatchingAttributesEmptyTest(){
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            List<Contact> contactList = ContactsDAO.newInstance().getContactsByMatchingAttributes(
                new Map<String,Set<String>>(),
                new Set<Date>(), 
                AccessLevel.SYSTEM_MODE
            );
            System.assert(contactList.isEmpty(), 'contactList is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getContactsByMatchingAttributesTest(){
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){

            Map<String,Set<String>> fieldSetMap = new Map<String,Set<String>>();
            
            Set<Date> birthDateSet = new Set<Date>();

            List<Contact> contactList = ContactsDAO.newInstance().getContactsByMatchingAttributes(
                fieldSetMap,
                birthDateSet, 
                AccessLevel.SYSTEM_MODE
            );
            System.assert(contactList.isEmpty(), 'contactList is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getPersonContactsByCalculatedCadencesTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
            List<Contact> contactList = ContactsDAO.newInstance()
                .getPersonContactsByCalculatedCadences(
                    new Set<String>()
                );
            System.assert(contactList.isEmpty(), 'contactList is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getContactCalculatedCadenceByIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
            List<Contact> contactList = ContactsDAO.newInstance()
                .getContactCalculatedCadenceByIds(
                    new Set<String>(),
                    'USER_MODE'
                );
            System.assert(contactList.isEmpty(), 'contactList should not be empty');
        }
        Test.stopTest();
    }
    @isTest
    static void getContactsFromConvertedLeadTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
            List<Contact> contactList = ContactsDAO.newInstance()
                .getContactsFromConvertedLead(
                    new Set<Id>(),
                    'USER_MODE'
                );
            System.assert(contactList.isEmpty(), 'contactList should not be empty');
        }
        Test.stopTest();
    }


    @isTest
    static void getPersonContactsByEmailOrNameTest() {
        Test.startTest();
        List<Contact> conList = TestDataFactory.createTestContactRecords(1);
        conList[0].FirstName = 'firstname';
        conList[0].LastName = 'lastname';
        conList[0].Email = 'firstlast@mail.test';
        conList[0].MobilePhone = '1234567';
        ContactsDAO.newInstance().insertRecords(conList, false, AccessLevel.SYSTEM_MODE);

        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
            ContactsDAO.QueryParamWrapperEmailOrName contactQueryParam = new ContactsDAO.QueryParamWrapperEmailOrName(
                conList[0].Email, conList[0].FirstName, conList[0].LastName , conList[0].MobilePhone
            );

            List<Contact> contactList = ContactsDAO.newInstance()
                .getPersonContactsByEmailOrName(
                    contactQueryParam,
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(contactList.isEmpty(), 'contact should not be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getPersonContactsBySetIdsTest() { 
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Contact> contactList = ContactsDAO.newInstance()
                .getPersonContactsBySetIds(
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(contactList.isEmpty(), 'contactList should be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getPersonContactsBySetIdsTestWithId() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
            MockIdGenerator contactMock = new MockIdGenerator(Contact.sObjectType);
            List<Contact> contactList = ContactsDAO.newInstance()
                .getPersonContactsBySetIds(
                    new Set<Id>{contactMock.getMockId()},
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(contactList.isEmpty(), 'contactList should be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getContactByCaseMobileTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Contact> contactList = ContactsDAO.newInstance()
                .getContactByCaseMobile(
                    new Set<String>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(contactList.isEmpty(), 'contactList should be empty');
        }
        Test.stopTest();
    }

    static void getContactsForQTACAddressUpdate() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Contact> contactList = ContactsDAO.newInstance().
                getContactsForQTACAddressUpdate(new Set<Id>(), AccessLevel.SYSTEM_MODE);
            System.assert(contactList.isEmpty(), 'contactList should not be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getContactMobilePhoneByRecordIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Contact> contactList = ContactsDAO.newInstance()
                .getContactMobilePhoneByRecordIds(
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(contactList.isEmpty(), 'contactList should be empty');
        }
        Test.stopTest();
    }
  
    @isTest
    static void queryLocatorGetContactsByIdsTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            System.assert(
                ContactsDAO.newInstance().queryLocatorGetContactsByIds(
                    new Set<Id>()
                ) != null,
                'contactList should not be empty.'
            );
            Test.stopTest();
        }
    }
    
    @isTest
    static void getExistingMCPersonaContactsBySetIds() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Contact> contactList = ContactsDAO.newInstance()
                .getExistingMCPersonaContactsBySetIds(
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(contactList.isEmpty(), 'contactList should be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getContactsByParentPersonLeadIdsTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            MockIdGenerator mockIdGen = new MockIdGenerator(Lead.SObjectType);
            List<Contact> contactList = ContactsDAO.newInstance()
                .getContactsByParentPersonLeadIds(
                    new Set<Id>{mockIdGen.getMockId()},
                    AccessLevel.USER_MODE
                );
            Test.stopTest();
            System.assert(contactList.isEmpty(), 'contactList should be empty');
        }
    }

    @isTest
    static void getContactsByParentPersonLeadIdsEmptyTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            List<Contact> contactList = ContactsDAO.newInstance()
                .getContactsByParentPersonLeadIds(
                    new Set<Id>(),
                    AccessLevel.USER_MODE
                );
            Test.stopTest();
            System.assert(contactList.isEmpty(), 'contactList should be empty');
        }
    }

    @isTest
    static void getContactsNoParentPersonContactByIdsTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            MockIdGenerator mockIdGen = new MockIdGenerator(Contact.SObjectType);
            List<Contact> contactList = ContactsDAO.newInstance()
                .getContactsNoParentPersonContactByIds(
                    new Set<Id>{mockIdGen.getMockId()},
                    AccessLevel.USER_MODE
                );
            Test.stopTest();
            System.assert(contactList.isEmpty(), 'contactList should be empty.');
        }
    }

    @isTest
    static void getContactsNoParentPersonContactByIdsEmptyTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            List<Contact> contactList = ContactsDAO.newInstance()
                .getContactsNoParentPersonContactByIds(
                    new Set<Id>(),
                    AccessLevel.USER_MODE
                );
            Test.stopTest();
            System.assert(contactList.isEmpty(), 'contactList should be empty.');
        }
    }

    @isTest
    static void getContactsWithParentPersonContactByIdsTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            MockIdGenerator mockIdGen = new MockIdGenerator(Contact.SObjectType);
            List<Contact> contactList = ContactsDAO.newInstance()
                .getContactsWithParentPersonContactByIds(
                    new Set<Id>{mockIdGen.getMockId()},
                    AccessLevel.USER_MODE
                );
            Test.stopTest();
            System.assert(contactList.isEmpty(), 'contactList should be empty.');
        }
    }

    @isTest
    static void getContactsWithParentPersonContactByIdsEmptyTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            List<Contact> contactList = ContactsDAO.newInstance()
                .getContactsWithParentPersonContactByIds(
                    new Set<Id>(),
                    AccessLevel.USER_MODE
                );
            Test.stopTest();
            System.assert(contactList.isEmpty(), 'contactList should be empty.');
        }
    }

    static void getMCPersonaContactsByParentPersonContactIds() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Contact> contactList = ContactsDAO.newInstance()
                .getMCPersonaContactsByParentPersonContactIds(
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(contactList.isEmpty(), 'contactList should be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getMCPersonaContactsByParentPersonLeadIds() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Contact> contactList = ContactsDAO.newInstance()
                .getMCPersonaContactsByParentPersonLeadIds(
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(contactList.isEmpty(), 'contactList should be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getPersonContactsByNameUsingSOSLTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Contact> contactList = ContactsDAO.newInstance()
                .getPersonContactsByNameUsingSOSL(
                    'test'
                );
            System.assert(contactList.isEmpty(), 'contactList should be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getWhereClauseByCriteriaTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {

            MockIdGenerator mockIdGen = new MockIdGenerator(Contact.SObjectType);
            Id contactId = mockIdGen.getMockId();
            ContactsDAO.Criteria contactCriteria = new ContactsDAO.Criteria();
            contactCriteria.setIsQUTStudent(true);
            contactCriteria.setRecordType(ContactsDAO.PERSON_RECORDTYPE);
            contactCriteria.setContactIdSet(new Set<Id>{contactId});
            contactCriteria.setCitizenshipStatus(ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL);

            String whereClauseString = ContactsDAO.newInstance().getWhereClauseByCriteria(contactCriteria);
            String expectedWhereClause = 'WHERE hed__Citizenship_Status__c = \'' + ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL + '\' AND QUT_Student__c = ' + true +
             ' AND RecordType.DeveloperName = \'' + ContactsDAO.PERSON_RECORDTYPE + '\' AND Id IN (\''+ contactId +'\')';
             
            System.assertEquals(expectedWhereClause, whereClauseString, 'Incorrect Where Clause');
        }
        Test.stopTest();
    }

    @isTest
    static void getWhereClauseByCriteriaNoCitizenshipTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {

            MockIdGenerator mockIdGen = new MockIdGenerator(Contact.SObjectType);
            Id contactId = mockIdGen.getMockId();
            ContactsDAO.Criteria contactCriteria = new ContactsDAO.Criteria();
            contactCriteria.setIsQUTStudent(true);
            contactCriteria.setRecordType(ContactsDAO.PERSON_RECORDTYPE);
            contactCriteria.setContactIdSet(new Set<Id>{contactId});

            String whereClauseString = ContactsDAO.newInstance().getWhereClauseByCriteria(contactCriteria);
            String expectedWhereClause = 'WHERE QUT_Student__c = ' + true +
             ' AND RecordType.DeveloperName = \'' + ContactsDAO.PERSON_RECORDTYPE + '\' AND Id IN (\''+ contactId +'\')';

            System.assertEquals(expectedWhereClause, whereClauseString, 'Incorrect Where Clause');
        }
        Test.stopTest();
    }

    @isTest
    static void getWhereClauseByNoCriteria() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            ContactsDAO.Criteria criteria = new ContactsDAO.Criteria();
            String whereClauseString = ContactsDAO.newInstance().getWhereClauseByCriteria(criteria);
            String expectedWhereClause = '';
            System.assertEquals(expectedWhereClause, whereClauseString, 'Incorrect Where Clause');
        }
        Test.stopTest();
    }

    @isTest
    static void findByCriteriaTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Contact> contactListCreated = TestDataFactory.createTestContactRecords(1);
            contactListCreated[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            contactListCreated[0].QUT_Student__c = true;
            ContactsDAO.newInstance().insertRecords(contactListCreated,true,AccessLevel.USER_MODE);

            ContactsDAO.Criteria contactCriteria = new ContactsDAO.Criteria();
            contactCriteria.setRecordType(ContactsDAO.PERSON_RECORDTYPE);
            contactCriteria.setIsQUTStudent(true);
            
            List<Contact> contactList = ContactsDAO.newInstance()
                .findByCriteria(
                    contactCriteria, 
                    AccessLevel.SYSTEM_MODE
                );
            System.assertEquals(contactListCreated.size(), contactList.size(), 'contactList should not be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void findByCriteriaNegativeTest() {
        Test.startTest();
        
        //Create a contact with MC Persona recordtype and not a student
        List<Contact> contactListCreated = TestDataFactory.createTestContactRecords(1);
        contactListCreated[0].RecordTypeId = ContactsDAO.MC_PERSONA_RECORDTYPE_ID;
        contactListCreated[0].QUT_Student__c = false;
        ContactsDAO.newInstance().insertRecords(contactListCreated,true,AccessLevel.USER_MODE);

        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            ContactsDAO.Criteria contactCriteria = new ContactsDAO.Criteria();
            contactCriteria.setRecordType(ContactsDAO.PERSON_RECORDTYPE);
            contactCriteria.setIsQUTStudent(true);
            
            List<Contact> contactList = ContactsDAO.newInstance()
                .findByCriteria(
                    contactCriteria, 
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(contactList.isEmpty(), 'Contact record should be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getQueryLocatorByCriteriaTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();

            MockIdGenerator mockIdGen = new MockIdGenerator(Contact.SObjectType);
            Id contactId = mockIdGen.getMockId();
            ContactsDAO.Criteria contactCriteria = new ContactsDAO.Criteria();
            contactCriteria.setIsQUTStudent(true);
            contactCriteria.setRecordType(ContactsDAO.PERSON_RECORDTYPE);
            contactCriteria.setContactIdSet(new Set<Id>{contactId});

            Database.QueryLocator contactQueryLocator = ContactsDAO.newInstance().getQueryLocatorByCriteria(contactCriteria);
            String expectedWhereClause = 'SELECT Id, hed__Citizenship_Status__c, QUT_Student_ID__c, Email, QUT_Learner_Email__c, Name, MobilePhone FROM Contact WHERE QUT_Student__c = ' + true +
             ' AND RecordType.DeveloperName = \'' + ContactsDAO.PERSON_RECORDTYPE + '\' AND Id IN (\''+ contactId +'\')';

            Test.stopTest();

            System.assertEquals(expectedWhereClause, contactQueryLocator.getQuery(), 'Incorrect Where Clause');
        }
        
    }

    @isTest
    static void getQueryLocatorBySubQueryTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            MockIdGenerator mockIdGen = new MockIdGenerator(Contact.SObjectType);
            Id contactId = mockIdGen.getMockId();
            ContactsDAO.Criteria contactCriteria = new ContactsDAO.Criteria();
            contactCriteria.setIsQUTStudent(true);
            contactCriteria.setRecordType(ContactsDAO.PERSON_RECORDTYPE);
            contactCriteria.setContactIdSet(new Set<Id>{contactId});

            String completedCadenceName = 'Domestic Accepted and Admitted';
            //Create a sample  Completed Cadence as a subquery for Contact
            CompletedCadencesDAO.Criteria completedCadenceCriteria = new CompletedCadencesDAO.Criteria();
            completedCadenceCriteria.setCompletedCadence(completedCadenceName);
            completedCadenceCriteria.setStatus(CompletedCadencesDAO.SUCCESSFUL_STATUS);
        
            String subQueryString = CompletedCadencesDAO.newInstance()
                .getContactQueryByCriteria(
                    completedCadenceCriteria,
                    contactCriteria
                );
            //Expected query to build
            String expectedquery = 'SELECT Id, hed__Citizenship_Status__c, QUT_Student_ID__c, Email, QUT_Learner_Email__c, Name, MobilePhone ' + 
                 'FROM Contact WHERE Id IN (' + subQueryString + ')';

            Database.QueryLocator contactQueryLocator = ContactsDAO.newInstance().getQueryLocatorBySubQuery(subQueryString); //update to string
            
            Test.stopTest();

            System.assertEquals(expectedquery, contactQueryLocator.getQuery(), 'Incorrect Where Clause');
        }
    }

    @isTest
    static void getContactByStudentIdTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Contact> contact = TestDataFactory.createTestContactRecords(1);
            contact[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            contact[0].QUT_Student__c = true;
            contact[0].QUT_Student_ID__c = '54321';
            ContactsDAO.newInstance().insertRecords(contact,true,AccessLevel.USER_MODE);


            Test.startTest();
            List<Contact> contactList = ContactsDAO.newInstance()
                .getContactByStudentId(
                    new List<String>{'54321'},
                    AccessLevel.USER_MODE
                );
            Test.stopTest();
            System.assert(!contactList.isEmpty(), 'contactList should not be empty.');
        }
    }

    @isTest
    static void getContactByStudentIdNegativeSTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            List<Contact> contactList = ContactsDAO.newInstance()
                .getContactByStudentId(
                    new List<String>{},
                    AccessLevel.USER_MODE
                );
            Test.stopTest();
            System.assert(contactList.isEmpty(), 'contactList should be empty.');
        }
    }

    @isTest
    static void getQueryLocatorContactByStudentIdTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            System.assert(
                ContactsDAO.newInstance().getQueryLocatorContactByStudentId(
                    new List<String>{},
                    AccessLevel.USER_MODE
                ) != null,
                'contactList should be empty'
            );
            Test.stopTest();
        }
    }

    @isTest
    static void queryLocatorGetMDMStudentsByIdsTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            System.assert(
                ContactsDAO.newInstance().queryLocatorGetMDMStudentsByIds(
                    new Set<Id>{},
                    AccessLevel.USER_MODE
                ) != null,
                'contactList should not be null'
            );
            Test.stopTest();
        }
    }

}