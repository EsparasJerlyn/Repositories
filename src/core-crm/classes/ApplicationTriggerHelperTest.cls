/**
 * @description Test Class for ApplicationTriggerHelper
 *
 * @see ApplicationTriggerHelper
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | mark.j.mahilum            | July 18,2023          | DEPP-5799    | Created file                                |
      | alexander.cadalin         | Aug 16, 2023          | DEPP-6124    | Refactor to consider multiple field updates |
      | julie.jane.alegre         | September 20, 2023    | DEPP-6667    | Added testUpdateContactWhenQTACAppIsInactive|
*/
@isTest
private class ApplicationTriggerHelperTest {
    private static final String FIRSTNAME = 'TestfirstName';
    private static final String LASTNAME = 'Testlastname';
    private static final String EMAIL = 'testmail@mail.test';
    private static final String BIRTHDAY = '2000-06-28';
    private static Integer recordsCount = 20;
    
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator', 'QUT_ESB' });
        System.runAs(TestDataFactory.getProgramAdminUser()) {
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
        System.runAs(TestDataFactory.getProgramAdminUser()) {
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
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            
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
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
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
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
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
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
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
            Test.stopTest();
            System.assert(applicationsToUpdate[0].Is_Agent_Assisted__c == updatedContact.Is_Agent_Assisted__c, 'Is_Agent_Assisted__c not updated correctly.');
            System.assert(applicationsToUpdate[0].Is_International_Applicant__c == updatedContact.Is_International_Applicant__c, 'Is_International_Applicant__c not updated correctly.');
            System.assert(applicationsToUpdate[0].Is_Personal_Illness_Disability_Applicant__c == updatedContact.Personal_Illness_Disability_Applicant__c, 'Personal_Illness_Disability_Applicant__c not updated correctly.');
            System.assert(applicationsToUpdate[0].Is_Elite_Athlete_Applicant__c == updatedContact.Elite_Athlete_Applicant__c, 'Elite_Athlete_Applicant__c not updated correctly.');
            System.assert(applicationsToUpdate[0].Is_Education_Disruption_Applicant__c == updatedContact.Education_Disruption_Applicant__c, 'Education_Disruption_Applicant__c not updated correctly.');
            System.assert(applicationsToUpdate[0].Is_First_In_Family_Applicant__c == updatedContact.First_In_Family_Applicant__c, 'First_In_Family_Applicant__c not updated correctly.');
            System.assert(applicationsToUpdate[0].Is_Financial_Hardship_Applicant__c == updatedContact.Financial_Hardship_Applicant__c, 'Financial_Hardship_Applicant__c not updated correctly.');
            System.assert(applicationsToUpdate[0].Agency_Name__c == updatedContact.Agency_Name__c, 'Agency_Name__c not updated correctly.');
            System.assert(applicationsToUpdate[0].Agency_Country__c == updatedContact.Agency_Country__c, 'Agency_Country__c not updated correctly.');
            System.assert(applicationsToUpdate[0].Agency_Email__c == updatedContact.Agency_Email__c, 'Agency_Email__c not updated correctly.');
        }
    }

    @isTest
    private static void testUpdateContactWhenQTACAppIsInactive(){
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            Id contactId = ContactsDAO.newInstance().getPersonContactsWithLimit(1).iterator().next()?.Id;                
            List<hed__Application__c> applicationToUpdate = ApplicationsDAO.newInstance().getApplicationsByContactIds(new Set<Id>{contactId},'USER_MODE');   
            for(hed__Application__c app : applicationToUpdate){
                app.RecordTypeId = ApplicationsDAO.QTAC_RECTYPE_ID;
                app.Is_Active__c = false;
            }
            Test.startTest();
            ApplicationsDAO.newInstance().updateRecords(applicationToUpdate, false, AccessLevel.SYSTEM_MODE);
            List<Contact> contactUpdated = ContactsDAO.newInstance().getPersonContactsBySetIds(new Set<Id>{contactId}, AccessLevel.USER_MODE);
            Test.stopTest();
            System.assert(contactUpdated[0].HasOptedOutOfEmail == true, 'HasOptedOutOfEmail should be updated to true.');
            System.assert(contactUpdated[0].HasOptedOutOfEmail == true, 'Learner_Email_Opt_Out__c should be updated to true.');
            System.assert(contactUpdated[0].Staff_Email_Opt_Out__c == true, 'Staff_Email_Opt_Out__c should be updated to true.');
            System.assert(contactUpdated[0].Work_Email_Opt_Out__c == true, 'Work_Email_Opt_Out__c should be updated to true.');
            System.assert(contactUpdated[0].Work_SMS_Opt_Out__c == true, 'Work_SMS_Opt_Out__c should be updated to true.');
            System.assert(contactUpdated[0].hed__SMS_Opt_Out__c == true, 'hed__SMS_Opt_Out__c should be updated to true.');
            System.assert(contactUpdated[0].DoNotCall == true, 'DoNotCall should be updated to true.');
            System.assert(contactUpdated[0].Sync_to_MC__c == false, 'Sync_to_MC__c should be updated to false.');
            System.assert(contactUpdated[0].Do_Not_Sync_To_MC_Override__c == false, 'Do_Not_Sync_To_MC_Override__c should be updated to false.');
            System.assert(contactUpdated[0].Dont_Market_Reason__c == 'QTAC Application QUT preferences withdrawn', 'Dont_Market_Reason__c does not have the correct value.');
        }
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