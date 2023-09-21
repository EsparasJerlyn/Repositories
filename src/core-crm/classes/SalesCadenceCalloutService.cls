/**
 * @description Service Class for Sales Cadence API callout use in assigning and removing target to existing cadences
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                   |
 *    |--------------------------------|-----------------------|------------------------|--------------------------------------------------|
 *    | mark.j.mahilum                 | June 26, 2023         | DEPP-6107              | created file                                     |
 *    | roy.nino.s.regala              | Aug 09, 2023          | DEPP-5677              | made sendRequest public and add type checking    |
 *    | mark.j.mahilum                 | Aug 23, 2023          | DEPP-6215              | Updated createCompletedCaddence method           |
 *    |                                |                       |                        | added logic to get the unsuccessful task         |
 *    |                                |                       |                        | and update any existing completed cadence        |
 *    |                                |                       |                        | to succesful once the task is Contact Successful |
 *    | mark.j.mahilum                 | Sept 19,2023          | DEPP-6524              | Updated logic to include Follow-up call outcomes |
 */
public with sharing class SalesCadenceCalloutService {
    
    private static final String ASSIGN_TARGET_CADENCE_ENDPOINT = System.Label.SalesCadenceAssignTargetEndpoint;
    private static final String REMOVE_TARGET_CADENCE_ENDPOINT = System.Label.SalesCadenceRemoveTargetEndpoint;

    /**
     * @description Enqueues the Contact or Lead to Sales Cadence
     *
     * @param Map<String,String> assignCadenceMap
     * @param Map<String,String> removeCadenceMap
     */
     public static void processSaleCadences(Map<String,String> assignCadenceMap,Map<String,String> removeCadenceMap) {
         QueueableCall executeQueueable = new QueueableCall(assignCadenceMap,removeCadenceMap);
         System.enqueueJob(executeQueueable);
     }    
        
    /**
     * @description: Assign target to sales cadence
     *
     * @param Map<String,String> assignCadenceMap)
     */
     private static void assignTargetToCadence(Map<String,String> assignCadenceMap) {
        // Create an instance of the wrapper class
        SalesCadenceWrapper wrapper = new SalesCadenceWrapper();
        
        for(String key: assignCadenceMap.keySet()){
           wrapper.addInputData(assignCadenceMap.get(key), key,null);
        }
   
        if(!wrapper.inputs.isEmpty()){
            sendRequest(JSON.serialize(wrapper,true), ASSIGN_TARGET_CADENCE_ENDPOINT);            
        }
    }
    
    /**
     * @description: Remove target from sales cadences
     *
     * @param Map<String,String> removeCadenceMap
     */
    public static void removeTargetToCadence(Map<String,String> removeCadenceMap) {
        // Create an instance of the wrapper class
        SalesCadenceWrapper wrapper = new SalesCadenceWrapper();
        
        //remove all contact/lead that has a running Cadence
        Set<Id> idSet2 = new Set<Id>( (List<Id>)new List<String>( removeCadenceMap.keySet() ) );        
        Set<Id> targetIdRunningCadence = new Set<Id>();
        
        //get all contact/lead that has a running Cadence
        for (
            ActionCadenceTracker aCadenceTracker : ActionCadenceTrackersDAO.newInstance()
            .getRunningACTrackerByTargetIdAndCadenceName(
                idSet2,
                new Set<String>(removeCadenceMap.values()),
                'SYSTEM_MODE'
            )
        ) {
            targetIdRunningCadence.add(aCadenceTracker.TargetId);
        }
        
        for(String key: removeCadenceMap.keySet()){
            if(targetIdRunningCadence.contains(key)){
                wrapper.addInputData(null, key,'ManuallyRemoved');                                                   
            }
        }
        
        if(!wrapper.inputs.isEmpty()){
            sendRequest(JSON.serialize(wrapper,true),REMOVE_TARGET_CADENCE_ENDPOINT);
        }
    }
    
    /**
     * @description: Create completed cadence record
     *
     * @param Map<String,String> removeCadenceMap
     */ 
    public static void createCompletedCadence(Map<String,String> targetCadenceMap,Set<String> actionCadenceIds){
        
        //get the related nurture track config record of the targetIds
        Map<String,String> nurtureMap = getNurtureTrackConfigMap(new Set<String>(targetCadenceMap.values()));
        
		//get the task related to the actionCadence of the targetIds          
        Map<Id,Task> mapTasks = getRelatedTaskMap(targetCadenceMap.keySet(),actionCadenceIds);
		
        //get the unsuccessfull completed cadence of the targetIds and cadence name
        Map<String, String> completedCadenceStatusMap = getCompletedCadenceStatusMap(targetCadenceMap);
            
        List<Completed_Cadence__c> completedCadenceList = new List<Completed_Cadence__c>();
        
        for(String recId: targetCadenceMap.keySet()){
            
            String cadenceName = targetCadenceMap.get(recId);
            String nurtureId =  nurtureMap.get(cadenceName);          
            String calculatedStatus = 'Successful';
            
            if(mapTasks.containsKey(recId)){
                
                String taskCadenceName = mapTasks.get(recId).ActionCadenceStepTracker.ActionCadenceName;
                String taskStatus = mapTasks.get(recId).Status;
                
                if(taskCadenceName == cadenceName){
                    calculatedStatus = (taskStatus =='Closed - Follow Up')?taskStatus:'Unsuccessful';
                }               
            }
            
            if(recId.startsWith('003')){
                completedCadenceList.add(
                    new Completed_Cadence__c(
                        Nurture_Track_Configuration__c = nurtureId,
                        Contact__c = recId,
                        Completed_Cadence_Status__c = calculatedStatus,
                        Id = completedCadenceStatusMap.containsKey(recId)? completedCadenceStatusMap.get(recId): null              
                    )
                );   
            }else{
                completedCadenceList.add(
                    new Completed_Cadence__c(
                        Nurture_Track_Configuration__c = nurtureId,
                        Lead__c = recId,
                        Completed_Cadence_Status__c = calculatedStatus,
                        Id = completedCadenceStatusMap.containsKey(recId)? completedCadenceStatusMap.get(recId): null  
                    )
                );
            }
        }
        
        if(!completedCadenceList.isEmpty()){
            CompletedCadencesDAO.newInstance().upsertRecords(completedCadenceList, false, AccessLevel.SYSTEM_MODE); 
        }        
    }
    
    /**
     * @description: send API request from Sales Cadences endpoint
     *
     * @param String requestBody - the content of the request
     * @param String endpoint - the endpoint of the callout request
     */ 
    public static void sendRequest(String requestBody,String endpoint) {
        
        String salesCadenceEndpoint = URL.getSalesforceBaseUrl().toExternalForm() + endpoint;  
        
        HttpRequest httpReq = new HttpRequest();
        httpReq.setMethod('POST');
        httpReq.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());//NOPMD
        httpReq.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());//NOPMD
        httpReq.setEndpoint(salesCadenceEndpoint);
        httpReq.setHeader('Content-Type', 'application/json');
        httpReq.setBody(requestBody);        
        try{
            Http http = new Http();
            HttpResponse httpResponse = http.send(httpReq);
            if (httpResponse.getStatusCode() == 200) {
                handleBulkErrors(
                    'Exception caught in method sendRequest in class SalesCadenceCalloutService.',
                    (List<Object>) JSON.deserializeUntyped(httpResponse.getBody())
                );
            } else {
                throw new CalloutException(httpResponse.getBody());
            }
            
        }catch(Exception e){
            Logger.error('Exception caught in method execute in Apex class SalesCadenceCalloutService.').setExceptionDetails(e);
        } finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }      
    }
    
   /**
    * @description: Log individual API error encountered in SalesCadenceCallout
    *
    * @param String message
    * @param List<Object> objDataList
    */    
    private static void handleBulkErrors(String message, List<Object> objDataList) {
        boolean hasError = false;
        for (Object objData : objDataList) {
            Map<String, Object> data = (Map<String, Object>) objData;
            try {
                if (
                    data.containsKey('isSuccess') &&
                    data.get('isSuccess') == false &&
                    data.containsKey('errors')
                ) {
                    throw new CalloutException(JSON.serialize(data.get('errors')));
                }
            } catch (System.Exception e) {
                hasError = true;
                Logger.error(
                    message
                )
                    .setExceptionDetails(e);
            }
        }
    }
    
   /**
    * @description: Queueable local apex class that execute method into queuable callout
    *
    * @param Map<String,String> assignCadence
    * @param Map<String,String> removeCadence
    */
    private class QueueableCall implements Queueable, Database.AllowsCallouts{
        private Map<String,String> assignCadenceMap;
        private Map<String,String> removeCadenceMap;
        
        public QueueableCall(Map<String,String> assignCadence,Map<String,String> removeCadence) {
            this.assignCadenceMap = assignCadence;
            this.removeCadenceMap = removeCadence;
        }
        public void execute(QueueableContext context) {
            
            if(!assignCadenceMap.isEmpty()){
                assignTargetToCadence(assignCadenceMap);
            }
            if(!removeCadenceMap.isEmpty()){
                removeTargetToCadence(removeCadenceMap);
            } 
            
        }
    }

   /**
    * @description: Sales Cadences API request payload wrapper class
    */    
    public class InputData {
        public String salesCadenceNameOrId;
        public String targetId;
        public String userId;
        public String completionReasonCode;
        
        public InputData(String salesCadenceNameOrId, String targetId, String completionReasonCode) {
            this.salesCadenceNameOrId = salesCadenceNameOrId;
            this.targetId = targetId;
            this.completionReasonCode = completionReasonCode;
            this.userId = UserInfo.getUserId();
        }
    }
    
    public class SalesCadenceWrapper {
        public List<InputData> inputs;
        
        public SalesCadenceWrapper() {
            inputs = new List<InputData>();
        }
        
        public void addInputData(String salesCadenceNameOrId, String targetId, String completionReasonCode) {
            InputData inputData = new InputData(salesCadenceNameOrId, targetId,completionReasonCode);
            inputs.add(inputData);
        }
    }
    
   /**
    * @description: Method to get the related nurture track configuration of contact or lead
    *
    * @param Set<String> targetCadenceMap
    * @return Map<String,String> nurtureMap
    */
    public static Map<String,String> getNurtureTrackConfigMap(Set<String> targetCadenceMap){
        
        List<Nurture_Track_Configuration__c> nurtureList = NurtureTrackConfigurationsDAO.newInstance().getNurtureTrackByCadenceNames(targetCadenceMap,'SYSTEM_MODE');
        Map<String,String> nurtureMap = new Map<String,String>();
        
        for (Nurture_Track_Configuration__c rec: nurtureList) {   
            if(rec.Criteria_Type__c == 'Entry'){
                nurtureMap.put(rec.Cadence_Name__c,rec.Id); 
            }               
        }
        
        return nurtureMap;
    }
    
   /**
    * @description: Get the task related to the sales cadence activity
    *
    * @param Set<String> targetCadenceMap
    * @param Set<String> actionCadenceIds
    * @return Map<String,String> mapTasks
    */
    private static Map<Id,Task> getRelatedTaskMap(Set<String> targetCadenceMap,Set<String> actionCadenceIds){
        
        List<task> listTasks = TasksDAO.newInstance().getCompletedTasksByTargetId(targetCadenceMap,actionCadenceIds); 
        Map<Id,Task> mapTasks = new Map<Id,Task>();
        
        for(Task ts: listTasks){            
            mapTasks.put(ts.ActionCadenceStepTracker.TargetId,ts);
        }
        
        return mapTasks;
    }

   /**
    * @description: Get the Completed Cadence record associated with the targetIds
    *
    * @param Map<String,String> targetCadenceMap
    * @return Map<String, String> completedCadenceStatusMap
    */
    public static Map<String, String> getCompletedCadenceStatusMap(Map<String,String> targetCadenceMap){
        
        Map<String, String> completedCadenceStatusMap = new Map<String, String>();
        
        for (
            Completed_Cadence__c completedCadence : CompletedCadencesDAO.newInstance()
            .getCompletedCadenceByTargetIdsAndCadenceName(
                targetCadenceMap.keySet(),
                new Set<String>(targetCadenceMap.values()),
                'SYSTEM_MODE'
            )
        ) {
            completedCadenceStatusMap.put(
                completedCadence.Contact__c != null
                ? completedCadence.Contact__c
                : completedCadence.Lead__c,
                completedCadence.Id
            );
        }
        
        return completedCadenceStatusMap;
    }

   /**
    * @description: Get the Completed Cadence record associated with the targetIds
    *
    * @param Map<String,String> targetCadenceMap
    * @return Map<String, String> completedCadenceStatusMap
    */
    public static void processCompletedCadenceTracker(List<String> recordIds){
        
        Map<String,String> targetCadenceMap = new Map<String,String>();
        List<Contact> contacts = new List<Contact>();
        List<Lead> leads = new List<Lead>();
        Set<String> actionCadenceIds = new Set<String>();
        List<ActionCadenceTracker> actionCadencesTrackerList = ActionCadenceTrackersDAO.newInstance().getCompletedACTrackerById(new Set<String>(recordIds),'SYSTEM_MODE');
        
        // Get All the ActionCadenceTracker records for completed cadences
        for (ActionCadenceTracker act: actionCadencesTrackerList){
            
            String recId = act.TargetId;                   
            updateContactOrLead(recId,contacts,leads);
            targetCadenceMap.put(recId,act.ActionCadence.Name);
            actionCadenceIds.add(act.Id);                    
        }  
        
        createCompletedCadence(targetCadenceMap,actionCadenceIds);
        updateContactCalculatedCadence(contacts);
        updateLeadCalculatedCadence(leads);
        
    }

	/**
     * @description populate contact or lead object base on the recordId
     * 
     * @param String targetId
     * @param List<Contact> contactsToUpdate
     * @param List<Lead> leadsToUpdate
     */    
    private static void updateContactOrLead(String targetId, List<Contact> contactsToUpdate, List<Lead> leadsToUpdate) {      
        if (targetId.startsWith('003')) {
            contactsToUpdate.add(new Contact(Id = targetId, Calculated_Cadence__c = ''));
        } else {
            leadsToUpdate.add(new Lead(Id = targetId, Calculated_Cadence__c = ''));
        }
    } 
    
    /**
     * @description update contact calculated cadence to blank
     * 
     * @param List<Contact> contactRecords - contact records to update
     */
    private static void updateContactCalculatedCadence(List<Contact> contacts) {
        if(!contacts.isEmpty()){
            ContactsDAO.newInstance().updateRecords(contacts, false, AccessLevel.SYSTEM_MODE);
        }    
    }
    
    /**
     * @description update lead calculated cadence to blank
     * 
     * @param List<Lead> leadRecords - lead records to update
     */
    private static void updateLeadCalculatedCadence(List<Lead> leads) {
        if(!leads.isEmpty()){
            LeadsDAO.newInstance().updateRecords(leads, false, AccessLevel.SYSTEM_MODE);
        }   
    }
}