/**
 * @description Test Class for EngagementListCriteriasDAO
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary                      |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------------|
 *    | vincent.ferrer                 |  May 1, 2024          | DEPP-8492              | Created file
 */
@isTest
public with sharing class EngagementListCriteriasDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserQUTESB();
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            System.assert(EngagementListCriteriasDAO.newInstance() != null, 'EngagementListCriteriasDAO instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            System.assert(
                new EngagementListCriteriasDAO().getSObjectType() == Engagement_List_Criteria__c.SObjectType,
                'SObject is not Engagement_List_Criteria__c'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void findActiveEntryCriteriaWithDatesTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<Engagement_List_Configuration__c> listELConfigs = new List<Engagement_List_Configuration__c>();
            for (Integer i=0; i<=3; i++){
                Engagement_List_Configuration__c newELConfig = new Engagement_List_Configuration__c();
                newELConfig.Name = 'ELC Config 0' + i;
                newELConfig.Engagement_List_Configuration_Status__c = EngagementListCriteriasDAO.ACTIVE_STATUS;
                newELConfig.Start_Date__c = System.Date.today().addDays(-i);
                newELConfig.End_Date__c = System.Date.today().addDays(i);
                listELConfigs.add(newELConfig);
            }
            EngagementListConfigurationsDAO.newInstance().insertRecords(listELConfigs, false, AccessLevel.USER_MODE);

            List<Engagement_List_Criteria__c> listELCriteria = new List<Engagement_List_Criteria__c>();
            for (Integer i=0; i<=3; i++){
                Engagement_List_Criteria__c newELCriteria = new Engagement_List_Criteria__c();
                newELCriteria.Engagement_List_Criteria_Title__c = 'Test ELC 0' + i;
                newELCriteria.Engagement_List_Configuration__c = listELConfigs[i].Id;
                newELCriteria.Status__c = EngagementListCriteriasDAO.ACTIVE_STATUS;
                newELCriteria.RecordTypeId = EngagementListCriteriasDAO.RECORD_TYPE_ID_ENTRY_CRITERIA;
                newELCriteria.Start_Date__c = System.Date.today().addDays(-i);
                newELCriteria.End_Date__c = System.Date.today().addDays(i);
                newELCriteria.Is_On_Leave_of_Absence__c = EngagementListCriteriasDAO.IS_ON_LEAVE_YES;
                newELCriteria.Key_Date__c = EngagementListCriteriasDAO.KEY_DATE_LEAVE_OF_ABSENCE_END_DATE;
                newELCriteria.Key_Date_Offset_Lower_Boundary__c = 1;
                newELCriteria.Key_Date_Offset_Upper_Boundary__c = 10;
                
                listELCriteria.add(newELCriteria);
            }
            EngagementListCriteriasDAO.newInstance().insertRecords(listELCriteria, false, AccessLevel.USER_MODE);

            List<Engagement_List_Criteria__c> actualEngagementListCriteriasFound = EngagementListCriteriasDAO.newInstance().findActiveEngagementListCriteriasByRecordtype(EngagementListCriteriasDAO.RECORD_TYPE_ID_ENTRY_CRITERIA, System.Date.Today(), AccessLevel.USER_MODE);
            
            System.assert(actualEngagementListCriteriasFound.size() > 0, 'No Active Criterias Found');
        }
        
        Test.stopTest();
    }

    @isTest
    static void findActiveEntryCriteriaWithNullDatesTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<Engagement_List_Configuration__c> listELConfigs = new List<Engagement_List_Configuration__c>();
            for (Integer i=0; i<=3; i++){
                Engagement_List_Configuration__c newELConfig = new Engagement_List_Configuration__c();
                newELConfig.Name = 'ELC Config 0' + i;
                newELConfig.Engagement_List_Configuration_Status__c = EngagementListCriteriasDAO.ACTIVE_STATUS;
                newELConfig.Start_Date__c = null;
                newELConfig.End_Date__c = null;
                listELConfigs.add(newELConfig);
            }
            EngagementListConfigurationsDAO.newInstance().insertRecords(listELConfigs, false, AccessLevel.USER_MODE);

            List<Engagement_List_Criteria__c> listELCriteria = new List<Engagement_List_Criteria__c>();
            for (Integer i=0; i<=3; i++){
                Engagement_List_Criteria__c newELCriteria = new Engagement_List_Criteria__c();
                newELCriteria.Engagement_List_Criteria_Title__c = 'Test ELC 0' + i;
                newELCriteria.Engagement_List_Configuration__c = listELConfigs[i].Id;
                newELCriteria.Status__c = EngagementListCriteriasDAO.ACTIVE_STATUS;
                newELCriteria.RecordTypeId = EngagementListCriteriasDAO.RECORD_TYPE_ID_ENTRY_CRITERIA;
                newELCriteria.Start_Date__c = null;
                newELCriteria.End_Date__c = null;
                newELCriteria.Is_On_Leave_of_Absence__c = EngagementListCriteriasDAO.IS_ON_LEAVE_YES;
                newELCriteria.Key_Date__c = EngagementListCriteriasDAO.KEY_DATE_LEAVE_OF_ABSENCE_END_DATE;
                newELCriteria.Key_Date_Offset_Lower_Boundary__c = 1;
                newELCriteria.Key_Date_Offset_Upper_Boundary__c = 10;
                
                listELCriteria.add(newELCriteria);
            }
            EngagementListCriteriasDAO.newInstance().insertRecords(listELCriteria, false, AccessLevel.USER_MODE);

            List<Engagement_List_Criteria__c> actualEngagementListCriteriasFound = EngagementListCriteriasDAO.newInstance().findActiveEngagementListCriteriasByRecordtype(EngagementListCriteriasDAO.RECORD_TYPE_ID_ENTRY_CRITERIA, System.Date.Today(), AccessLevel.USER_MODE);
            
            System.assert(actualEngagementListCriteriasFound.size() > 0, 'No Active Criterias Found');
        }
        
        Test.stopTest();
    }

    @isTest
    static void findActiveEntryCriteriaEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<Engagement_List_Configuration__c> listELConfigs = new List<Engagement_List_Configuration__c>();
            for (Integer i=0; i<=3; i++){
                Engagement_List_Configuration__c newELConfig = new Engagement_List_Configuration__c();
                newELConfig.Name = 'ELC Config 0' + i;
                newELConfig.Engagement_List_Configuration_Status__c = EngagementListCriteriasDAO.DEACTIVATED_STATUS;
                newELConfig.Start_Date__c = null;
                newELConfig.End_Date__c = null;
                listELConfigs.add(newELConfig);
            }
            EngagementListConfigurationsDAO.newInstance().insertRecords(listELConfigs, false, AccessLevel.USER_MODE);

            List<Engagement_List_Criteria__c> listELCriteria = new List<Engagement_List_Criteria__c>();
            for (Integer i=0; i<=3; i++){
                Engagement_List_Criteria__c newELCriteria = new Engagement_List_Criteria__c();
                newELCriteria.Engagement_List_Criteria_Title__c = 'Test ELC 0' + i;
                newELCriteria.Engagement_List_Configuration__c = listELConfigs[i].Id;
                newELCriteria.Status__c = EngagementListCriteriasDAO.DEACTIVATED_STATUS;
                newELCriteria.RecordTypeId = EngagementListCriteriasDAO.RECORD_TYPE_ID_ENTRY_CRITERIA;
                newELCriteria.Start_Date__c = null;
                newELCriteria.End_Date__c = null;
                newELCriteria.Is_On_Leave_of_Absence__c = EngagementListCriteriasDAO.IS_ON_LEAVE_YES;
                newELCriteria.Key_Date__c = EngagementListCriteriasDAO.KEY_DATE_LEAVE_OF_ABSENCE_END_DATE;
                newELCriteria.Key_Date_Offset_Lower_Boundary__c = 1;
                newELCriteria.Key_Date_Offset_Upper_Boundary__c = 10;
                
                listELCriteria.add(newELCriteria);
            }
            EngagementListCriteriasDAO.newInstance().insertRecords(listELCriteria, false, AccessLevel.USER_MODE);

            List<Engagement_List_Criteria__c> actualEngagementListCriteriasFound = EngagementListCriteriasDAO.newInstance().findActiveEngagementListCriteriasByRecordtype(EngagementListCriteriasDAO.RECORD_TYPE_ID_ENTRY_CRITERIA, System.Date.Today(), AccessLevel.USER_MODE);
            
            System.assertEquals(actualEngagementListCriteriasFound.size(), 0, 'There Should be No Criteries Found.');
        }
        
        Test.stopTest();
    }
    
    @isTest
    static void getEntryCriteriaByIdTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

            List<Engagement_List_Configuration__c> configs = new List<Engagement_List_Configuration__c>();
            Engagement_List_Configuration__c config = new Engagement_List_Configuration__c();
            config.Name = 'ELConfig Test';
            config.Engagement_List_Configuration_Status__c = 'Active';
            config.Start_Date__c = Date.today().addDays(-1);
            config.End_Date__c = Date.today().addDays(1);
            configs.add(config);
            EngagementListConfigurationsDAO.newInstance()
                .insertRecords(configs, true, AccessLevel.SYSTEM_MODE);

            Engagement_List_Criteria__c elc = new Engagement_List_Criteria__c(
                Engagement_List_Criteria_Title__c = 'Test',
                Citizenship_Status__c = 'International',
                Engagement_List_Configuration__c = configs[0].Id
            );

            EngagementListConfigurationsDAO.newInstance().insertRecords(new List<Engagement_List_Criteria__c>{elc},true,AccessLevel.USER_MODE);
            Engagement_List_Criteria__c elCrit = EngagementListCriteriasDAO.newInstance()
                .getEntryCriteriaById(
                    elc.Id,
                    AccessLevel.USER_MODE
                );
            System.assertEquals(elCrit.Id,elc.Id, 'The returned criteria id should match to the newly inserted criteria');
        }
        Test.stopTest();
    }

    @isTest
    static void getEntryCriteriaByIdEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Engagement_List_Criteria__c elCrit = EngagementListCriteriasDAO.newInstance()
                .getEntryCriteriaById(
                    null,
                    AccessLevel.USER_MODE
                );
            System.assert(elCrit == null, 'The criteria should be empty.');
        }
        Test.stopTest();
    }
} 