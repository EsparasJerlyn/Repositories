/**
 * @description Controller Class for Lead Score Progress Ring
 * @see ../lwc/leadScoreSection
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                               |
      |--------------------------------|-----------------------|------------------------|----------------------------------------------|
      | neil.s.h.lesidan               | August 30, 2023       | DEPP-5835              | Created file                                 |
 */
public with sharing class LeadScoreSectionCtrl {

    @AuraEnabled(cacheable=true)
    public static List<Lead_Score_Configuration__c> getScoreByCitizenshipStudyLvl(
        String citizenshipStatus,
        String primaryStudyLevel
    ) {

        List<Lead_Score_Configuration__c> leadScoreConfig = LeadScoreConfigurationDAO.newInstance().getLeadScoreConfigByCitizenshipStudyLvl(
            citizenshipStatus,
            primaryStudyLevel
        );

        List<Lead_Score_Configuration__c> leadScoreConfigMap = new List<Lead_Score_Configuration__c>();

        for (Lead_Score_Configuration__c rec: leadScoreConfig) {
            if(rec.RecordType.DeveloperName == LeadScoreConfigurationDAO.RECORD_TYPE_CONFIGURATION){
                leadScoreConfigMap.add(rec);
            }
        }

        return leadScoreConfigMap;
    }

    @AuraEnabled(cacheable=true)
    public static List<Nurture_Track_Configuration__c> getScoreDomesticStrongInterestPreApplication(String citizenshipStatus) {
        String cadenceName = NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PRE_APPLICATION_MANUAL;
        if (citizenshipStatus == 'Domestic') {
            cadenceName = NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_MANUAL;
        }

        Set<String> cadenceNames = new Set<String>();
        cadenceNames.add(cadenceName);

        List<Nurture_Track_Configuration__c> nurtureList = NurtureTrackConfigurationsDAO.newInstance().getNurtureTrackByCadenceNames(cadenceNames, 'USER_MODE');
        List<Nurture_Track_Configuration__c> nurtureMap = new List<Nurture_Track_Configuration__c>();

        for (Nurture_Track_Configuration__c rec: nurtureList) {
            if(rec.Criteria_Type__c == NurtureTrackConfigurationsDAO.CRITERIA_TYPE_ENTRY){
                nurtureMap.add(rec);
            }
        }

        return nurtureMap;
    }
}