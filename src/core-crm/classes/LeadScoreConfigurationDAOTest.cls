/**
 * @description Test class for LeadScoreConfigurationDAOTest
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | neil.s.h.lesidan               | August 30, 2023       | DEPP-5835              | created file                 |
      | eccarius.munoz                 | October 05, 2023      | DEPP-5866              | Added getLeadScoreConfig     |
 */
@isTest
public with sharing class LeadScoreConfigurationDAOTest {

    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_System_Administrator' });
    }
    
    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getSystemAdminUser()){
		System.assert(
            new LeadScoreConfigurationDAO().getSObjectType() == Lead_Score_Configuration__c.SObjectType,
            'SObject is not Account'
             );
        }
        Test.stopTest();
    }

    @isTest
    static void getLeadScoreConfigByCitizenshipStudyLvlTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getSystemAdminUser()){
        List<Lead_Score_Configuration__c> leadScoreConfig = LeadScoreConfigurationDAO.newInstance()
            .getLeadScoreConfigByCitizenshipStudyLvl(
                '',
                ''
            );
        System.assert(leadScoreConfig.isEmpty(), 'leadScoreConfig should be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getLeadScoreConfigTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getSystemAdminUser()){
        List<Lead_Score_Configuration__c> leadScoreConfig = LeadScoreConfigurationDAO.newInstance().getLeadScoreConfigByRecordTypeIds(AccessLevel.SYSTEM_MODE, LeadScoreConfigurationDAO.RECTYPE_IDS_CATEGORY_AND_SUB_CATEGORY);
        System.assert(leadScoreConfig.isEmpty(), 'leadScoreConfig should be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getLeadScoreConfigsByIdTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getSystemAdminUser()){
        List<Lead_Score_Configuration__c> leadScoreConfig = LeadScoreConfigurationDAO.newInstance()
            .getLeadScoreConfigsById(
                new Set<Id>(), 
                new List<String>(), 
                AccessLevel.SYSTEM_MODE
            );
        System.assert(leadScoreConfig.isEmpty(), 'leadScoreConfig should be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void queryLocatorLeadScoreConfigByIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getSystemAdminUser()){
        System.assert(
            LeadScoreConfigurationDAO.newInstance().queryLocatorLeadScoreConfigByIds(new Set<Id>()) != null,
            'leadScoreConfig should be empty'
        );
        }
        Test.stopTest();
    }

    @isTest
    static void getCategoryLeadScoreConfigsByIdTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getSystemAdminUser()){
            MockIdGenerator leadScoreConfigMock = new MockIdGenerator(Lead_Score_Configuration__c.sObjectType);
            List<Lead_Score_Configuration__c> leadScoreConfig = LeadScoreConfigurationDAO.newInstance()
                .getCategoryLeadScoreConfigsById(
                    new Set<Id>{leadScoreConfigMock.getMockId()}, 
                    new List<String>(), 
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(leadScoreConfig.isEmpty(), 'leadScoreConfig should be empty.');
        }
        Test.stopTest();
    }    

    @isTest
    static void getCategoryLeadScoreConfigsByIdEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getSystemAdminUser()){
            List<Lead_Score_Configuration__c> leadScoreConfig = LeadScoreConfigurationDAO.newInstance()
                .getCategoryLeadScoreConfigsById(
                    new Set<Id>(), 
                    new List<String>(), 
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(leadScoreConfig.isEmpty(), 'leadScoreConfig should be empty.');
        }
        Test.stopTest();
    }  

}