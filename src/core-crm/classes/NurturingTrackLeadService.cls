/**
 * @description helper class for NurturingTrackLeadService
 * @see NurturingTrackLeadBatch
 *
 * @author Accenture-
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                   |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------------|
      | mark.j.mahilum                 | July 18, 2023         | DEPP-6105              | Created file                                     |
 */
public with sharing class NurturingTrackLeadService {
    
    private static List<hed__Application__c>  applicationList;
    private static List<Case> caseList;
    private static Map<String,Nurture_Track_Configuration__c>  nurturingTrackMap = new Map<String,Nurture_Track_Configuration__c>();
    private static Map<Id,Lead>  domesticEntryLeadMap = new Map<Id,Lead>();
    private static Map<Id,Lead>  domesticExitLeadMap = new Map<Id,Lead>();
    private static Map<Id,Lead>  internationalEntryLeadMap = new Map<Id,Lead>();
    private static Map<Id,Lead>  internationalExitLeadMap = new Map<Id,Lead>();
       
   /**
    * @description: process All leads for Entry and Exit in Cadences assignment
    *
    * @param void
    * @return List<Lead> return the list of lead to update
    */          
    public static List<Lead> processLeadForEntryAndExit( Map<Id, Lead> leadMap) {       
        
        Map<Id, Lead> leadToUpdate = new Map<Id, Lead>();

        //query all the related records required for each entry/exit criteria
        getAllRelatedRecords(leadMap);
        
       	//CALL YOUR ENTRY AND EXIT METHOD HERE PASS ONLY THE REQUIRED DATA e.g. (See below)
        
        //Lead entry criteria to process //SAMPLE METHOD ONLY
        //leadToUpdate.putAll(getEntryDomesticStrongInterestPreApplication(domesticEntryLeadMap));
                
        //Contact exit criteria to //SAMPLE METHOD ONLY
        //leadToUpdate.putAll(.getExitDomesticStrongInterestPreApplication(domesticExitLeadMap));
        
        return leadToUpdate.values(); 
    }  
       
   /**
     * @description: Query all the required records needed for each entry and exit criteria
     *
     * @param Map<Id,Lead> mapOfLeads record to query
     */          
    private static void getAllRelatedRecords(Map<Id,Lead> mapOfLeads) {       
        applicationList = getApplicationRecords(mapOfLeads.keySet());
        getNurturingTrackRecords();
    }  
    
    /**
     * @description: Checks existing application records of the contact
     *
     * @param Set<Id> leadIds to evaluate
     */
    private static List<hed__Application__c> getApplicationRecords(Set<Id> leadIds) {        
        List<hed__Application__c> existingApplicationList = ApplicationsDAO.newInstance().getApplicationsByLeadIds(leadIds,'SYSTEM_MODE');         
        return existingApplicationList;
    }    
    
   /**
    * @description: Get the nurturing Track Records and set the key to Cadence Name
    *
    */
    private static void getNurturingTrackRecords() {                      
        List<Nurture_Track_Configuration__c> nurtureList = NurtureTrackConfigurationsDAO.newInstance().getNurtureTrackLeadScoreThreshold('SYSTEM_MODE');
        for(Nurture_Track_Configuration__c nurture: nurtureList){
            nurturingTrackMap.put(nurture.Cadence_Name__c,nurture);               
        }     
    }
}