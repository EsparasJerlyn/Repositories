/**
 * @description Test class for PackageComponentServiceTest
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                    |
      |--------------------------------|-----------------------|------------------------|-----------------------------------|
      | arsenio.jr.dayrit       	   | August 15, 2023       | DEPP-6370              | Created file                      | 
 */
@isTest
public with sharing class PackageComponentServiceTest { //NOPMD
    private static final String FIRSTNAME = 'TestfirstName';
    private static final String LASTNAME = 'Testlastname';
    private static final String EMAIL = 'testmail@mail.test';
    private static final String BIRTHDAY = '2000-06-28';
    private static Integer recordsCount = 20;

    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactoryUser.generateUserQUTESB();
        Test.stopTest();
    }

    @isTest
    private static void getAllApplicationPreferenceIdInPackageComponent(){
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            
            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'Domestic';
            newContacts[0].Calculated_Cadence__c = '';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);

            Test.startTest();
            List<hed__Application__c> newStudyLinkApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.STUDYLINK_RECTYPE_ID, 'New');
            ApplicationsDAO.newInstance().insertRecords(newStudyLinkApplications, false, AccessLevel.SYSTEM_MODE);
            
            List<Application_Preference__c> appPrefList = new List<Application_Preference__c>();
            Application_Preference__c appPref = new Application_Preference__c();
            appPref.Is_Current_Preference__c = true;
            appPref.RecordTypeId = ApplicationPreferencesDAO.STUDYLINK_RECTYPE_ID;
            appPref.Application__c = newStudyLinkApplications[0].Id;
            appPrefList.add(appPref);
            ApplicationPreferencesDAO.newInstance().insertRecords(appPrefList, false, AccessLevel.SYSTEM_MODE);

            List<Package_Component__c> packageComList = new List<Package_Component__c>();
            Package_Component__c packageCom = new Package_Component__c();
            packageCom.Package_Component_No__c = 1;
            packageCom.Application_Preference__c = appPrefList[0].Id;
            packageCom.Start_Date__c = System.today();
            packageComList.add(packageCom);
            PackageComponentDAO.newInstance().insertRecords(packageComList, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();

        }
            
        List<hed__Application__c> updatedApplication = [SELECT Id, Calculated_Intake_Date__c FROM hed__Application__c];
        System.assertEquals(System.today(), updatedApplication[0].Calculated_Intake_Date__c, 'Calculated Intake date should be populated');
    }

    private static List<hed__Application__c> createTestApplicationRecords(List<Contact> conList, String recordType, String applicationStatus) {
        List<hed__Application__c> newApplications = new List<hed__Application__c>();
        for (Contact con: conList) {
            newApplications.add(
                new hed__Application__c(
                    FirstName__c = FIRSTNAME,
                    LastName__c = LASTNAME,
                    BirthDate__c = Date.valueOf(BIRTHDAY),
                    Email__c = 'work' + EMAIL,
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