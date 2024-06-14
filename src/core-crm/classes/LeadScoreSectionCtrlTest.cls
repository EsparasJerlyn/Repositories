/**
 * @description Test Class for Lead Score Section
 *
 * @see ../class/LeadScoreSectionCtrl
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | neil.s.h.lesidan          | August 30, 2023       | DEPP-5835    | Created file                                |
      |                           |                       |              |                                             |
*/
@isTest
private class LeadScoreSectionCtrlTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserSystemAdministrator();
    }

    @isTest
    public static void testGetScoreByCitizenshipStudyLvl() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            Test.startTest();

            List<RecordType> recordType = [
                SELECT id, Name
                FROM RecordType
                WHERE SobjectType = 'Lead_Score_Configuration__c'
                    AND DeveloperName = 'Configuration'
            ];

            List<Lead_Score_Configuration__c> leadScoreConfiguration = new List<Lead_Score_Configuration__c>();
            leadScoreConfiguration.add(new Lead_Score_Configuration__c(
                Max_Score__c = 100,
                Study_Level__c = 'Undergraduate',
                Domestic_International__c = 'Domestic',
                RecordTypeId = recordType[0].Id
            ));

            String domesticInternational = leadScoreConfiguration[0].Domestic_International__c;
            String studyLevel = leadScoreConfiguration[0].Study_Level__c;

            LeadScoreConfigurationDAO.newInstance().insertRecords(leadScoreConfiguration, false, AccessLevel.USER_MODE);

            List<Lead_Score_Configuration__c> scoreByCitizenshipStudyLvl = LeadScoreSectionCtrl.getScoreByCitizenshipStudyLvl(domesticInternational, studyLevel);
            system.assert(!scoreByCitizenshipStudyLvl.isEmpty(), 'scoreByCitizenshipStudyLvl should not be empty.');

            Test.stopTest();
        }

    }

    @isTest
    public static void testGetScoreDomesticStrongInterestPreApplication() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            Test.startTest();

            List<Nurture_Track_Configuration__c> nurtureTrackConfiguration = new List<Nurture_Track_Configuration__c>();
            nurtureTrackConfiguration.add(new Nurture_Track_Configuration__c(
                Cadence_Name__c = 'Domestic Strong Interest Pre-Application',
                Lead_Score_Threshold__c = 100,
                Criteria_Type__c = 'Entry',
                Status__c = 'Active'
            ));

            ImplementationSelector.DAO.setMock(new NurtureTrackConfigurationsDAOMock());

            NurtureTrackConfigurationsDAO.newInstance().insertRecords(nurtureTrackConfiguration, false, AccessLevel.USER_MODE);

            List<Nurture_Track_Configuration__c> scoreDomesticStrongInterestPreApplication = LeadScoreSectionCtrl.getScoreDomesticStrongInterestPreApplication('Domestic');
            system.assert(!scoreDomesticStrongInterestPreApplication.isEmpty(), 'scoreDomesticStrongInterestPreApplication should not be empty.');

            Test.stopTest();
        }
    }
}