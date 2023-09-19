/**
 * @description Helper class for updating the Lead Status of Lead Type = Learner
 * 
 * @see LeadTriggerHandler
 * 
 * @author Accenture
 * 
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                           |
 *    |--------------------------------|-----------------------|------------------------|------------------------------------------|
 *    | mark.j.mahilum                 | June 08,2023          | DEPP-5798              | Created File                             | 
 *    | mark.j.mahilum                 | July 25, 2023         | DEPP-6106              | Added new method to set Can Nurture flag |
 *    | mark.j.mahilum                 | July 27, 2023         | DEPP-6107              | Added new method getLeadCalculatedCadence|
 *    | julie.jane.alegre              | Sept 6, 2023          | DEPP-5965              | Added new method createLeadScoreDetail   |
 *    | julie.jane.alegre              | Sept 14, 2023         | DEPP-6679              | Added new method createMarketingSegmentation|
 */
@SuppressWarnings('PMD')
public with sharing class LeadService {
 
   /**
    * @description update Lead Status base on the lead score for Learner Lead
    *
    * @param newItems  List of new Lead records
    * @param oldItems  Map of old Lead records
    */
    public static void updateLeadStatus(List<Lead> newItems, Map<Id, Lead> oldItems) {        
        for (Lead lead : newItems) {          
            Boolean isExplore = lead.Lead_Score__c != null && lead.Lead_Score__c > 0;
            Boolean isLearner = String.isNotBlank(lead.Lead_Type__c) && lead.Lead_Type__c == 'Learner';
            
            lead.Future_Student_Journey_Status__c = isExplore?LeadsDAO.EXPLORE_JOURNEY_STATUS:'';  

            if (isLearner && isLeadScoreNullOrUnderFifty(lead)) {
                lead.Status = 'New';
            } else if (isLearner && isLeadScoreInRange(lead, 50, 100)) {
                lead.Status = 'Engaging';
            } else if(isLearner) {
                lead.Status = isLeadScoreGreaterThanOrEqual(lead, 100) ? 'Nurturing' : 'Qualified';
            }
        }
    }
   /**
    * @description check if lead score is null or below 50
    *
    * @param Lead new lead record 
    * @return boolean true or false
    */
    private static Boolean isLeadScoreNullOrUnderFifty(Lead lead) {
        return !lead.IsConverted && (lead.Lead_Score__c == null || lead.Lead_Score__c < 50);
    }
   /**
    * @description check if lead score is null or below 50
    *
    * @param Lead new lead record 
    * @param Integer maxScore value
    * @return boolean true or false
    */
    private static Boolean isLeadScoreInRange(Lead lead, Integer minScore, Integer maxScore) {
        return !lead.IsConverted && lead.Lead_Score__c >= minScore && lead.Lead_Score__c < maxScore;
    }
   /**
    * @description check if lead score is null or below 50
    *
    * @param Lead new lead record
    * @param Integer Score value
    * @return boolean true or false
    */
    private static Boolean isLeadScoreGreaterThanOrEqual(Lead lead, Integer score) {
        return !lead.IsConverted && lead.Lead_Score__c >= score;
    }
   /**
    * @description update Can Nurture field base on the lead score threshold
    *
    * @param newItems  List of new lead records
    * @param oldItems  Map of old lead records
    */
    public static void updateCanNurtureFlag(List<Lead> newItems, Map<Id, Lead> oldItems) {   
        
        List<Nurture_Track_Configuration__c> nurtureList = NurtureTrackConfigurationsDAO.newInstance().getNurtureTrackLeadScoreThreshold('SYSTEM_MODE');
		
        for (Lead lead : newItems) {			
            
            Boolean isLeadUnconverted = !lead.IsConverted;
            Boolean isLeadScoreNotNull = lead.Lead_Score__c != NULL;			            
            
            if (oldItems == null && isLeadUnconverted && isLeadScoreNotNull) {
                lead.Can_Nurture__c = isLeadScoreAboveLeadThreshold(lead,nurtureList);
            } else if (oldItems != null && isLeadUnconverted) {
                Lead oldLead = oldItems.get(lead.Id);
                if(lead.Lead_Score__c != oldLead.Lead_Score__c){
                    lead.Can_Nurture__c = isLeadScoreNotNull && isLeadScoreAboveLeadThreshold(lead,nurtureList);
                }
            }
        }
    }
   /**
    * @description check if the lead score is above or equal to threshold
    *
    * @param Lead new lead records  List of new lead records
    * @param List of Nurture Track Configuration
    * @return Boolean true or false
    */    
    private static Boolean isLeadScoreAboveLeadThreshold(Lead lead, List<Nurture_Track_Configuration__c> nurtureList) {        
        for (Nurture_Track_Configuration__c rec: nurtureList) {
            if((lead.Lead_Score__c >= rec.Lead_Score_Threshold__c)) return true;
        }
        return false;
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
            
            if(calculatedCadence != oldCalculatedCadence){              
                if (String.isNotEmpty(calculatedCadence) && calculatedCadence.containsIgnoreCase('automated')) {
                    assignLeadToCadenceMap.put(lead.Id,calculatedCadence);
                } else if (String.isEmpty(calculatedCadence)) {
                    removeLeadToCadenceMap.put(lead.Id,oldCalculatedCadence);
                }                
            }          
        }
        
        if (!assignLeadToCadenceMap.isEmpty() || !removeLeadToCadenceMap.isEmpty()) {
            SalesCadenceCalloutService.processSaleCadences(assignLeadToCadenceMap, removeLeadToCadenceMap);
        }
    }  
    /**
     * @description creating Lead Score Detail to converted lead's contact
     * @param newItems - Map of new leads
     * @param oldItems - Map of old leads
     */
    public static void createLeadScoreDetail(Map<Id,Lead> newItems, Map<Id, Lead> oldItems) {
        List<Lead_Score_Detail__c> leadScoreDetailToInsert = new List<Lead_Score_Detail__c>();
        Set<Id> convertedContactIds = new Set<Id>();
        //Create Lead Score Detail record for the Contact converted
        for(Lead lead:newItems.values()){
            if( oldItems.get(lead.Id).IsConverted != lead.IsConverted && 
                lead.IsConverted == true && lead.ConvertedContactId != null){
                    leadScoreDetailToInsert.add(
                        new Lead_Score_Detail__c(  
                            Contact__c = lead.ConvertedContactId
                        )
                    );
                    convertedContactIds.add(lead.ConvertedContactId);
            }
        }
        if(!leadScoreDetailToInsert.isEmpty()){
            LeadScoreDetailsDAO.newInstance().insertRecords(leadScoreDetailToInsert, false, AccessLevel.SYSTEM_MODE);
        }
    }

    /**
    * @description create a Marketing Segmentation on the newly created contact
    *
    * @param Map<Id, Lead> newItems
    */         
    public static void createMarketingSegmentationForLeads(Map<Id, Lead> newItems) {    
        List<Marketing_Segmentation__c> marketingSegToInsert = new List<Marketing_Segmentation__c>();

        for(Lead leads: newItems.values()){
                marketingSegToInsert.add(
                    new Marketing_Segmentation__c(
                        Lead__c = leads.Id
                    )
                );       
        }
        if(!marketingSegToInsert.IsEmpty()){
            MarketingSegmentationsDAO.newInstance().insertRecords(marketingSegToInsert, false, AccessLevel.SYSTEM_MODE);
        }
    }

}