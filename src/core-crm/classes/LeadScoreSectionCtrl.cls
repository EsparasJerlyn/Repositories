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
        return [//NOPMD
            SELECT
            Id, Max_Score__c, Study_Level__c, Domestic_International__c
            FROM Lead_Score_Configuration__c
            WHERE Domestic_International__c =: citizenshipStatus
            AND Study_Level__c =: primaryStudyLevel
            LIMIT 1
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Nurture_Track_Configuration__c> getScoreDomesticStrongInterestPreApplication(String citizenshipStatus) {
        try {
            String cadenceName = 'International Strong Interest Pre-Application';
            if (citizenshipStatus == 'Domestic') {
                cadenceName = 'Domestic Strong Interest Pre-Application';
            }

            return [//NOPMD
                SELECT
                Id, Cadence_Name__c, Lead_Score_Threshold__c
                FROM Nurture_Track_Configuration__c
                WHERE Cadence_Name__c =: cadenceName
                AND Criteria_Type__c = 'Entry'
                LIMIT 1
            ];
        } catch (Exception e) {
            // prettier-ignore
            NebulaLoggerService.logExceptionDetails('Exception caught in LeadScoreSectionCtrl.cls',e);
            throw e;
        }
    }
}