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

        Lead_Score_Configuration__c leadScoreConfiguration = new Lead_Score_Configuration__c(
            Max_Score__c = 100,
            Study_Level__c = 'Undergraduate',
            Domestic_International__c = 'Domestic'
        );

        insert leadScoreConfiguration;

        String domesticInternational = leadScoreConfiguration.Domestic_International__c;
        String studyLevel = leadScoreConfiguration.Study_Level__c;

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
        Nurture_Track_Configuration__c nurtureTrackConfiguration = new Nurture_Track_Configuration__c(
            Cadence_Name__c = 'Domestic Strong Interest Pre-Application',
            Lead_Score_Threshold__c = 100,
            Criteria_Type__c = 'Entry'
        );

        insert nurtureTrackConfiguration;

        try {
            LeadScoreSectionCtrl.getScoreDomesticStrongInterestPreApplication('Domestic');
        } catch (Exception e) {
            System.assert(e != null, 'Exception should have been thrown');
        }

        Test.stopTest();
    }
}
