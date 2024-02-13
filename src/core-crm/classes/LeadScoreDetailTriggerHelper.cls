/**
 * @description helper for LeadScoreDetailTriggerHandler
 * @see LeadScoreDetailTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                   |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------------|
      | julie.jane.alegre              | Sept 07, 2023         | DEPP-5965              | Created file                                     |
      | eccarius.munoz                 | October 05, 2023      | DEPP-5866              | Added handling for calculating total lead score  |
      | kenneth.f.alsay                | December 27, 2023     |                        | Removed unused variables                         |
      | mark.j.mahilum                 | Jan 15, 2024          | DEPP-7519              | Added logic to turn off can nurture flag when    |
      |                                |                       |                        | the lead score is below threshold only if the    |
      |                                |                       |                        | QUT_Applicant flag is false                      |
      | roy.nino.s.regala              | Feb 5, 2024           | DEPP-7742              | update to a without sharing context for site user|
 */
public with sharing class LeadScoreDetailTriggerHelper {
    /**
     * @description process records to be set as current preference
     * @param newItems - List of Lead_Score_Detail__c new records
     * @param oldItems - Map<Id, Lead_Score_Detail__c> old records map
     */
    public static void linkLeadScoreDetailToContact(Map<Id, Lead_Score_Detail__c> newItems) {
        Map<Id, Contact> contactToUpdateMap = new Map<Id, Contact>();
        Map<Id, Lead> leadToUpdateMap = new Map<Id, Lead>();
        //Get contact id link to the newly created lead score detail
        for (Lead_Score_Detail__c leadScoreDetail : newItems.values()) {
            if (leadScoreDetail.Contact__c != null) {
                contactToUpdateMap.put(
                    leadScoreDetail.Contact__c,
                    new Contact(
                        Id = leadScoreDetail.Contact__c,
                        Lead_Score_Detail__c = leadScoreDetail.Id
                    )
                );
            }
            if (leadScoreDetail.Lead__c != null) {
                leadToUpdateMap.put(
                    leadScoreDetail.Lead__c,
                    new Lead(
                        Id = leadScoreDetail.Lead__c,
                        Lead_Score_Detail__c = leadScoreDetail.Id
                    )
                );
            }
        }

        if (!contactToUpdateMap.keySet().isEmpty()) {
            LeadScoreDetailWithoutSharingService.updateContactRecordsWithoutSharing(contactToUpdateMap.values());
        }
        if (!leadToUpdateMap.keySet().isEmpty()) {
            LeadsDAO.newInstance()
                .updateRecords(leadToUpdateMap.values(), false, AccessLevel.SYSTEM_MODE);
        }
    }

    public static void calculateTotalLeadScore(
        List<Lead_Score_Detail__c> newItems,
        Map<Id, Lead_Score_Detail__c> oldItems
    ) {
        Map<String, Integer> configMap = mapLeadScoreConfigMax();
        Map<Id, Decimal> contactToScoreMap = new Map<Id, Decimal>();
        Map<Id, Decimal> leadToScoreMap = new Map<Id, Decimal>();
        List<Nurture_Track_Configuration__c> nurtureList = NurtureTrackConfigurationsDAO.newInstance()
            .getNurtureTrackLeadScoreThreshold('SYSTEM_MODE');

        for (Lead_Score_Detail__c leadScoreDetail : newItems) {
            Integer countryTier = getScore(leadScoreDetail.Country_Tier__c);
            Integer courseLevel = getScore(leadScoreDetail.Course_Level__c);
            Integer download = getScore(leadScoreDetail.Download__c);
            Integer emailInteraction = getScore(leadScoreDetail.Email_Interaction__c);
            Integer enquiries = getScore(leadScoreDetail.Enquiries__c);
            Integer eventReg = getScore(leadScoreDetail.Event_Registration_Attendance__c);
            Integer funding = getScore(leadScoreDetail.Funding__c);
            Integer intDoubleDeg = getScore(leadScoreDetail.Interested_In_Double_Degrees__c);
            Integer intEngPath = getScore(
                leadScoreDetail.Interested_In_English_Pathway_Programs__c
            );
            Integer manualAssess = getScore(leadScoreDetail.Manual_Assessment__c);
            Integer mktgCons = getScore(leadScoreDetail.Marketing_Consent__c);
            Integer matchMySkills = getScore(leadScoreDetail.Match_My_Skills__c);
            Integer prefIntake = getScore(leadScoreDetail.Preferred_Intake__c);
            Integer primaryNSA = getScore(leadScoreDetail.Primary_NSA__c);
            Integer primaryBSA = getScore(leadScoreDetail.Primary_BSA__c);
            Integer progEng = getScore(leadScoreDetail.Program_Engagement__c);
            Integer residence = getScore(leadScoreDetail.Residence__c);

            Integer score =
                countryTier +
                courseLevel +
                download +
                emailInteraction +
                enquiries +
                eventReg +
                funding +
                intDoubleDeg +
                intEngPath +
                manualAssess +
                mktgCons +
                matchMySkills +
                prefIntake +
                primaryNSA +
                primaryBSA +
                progEng +
                residence;

            Integer validatedScore = LeadScoreCalculatorService.validateScore(
                score,
                configMap.get(
                    leadScoreDetail.Domestic_International__c + leadScoreDetail.Study_Level__c
                )
            );
            leadScoreDetail.Total_Lead_Score__c = validatedScore;

            //map contact to its total lead score
            if (leadScoreDetail.Contact__c != null) {
                contactToScoreMap.put(
                    leadScoreDetail.Contact__c,
                    leadScoreDetail.Total_Lead_Score__c
                );
            }

            //map lead to its total lead score
            if (leadScoreDetail.Lead__c != null) {
                leadToScoreMap.put(leadScoreDetail.Lead__c, leadScoreDetail.Total_Lead_Score__c);
            }
        }

        Decimal minimumThreshold = nurtureList.isEmpty()?null:nurtureList[0].Lead_Score_Threshold__c;

        //update Contact and Lead Flag fields when lead score is recalculated
        setContactFlags(contactToScoreMap, minimumThreshold);
        setLeadFlags(leadToScoreMap, minimumThreshold);
    }

    /**
     * @description set the contact flags that depends on lead score
     * @param  Map<Id, Decimal> contactToScoreMap - contact id to its total score map
     * @param Decimal minimumThreshold - minimum threshold of nuturetrack
     */
    private static void setContactFlags(
        Map<Id, Decimal> contactToScoreMap,
        Decimal minimumThreshold
    ) {
        Map<Id, Contact> contactToUpdateMap = new Map<Id, Contact>();
        Contact contactRecord;
        if (!contactToScoreMap.keySet().isEmpty()) {
            
            Map<String, Nurture_Track_Configuration__c> mapOfNurtureTrack = new Map<String, Nurture_Track_Configuration__c>();

            // Populate mapOfNurtureTrack with nurturing track records for Strong Interest
            populateNurtureTrackMap(mapOfNurtureTrack);            

            for (
                Contact con : ContactsDAO.newInstance()
                    .getPersonContactsBySetIds(contactToScoreMap.keySet(), AccessLevel.SYSTEM_MODE)
            ) {
                minimumThreshold = getMinScore(con.hed__Citizenship_Status__c, mapOfNurtureTrack);
                Decimal totalLeadScore = contactToScoreMap.get(con.Id);
                boolean newCanNuture = con.QUT_Applicant__c || LeadScoreService.isLeadScoreInRange(totalLeadScore, minimumThreshold, null);
                boolean newQUTLead = totalLeadScore > 0;

                //if any of the fields above are changed by recalculation
                //then contact is for update
                boolean isForUpdate = (con.Can_Nurture__c != newCanNuture || con.QUT_Lead__c != newQUTLead);
                     
                if (isForUpdate) {
                    contactRecord = new Contact();
                    contactRecord.Id = con.Id;
                    contactRecord.Can_Nurture__c = newCanNuture;
                    contactRecord.QUT_Lead__c = newQUTLead;
                    contactToUpdateMap.put(con.Id, contactRecord);
                }
            }
        }

        if (!contactToUpdateMap.keySet().isEmpty()) {
            ContactsDAO.newInstance()
                .updateRecords(contactToUpdateMap.values(), false, AccessLevel.SYSTEM_MODE);
        }
    }

    /**
     * @description set the lead flags that depends on lead score
     * @param  Map<Id, Decimal> leadToScoreMap - lead id to its total score map
     * @param Decimal minimumThreshold - minimum threshold of nuturetrack
     */
    private static void setLeadFlags(Map<Id, Decimal> leadToScoreMap, Decimal minimumThreshold) {
        Map<Id, Lead> leadToUpdateMap = new Map<Id, Lead>();
        Lead leadRecord;

        if (!leadToScoreMap.keySet().isEmpty()) {
            for (
                Lead lead : LeadsDAO.newInstance()
                    .getLeadsByIdSet(leadToScoreMap.keySet(), AccessLevel.SYSTEM_MODE)
            ) {
                Decimal totalLeadScore = leadToScoreMap.get(lead.Id);
                String newStatus = LeadScoreService.getLeadStatus(totalLeadScore);
                boolean isAboveThreshold = minimumThreshold != null && LeadScoreService.isLeadScoreInRange(
                    totalLeadScore,
                    minimumThreshold,
                    null
                );
                String newJourneyStatus = totalLeadScore > 0 ? LeadsDAO.EXPLORE_JOURNEY_STATUS : '';

                //if any of the fields above is changed by recalculation, then lead is for update
                boolean isForUdpate =
                    lead.Can_Nurture__c != isAboveThreshold ||
                    lead.Future_Student_Journey_Status__c != newJourneyStatus ||
                    lead.Status != newStatus;

                if (isForUdpate) {
                    leadRecord = new Lead();
                    leadRecord.Id = lead.Id;
                    leadRecord.Can_Nurture__c = isAboveThreshold;
                    leadRecord.Future_Student_Journey_Status__c = newJourneyStatus;
                    leadRecord.Status = newStatus;
                    leadToUpdateMap.put(lead.Id, leadRecord);
                }
            }
        }

        if (!leadToUpdateMap.keySet().isEmpty()) {
            LeadsDAO.newInstance()
                .updateRecords(leadToUpdateMap.values(), false, AccessLevel.SYSTEM_MODE);
        }
    }

    private static Map<String, Integer> mapLeadScoreConfigMax() {
        List<Lead_Score_Configuration__c> leadScoreConfigList = LeadScoreConfigurationDAO.newInstance()
            .getLeadScoreConfigByRecordTypeIds(
                AccessLevel.SYSTEM_MODE,
                new Set<Id>{ LeadScoreConfigurationDAO.RECTYPE_ID_CONFIG }
            );
        Map<String, Integer> configMap = new Map<String, Integer>();
        for (Lead_Score_Configuration__c config : leadScoreConfigList) {
            configMap.put(
                config.Domestic_International__c + config.Study_Level__c,
                Integer.valueOf(config.Max_Score__c)
            );
        }
        return configMap;
    }

    private static Integer getScore(Decimal leadScore) {
        return leadScore != null ? Integer.valueOf(leadScore) : 0;
    }

    /**
     * @description set the nurture track lead score threshold
     *
     * @param String citizenshipStatus, Map<String, Nurture_Track_Configuration__c> mapOfNurtureTrack
     */     
    private static Decimal getMinScore(String citizenshipStatus, Map<String, Nurture_Track_Configuration__c> mapOfNurtureTrack) {
        if (citizenshipStatus == 'Domestic' || citizenshipStatus == 'International') {
            String cadenceName = (citizenshipStatus == 'International') ? NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PRE_APPLICATION_MANUAL : NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_MANUAL;
            return mapOfNurtureTrack.get(cadenceName)?.Lead_Score_Threshold__c;
        }
        return null;
    }

    /**
     * @description get strong interest nurture track
     *
     * @param Map<String, Nurture_Track_Configuration__c> mapOfNurtureTrack)
     */    
    private static void populateNurtureTrackMap(Map<String, Nurture_Track_Configuration__c> mapOfNurtureTrack) {
        for (Nurture_Track_Configuration__c nurture : NurtureTrackConfigurationsDAO.newInstance().getNurtureTrackLeadScoreThreshold('SYSTEM_MODE')) {
            if (isStrongInterestCadence(nurture.Cadence_Name__c)) {
                mapOfNurtureTrack.put(nurture.Cadence_Name__c, nurture);
            }
        }
    }
    
    /**
     * @description check if cadence is strong interest
     *
     * @param String cadenceName
     */      
    private static boolean isStrongInterestCadence(String cadenceName) {
        return cadenceName == NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_MANUAL ||
            cadenceName == NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PRE_APPLICATION_MANUAL;
    }

}