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
            SalesCadenceCalloutService.updateCompletedCadences(assignLeadToCadenceMap);
        }
    }

    /**
     * @description create a Marketing Segmentation on the newly created Lead
     *
     * @param Set<Id> leadIds
     */
    @future
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
}
