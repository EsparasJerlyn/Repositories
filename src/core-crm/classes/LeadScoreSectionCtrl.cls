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
public without sharing class LeadScoreSectionCtrl {

    @AuraEnabled(cacheable=true)
    public static List<Lead_Score_Configuration__c> getScoreByCitizenshipStudyLvl(
        String citizenshipStatus,
        String primaryStudyLevel
    ) {

        List<Lead_Score_Configuration__c> nurtureList = LeadScoreConfigurationDAO.newInstance().getLeadScoreConfigByCitizenshipStudyLvl(
            citizenshipStatus,
            primaryStudyLevel
        );

        return nurtureList;
    }

    @AuraEnabled(cacheable=true)
    public static List<Nurture_Track_Configuration__c> getScoreDomesticStrongInterestPreApplication(String citizenshipStatus) {
        String cadenceName = 'International Strong Interest Pre-Application';
        if (citizenshipStatus == 'Domestic') {
            cadenceName = 'Domestic Strong Interest Pre-Application';
        }

        Set<String> cadenceNames = new Set<String>();
		cadenceNames.add(cadenceName);

        List<Nurture_Track_Configuration__c> nurtureList = NurtureTrackConfigurationsDAO.newInstance().getNurtureTrackByCadenceNames(cadenceNames,'USER_MODE');
        List<Nurture_Track_Configuration__c> nurtureMap = new List<Nurture_Track_Configuration__c>();

        for (Nurture_Track_Configuration__c rec: nurtureList) {
            if(rec.Criteria_Type__c == 'Entry'){
                nurtureMap.add(rec);
            }
        }

        return nurtureMap;
    }
}