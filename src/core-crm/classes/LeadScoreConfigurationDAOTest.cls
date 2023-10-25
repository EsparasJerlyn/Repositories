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
    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
		System.assert(
            new LeadScoreConfigurationDAO().getSObjectType() == Lead_Score_Configuration__c.SObjectType,
            'SObject is not Account'
        );
        Test.stopTest();
    }

    @isTest
    static void getLeadScoreConfigByCitizenshipStudyLvlTest() {
        Test.startTest();
        List<Lead_Score_Configuration__c> leadScoreConfig = LeadScoreConfigurationDAO.newInstance()
            .getLeadScoreConfigByCitizenshipStudyLvl(
                '',
                ''
            );
        System.assert(leadScoreConfig.isEmpty(), 'leadScoreConfig should be empty.');
        Test.stopTest();
    }

    @isTest
    static void getLeadScoreConfigTest() {
        Test.startTest();
        List<Lead_Score_Configuration__c> leadScoreConfig = LeadScoreConfigurationDAO.newInstance().getLeadScoreConfigByRecordTypeIds(AccessLevel.SYSTEM_MODE, LeadScoreConfigurationDAO.RECTYPE_IDS_CATEGORY_AND_SUB_CATEGORY);
        System.assert(leadScoreConfig.isEmpty(), 'leadScoreConfig should be empty.');
        Test.stopTest();
    }

    @isTest
    static void getLeadScoreConfigsByIdTest() {
        Test.startTest();
        List<Lead_Score_Configuration__c> leadScoreConfig = LeadScoreConfigurationDAO.newInstance()
            .getLeadScoreConfigsById(
                new Set<Id>(), 
                new List<String>(), 
                AccessLevel.SYSTEM_MODE
            );
        System.assert(leadScoreConfig.isEmpty(), 'leadScoreConfig should be empty.');
        Test.stopTest();
    }
    
    
}