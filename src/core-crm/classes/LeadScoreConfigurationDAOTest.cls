/**
 * @description Test class for LeadScoreConfigurationDAOTest
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | neil.s.h.lesidan               | August 30, 2023       | DEPP-5835              | created file                 |
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
        System.assert(leadScoreConfig.isEmpty(), 'leadScoreConfig should not be empty.');
        Test.stopTest();
    }
}