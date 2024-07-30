/**
 * @description Helper class for updating the Lead Status of Lead Type = Learner
 *
 * @see LeadTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                              |
 *    |--------------------------------|-----------------------|------------------------|---------------------------------------------|
 *    | mark.j.mahilum                 | June 08,2023          | DEPP-5798              | Created File                                |
 *    | mark.j.mahilum                 | July 25, 2023         | DEPP-6106              | Added new method to set Can Nurture flag    |
 *    | mark.j.mahilum                 | July 27, 2023         | DEPP-6107              | Added new method getLeadCalculatedCadence   |
 *    | julie.jane.alegre              | Sept 6, 2023          | DEPP-5965              | Added new method createLeadScoreDetail      |
 *    | julie.jane.alegre              | Sept 14, 2023         | DEPP-6679              | Added new method createMarketingSegmentation|
 *    | mark.j.mahilum                 | Sept 22, 2023         | DEPP-6488              | Updated getLeadCalculatedCadence to include |
 *    |                                |                       |                        | automated cadence in the processSaleCadences|
 *    | johanna.a.gibas                | Oct 25, 2023          | DEPP-6889              | Updated getLeadCalculatedCadence to include |
 *    |                                |                       |                        |     updateCompletedCadences                 |
 *    | roy.nino.s.regala              | Nov 01, 2023          | DEPP-7105              | updated createMarketingSegmentationForLeads |
 *    |                                |                       |                        |     to future                               |
 *    | eccarius.munoz                 | March 5, 2024         | DEPP-7699              | Added method for lead source and lead source|
 *    |                                |                       |                        | category values when user profile is FSE.   |
 *    ! arsenio.jr.dayrit              | April 15, 2024        | DEPP-8495              | Update updateCanNurture method              |
 *    | mark.j.mahilum                 | May 06, 2024          | DEPP-7987              | Added new method to separate async and sync |
 *    |                                |                       |                        | call when current transaction is running on |
 *    |                                |                       |                        | async callout or not                        |
 */
