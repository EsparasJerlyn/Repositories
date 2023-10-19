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
 */
@isTest
private class ApplicationPreferenceTriggerHelperTest {
    
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_ESB' });
        System.runAs(TestDataFactory.getESBIntegrationUser()) {

            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);

            Integer numOfPrefRec = 2;
            //QTAC
            List<hed__Application__c> qtacApplicationList = TestDataFactory.createApplicationRecords(contactList[0].Id, ApplicationsDAO.QTAC_RECTYPE_ID, 1);
            ApplicationsDAO.newInstance().insertRecords(qtacApplicationList, false, AccessLevel.USER_MODE);
            List<Application_Preference__c> qtacAppPrefList = TestDataFactory.createApplicationPreferenceRecords(qtacApplicationList[0].Id, ApplicationPreferencesDAO.QTAC_RECTYPE_ID, numOfPrefRec);
            ApplicationPreferencesDAO.newInstance().insertRecords(qtacAppPrefList, false, AccessLevel.USER_MODE);

            //Study Link
            List<hed__Application__c> studyLinkApplicationList = TestDataFactory.createApplicationRecords(contactList[0].Id, ApplicationsDAO.STUDYLINK_RECTYPE_ID, 1);
            ApplicationsDAO.newInstance().insertRecords(studyLinkApplicationList, false, AccessLevel.USER_MODE);
            List<Application_Preference__c> studyLinkappPrefList = TestDataFactory.createApplicationPreferenceRecords(studyLinkApplicationList[0].Id, ApplicationPreferencesDAO.STUDYLINK_RECTYPE_ID, numOfPrefRec);
            ApplicationPreferencesDAO.newInstance().insertRecords(studyLinkappPrefList, false, AccessLevel.USER_MODE);

            List<Package_Component__c> packageComponentList = TestDataFactory.createPackageComponentRecords(studyLinkappPrefList[0].Id, System.Today(), 1);

            /** Start: DEPP-6970 - Temporarily commenting this code as a workaround for UAT deploy error */
            //PackageComponentDAO.newInstance().insertRecords(packageComponentList, false, AccessLevel.USER_MODE);
            List<Database.SaveResult> saveResult = Database.insert(packageComponentList, false, AccessLevel.USER_MODE);
            for (Database.SaveResult result : saveResult) {
                if (!result.isSuccess()) {
                    Logger.error('Error in inserting records').setDatabaseResult(result);
                }
            }
            if (Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
            /** End: DEPP-6970 */
        }
    }

    @isTest
    private static void setCurrentPreferenceQTACInsertTest() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
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
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
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
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
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
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
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
   
}