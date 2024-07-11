/**
 * @description Test Class for ApplicationTriggerHelper.
 * 
 * @see ApplicationTriggerHelper
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                                      |
      |---------------------------|-----------------------|--------------|---------------------------------------------------------------------|
      | mark.j.mahilum            | July 18,2023          | DEPP-5799    | Created file                                                        |
      | alexander.cadalin         | Aug 16, 2023          | DEPP-6124    | Refactor to consider multiple field updates                         |
      | julie.jane.alegre         | September 20, 2023    | DEPP-6667    | Added testUpdateContactWhenQTACAppIsInactive                        |
      | alexander.cadalin         | Sep. 22, 2023         | DEPP-6652    | Added methods for contact field updates on match to application     |
      |                           |                       | DEPP-6653    |                                                                     |
      |                           |                       | DEPP-6654    |                                                                     |  
      | nicole.genon              | Oct. 4, 2023          | DEPP-6821    | Added Citizenship_Status__c field mapping for QTAC matching         |
      | roy.nino.s.regala         | Feb, 23, 2024         | DEPP-7738    | optimized creation of data setup                                    |
      | sebastianne.k.trias       | June 1, 2024          | DEPP-8474    | Removed modify Opt in/out fields                                    |
*/
@isTest
private class ApplicationTriggerHelperTest {
    private static final String FIRSTNAME = 'TestfirstName';
    private static final String LASTNAME = 'Testlastname';
    private static final String EMAIL = 'testmail@mail.test';
    private static final String BIRTHDAY = '2000-06-28';
    private static Integer recordsCount = 20;
    
    static {
        ImplementationSelector.DAO.setMock(new ConMatchingServiceConfigurationsDAOMock());
        String developerName = ConMatchingServiceConfigurationsDAO.APPLICATION_BATCH;
        Contact_Matching_Service_Configuration__mdt customMetaData = (Contact_Matching_Service_Configuration__mdt) JSON.deserialize(
            '{"IsActive__c":"true","Size__c":"200","DeveloperName":"' + developerName + '"}',
            Contact_Matching_Service_Configuration__mdt.class
        );

        ConMatchingServiceConfigurationsDAO.newInstance()
            .insertRecords(
                new List<Contact_Matching_Service_Configuration__mdt>{ customMetaData },
                true,
                AccessLevel.SYSTEM_MODE
            );
    }
    
    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        TestDataFactoryUser.generateUserQUTESB();
        TestDataFactory.loadEDATriggers();
        Test.stopTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<Account> newAccounts = new List<Account>();
            newAccounts.add(TestDataFactory.createTestAccount(false));
            newAccounts[0].RecordTypeId = AccountsDAO.ACCT_UNIV_DEP_ID;
            AccountsDAO.newInstance().insertRecords(newAccounts, false, AccessLevel.SYSTEM_MODE);

            List<Contact> newContacts = createTestContactRecords(0, 1);
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
            
            ApplicationsDAO.newInstance().insertRecords(
                createTestApplicationRecords(newContacts,'Existing',ApplicationsDAO.STUDYLINK_RECTYPE_ID),
                false,
                AccessLevel.SYSTEM_MODE
            );    