@SuppressWarnings('PMD')
public with sharing class LeadService {
    /**
     * @description update lead status to qualified
     *
     * @param newItems  List of new Lead records
     */
    public static void updateLeadStatus(List<Lead> newItems) {
        for (Lead lead : newItems) {
            lead.Status = lead.Lead_Type__c == LeadsDAO.LEARNER_LEAD_TYPE && lead.IsConverted
                ? LeadsDAO.QUALIFIED_STATUS
                : lead.Status;
        }
    }

    /**
     * @description To populated the Ids of Lead if the Calculated cadences is changed
     *
     * @param newItems  List of new lead records
     * @param oldItems  Map of old lead records
     */
    public static void getLeadCalculatedCadence(List<Lead> newItems, Map<Id, Lead> oldItems) {
        Map<String, String> assignLeadToCadenceMap = new Map<String, String>();
        Map<String, String> removeLeadToCadenceMap = new Map<String, String>();

        for (Lead lead : newItems) {
            if (lead.IsConverted) {
                continue;
            }

            Lead oldLead = oldItems.get(lead.Id);
            String calculatedCadence = lead.Calculated_Cadence__c;
            String oldCalculatedCadence = oldLead.Calculated_Cadence__c;

            if (calculatedCadence != oldCalculatedCadence) {
                if (String.isNotEmpty(calculatedCadence) && String.isEmpty(oldCalculatedCadence)) {
                    assignLeadToCadenceMap.put(lead.Id, calculatedCadence);
                } else if (
                    String.isEmpty(calculatedCadence) && String.isNotEmpty(oldCalculatedCadence)
                ) {
                    removeLeadToCadenceMap.put(lead.Id, oldCalculatedCadence);
                }
            }
        }

        if (!assignLeadToCadenceMap.isEmpty() || !removeLeadToCadenceMap.isEmpty()) {
            SalesCadenceCalloutService.processSaleCadences(
                assignLeadToCadenceMap,
                removeLeadToCadenceMap
            );
            SalesCadenceCalloutService.updateCreateCompletedCadenceRecords(assignLeadToCadenceMap,removeLeadToCadenceMap);
        }
    }

    @future
    public static void createMarketingSegmentationAsync(Set<Id> leadIds) {
        createMarketingSegmentationForLeads(leadIds);
    }
    
    public static void createMarketingSegmentationSync(Set<Id> leadIds) {
        createMarketingSegmentationForLeads(leadIds);
    }

    /**
     * @description create a Marketing Segmentation on the newly created Lead
     *
     * @param Set<Id> leadIds
     */
    public static void createMarketingSegmentationForLeads(Set<Id> leadIds) {
        List<Marketing_Segmentation__c> marketingSegToInsert = new List<Marketing_Segmentation__c>();
        Map<Id,ServiceAppointment> serviceAppointmentMap = new Map<Id,ServiceAppointment>();
        for(ServiceAppointment serviceAppointment : ServiceAppointmentsDAO.newInstance().getServiceAppointmentByLeadId(leadIds)){
            serviceAppointmentMap.put(serviceAppointment.LeadId__c, serviceAppointment);
        }
        for (Lead lead : LeadsDAO.newInstance().getLeadsByIdSet(leadIds,AccessLevel.SYSTEM_MODE)) {
            Boolean hasServiceAppointment = serviceAppointmentMap.containsKey(lead.Id);
            if (lead.Marketing_Segmentation__c == null) {
                marketingSegToInsert.add(new Marketing_Segmentation__c(
                    Lead__c = lead.Id,
                    My_Citizenship_Status__c = hasServiceAppointment?serviceAppointmentMap.get(lead.Id).My_Citizenship_Status__c:null,
                    My_Country_Of_Citizenship__c = hasServiceAppointment?serviceAppointmentMap.get(lead.Id).My_Country_Of_Citizenship__c:null,
                    My_Country_Of_Residency__c = hasServiceAppointment?serviceAppointmentMap.get(lead.Id).My_Country_Of_Residency__c:null
                ));
            }
        }
        if (!marketingSegToInsert.IsEmpty()) {
            MarketingSegmentationsDAO.newInstance()
                .insertRecords(marketingSegToInsert, false, AccessLevel.SYSTEM_MODE);
        }
    }

    public static void createLeadScoreDetailRecord(List<Lead> leadList) {
        List<Lead_Score_Detail__c> leadScoreDetailsToInsert = new List<Lead_Score_Detail__c>();
        for (Lead lead : leadList) {
            if(!lead.IsConverted){
                leadScoreDetailsToInsert.add(new Lead_Score_Detail__c(Lead__c = lead.Id));
            }
        }
        if(!leadScoreDetailsToInsert.isEmpty()){
            LeadScoreDetailsDAO.newInstance().insertRecords(leadScoreDetailsToInsert, false, AccessLevel.SYSTEM_MODE);
        }
    }

    /**
     * @description Update Lead when Lead Source Category is Partner Sourced
     *
     * @param newItems  Map of new lead records
     * @param oldItems  Map of old lead records
     */
    public static void updateCanNurture(Map<Id, Lead> newItems, Map<Id, Lead> oldItems) {

        Boolean isForInsert = oldItems == null;
        Boolean isForUpdate = oldItems!= null;
        Set<Id> leadWithCompletedCadencePartnerSource = checkCompletedCadenceWithPartnerSource(newItems.keySet());
        for (Lead lead : newItems.values()) {
            Boolean hasLeadWithCompletedCadencePartnerSource = leadWithCompletedCadencePartnerSource.contains(lead.Id);
            Boolean leadWithPartnerSourcedCadenceForUpdateFlagToFalse = lead.Lead_Source_Category__c == LeadsDAO.LEAD_SOURCE_CATEGORY_PARTNER_SOURCED &&
                                    !lead.IsConverted &&
                                    isForUpdate &&
                                    hasLeadWithCompletedCadencePartnerSource &&
                                    lead.Can_Nurture__c;
            Boolean leadToPartnerSourcedForUpdateFlagToTrue = isForUpdate &&
                                    !lead.IsConverted &&
                                    oldItems.get(lead.Id).Lead_Source_Category__c != lead.Lead_Source_Category__c &&
                                    lead.Lead_Source_Category__c == LeadsDAO.LEAD_SOURCE_CATEGORY_PARTNER_SOURCED &&
                                    lead.Lead_Type__c == LeadsDAO.LEARNER_LEAD_TYPE &&
                                    !lead.Can_Nurture__c;



            if(leadWithPartnerSourcedCadenceForUpdateFlagToFalse){
                lead.Can_Nurture__c = false;
                lead.Calculated_Cadence__c = null;
                lead.Cadence_Application__c = null;
            }
            else if (leadToPartnerSourcedForUpdateFlagToTrue){
                lead.Can_Nurture__c = true;
            }

        }
    }

    public static Set<Id> checkCompletedCadenceWithPartnerSource(Set<Id> leadIds){
        date afterThreeYears = System.today().addYears(-3);
        Set<Id> leadsWithSubmittedApplication = new Set<Id>();
        Set<Id> leadWithCompletedCadenceWithPartnerSourceIdSet = new Set<Id>();
        List<hed__Application__c> applicationList = ApplicationsDAO.newInstance().getApplicationsByLeadIds(leadIds, 'SYSTEM_MODE');
            For(hed__Application__c app : applicationList){
                if(app.Application_Status__c == ApplicationsDAO.STATUS_SUBMITTED){
                    leadsWithSubmittedApplication.add(app.Lead__c);
                }
            }

        List<Completed_Cadence__c> completedCadenceList = CompletedCadencesDAO.newInstance().getCompletedCadenceByLeadIds(leadIds,'SYSTEM_MODE');
        for(Completed_Cadence__c completedCadence : completedCadenceList){
            Boolean isValid = completedCadence.Lead__c != null &&
                              completedCadence.Lead__r.Can_Nurture__c && 
                              NurtureTrackConfigurationsDAO.INTERNATIONAL_PARTNER_SOURCED.contains(completedCadence.Lead__r.Calculated_Cadence__c) &&
                              completedCadence.CreatedDate < afterThreeYears &&
                              !leadsWithSubmittedApplication.contains(completedCadence.Lead__c);
            if(isValid){
                leadWithCompletedCadenceWithPartnerSourceIdSet.add(completedCadence.Lead__c);
            }
        }

        return leadWithCompletedCadenceWithPartnerSourceIdSet;
    }

     /**
     * Sets the Lead Source and Lead Source Category when User Profile is Future Student Engagement
     * 
     * @param List<Lead> newItems - List of lead to be inserted
     */
    public static void setLeadSourceAndLeadSourceCategoryFields(List<Lead> newItems){

        boolean isFSEUserProfile = false;
        Id userProfileId = UserInfo.getProfileId();
        List<Profile> profileList = ProfilesDAO.newInstance().getProfileRecordsBySetIds(new Set<Id>{userProfileId});
        for(Profile profile : profileList){
            if(profile.Name == ProfilesDAO.FUTURE_STUDENT_ENGAGEMENT_PROFILE){
                isFSEUserProfile = true;
            }
        }
        if(isFSEUserProfile){
            for (Lead lead : newItems) {
                if(lead.LeadSource == null){
                    lead.LeadSource = LeadsDAO.LEAD_SOURCE_MANUAL_CREATE;
                }
                if(lead.Lead_Source_Category__c == null){
                    lead.Lead_Source_Category__c = LeadsDAO.LEAD_SOURCE_CATEGORY_OTHER;
                }
            }
        }
    }
}
