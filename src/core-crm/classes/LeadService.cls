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
 */
public with sharing class LeadService {
 
   /**
    * @description update Lead Status base on the lead score for Learner Lead
    *
    * @param newItems  List of new Lead records
    * @param oldItems  Map of old Lead records
    */
    public static void updateLearnerLeadStatus(List<Lead> newItems, Map<Id, Lead> oldItems) {        
        for (Lead lead : newItems) {            
            if (String.isNotBlank(lead.Lead_Type__c) && lead.Lead_Type__c == 'Learner') {
                if (isLeadScoreNullOrUnderFifty(lead)) {
                    lead.Status = 'New';
                } else if (isLeadScoreInRange(lead, 50, 100)) {
                    lead.Status = 'Engaging';
                } else {
                    lead.Status = isLeadScoreGreaterThanOrEqual(lead, 100) ? 'Nurturing' : 'Qualified';
                }
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

}