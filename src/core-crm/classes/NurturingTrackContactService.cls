/**
 * @description helper class for NurturingTrackContactService
 * @see NurturingTrackContactBatch
 *
 * @author Accenture-
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                   |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------------|
      | mark.j.mahilum                 | July 25, 2023         | DEPP-6105              | Created file                                     |
 */
public with sharing class NurturingTrackContactService {
    
    private static List<hed__Application__c>  applicationList;
    private static List<Case> caseList;
    private static Map<String,Nurture_Track_Configuration__c>  nurturingTrackMap = new Map<String,Nurture_Track_Configuration__c>();
    private static Map<Id,Contact>  domesticEntryContactMap = new Map<Id,Contact>();
    private static Map<Id,Contact>  domesticExitContactMap = new Map<Id,Contact>();
    private static Map<Id,Contact>  internationalEntryContactMap = new Map<Id,Contact>(); 
    private static Map<Id,Contact>  internationalExitContactMap = new Map<Id,Contact>();
       
   /**
    * @description: process All contacts for Entry and Exit in Cadences assignment
    *
    * @param void
    */          
    public static List<Contact> processContactForEntryAndExit( Map<Id, Contact> contactMap) {       
        
        Map<Id, Contact> contactToUpdate = new Map<Id, Contact>();

        //query all the related records required for each entry/exit criteria
        getAllRelatedRecords(contactMap);
        
       	//CALL YOUR ENTRY AND EXIT METHOD HERE PASS ONLY THE 
        
        //Contact entry criteria to process //SAMPLE METHOD ONLY
        //contactToUpdate.putAll(NurturingTrackService.getEntryDomesticStrongInterestPreApplication(domesticEntryContactMap));
                
        //Contact exit criteria to //SAMPLE METHOD ONLY
        //contactToUpdate.putAll(NurturingTrackService.getExitDomesticStrongInterestPreApplication(domesticExitContactMap));
        
        return contactToUpdate.values(); 
    }  
       
   /**
     * @description: Query all the required records needed for each entry and exit criteria
     *
     * @param Map<Id,Contact> mapOfContacts record to query
     */          
    private static void getAllRelatedRecords(Map<Id,Contact> mapOfContacts) {       
        applicationList = getApplicationRecords(mapOfContacts.keySet());
        getContactRecordCitizenship(mapOfContacts); 
        getNurturingTrackRecords();             
    }  
    
    /**
     * @description: separate the contact for international or domestic 
     *
     * @param Map<Id,Contact> mapOfContacts
     */    
    private static void getContactRecordCitizenship(Map<Id,Contact> mapOfContacts) {               
        
        for(Id key: mapOfContacts.KeySet()){
            
            Contact con = mapOfContacts.get(key);
            Boolean isContactDomestic = (con.hed__Citizenship_Status__c =='Domestic');
            
            if(String.isEmpty(con.Calculated_Cadence__c)){
                if(isContactDomestic){
                    domesticEntryContactMap.put(key,con);
                }else{
                    internationalEntryContactMap.put(key,con);
                }   
            }else{
                if(isContactDomestic){
                    domesticExitContactMap.put(key,con);
                }else{
                    internationalExitContactMap.put(key,con);
                }  
            }   
        }
    }    
    
    /**
     * @description: Checks existing application records of the contact
     *
     * @param Set<Id> contactIds to evaluate
     */
    private static List<hed__Application__c> getApplicationRecords(Set<Id> contactIds) {        
        List<hed__Application__c> existingApplicationList = ApplicationsDAO.newInstance().getApplicationsByContactIds(contactIds,'SYSTEM_MODE');         
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