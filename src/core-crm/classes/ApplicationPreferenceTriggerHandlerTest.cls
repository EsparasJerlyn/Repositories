/**
 * @description Test Class for ApplicationPreferenceTriggerHandler
 *
 * @see ApplicationPreferenceTriggerHandler
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
private class ApplicationPreferenceTriggerHandlerTest {
    
    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactoryUser.generateUserQUTESB();
        Test.stopTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);

            Integer numOfPrefRec = 2;
            List<hed__Application__c> qtacApplicationList = TestDataFactory.createApplicationRecords(contactList[0].Id, ApplicationsDAO.QTAC_RECTYPE_ID, 1);
            ApplicationsDAO.newInstance().insertRecords(qtacApplicationList, false, AccessLevel.USER_MODE);
            List<Application_Preference__c> qtacAppPrefList = TestDataFactory.createApplicationPreferenceRecords(qtacApplicationList[0].Id, ApplicationPreferencesDAO.QTAC_RECTYPE_ID, numOfPrefRec);
            ApplicationPreferencesDAO.newInstance().insertRecords(qtacAppPrefList, false, AccessLevel.USER_MODE);

        }
    }

    @isTest
    private static void insertTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
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
    private static void updateTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
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

}