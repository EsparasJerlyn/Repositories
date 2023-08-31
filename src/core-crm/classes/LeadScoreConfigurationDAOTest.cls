/**
 * @description Test class for NurtureTrackConfigurationsDAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | mark.j.mahilum                 | July 25, 2023         | DEPP-6106              | created file                 |
 */
@isTest
public with sharing class LeadScoreConfigurationDAOTest {
    @isTest
    static void getLeadScoreConfigByCitizenshipStudyLvlTest() {
        Test.startTest();
        List<Lead_Score_Configuration__c> leadScoreConfig = LeadScoreConfigurationDAO.newInstance()
            .getLeadScoreConfigByCitizenshipStudyLvl(
                '',
                '',
                'SYSTEM_MODE'
            );
        System.assert(leadScoreConfig.isEmpty(), 'leadScoreConfig should not be empty.');
        Test.stopTest();
    }
}