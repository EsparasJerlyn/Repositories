/**
 * @description Test Class for ContactTriggerHelper
 *
 * @see ../fContactTriggerHelper
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                            |
      |---------------------------|-----------------------|--------------|-----------------------------------------------------------|
      | angelika.j.s.galang       | November 3, 2021      | DEPP-734     | Created file                                              | 
      | roy.nino.s.regala         | January  18,2022      | DEPP-1178    | Updated for logic when primary bussiness org is populated | 
      |                           |                       |              |                                                           |
      | mark.j.mahilum            | July 28, 2023         | DEPP-6106    | Added test class coverage for can nurture logic           |
      | julie.jane.alegre         | Sept 14, 2023         | DEPP-6679    | Added test class createMarketingSegmentationTest          |
      | julie.jane.alegre         | Oct 27, 2023          | DEPP-6955    | Added new method updateRegisteredEmailTest                |
      | mark.j.mahilum            | Feb 29, 2024          | DEPP-7739    | Added new test method for contact to lead conversion      |
*/
@isTest
private class ContactTriggerHelperTest {
    private static final Id BUSINESS_ACC_RECTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Business_Organization')
        .getRecordTypeId();
    private static final Id ADMINISTRATIVE = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Administrative')
        .getRecordTypeId();

    @testSetup
    static void setupMethod() {
        Test.startTest();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        TestDataFactoryUser.generateUserQUTESB();
        TestDataFactory.loadEDATriggers();
        Test.stopTest();

        List<Account> accountList = new List<Account>();
        Account acc = TestDataFactory.createTestAccountRecords(1).iterator().next();
        acc.RecordTypeId = BUSINESS_ACC_RECTYPEID;
        accountList.add(acc);
        insert accountList;

        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<Lead_Score_Configuration__c> leadScoreParentConfigList = new List<Lead_Score_Configuration__c>();
            leadScoreParentConfigList.add(
                new Lead_Score_Configuration__c(
                    Name = 'Total Max Score DUG',
                    RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CONFIG,
                    Domestic_International__c = 'Undetermined',
                    Study_Level__c = 'Undetermined'
                )
            );

            LeadScoreConfigurationDAO.newInstance()
                .insertRecords(leadScoreParentConfigList, true, AccessLevel.SYSTEM_MODE);

            List<Lead_Score_Configuration__c> leadScoreConfigList = new List<Lead_Score_Configuration__c>();

            leadScoreConfigList.add(
                new Lead_Score_Configuration__c(
                    Name = 'Marketing Consent',
                    RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY,
                    Domestic_International__c = 'Undetermined',
                    Study_Level__c = 'Undetermined',
                    Description__c = '',
                    Score_Allocation__c = null,
                    Time_Limit_Months__c = null,
                    Max_Score__c = 20,
                    Parent_Category__c = leadScoreParentConfigList[0].Id
                )
            );

            LeadScoreConfigurationDAO.newInstance()
                .insertRecords(leadScoreConfigList, true, AccessLevel.USER_MODE);

            List<Lead_Score_Configuration__c> leadScoreConfigChildList = new List<Lead_Score_Configuration__c>();
            leadScoreConfigChildList.addAll(
                TestDataFactory.createUndAndUndeterminedSubCategory(
                    leadScoreConfigList[0].Id,
                    new List<String>{ 'Yes', 'Is blank' },
                    new List<Integer>{ 10, 10 }
                )
            );

            LeadScoreConfigurationDAO.newInstance()
                .insertRecords(leadScoreConfigChildList, true, AccessLevel.USER_MODE);

            List<Nurture_Track_Configuration__c> nurtureList = new List<Nurture_Track_Configuration__c>();
            Nurture_Track_Configuration__c nurtureConfig = new Nurture_Track_Configuration__c();
            nurtureConfig.Lead_Score_Threshold__c = -1;
            nurtureConfig.Status__c = 'Active';
            nurtureConfig.Cadence_Name__c = NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PRE_APPLICATION_MANUAL;
            nurtureList.add(nurtureConfig);

            NurtureTrackConfigurationsDAO.newInstance()
                .insertRecords(nurtureList, false, AccessLevel.SYSTEM_MODE);

            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].FirstName = 'Test Contact For Nurture';
            contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.SYSTEM_MODE);
        }
    }

    @isTest
    private static void insertContactTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Account> accList = [
                SELECT Id, RecordTypeId
                FROM Account
                WHERE RecordTypeId = :BUSINESS_ACC_RECTYPEID OR RecordTypeId = :ADMINISTRATIVE
            ];
            Id adminAccount;
            Id businessAccount;
            for (Account acc : accList) {
                if (acc.RecordTypeId == BUSINESS_ACC_RECTYPEID) {
                    businessAccount = acc.Id;
                } else if (acc.RecordTypeId == ADMINISTRATIVE) {
                    adminAccount = acc.Id;
                }
            }

            List<Contact> conList = TestDataFactory.createTestContactRecords(100);
            for (Integer i = 0; i < conList.size(); i++) {
                conList[i].hed__Primary_Organization__c = businessAccount;
            }

            Test.startTest();
            insert (conList);
            Test.stopTest();

            List<AccountContactRelation> acrt = new List<AccountContactRelation>(
                [
                    SELECT Id
                    FROM AccountContactRelation
                    WHERE Account.RecordTypeId = :BUSINESS_ACC_RECTYPEID
                ]
            );
            System.assert(acrt.size() == 100, 'Contacts where not updated');
        }
    }

    @isTest
    private static void updatePrimaryBusinessOrgContactTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Account> accList = [
                SELECT Id, RecordTypeId
                FROM Account
                WHERE RecordTypeId = :BUSINESS_ACC_RECTYPEID OR RecordTypeId = :ADMINISTRATIVE
            ];
            Id adminAccount;
            Id businessAccount;
            for (Account acc : accList) {
                if (acc.RecordTypeId == BUSINESS_ACC_RECTYPEID) {
                    businessAccount = acc.Id;
                } else if (acc.RecordTypeId == ADMINISTRATIVE) {
                    adminAccount = acc.Id;
                }
            }

            List<Contact> conList = TestDataFactory.createTestContactRecords(100);
            for (Integer i = 0; i < conList.size(); i++) {
                conList[i].hed__Primary_Organization__c = businessAccount;
            }

            Test.startTest();
            insert (conList);
            Test.stopTest();

            List<AccountContactRelation> acrt = new List<AccountContactRelation>(
                [
                    SELECT Id
                    FROM AccountContactRelation
                    WHERE Account.RecordTypeId = :BUSINESS_ACC_RECTYPEID
                ]
            );
            System.assert(acrt.size() == 100, 'Contacts where not updated');
        }
    }
    
    @isTest
    private static void testContactCanNurtureFlag() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Contact> contactList = ContactsDAO.newInstance().getPersonContactsWithLimit(10);
            List<Contact> contactListToUpdate = new List<Contact>();
            for (Contact record : contactList) {
                if (record.FirstName == 'Test Contact For Nurture') {
                    record.Email_Opt_In_DateTime__c = Date.today();
                    record.hed__Citizenship_Status__c = 'International';
                    contactListToUpdate.add(record);
                }
            }
            ContactsDAO.newInstance()
                .updateRecords(contactListToUpdate, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();

            Contact record = ContactsDAO.newInstance()
                .getPersonContactsBySetIds(
                    new Set<Id>{ contactList[0].Id },
                    AccessLevel.SYSTEM_MODE
                )[0];
            System.assertEquals(
                true,
                record.Can_Nurture__c,
                'Contact Can_Nurture__c did not match'
            );
        }
    }

    @isTest
    private static void testGetContactCalculatedCadence() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Contact> newContacts = TestDataFactory.createTestContactRecords(10);
            newContacts[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
            List<Contact> updateContactList = new List<Contact>();
            for (Contact con : newContacts) {
                Contact conRec = new Contact();
                conRec.Id = con.Id;
                conRec.Calculated_Cadence__c = 'Test Cadences automated1';
                updateContactList.add(conRec);
            }

            Test.startTest();
            ContactsDAO.newInstance()
                .updateRecords(updateContactList, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();

            System.assert(
                ![SELECT Id FROM AsyncApexJob WHERE ApexClass.Name = 'SalesCadenceCalloutService']
                    .isEmpty(),
                'SalesCadenceCalloutService Queueable Job was not executed'
            );
        }
    }

    @isTest
    private static void testUpdateMovingToBrisbaneOnInsert() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            Marketing_Segmentation__c marSeg = new Marketing_Segmentation__c(
                My_Moving_To_Brisbane__c = true
            );
            insert marSeg;
            Contact con = new Contact(LastName = 'Test', Marketing_Segmentation__c = marSeg.Id);
            ContactsDAO.newInstance()
                .insertRecords(new List<Contact>{ con }, true, AccessLevel.SYSTEM_MODE);
            marSeg.Contact__c = con.Id;
            update marSeg;
            Contact finalCon = [
                SELECT Id, Moving_To_Brisbane__c
                FROM Contact
                WHERE Id = :con.Id
                LIMIT 1
            ];
            Test.stopTest();
            System.assertEquals(
                true,
                finalCon.Moving_to_Brisbane__c,
                'The contact\'s Moving To Brisbane field was not set to true.'
            );
        }
    }

    @isTest
    private static void testUpdateMovingToBrisbaneOnUpdate() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            Marketing_Segmentation__c marSeg = new Marketing_Segmentation__c(
                My_Moving_To_Brisbane__c = true
            );
            insert marSeg;
            Contact con = new Contact(LastName = 'Test');
            ContactsDAO.newInstance()
                .insertRecords(new List<Contact>{ con }, false, AccessLevel.SYSTEM_MODE);
            con.Marketing_Segmentation__c = marSeg.Id;
            ContactsDAO.newInstance()
                .updateRecords(new List<Contact>{ con }, false, AccessLevel.SYSTEM_MODE);
            Contact finalCon = [
                SELECT Id, Moving_To_Brisbane__c
                FROM Contact
                WHERE Id = :con.Id
                LIMIT 1
            ];
            Test.stopTest();
            System.assertEquals(
                true,
                finalCon.Moving_to_Brisbane__c,
                'The contact\'s Moving To Brisbane field was not set to true.'
            );
        }
    }

    @isTest
    private static void createMarketingSegmentationTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            List<Contact> contacts = TestDataFactory.createTestContactRecords(10);

            for (Integer i = 0; i < 10; i++) {
                contacts[i].FirstName = 'Test Fname' + i;
                contacts[i].LastName = 'Test Lname' + i;
                contacts[i].email = i + 'test@email.com';
                contacts[i].Work_Email__c = i + 'test@workemail.com';
            }
            Database.SaveResult[] srList = ContactsDAO.newInstance()
                .insertRecords(contacts, false, AccessLevel.USER_MODE);
            Test.stopTest();
            Set<Id> contactIds = new Set<Id>();
            for (Database.SaveResult sr : srList) {
                contactIds.add(sr.getId());
            }
            List<Marketing_Segmentation__c> marketingSegList = MarketingSegmentationsDAO.newInstance()
                .getMarketingSegmentationByContactIds(contactIds, AccessLevel.USER_MODE);

            for (Marketing_Segmentation__c marketingSeg : marketingSegList) {
                System.assert(
                    marketingSeg.Contact__c != null,
                    'No Marketing Segmentation record created for the contact'
                );
            }
        }
    }

    @isTest
    private static void updateRegisteredEmailTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Contact> contacts = TestDataFactory.createTestContactRecords(10);

            for (Integer i = 0; i < 10; i++) {
                contacts[i].FirstName = 'Test Fname' + i;
                contacts[i].LastName = 'Test Lname' + i;
                contacts[i].Email = i + 'test@email.com';
                contacts[i].Work_Email__c = i + 'test@workemail.com';
                contacts[i].Registered_Email__c = i + 'test@email.com';
            }
            Database.SaveResult[] srList = ContactsDAO.newInstance()
                .insertRecords(contacts, false, AccessLevel.USER_MODE);

            Set<Id> contactIds = new Set<Id>();
            for (Database.SaveResult sr : srList) {
                contactIds.add(sr.getId());
            }
            List<Contact> contactList = ContactsDAO.newInstance()
                .getPersonContactsBySetIds(contactIds, AccessLevel.USER_MODE);

            for (Integer i = 0; i < contactList.size(); i++) {
                contactList[i].Email = i + 'test@emailupdates123.com';
            }
            ContactsDAO.newInstance().updateRecords(contactList, false, AccessLevel.USER_MODE);

            Test.stopTest();

            for (
                Contact record : ContactsDAO.newInstance()
                    .getPersonContactsBySetIds(contactIds, AccessLevel.SYSTEM_MODE)
            ) {
                System.assertEquals(
                    record.Email,
                    record.Registered_Email__c,
                    'Contact Registered_Email__c did not match.'
                );
            }
        }
    }

    @isTest
    private static void createMCPersonaRecordsTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<Contact> contacts = TestDataFactory.createTestContactRecords(10);
            Set<Id> personContactIds = new Set<Id>();
            Test.startTest();
            for (Integer i = 0; i < 10; i++) {
                contacts[i].FirstName = 'Test Fname' + i;
                contacts[i].LastName = 'Test Lname' + i;
                contacts[i].Email = i + 'test@email.com';
                contacts[i].Work_Email__c = i + 'test@workemail.com';
                contacts[i].QUT_Staff_Email__c = i + 'test@staffemail.com';
                contacts[i].QUT_Learner_Email__c = i + 'test@learneremail.com';
                contacts[i].hed__Preferred_Email__c = 'Alternate Email';
                contacts[i].hed__AlternateEmail__c = i + 'test@email.com';
            }

            ContactsDAO.newInstance().insertRecords(contacts, true, AccessLevel.USER_MODE);
            Test.stopTest();
            for (Contact con : contacts) {
                personContactIds.add(con.Id);
            }

            System.assertEquals(
                30,
                ContactsDAO.newInstance()
                    .getMCPersonaContactsByParentPersonContactIds(
                        personContactIds,
                        AccessLevel.SYSTEM_MODE
                    )
                    .size(),
                'MC Persona Records must be created'
            );
        }
    }

    @isTest
    private static void createMCPersonaByUpdatingPersonContact() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<Contact> contacts = TestDataFactory.createTestContactRecords(10);
            Set<Id> personContactIds = new Set<Id>();
            Test.startTest();
            for (Integer i = 0; i < 10; i++) {
                contacts[i].FirstName = 'Test Fname' + i;
                contacts[i].LastName = 'Test Lname' + i;
                contacts[i].Email = i + 'test@email.com';
                contacts[i].hed__Preferred_Email__c = 'Alternate Email';
                contacts[i].hed__AlternateEmail__c = i + 'test@email.com';
            }

            ContactsDAO.newInstance().insertRecords(contacts, true, AccessLevel.USER_MODE);
            Test.stopTest();
            for (Contact con : contacts) {
                personContactIds.add(con.Id);
            }

            System.assertEquals(
                0,
                ContactsDAO.newInstance()
                    .getMCPersonaContactsByParentPersonContactIds(
                        personContactIds,
                        AccessLevel.SYSTEM_MODE
                    )
                    .size(),
                'MC Persona Records must not be created'
            );

            for (Integer i = 0; i < 10; i++) {
                contacts[i].Work_Email__c = i + 'test@workemail.com';
                contacts[i].QUT_Staff_Email__c = i + 'test@staffemail.com';
                contacts[i].QUT_Learner_Email__c = i + 'test@learneremail.com';
            }

            ContactsDAO.newInstance().updateRecords(contacts, true, AccessLevel.USER_MODE);

            System.assertEquals(
                30,
                ContactsDAO.newInstance()
                    .getMCPersonaContactsByParentPersonContactIds(
                        personContactIds,
                        AccessLevel.SYSTEM_MODE
                    )
                    .size(),
                'MC Persona Records must be created'
            );
        }
    }

    @isTest
    private static void updateMCPersonaByUpdatingPersonContact() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<Contact> contacts = TestDataFactory.createTestContactRecords(10);

            Set<Id> personContactIds = new Set<Id>();
            Test.startTest();
            for (Integer i = 0; i < 10; i++) {
                contacts[i].FirstName = 'Test Fname' + i;
                contacts[i].LastName = 'Test Lname' + i;
                contacts[i].Email = i + 'test@email.com';
                contacts[i].Work_Email__c = i + 'test@workemail.com';
                contacts[i].QUT_Staff_Email__c = i + 'test@staffemail.com';
                contacts[i].QUT_Learner_Email__c = i + 'test@learneremail.com';
                contacts[i].hed__Preferred_Email__c = 'Alternate Email';
                contacts[i].hed__AlternateEmail__c = i + 'test@email.com';
                contacts[i].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            }

            ContactsDAO.newInstance().insertRecords(contacts, true, AccessLevel.SYSTEM_MODE);
            Test.stopTest();
            for (Contact con : contacts) {
                personContactIds.add(con.Id);
            }

            System.assertEquals(
                30,
                ContactsDAO.newInstance()
                    .getMCPersonaContactsByParentPersonContactIds(
                        personContactIds,
                        AccessLevel.SYSTEM_MODE
                    )
                    .size(),
                'MC Persona Records must be created'
            );
            List<Contact> contactsToUpdate = new List<Contact>();

            for (Integer i = 0; i < 10; i++) {
                contactsToUpdate.add(
                    new Contact(
                        Id = contacts[i].Id,
                        Work_Email__c = i + 'test@workemailupdated.com',
                        QUT_Staff_Email__c = i + 'test@staffemailupdated.com',
                        QUT_Learner_Email__c = i + 'test@learneremailupdated.com',
                        Work_Email_Opt_Out__c = false,
                        Work_Email_Opt_In_DateTime__c = System.now(),
                        Learner_Email_Opt_Out__c = false,
                        Learner_Email_Opt_In_DateTime__c = System.now(),
                        Staff_Email_Opt_Out__c = false,
                        Staff_Email_Opt_In_DateTime__c = System.now()
                    )
                );
            }

            ContactsDAO.newInstance()
                .updateRecords(contactsToUpdate, true, AccessLevel.SYSTEM_MODE);
            List<Contact> mcContacts = ContactsDAO.newInstance()
                .getMCPersonaContactsByParentPersonContactIds(
                    personContactIds,
                    AccessLevel.SYSTEM_MODE
                );
            System.assertEquals(30, mcContacts.size(), 'MC Persona Records where newly created');

            for (Contact con : mcContacts) {
                System.assert(con.email.contains('updated'), 'Email should be updated');
                System.assert(
                    con.Email_Opt_In_Datetime__c != null,
                    'Email opt in date time must be updated'
                );
            }
        }
    }

    @isTest
    private static void updateParentByUpdatingChildMCPersona() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<Contact> contacts = TestDataFactory.createTestContactRecords(10);

            Set<Id> personContactIds = new Set<Id>();
            Test.startTest();
            for (Integer i = 0; i < 10; i++) {
                contacts[i].FirstName = 'Test Fname' + i;
                contacts[i].LastName = 'Test Lname' + i;
                contacts[i].Email = i + 'test@email.com';
                contacts[i].Work_Email__c = i + 'test@workemail.com';
                contacts[i].QUT_Staff_Email__c = i + 'test@staffemail.com';
                contacts[i].QUT_Learner_Email__c = i + 'test@learneremail.com';
                contacts[i].hed__Preferred_Email__c = 'Alternate Email';
                contacts[i].hed__AlternateEmail__c = i + 'test@email.com';
                contacts[i].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            }

            ContactsDAO.newInstance().insertRecords(contacts, true, AccessLevel.SYSTEM_MODE);
            Test.stopTest();
            for (Contact con : contacts) {
                personContactIds.add(con.Id);
            }

            System.assertEquals(
                30,
                ContactsDAO.newInstance()
                    .getMCPersonaContactsByParentPersonContactIds(
                        personContactIds,
                        AccessLevel.SYSTEM_MODE
                    )
                    .size(),
                'MC Persona Records must be created'
            );

            List<Contact> contactsToUpdate = new List<Contact>();

            for (
                Contact con : ContactsDAO.newInstance()
                    .getMCPersonaContactsByParentPersonContactIds(
                        personContactIds,
                        AccessLevel.SYSTEM_MODE
                    )
            ) {
                con.Email = 'updated' + con.Email;
                contactsToUpdate.add(con);
            }

            ContactsDAO.newInstance()
                .updateRecords(contactsToUpdate, true, AccessLevel.SYSTEM_MODE);

            for (
                Contact con : ContactsDAO.newInstance()
                    .getPersonContactsBySetIds(personContactIds, AccessLevel.SYSTEM_MODE)
            ) {
                System.assert(con.Work_Email__c.contains('updated'), 'Email should be updated');
                System.assert(
                    con.QUT_Staff_Email__c.contains('updated'),
                    'QUT Staff Email should be updated'
                );
                System.assert(
                    con.QUT_Learner_Email__c.contains('updated'),
                    'QUT Learner Email should be updated'
                );
            }
        }
    }

    @isTest
    private static void updateParentLeadByUpdatingMCPersona() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<Lead> leads = TestDataFactory.createTestLeadRecords(10);
            Set<Id> leadIds = new Set<Id>();

            Test.startTest();

            for (Integer i = 0; i < 10; i++) {
                leads[i].Work_Email__c = i + 'test@workemail.com';
            }

            LeadsDAO.newInstance().insertRecords(leads, true, AccessLevel.SYSTEM_MODE);
            Test.stopTest();
            for (Lead lead : leads) {
                leadIds.add(lead.Id);
            }

            List<Contact> contactsToUpdate = new List<Contact>();

            for (
                Contact con : ContactsDAO.newInstance()
                    .getMCPersonaContactsByParentPersonLeadIds(leadIds, AccessLevel.SYSTEM_MODE)
            ) {
                con.Email = 'updated' + con.Email;
                contactsToUpdate.add(con);
            }

            ContactsDAO.newInstance()
                .updateRecords(contactsToUpdate, true, AccessLevel.SYSTEM_MODE);

            for (
                Contact con : ContactsDAO.newInstance()
                    .getMCPersonaContactsByParentPersonLeadIds(leadIds, AccessLevel.SYSTEM_MODE)
            ) {
                System.assert(
                    con.Parent_Person_Lead__r.Work_Email__c.contains('updated'),
                    'Work Email should be updated'
                );
            }
        }
    }

    @isTest
    private static void testContactPrimaryEmailIsEmptyAndConvertLeadToContact() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Integer numOfRecords = 10;
            List<Lead> leads = new List<Lead>();
            for (Integer i = 0; i <= numOfRecords; i++) {
                leads.add(
                    new Lead(
                        FirstName = 'Test' + i,
                        LastName = 'Record' + i,
                        Company = 'TestCompany',
                        Phone = '012345678',
                        Street = 'TestStreet',
                        State = 'TestState',
                        City = 'TestCity',
                        Country = 'Japan',
                        PostalCode = '4102',
                        Email = 'test@record.com' + i,
                        MobilePhone = '012345678',
                        Personal_Mobile__c = '012345678',
                        Company_Category__c = 'Corporate',
                        ABN__c = '000',
                        LeadABNEntity_Validation__c = 'Valid',
                        LeadAddress_Validation__c = 'Valid',
                        LeadMobile_Validation__c = 'Valid',
                        Mobile_No_Locale__c = '012345678',
                        LeadPersonalMobile_Validation__c = 'Valid',
                        LeadPhone_Validation__c = 'Valid',
                        LinkedIn_Profile_URL__c = 'test@record.com',
                        WorkPhone_Validation__c = 'Valid',
                        Phone_No_Locale__c = '012345678',
                        Lead_Type__c = 'Learner'
                    )
                );
            }

            Database.SaveResult[] srLeadList = LeadsDAO.newInstance()
                .insertRecords(leads, false, AccessLevel.SYSTEM_MODE);
            Set<Id> leadIds = new Set<Id>();
            for (Database.SaveResult sr : srLeadList) {
                if (sr.isSuccess()) {
                    leadIds.add(sr.getId());
                }
            }

            List<Contact> contactList = new List<Contact>();
            for (Integer i = 0; i <= numOfRecords; i++) {
                contactList.add(
                    new Contact(
                        FirstName = 'Test' + i,
                        LastName = 'Record' + i,
                        Work_Email__c = 'test@record.com' + i,
                        Company_Name__c = 'mcTestCompany',
                        RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID
                    )
                );
            }
            Test.startTest();
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();

            for (Lead rec : [SELECT Id, IsConverted, Status FROM Lead WHERE Id IN :leadIds]) {
                System.assertEquals(true, rec.IsConverted, 'Lead is not converted');
                System.assertEquals('Qualified', rec.Status, 'Lead is not converted');
            }
        }
    }

    @isTest
    private static void setMatchingfirstAndLastNameTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            String regexPattern = '[^a-zA-Z]';
            for (Contact con : ContactsDAO.newInstance().getPersonContactsWithLimit(100)) {
                system.assertEquals(
                    con.FirstName.replaceAll(regexPattern, ''),
                    con.Matching_Firstname__c,
                    'FirstName without special characters should match with Matching_Firstname__c'
                );
                system.assertEquals(
                    con.LastName.replaceAll(regexPattern, ''),
                    con.Matching_Lastname__c,
                    'LastName without special characters should match with Matching_Lastname__c'
                );
            }
        }
    }

    @isTest
    private static void processSystemKeyChangeOnContactTriggerInsert() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Contact> contactRecords = TestDataFactory.createTestContactRecords(100);
            Integer count = 0;
            Set<String> systemKeyIds = new Set<String>();
            for (Contact con : contactRecords) {
                con.QUT_Employee_ID__c = '01' + count++;
                con.QUT_Student_ID__c = 'O2' + count++;
                systemKeyIds.add(con.QUT_Employee_ID__c);
                systemKeyIds.add(con.QUT_Student_ID__c);
            }
            ContactsDAO.newInstance().insertRecords(contactRecords, true, AccessLevel.USER_MODE);
            Test.stopTest();

            System.assertEquals(
                200,
                ContactAlternateIdsDAO.newInstance()
                    .getContactAlternateIdsBySystemKeyIdSet(systemKeyIds, AccessLevel.USER_MODE)
                    .size(),
                'There should be 200 alternate ids created'
            );
        }
    }

    @isTest
    private static void processSystemKeyChangeOnContactTriggerUpdate() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Contact> contactRecords = TestDataFactory.createTestContactRecords(100);
            Integer count = 0;
            Set<String> systemKeyIdsOnInsert = new Set<String>();
            Set<String> systemKeyIdsOnUpdate = new Set<String>();
            Set<String> allSystemKeyIds = new Set<String>();

            for (Contact con : contactRecords) {
                con.QUT_Employee_ID__c = '01' + count++;
                con.QUT_Student_ID__c = 'O2' + count++;
                systemKeyIdsOnInsert.add(con.QUT_Employee_ID__c);
                systemKeyIdsOnInsert.add(con.QUT_Student_ID__c);
            }

            ContactsDAO.newInstance().insertRecords(contactRecords, true, AccessLevel.USER_MODE);
            Test.stopTest();

            System.assertEquals(
                200,
                ContactAlternateIdsDAO.newInstance()
                    .getContactAlternateIdsBySystemKeyIdSet(
                        systemKeyIdsOnInsert,
                        AccessLevel.USER_MODE
                    )
                    .size(),
                'There should be 200 active alternate ids created'
            );

            for (Contact con : contactRecords) {
                con.QUT_Employee_ID__c = '03' + count++;
                con.QUT_Student_ID__c = 'O4' + count++;
                systemKeyIdsOnUpdate.add(con.QUT_Employee_ID__c);
                systemKeyIdsOnUpdate.add(con.QUT_Student_ID__c);
            }

            ContactsDAO.newInstance().updateRecords(contactRecords, true, AccessLevel.USER_MODE);
            allSystemKeyIds.addAll(systemKeyIdsOnInsert);
            allSystemKeyIds.addAll(systemKeyIdsOnUpdate);

            List<Contact_Alternate_ID__c> conAltIds = ContactAlternateIdsDAO.newInstance()
                .getContactAlternateIdsBySystemKeyIdSet(allSystemKeyIds, AccessLevel.USER_MODE);

            System.assertEquals(
                200,
                conAltIds.size(),
                'There should be 200 alternate active alternate ids created'
            );

            for (Contact_Alternate_ID__c conAltId : conAltIds) {
                System.assert(
                    systemKeyIdsOnUpdate.contains(conAltId.Contact_Alternate_Id__c),
                    'Contact alternate id should exist in the set of contact alternate ids on update'
                );
            }
        }
    }

    @isTest
    private static void testLeadWorkEmailIsPopulatedAndConvertLeadToContact() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Integer numOfRecords = 5;
            List<Contact> contactList = new List<Contact>();
            for (Integer i = 0; i <= numOfRecords; i++) {
                contactList.add(
                    new Contact(
                        FirstName = 'Test' + i,
                        LastName = 'Record' + i,
                        Company_Name__c = 'mcTestCompany',
                        RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID
                    )
                );
            }
            Database.SaveResult[] srContactList = ContactsDAO.newInstance()
                .insertRecords(contactList, false, AccessLevel.SYSTEM_MODE);
            Set<Id> contactIds = new Set<Id>();
            for (Database.SaveResult sr : srContactList) {
                if (sr.isSuccess()) {
                    contactIds.add(sr.getId());
                }
            }
            Test.startTest();
            List<Lead> leads = new List<Lead>();
            for (Integer i = 0; i <= numOfRecords; i++) {
                leads.add(
                    new Lead(
                        FirstName = 'Test' + i,
                        LastName = 'Record' + i,
                        Company = 'TestCompany',
                        Phone = '012345678',
                        Street = 'TestStreet',
                        State = 'TestState',
                        City = 'TestCity',
                        Country = 'Japan',
                        PostalCode = '4102',
                        Work_Email__c = 'testLead@record.com' + i,
                        MobilePhone = '012345678',
                        Personal_Mobile__c = '012345678',
                        Company_Category__c = 'Corporate',
                        ABN__c = '000',
                        LeadABNEntity_Validation__c = 'Valid',
                        LeadAddress_Validation__c = 'Valid',
                        LeadMobile_Validation__c = 'Valid',
                        Mobile_No_Locale__c = '012345678',
                        LeadPersonalMobile_Validation__c = 'Valid',
                        LeadPhone_Validation__c = 'Valid',
                        LinkedIn_Profile_URL__c = 'test@record.com',
                        WorkPhone_Validation__c = 'Valid',
                        Phone_No_Locale__c = '012345678',
                        Lead_Type__c = 'Learner'
                    )
                );
            }

            Database.SaveResult[] srLeadList = LeadsDAO.newInstance()
                .insertRecords(leads, false, AccessLevel.USER_MODE);

            Set<Id> leadIds = new Set<Id>();
            for (Database.SaveResult sr : srLeadList) {
                if (sr.isSuccess()) {
                    leadIds.add(sr.getId());
                }
            }

            List<Contact> updateContactList = [SELECT Id FROM Contact WHERE Id IN :contactIds];
            Integer i = 0;
            for (Contact con : updateContactList) {
                con.Email = 'testLead@record.com' + i;
                i++;
            }

            ContactsDAO.newInstance()
                .updateRecords(updateContactList, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();

            for (Lead rec : [SELECT Id, IsConverted, Status FROM Lead WHERE Id IN :leadIds]) {
                System.assertEquals(true, rec.IsConverted, 'Lead is not converted');
                System.assertEquals('Qualified', rec.Status, 'Lead is not converted');
            }
        }
    }

    @isTest
    private static void testContactMatching() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<Contact> contactRecords = TestDataFactory.createTestContactRecords(0, 50);
            List<Contact> contactToUpdate = new List<Contact>();
            for (Contact con : contactRecords) {
                con.Birthdate = System.Today().addYears(-18);
            }
            ContactsDAO.newInstance().insertRecords(contactRecords, true, AccessLevel.USER_MODE);

            Test.startTest();
            Integer count = 0;
            for (Contact con : contactRecords) {
                con.Birthdate = System.Today().addYears(-18);
                con.MobilePhone = '12345612345';
                contactToUpdate.add(con);
                count++;
                if (count == 25) {
                    break;
                }
            }
            for (
                Database.SaveResult result : ContactsDAO.newInstance()
                    .updateRecords(contactRecords, false, AccessLevel.USER_MODE)
            ) {
                for (Database.Error error : result.getErrors()) {
                    System.assertEquals(
                        error.getMessage(),
                        'Contact update failed to prevent duplicate contact creation',
                        'update was successful'
                    );
                }
            }
            Test.stopTest();
        }
    }
}