            List<Marketing_Interaction__c> marketingInteractionList = TestDataFactory.createMarketingInteractionRecords(newContacts[0].Id, 1, 'QTAC');
            MarketingInteractionsDAO.newInstance().insertRecords(marketingInteractionList, false, AccessLevel.SYSTEM_MODE);
        }
    }

    @isTest
    private static void testApplicationInsertWithContact() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<Contact> newContacts = createTestContactRecords(0, 1);            
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
            
            Test.startTest();
            Database.SaveResult[] srList = ApplicationsDAO.newInstance()
                .insertRecords(
                    createTestApplicationRecords(newContacts,'Existing',ApplicationsDAO.STUDYLINK_RECTYPE_ID),
                    false,
                    AccessLevel.SYSTEM_MODE
                );
            Test.stopTest();
            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record was not saved.');
            }
        }
    }
    
    @isTest
    private static void testApplicationUpdateRemoveContact() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            
            Id contactId = ContactsDAO.newInstance().getPersonContactsWithLimit(1).iterator().next()?.Id;                
            List<hed__Application__c> existingApplicationList = ApplicationsDAO.newInstance().getApplicationsByContactIds(new Set<Id>{contactId},'SYSTEM_MODE');   
            
            for(hed__Application__c app: existingApplicationList){            
                
				app.Application_Status__c = 'Accepted';  
                app.hed__Applicant__c = null;
            }
            
            Test.startTest();
            Database.SaveResult[] srList = ApplicationsDAO.newInstance()
                .updateRecords(
                    existingApplicationList,
                    false,
                    AccessLevel.SYSTEM_MODE
                );
            Test.stopTest();
            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record was not updated.');
            }
        }
    }
    
    @isTest
    private static void testApplicationWithLeadApplicationStatusWithdrawn() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Id contactId = ContactsDAO.newInstance().getPersonContactsWithLimit(1).iterator().next()?.Id;                
            List<hed__Application__c> existingApplicationList = ApplicationsDAO.newInstance().getApplicationsByContactIds(new Set<Id>{contactId},'USER_MODE');   
            List<hed__Application__c> applicationToUpdateList = new List<hed__Application__c>();
            for(hed__Application__c app: existingApplicationList){                           
                applicationToUpdateList.add(new hed__Application__c(Id = app.Id ,Application_Status__c = 'Withdrawn'));
            }
            
            Test.startTest();
            Database.SaveResult[] srList = ApplicationsDAO.newInstance()
                .updateRecords(
                    applicationToUpdateList,
                    false,
                    AccessLevel.USER_MODE
                );
            Test.stopTest();
            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record was not updated.');
            }
        }
    } 

    @isTest
    private static void updateCalculatedDateOnSamsApplicationRecordsTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Contact> newContacts = createTestContactRecords(0, 1);
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);

            // create term
            List<Account> accountList = AccountsDAO.newInstance()
                .getAccountsBySetNames(new Set<String>{'Test Account'});
            hed__Term__c appliedIntakeTerm = new hed__Term__c(
                hed__Start_Date__c = System.today(),
                hed__Account__c = accountList[0].Id
            );
            insert appliedIntakeTerm;
            // create application
            List<hed__Application__c> newApplications = createTestApplicationRecords(newContacts,'New', ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID);
            newApplications[0].Applied_Intake_Study_Period__c = appliedIntakeTerm.Id;
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);
            
            Test.stopTest();

            List<hed__Application__c> updatedApplicationList = [SELECT Id, Calculated_Intake_Date__c,Applied_Intake_Study_Period__c FROM hed__Application__c WHERE Applied_Intake_Study_Period__c =: appliedIntakeTerm.Id];
            // assert
            System.assertEquals(
                Date.today(),
                updatedApplicationList[0].Calculated_Intake_Date__c, 
                'Error, Should be equal to term start date.'
            );
        }
    } 
    
    @isTest
    private static void testUpdateRelatedContacts() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<hed__Application__c> applicationsToUpdate = [
                SELECT Id, Is_Agent_Assisted__c, Is_International_Applicant__c,
                Is_Personal_Illness_Disability_Applicant__c, Is_Elite_Athlete_Applicant__c, 
                Is_Education_Disruption_Applicant__c, Is_First_In_Family_Applicant__c, 
                Is_Financial_Hardship_Applicant__c, Agency_Name__c, Agency_Country__c, Agency_Email__c,
                hed__Applicant__c
                FROM hed__Application__c
                WHERE hed__Applicant__c != null
                WITH SYSTEM_MODE
                LIMIT 1
            ];
            for(hed__Application__c app : applicationsToUpdate) {
                app.Is_Agent_Assisted__c = true;
                app.Is_International_Applicant__c = true;
                app.Is_Personal_Illness_Disability_Applicant__c = true;
                app.Is_Elite_Athlete_Applicant__c = true;
                app.Is_Education_Disruption_Applicant__c = true;
                app.Is_First_In_Family_Applicant__c = true;
                app.Is_Financial_Hardship_Applicant__c = true;
                app.Agency_Name__c = 'Agency Name';
                app.Agency_Country__c = 'Agency Country';
                app.Agency_Email__c = 'agency@email.test';
            }
            Test.startTest();
            ApplicationsDAO.newInstance().updateRecords(applicationsToUpdate, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();
            Contact updatedContact = [
                SELECT Id, Is_Agent_Assisted__c, 
                Is_International_Applicant__c, 
                Personal_Illness_Disability_Applicant__c,
                Elite_Athlete_Applicant__c,
                Education_Disruption_Applicant__c,
                First_In_Family_Applicant__c,
                Financial_Hardship_Applicant__c,
                Agency_Name__c,
                Agency_Country__c,
                Agency_Email__c
                FROM Contact
                WHERE Id = :applicationsToUpdate[0].hed__Applicant__c
                WITH SYSTEM_MODE
                LIMIT 1
            ];
            System.assert(applicationsToUpdate[0].Is_Agent_Assisted__c == updatedContact.Is_Agent_Assisted__c, 'Is_Agent_Assisted__c not updated correctly.');
            System.assert(applicationsToUpdate[0].Is_International_Applicant__c == updatedContact.Is_International_Applicant__c, 'Is_International_Applicant__c not updated correctly.');
            System.assert(applicationsToUpdate[0].Is_Personal_Illness_Disability_Applicant__c != updatedContact.Personal_Illness_Disability_Applicant__c, 'Personal_Illness_Disability_Applicant__c not updated correctly.');
            System.assert(applicationsToUpdate[0].Is_Elite_Athlete_Applicant__c != updatedContact.Elite_Athlete_Applicant__c, 'Elite_Athlete_Applicant__c not updated correctly.');
            System.assert(applicationsToUpdate[0].Is_Education_Disruption_Applicant__c != updatedContact.Education_Disruption_Applicant__c, 'Education_Disruption_Applicant__c not updated correctly.');
            System.assert(applicationsToUpdate[0].Is_First_In_Family_Applicant__c != updatedContact.First_In_Family_Applicant__c, 'First_In_Family_Applicant__c not updated correctly.');
            System.assert(applicationsToUpdate[0].Is_Financial_Hardship_Applicant__c != updatedContact.Financial_Hardship_Applicant__c, 'Financial_Hardship_Applicant__c not updated correctly.');
            System.assert(applicationsToUpdate[0].Agency_Name__c == updatedContact.Agency_Name__c, 'Agency_Name__c not updated correctly.');
            System.assert(applicationsToUpdate[0].Agency_Country__c == updatedContact.Agency_Country__c, 'Agency_Country__c not updated correctly.');
            System.assert(applicationsToUpdate[0].Agency_Email__c == updatedContact.Agency_Email__c, 'Agency_Email__c not updated correctly.');
        }
    }

    @isTest
    private static void testStudyLinkMatching() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Contact> contacts = new List<Contact>{
                createTestContactForApplicationMatching()
            };
            ContactsDAO.newInstance().insertRecords(contacts, true, AccessLevel.SYSTEM_MODE);
            Id contactId = contacts[0].Id;
            List<hed__Application__c> applications = new List<hed__Application__c>{
                createTestApplicationForContactMatching(ApplicationsDAO.STUDYLINK_RECTYPE_ID)
            };
            applications[0].FirstName__c = contacts[0].FirstName;
            applications[0].LastName__c = contacts[0].LastName;
            applications[0].Email__c = contacts[0].Email;
            applications[0].Application_Status__c = 'Accepted';
            applications[0].Birthdate__c = null;
            
            ApplicationsDAO.newInstance().insertRecords(applications, true, AccessLevel.SYSTEM_MODE);
            Test.stopTest();

            Contact updatedContact = [
                SELECT Id, Birthdate, Mobile_No_Locale__c,
                ATSI_Code__c, hed__Citizenship_Status__c,
                Citizenship_Country__c, Country_of_Residency__c,
                Applicant_Onshore__c
                FROM Contact WHERE Id = :contactId 
                WITH SYSTEM_MODE LIMIT 1];
            System.assertEquals(applications[0].BirthDate__c, updatedContact.Birthdate, 'Birthdate update failed.');
            System.assertEquals(applications[0].Mobile__c, updatedContact.Mobile_No_Locale__c, 'Mobile_No_Locale__c update failed.');
            System.assertEquals(applications[0].Indigenous_Status__c, updatedContact.ATSI_Code__c, 'ATSI_Code__c update failed.');
            System.assertEquals(applications[0].Citizenship_Status__c, updatedContact.hed__Citizenship_Status__c, 'hed__Citizenship_Status__c update failed.');
            System.assertEquals(applications[0].Citizenship_Country__c, updatedContact.Citizenship_Country__c, 'Citizenship_Country__c update failed.');
            System.assertEquals(applications[0].Country_of_Residency__c, updatedContact.Country_of_Residency__c, 'Country_of_Residency__c update failed.');
            System.assertEquals(false, updatedContact.Applicant_Onshore__c, 'Applicant_Onshore__c update failed.');
        }
    }
    
    @isTest
    private static void testStudyLinkMatchingFailOnUpdate() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Contact> contacts = new List<Contact>{
                createTestContactForApplicationMatching()
            };
            ContactsDAO.newInstance().insertRecords(contacts, true, AccessLevel.SYSTEM_MODE);
            Id contactId = contacts[0].Id;
            List<hed__Application__c> applications = new List<hed__Application__c>{
                createTestApplicationForContactMatching(ApplicationsDAO.STUDYLINK_RECTYPE_ID)
            };
            applications[0].FirstName__c = contacts[0].FirstName;
            applications[0].LastName__c = contacts[0].LastName;
            applications[0].Email__c = contacts[0].Email;
            applications[0].Application_Status__c = 'Accepted';
            applications[0].Birthdate__c = null;
            ApplicationsDAO.newInstance().insertRecords(applications, true, AccessLevel.SYSTEM_MODE);
            Test.stopTest();
            
            applications[0].Applicant_Onshore__c = true;
            applications[0].Country_of_Residency__c = 'Residency Update';
            ApplicationsDAO.newInstance().updateRecords(applications, true, AccessLevel.SYSTEM_MODE);

            Contact updatedContact = [
                SELECT Id, Birthdate, Mobile_No_Locale__c,
                ATSI_Code__c, hed__Citizenship_Status__c,
                Citizenship_Country__c, Country_of_Residency__c,
                Applicant_Onshore__c
                FROM Contact WHERE Id = :contactId 
                WITH SYSTEM_MODE LIMIT 1];

            System.assertEquals(applications[0].Indigenous_Status__c, updatedContact.ATSI_Code__c, 'ATSI_Code__c update failed.');
            System.assertEquals(applications[0].Citizenship_Status__c, updatedContact.hed__Citizenship_Status__c, 'hed__Citizenship_Status__c update failed.');
            System.assertEquals(applications[0].Citizenship_Country__c, updatedContact.Citizenship_Country__c, 'Citizenship_Country__c update failed.');
            System.assertNotEquals(applications[0].Country_of_Residency__c, updatedContact.Country_of_Residency__c, 'Country_of_Residency__c should not be updated');
            System.assertEquals(false, updatedContact.Applicant_Onshore__c, 'Applicant_Onshore__c update should fail.');
        }
    }

    @isTest
    private static void testStudyLinkMatchingSuccessOnUpdate() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Contact> contacts = new List<Contact>{
                createTestContactForApplicationMatching()
            };
            ContactsDAO.newInstance().insertRecords(contacts, true, AccessLevel.SYSTEM_MODE);
            Id contactId = contacts[0].Id;
            List<hed__Application__c> applications = new List<hed__Application__c>{
                createTestApplicationForContactMatching(ApplicationsDAO.STUDYLINK_RECTYPE_ID)
            };
            applications[0].FirstName__c = contacts[0].FirstName;
            applications[0].LastName__c = contacts[0].LastName;
            applications[0].Email__c = contacts[0].Email;
            applications[0].Application_Status__c = 'Test';
            applications[0].Birthdate__c = null;
            
            ApplicationsDAO.newInstance().insertRecords(applications, true, AccessLevel.SYSTEM_MODE);
            Test.stopTest();
            applications[0].Applicant_Onshore__c = true;
            applications[0].Country_of_Residency__c = 'Residency Update';
            ApplicationsDAO.newInstance().updateRecords(applications, true, AccessLevel.SYSTEM_MODE);
            Contact updatedContact = [
                SELECT Id, Birthdate, Mobile_No_Locale__c,
                ATSI_Code__c, hed__Citizenship_Status__c,
                Citizenship_Country__c, Country_of_Residency__c,
                Applicant_Onshore__c
                FROM Contact WHERE Id = :contactId 
                WITH SYSTEM_MODE LIMIT 1];

            System.assertEquals(applications[0].Indigenous_Status__c, updatedContact.ATSI_Code__c, 'ATSI_Code__c update failed.');
            System.assertEquals(applications[0].Citizenship_Status__c, updatedContact.hed__Citizenship_Status__c, 'hed__Citizenship_Status__c update failed.');
            System.assertEquals(applications[0].Citizenship_Country__c, updatedContact.Citizenship_Country__c, 'Citizenship_Country__c update failed.');
            System.assertEquals(applications[0].Country_of_Residency__c, updatedContact.Country_of_Residency__c, 'Country_of_Residency__c update failed');
        }
    }

    @isTest
    private static void testSAMSMatchingFailOnUpdate() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Contact> contacts = new List<Contact>{
                createTestContactForApplicationMatching()
            };
            ContactsDAO.newInstance().insertRecords(contacts, true, AccessLevel.SYSTEM_MODE);
            Id contactId = contacts[0].Id;
            List<hed__Application__c> applications = new List<hed__Application__c>{
                createTestApplicationForContactMatching(ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID)
            };
            applications[0].FirstName__c = contacts[0].FirstName;
            applications[0].LastName__c = contacts[0].LastName;
            applications[0].Email__c = contacts[0].Email;
            applications[0].Offer_Status__c = 'Offered';
            applications[0].Birthdate__c = null;
            applications[0].Is_International_Applicant__c = true;
            ApplicationsDAO.newInstance().insertRecords(applications, true, AccessLevel.SYSTEM_MODE);
            Test.stopTest();
            
            applications[0].Is_International_Applicant__c = false;
            applications[0].Indigenous_Status__c = 'Aboriginal';
            ApplicationsDAO.newInstance().updateRecords(applications, true, AccessLevel.SYSTEM_MODE);

            Contact updatedContact = [
                SELECT Id, Birthdate, Mobile_No_Locale__c,
                ATSI_Code__c, hed__Citizenship_Status__c,
                Citizenship_Country__c, Country_of_Residency__c,
                Applicant_Onshore__c, Is_International_Applicant__c
                FROM Contact WHERE Id = :contactId 
                WITH SYSTEM_MODE LIMIT 1];

            System.assertEquals('I prefer not to say', updatedContact.ATSI_Code__c, 'ATSI_Code__c update should fail.');
            System.assertEquals(true, updatedContact.Is_International_Applicant__c, 'Is_International_Applicant__c update should fail.');
        }
    }

    @isTest
    private static void testSAMSMatchingSuccessOnUpdate() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Contact> contacts = new List<Contact>{
                createTestContactForApplicationMatching()
            };
            ContactsDAO.newInstance().insertRecords(contacts, true, AccessLevel.SYSTEM_MODE);
            Id contactId = contacts[0].Id;
            List<hed__Application__c> applications = new List<hed__Application__c>{
                createTestApplicationForContactMatching(ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID)
            };
            applications[0].FirstName__c = contacts[0].FirstName;
            applications[0].LastName__c = contacts[0].LastName;
            applications[0].Email__c = contacts[0].Email;
            applications[0].Offer_Status__c = null;
            applications[0].Birthdate__c = null;
            applications[0].Is_International_Applicant__c = true;
            
            ApplicationsDAO.newInstance().insertRecords(applications, true, AccessLevel.SYSTEM_MODE);
            Test.stopTest();
            applications[0].Is_International_Applicant__c = false;
            applications[0].Indigenous_Status__c = 'Aboriginal';
            ApplicationsDAO.newInstance().updateRecords(applications, true, AccessLevel.SYSTEM_MODE);
            Contact updatedContact = [
                SELECT Id, Birthdate, Mobile_No_Locale__c,
                ATSI_Code__c, hed__Citizenship_Status__c,
                Citizenship_Country__c, Country_of_Residency__c,
                Applicant_Onshore__c, Is_International_Applicant__c
                FROM Contact WHERE Id = :contactId 
                WITH SYSTEM_MODE LIMIT 1];

            System.assertEquals('Aboriginal', updatedContact.ATSI_Code__c, 'ATSI_Code__c update failed.');
            System.assertEquals(false, updatedContact.Is_International_Applicant__c, 'Is_International_Applicant__c update failed.');
        }
    }

    @isTest
    private static void testSAMSLegacyMatching() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Contact> contacts = new List<Contact>{
                createTestContactForApplicationMatching()
            };
            ContactsDAO.newInstance().insertRecords(contacts, false, AccessLevel.SYSTEM_MODE);
            Id contactId = contacts[0].Id;
            List<hed__Application__c> applications = new List<hed__Application__c>{
                createTestApplicationForContactMatching(ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID)
            };
            
            applications[0].FirstName__c = contacts[0].FirstName;
            applications[0].LastName__c = contacts[0].LastName;
            applications[0].Email__c = contacts[0].Email;
            applications[0].hed__Applicant__c = contacts[0].Id;
            ApplicationsDAO.newInstance().insertRecords(applications, true, AccessLevel.SYSTEM_MODE);
            Test.stopTest();
            Contact updatedContact = [
                SELECT Id, Birthdate, Mobile_No_Locale__c,
                ATSI_Code__c, hed__Citizenship_Status__c,
                Citizenship_Country__c
                FROM Contact WHERE Id = :contactId 
                WITH SYSTEM_MODE LIMIT 1];
            System.assertEquals(applications[0].BirthDate__c, updatedContact.Birthdate, 'Birthdate update failed.');
            System.assertEquals(applications[0].Indigenous_Status__c, updatedContact.ATSI_Code__c, 'ATSI_Code__c update failed.');
            System.assertEquals(applications[0].Citizenship_Status__c, updatedContact.hed__Citizenship_Status__c, 'hed__Citizenship_Status__c update failed.');
            System.assertEquals(applications[0].Citizenship_Country__c, updatedContact.Citizenship_Country__c, 'Citizenship_Country__c update failed.');
        }
    }
    
    @isTest
    private static void testSAMSCIAnywhereMatching() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Contact> contacts = new List<Contact>{
                createTestContactForApplicationMatching()
            };
            ContactsDAO.newInstance().insertRecords(contacts, false, AccessLevel.SYSTEM_MODE);
            Id contactId = contacts[0].Id;
            List<hed__Application__c> applications = new List<hed__Application__c>{
                createTestApplicationForContactMatching(ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID)
            };
            
            applications[0].FirstName__c = contacts[0].FirstName;
            applications[0].LastName__c = contacts[0].LastName;
            applications[0].Email__c = contacts[0].Email;
            applications[0].hed__Applicant__c = contacts[0].Id;
            ApplicationsDAO.newInstance().insertRecords(applications, true, AccessLevel.SYSTEM_MODE);
            Test.stopTest();
            Contact updatedContact = [
                SELECT Id, Birthdate, Mobile_No_Locale__c,
                ATSI_Code__c, hed__Citizenship_Status__c,
                Citizenship_Country__c
                FROM Contact WHERE Id = :contactId
                WITH SYSTEM_MODE LIMIT 1];
            System.assertEquals(applications[0].BirthDate__c, updatedContact.Birthdate, 'Birthdate update failed.');
            System.assertEquals(applications[0].Mobile__c, updatedContact.Mobile_No_Locale__c, 'Mobile_No_Locale__c update failed.');
            System.assertEquals(applications[0].Indigenous_Status__c, updatedContact.ATSI_Code__c, 'ATSI_Code__c update failed.');
            System.assertEquals(applications[0].Citizenship_Status__c, updatedContact.hed__Citizenship_Status__c, 'hed__Citizenship_Status__c update failed.');
            System.assertEquals(applications[0].Citizenship_Country__c, updatedContact.Citizenship_Country__c, 'Citizenship_Country__c update failed.');
        }
    }

    @isTest
    private static void testQTACFailOnUpdate() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Contact> contacts = new List<Contact>{
                createTestContactForApplicationMatching()
            };
            ContactsDAO.newInstance().insertRecords(contacts, true, AccessLevel.SYSTEM_MODE);
            Id contactId = contacts[0].Id;
            List<hed__Application__c> applications = new List<hed__Application__c>{
                createTestApplicationForContactMatching(ApplicationsDAO.QTAC_RECTYPE_ID)
            };
            applications[0].FirstName__c = contacts[0].FirstName;
            applications[0].LastName__c = contacts[0].LastName;
            applications[0].Email__c = contacts[0].Email;
            applications[0].Offer_Status__c = 'Offered';
            applications[0].Birthdate__c = null;
            applications[0].Postal_Address_Line1__c = 'Postal';
            ApplicationsDAO.newInstance().insertRecords(applications, true, AccessLevel.SYSTEM_MODE);
            Test.stopTest();
            
            applications[0].Indigenous_Status__c = 'Aboriginal';
            applications[0].Postal_Address_Line1__c = 'Postal 1';
            ApplicationsDAO.newInstance().updateRecords(applications, true, AccessLevel.SYSTEM_MODE);

            Contact updatedContact = [
                SELECT Id, Birthdate, Mobile_No_Locale__c,
                ATSI_Code__c, hed__Citizenship_Status__c,
                Citizenship_Country__c, Country_of_Residency__c,
                MailingStreet
                FROM Contact WHERE Id = :contactId 
                WITH SYSTEM_MODE LIMIT 1];

            System.assertEquals('I prefer not to say', updatedContact.ATSI_Code__c, 'ATSI_Code__c update should fail.');
            System.assertEquals('Postal', updatedContact.MailingStreet, 'MailingStreet update should fail.');
        }
    }

    @isTest
    private static void testQTACSuccessOnUpdate() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Contact> contacts = new List<Contact>{
                createTestContactForApplicationMatching()
            };
            ContactsDAO.newInstance().insertRecords(contacts, true, AccessLevel.SYSTEM_MODE);
            Id contactId = contacts[0].Id;
            List<hed__Application__c> applications = new List<hed__Application__c>{
                createTestApplicationForContactMatching(ApplicationsDAO.QTAC_RECTYPE_ID)
            };
            applications[0].FirstName__c = null;
            applications[0].LastName__c = null;
            applications[0].Email__c = null;
            applications[0].Offer_Status__c = null;
            applications[0].Birthdate__c = null;
            applications[0].Postal_Address_Line1__c = 'Postal';
            ApplicationsDAO.newInstance().insertRecords(applications, true, AccessLevel.SYSTEM_MODE);
            applications[0].FirstName__c = contacts[0].FirstName;
            applications[0].LastName__c = contacts[0].LastName;
            applications[0].Email__c = contacts[0].Email;
            applications[0].Indigenous_Status__c = 'Aboriginal';
            applications[0].Postal_Address_Line1__c = 'Postal 1';
            ApplicationsDAO.newInstance().updateRecords(applications, true, AccessLevel.SYSTEM_MODE);
            Test.stopTest();
            Contact updatedContact = [
                SELECT Id, Birthdate, Mobile_No_Locale__c,
                ATSI_Code__c, hed__Citizenship_Status__c,
                Citizenship_Country__c, Country_of_Residency__c,
                Applicant_Onshore__c, Is_International_Applicant__c,
                MailingStreet
                FROM Contact WHERE Id = :contactId 
                WITH SYSTEM_MODE LIMIT 1];

            System.assertEquals('Aboriginal', updatedContact.ATSI_Code__c, 'ATSI_Code__c update failed.');
            System.assertEquals('Postal 1', updatedContact.MailingStreet, 'MailingStreet update failed.');
        }
    }
    
    @isTest
    private static void testQTACMatching() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Contact> contacts = new List<Contact>{
                new Contact(
                    FirstName = 'Gordon',
                    LastName = 'Freeman',
                    Email = 'g.freeman@test.mail'
                )
            };
            ContactsDAO.newInstance().insertRecords(contacts, false, AccessLevel.SYSTEM_MODE);
            List<hed__Application__c> applications = new List<hed__Application__c>{
                createTestQTACApplicationForContactMatching(contacts[0])
            };
            ApplicationsDAO.newInstance().insertRecords(applications, true, AccessLevel.SYSTEM_MODE);
            applications[0].RecordTypeId = ApplicationsDAO.QTAC_RECTYPE_ID;
            Map<Id, SObject> newItems = new Map<Id, SObject>((List<Sobject>) applications);
            ApplicationTriggerHelper.createAddressesForMatchingQTACApplicant(newItems, null);
            ApplicationTriggerHelper.updateRelatedRecords(newItems, null);
            Contact createdContact = ContactsDAO.newInstance().getPersonContactsBySetIds(new Set<Id>{contacts[0].Id}, AccessLevel.SYSTEM_MODE)[0];
            Test.stopTest();
            System.assertEquals(applications[0].Indigenous_Status__c, createdContact.ATSI_Code__c, 'ATSI_Code__c update failed.');
            System.assertEquals(applications[0].Birth_Country__c, createdContact.Birth_Country__c, 'Birth_Country__c update failed.');
            System.assertEquals(applications[0].BirthDate__c, createdContact.BirthDate, 'BirthDate update failed.');
            System.assertEquals(applications[0].Citizenship_Status__c, createdContact.hed__Citizenship_Status__c, 'Citizenship_Status__c update failed.');
            System.assertEquals(applications[0].Citizenship_Type__c, createdContact.Citizenship_Type__c, 'Citizenship_Type__c update failed.');
            System.assertEquals(applications[0].Email__c, createdContact.Email, 'Email update failed.');
            System.assertEquals(applications[0].FirstName__c, createdContact.FirstName, 'FirstName update failed.');
            System.assertEquals(applications[0].Home_Language__c, createdContact.Home_Language__c, 'Home_Language__c update failed.');
            System.assertEquals(applications[0].LastName__c, createdContact.LastName, 'LastName update failed.');
            System.assert(createdContact.MailingAddress != null, 'MailingAddress is blank. Update failed.');
            System.assertEquals(applications[0].MiddleName__c, createdContact.MiddleName, 'MiddleName update failed.');
            System.assert(createdContact.OtherAddress != null, 'OtherAddress is blank. Update failed.');
            System.assertEquals(applications[0].Salutation__c, createdContact.Salutation, 'Salutation update failed.');
            System.assertEquals(applications[0].Applicant_Onshore__c, createdContact.Applicant_Onshore__c, 'Applicant_Onshore__c update failed.');
            System.assert(applications[0].Is_Personal_Illness_Disability_Applicant__c == createdContact.Personal_Illness_Disability_Applicant__c, 'Personal_Illness_Disability_Applicant__c not updated correctly.');
            System.assert(applications[0].Is_Elite_Athlete_Applicant__c == createdContact.Elite_Athlete_Applicant__c, 'Elite_Athlete_Applicant__c not updated correctly.');
            System.assert(applications[0].Is_Education_Disruption_Applicant__c == createdContact.Education_Disruption_Applicant__c, 'Education_Disruption_Applicant__c not updated correctly.');
            System.assert(applications[0].Is_First_In_Family_Applicant__c == createdContact.First_In_Family_Applicant__c, 'First_In_Family_Applicant__c not updated correctly.');
            System.assert(applications[0].Is_Financial_Hardship_Applicant__c == createdContact.Financial_Hardship_Applicant__c, 'Financial_Hardship_Applicant__c not updated correctly.');
        }
    }

    private static Contact createTestContactForApplicationMatching() {
        return new Contact(
            RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID,
            FirstName = 'Matcher',
            LastName = 'Contact',
            Email = 'matchercontact@mail.test'
        );
    }
    
    private static hed__Application__c createTestApplicationForContactMatching(Id applicationRecordType) {
        return new hed__Application__c(
            RecordTypeId = applicationRecordType,
            BirthDate__c = System.today().addYears(-18),
            Mobile__c = '0987654321',
            Indigenous_Status__c = 'I prefer not to say',
            Citizenship_Status__c = 'International',
            Citizenship_Country__c = 'Antarctica',
            Offer_Status__c = 'Admitted',
            QTAC_Application_ID__c = applicationRecordType,
            Applicant_Onshore__c = true,
            Country_of_Residency__c = 'Test'
        );
    }

    private static hed__Application__c createTestQTACApplicationForContactMatching(Contact contactToMatch) {
        // Testing method directly without triggering the matching.
        // The tests emulates that that part is already done.
        // This creates an application without the QTAC record type.
        return new hed__Application__c(
            Indigenous_Status__c = 'I prefer not to say',
            Birth_Country__c = 'Philippines (the)',
            Citizenship_Status__c = 'International',
            Citizenship_Type__c = 'Permanent',
            Home_Language__c = 'Noot noot',
            Postal_Address_Line1__c = 'Postal',
            Postal_Address_Line2__c = 'Address',
            Postal_Address_Line3__c = 'Lines',
            Postal_Town__c = 'Town of Postal',
            Postal_State__c = 'State of Postal',
            Postal_Country__c = 'Republic of Postal',
            Postal_Postcode__c = '0000',
            Residential_Address_Line1__c = 'Residential',
            Residential_Address_Line2__c = 'Address',
            Residential_Address_Line3__c = 'Lines',
            Residential_Town__c = 'Town of Residence',
            Residential_State__c = 'State of Residence',
            Residential_Country__c = 'Republic of Residence',
            Residential_Postcode__c = '0001',
            Salutation__c = 'Doctor',
            FirstName__c = contactToMatch.FirstName,
            MiddleName__c = 'One',
            LastName__c = contactToMatch.LastName,
            Email__c = contactToMatch.Email,
            BirthDate__c = System.today().addYears(-25),
            Mobile__c = '0987654321',
            hed__Applicant__c = contactToMatch.Id,
            Applicant_Onshore__c = true,
            Is_Personal_Illness_Disability_Applicant__c = true,
            Is_Elite_Athlete_Applicant__c = true,
            Is_Education_Disruption_Applicant__c = true,
            Is_First_In_Family_Applicant__c = true,
            Is_Financial_Hardship_Applicant__c = true
        );
    }

    private static List<hed__Application__c> createTestApplicationRecords(List<Contact> conList, String applicationStatus,String recordType) {
        List<hed__Application__c> newApplications = new List<hed__Application__c>();
        for (Contact con: conList) {
            newApplications.add(
                new hed__Application__c(
                    FirstName__c = 'Test First' + FIRSTNAME,
                    LastName__c = 'Test Last' + LASTNAME,
                    BirthDate__c = Date.valueOf(BIRTHDAY),
                    Email__c = 'workTest' + EMAIL,
                    Application_Status__c = applicationStatus,
                    hed__Applicant__c = con.Id,
                    RecordTypeId = recordType
    
                )
            );
        }
        return newApplications;
    }
    
    private static List<Contact> createTestContactRecords(
        Integer startAtCount,
        Integer endBeforeCount
    ) {
        List<Contact> newContacts = new List<Contact>();
        for (Integer i = startAtCount; i < endBeforeCount; i++) {
            newContacts.add(
                new Contact(
                    FirstName = FIRSTNAME + i,
                    LastName = i + LASTNAME,
                    BirthDate = Date.valueOf(BIRTHDAY),
                    Email = i + EMAIL,
                    QUT_Learner_Email__c = 'learner' + i + EMAIL,
                    QUT_Staff_Email__c = 'staff' + i + EMAIL,
                    Work_Email__c = 'work' + i + EMAIL,
                    hed__Preferred_Email__c = 'Alternate Email',
                    hed__AlternateEmail__c = i + EMAIL,
                    RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID 
                )
            );
        }
        return newContacts;
    }
}