/**
 * @description Test Class for ApplicationPreferenceTriggerHelper
 *
 * @see ApplicationPreferenceTriggerHelper
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                   |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------------|
      | julie.jane.alegre              | August 21, 2023       | DEPP-6252              | Created file                                     |
      | sebastianne.k.trias            | May 9, 2024           | DEPP-8382              | Changed logic in setting value of application    |
      |                                |                       |                        | calculated intake date field                     |
 */
@isTest
private class ApplicationPreferenceTriggerHelperTest {
    
    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactoryUser.generateUserSystemAdministrator();
        Test.stopTest();

        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
			
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1,2);
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);

            Integer numOfPrefRec = 2;
            List<hed__Application__c> allApplicationList = new List<hed__Application__c>();
            List<Application_Preference__c> allApplicationPrefList = new List<Application_Preference__c>();

            //QTAC
            List<hed__Application__c> qtacApplicationList = TestDataFactory.createApplicationRecords(contactList[0].Id, ApplicationsDAO.QTAC_RECTYPE_ID, 1);
            //Study Link
            List<hed__Application__c> studyLinkApplicationList = TestDataFactory.createApplicationRecords(contactList[0].Id, ApplicationsDAO.STUDYLINK_RECTYPE_ID, 1);
            allApplicationList.addAll(qtacApplicationList);
            allApplicationList.addAll(studyLinkApplicationList);

            ApplicationsDAO.newInstance().insertRecords(allApplicationList, false, AccessLevel.USER_MODE);

            List<Application_Preference__c> qtacAppPrefList = TestDataFactory.createApplicationPreferenceRecords(allApplicationList[0].Id, ApplicationPreferencesDAO.QTAC_RECTYPE_ID, numOfPrefRec);
            List<Application_Preference__c> studyLinkappPrefList = TestDataFactory.createApplicationPreferenceRecords(allApplicationList[1].Id, ApplicationPreferencesDAO.STUDYLINK_RECTYPE_ID, numOfPrefRec);
            allApplicationPrefList.addAll(qtacAppPrefList);
            allApplicationPrefList.addAll(studyLinkappPrefList);
            ApplicationPreferencesDAO.newInstance().insertRecords(allApplicationPrefList, false, AccessLevel.USER_MODE);

            List<Package_Component__c> packageComponentList = TestDataFactory.createPackageComponentRecords(allApplicationPrefList[1].Id, System.Today(), 1);
            PackageComponentDAO.newInstance().insertRecords(packageComponentList, false, AccessLevel.USER_MODE);
			
        }
    }

    @isTest
    private static void setCurrentPreferenceQTACInsertTest() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            List<hed__Application__c> applicationList = [SELECT Id, RecordTypeId FROM hed__Application__c WHERE RecordTypeId =: ApplicationsDAO.QTAC_RECTYPE_ID WITH USER_MODE LIMIT 1];
            Test.startTest();
            List<Application_Preference__c> qtacAppPrefList = TestDataFactory.createApplicationPreferenceRecords(applicationList[0].Id, ApplicationPreferencesDAO.QTAC_RECTYPE_ID, 1);
            for(Application_Preference__c ap : qtacAppPrefList){
                ap.Program_Name__c = 'QTAC App Pref';
                ap.Preference_Number__c = 1;
            }
            ApplicationPreferencesDAO.newInstance().insertRecords(qtacAppPrefList, false, AccessLevel.USER_MODE);
            Test.stopTest();

            List<Application_Preference__c> updatedAppPrefList = [SELECT Id, Is_Current_Preference__c FROM Application_Preference__c WHERE Program_Name__c = 'QTAC App Pref' WITH USER_MODE LIMIT 1];
            System.assert(updatedAppPrefList[0].Is_Current_Preference__c, 'Is current preference field must be true.');
        }
    }

    @isTest
    private static void setCurrentPreferenceQTACUpdateTest() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            Test.startTest();
            List<Application_Preference__c> appPrefListToUpdate = new List<Application_Preference__c>();
            List<Application_Preference__c> appPrefList = [SELECT Id, Preference_Number__c, Program_Name__c, Is_Current_Preference__c FROM Application_Preference__c WHERE Program_Name__c = 'App Pref 1' WITH USER_MODE LIMIT 1];    
            for(Application_Preference__c ap : appPrefList){
                ap.Preference_Number__c = 5;
                appPrefListToUpdate.add(ap);
            }
            ApplicationPreferencesDAO.newInstance().updateRecords(appPrefListToUpdate, false, AccessLevel.USER_MODE);
            
            List<Application_Preference__c> appPrefToAssertList = [SELECT Id, Program_Name__c, Preference_Number__c, Is_Current_Preference__c FROM Application_Preference__c WHERE Program_Name__c = 'App Pref 2' WITH USER_MODE LIMIT 1];
            Test.stopTest();
            System.assert(appPrefToAssertList[0].Is_Current_Preference__c, 'Is current preference field must be true.');
        }
    }

    @isTest
    private static void setCurrentPreferenceStudyLinkInsertTest() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            List<hed__Application__c> applicationList = [SELECT Id, RecordTypeId FROM hed__Application__c WHERE RecordTypeId =: ApplicationsDAO.STUDYLINK_RECTYPE_ID WITH USER_MODE LIMIT 1];
            Test.startTest();
            List<Application_Preference__c> studyLinkAppPrefList = TestDataFactory.createApplicationPreferenceRecords(applicationList[0].Id, ApplicationPreferencesDAO.STUDYLINK_RECTYPE_ID, 1);
            for(Application_Preference__c ap : studyLinkAppPrefList){
                ap.Program_Name__c = 'StudyLinkAppPref';
            }
            ApplicationPreferencesDAO.newInstance().insertRecords(studyLinkAppPrefList, false, AccessLevel.USER_MODE);
            Test.stopTest();

            List<Application_Preference__c> updatedAppPrefList = [SELECT Id, Is_Current_Preference__c FROM Application_Preference__c WHERE Program_Name__c = 'StudyLinkAppPref' WITH USER_MODE LIMIT 1];
            System.assert(updatedAppPrefList[0].Is_Current_Preference__c, 'Is current preference field must be true.');
        }
    }

    @isTest
    private static void setCurrentPreferenceStudyLinkUpdateTest() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            Test.startTest();
            List<Application_Preference__c> appPrefListToUpdate = new List<Application_Preference__c>();
            List<Application_Preference__c> appPrefList = [SELECT Id, Preference_Number__c, Program_Name__c, Is_Current_Preference__c FROM Application_Preference__c WHERE Program_Name__c = 'App Pref 1' WITH USER_MODE LIMIT 1];    
            for(Application_Preference__c ap : appPrefList){
                ap.Program_Name__c = 'App Pref to Check';
                appPrefListToUpdate.add(ap);
            }
            ApplicationPreferencesDAO.newInstance().updateRecords(appPrefListToUpdate, false, AccessLevel.USER_MODE);
            
            List<Application_Preference__c> appPrefToAssertList = [SELECT Id, Program_Name__c, Preference_Number__c, Is_Current_Preference__c FROM Application_Preference__c WHERE Program_Name__c = 'App Pref to Check' WITH USER_MODE LIMIT 1];
            Test.stopTest();
            System.assert(appPrefToAssertList[0].Is_Current_Preference__c, 'Is current preference field must be true.');
        }
    }

    @isTest
    private static void setCurrentPreferenceAppCalculatedIntakeDateTest(){
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            List<hed__Application__c> applicationList = [SELECT Id, RecordTypeId FROM hed__Application__c WHERE RecordTypeId =: ApplicationsDAO.STUDYLINK_RECTYPE_ID WITH USER_MODE LIMIT 1];
            List<Application_Preference__c> studyLinkAppPrefList = TestDataFactory.createApplicationPreferenceRecords(applicationList[0].Id, ApplicationPreferencesDAO.STUDYLINK_RECTYPE_ID, 1);
           
            // List<Package_Component__c> packageComponentList = TestDataFactory.createPackageComponentRecords(allApplicationPrefList[1].Id, System.Today(), 1);

            for(Application_Preference__c ap : studyLinkAppPrefList){
                ap.Program_Name__c = 'StudyLinkAppPref';
            }
            ApplicationPreferencesDAO.newInstance().insertRecords(studyLinkAppPrefList, false, AccessLevel.USER_MODE);
            
            Test.startTest();
            List<Package_Component__c> packageCompList = new List<Package_Component__c>();
            Package_Component__c packageComp = new Package_Component__c();
            packageComp.Application_Preference__c = studyLinkAppPrefList[0].Id;
            packageComp.Start_Date__c = System.Today();
            packageCompList.add(packageComp);
            Package_Component__c packageComp2 = new Package_Component__c();
            packageComp2.Application_Preference__c = studyLinkAppPrefList[0].Id;
            packageComp2.Start_Date__c = System.Today().addDays(-2);
            packageCompList.add(packageComp2);
            PackageComponentDAO.newInstance().insertRecords(packageCompList, true, AccessLevel.USER_MODE);

            for(Application_Preference__c ap : studyLinkAppPrefList){
                ap.Program_Name__c = 'StudyLinkAppPrefUpdate';
            }
            Test.stopTest();
            ApplicationPreferencesDAO.newInstance().updateRecords(studyLinkAppPrefList, true, AccessLevel.USER_MODE);
            List<hed__Application__c> updatedApplication = [SELECT Id, Calculated_Intake_Date__c FROM hed__Application__c WHERE RecordTypeId =: ApplicationsDAO.STUDYLINK_RECTYPE_ID WITH USER_MODE LIMIT 1];
            System.assertEquals(System.Today().addDays(-2), updatedApplication[0].Calculated_Intake_Date__c, 'Calculated Date should be equal to the earliest package component startdate');
        }
    }
   
}