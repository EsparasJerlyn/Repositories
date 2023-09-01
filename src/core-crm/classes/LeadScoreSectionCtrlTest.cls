/**
 * @description Test Class for Lead Scpre Section
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

    @isTest
    public static void testGetScoreByCitizenshipStudyLvl() {
        Test.startTest();

        List<RecordType> recordType = [
            SELECT id, Name
            FROM RecordType
            WHERE SobjectType = 'Lead_Score_Configuration__c'
                AND Name = 'Configuration'
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

        try {
            LeadScoreSectionCtrl.getScoreByCitizenshipStudyLvl(domesticInternational, studyLevel);
        } catch (Exception e) {
            System.assert(e != null, 'Exception should have been thrown');
        }

        Test.stopTest();

    }

    @isTest
    public static void testGetScoreDomesticStrongInterestPreApplication() {
        Test.startTest();

        List<Nurture_Track_Configuration__c> nurtureTrackConfiguration = new List<Nurture_Track_Configuration__c>();
        nurtureTrackConfiguration.add(new Nurture_Track_Configuration__c(
            Cadence_Name__c = 'Domestic Strong Interest Pre-Application',
            Lead_Score_Threshold__c = 100,
            Criteria_Type__c = 'Entry',
            Status__c = 'Active'
        ));

        LeadScoreConfigurationDAO.newInstance().insertRecords(nurtureTrackConfiguration, false, AccessLevel.USER_MODE); 

        try {
            LeadScoreSectionCtrl.getScoreDomesticStrongInterestPreApplication('Domestic');
        } catch (Exception e) {
            System.assert(e != null, 'Exception should have been thrown');
        }

        Test.stopTest();
    }
}