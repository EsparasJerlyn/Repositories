/**
 * @description Service Class for Sales Cadence API callout use in assigning and removing target to existing cadences
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                       |
 *    |--------------------------------|-----------------------|------------------------|----------------------------------------------------------------------|
 *    | mark.j.mahilum                 | June 26, 2023         | DEPP-6107              | created file                                                         |
 *    | roy.nino.s.regala              | Aug 09, 2023          | DEPP-5677              | made sendRequest public and add type checking                        |
 *    | mark.j.mahilum                 | Aug 23, 2023          | DEPP-6215              | Updated createCompletedCaddence method                               |
 *    |                                |                       |                        | added logic to get the unsuccessful task                             |
 *    |                                |                       |                        | and update any existing completed cadence                            |
 *    |                                |                       |                        | to succesful once the task is Contact Successful                     |
 *    | mark.j.mahilum                 | Sept 19,2023          | DEPP-6524              | Updated logic to include Follow-up call outcomes                     |
 *    | mark.j.mahilum                 | Sept 22, 2023         | DEPP-6488              | Added new method in completed Cadence creation                       |
 *    | mark.j.mahilum                 | Oct. 06, 2023         | DEPP-6856              | Added checking for running user                                      |
 *    | johanna.a.gibas                | Oct 16, 2023          | DEPP-6855              | Added Closed - Contacted in createCompletedCadence and               |
 *    |                                |                       |                        |     created updateTasks                                              |
 *    | johanna.a.gibas                | Oct 25, 2023          | DEPP-6889              | Updated createInitialCompletedCadences with                          |
 *    |                                |                       |                        |     Displayed in List View, and created                              |
 *    |                                |                       |                        |     updateCompletedCadences and getRunningCallACTrackersMap          |
 *    | roy.nino.s.regala              | Nov 1, 2023           | DEPP-7064              | updated logic to get the latest application                          |
 *    | johanna.a.gibas                | Nov 16, 2023          | DEPP-7118              | Replaced Closed - Contacted with Closed - No Further Action Required |
 *    | roy.nino.s.regala              | Jan 3, 2024           | Shutdown PMD Fix       | Fixed method complexity pmd issues                                   |
 *    | johanna.a.gibas                | Jan 15, 2024          | DEPP-7596              | Changed getCompletedCadenceStatusMap datatype to Completed_Cadence,  |
 *    |                                |                       |                        |   and added QTAC Offer Round in updateTasks                          |
 *    | mark.j.mahilum                 | April 08, 2024        | DEPP-8377              | Fixed callout issue and removed DML inside service callout           |
 *    | eugene.andrew.abuan            | August 05, 2024       | DEPP-8255              | Added counter to completed cadence and relate it to a task           |
 */
public with sharing class SalesCadenceCalloutService {//NOPMD this is a service class. high number of public methods and overall complexity are expected.
    
    private static final String ASSIGN_TARGET_CADENCE_ENDPOINT = System.Label.SalesCadenceAssignTargetEndpoint;
    private static final String REMOVE_TARGET_CADENCE_ENDPOINT = System.Label.SalesCadenceRemoveTargetEndpoint;
    private static final String UPDATE_TARGET_CADENCE_ENDPOINT = System.Label.SalesCadenceUpdateTargetEndpoint;

    /**
     * @description Enqueues the Contact or Lead to Sales Cadence
     *
     * @param Map<String,String> assignCadenceMap
     * @param Map<String,String> removeCadenceMap
     */
     public static void processSaleCadences(Map<String,String> assignCadenceMap,Map<String,String> removeCadenceMap) {
        Boolean isNotExecutedByAutomatedProcess = !UserInfo.getUserName().contains('autoproc');
        if(!assignCadenceMap.isEmpty() || (!removeCadenceMap.isEmpty() && isNotExecutedByAutomatedProcess)){
            QueueableCall executeQueueable = new QueueableCall(assignCadenceMap,removeCadenceMap);
            System.enqueueJob(executeQueueable);
        }
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
            if(assignCadenceMap.get(key).containsIgnoreCase('automated')){
                wrapper.addInputData(assignCadenceMap.get(key), key,null);  
            }
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
     * API call to complete cadence
     */
    public static void updateCadenceStepTracker(Set<Id> targetIds, String eventType){

        SendCadenceEventPayload payload = new SendCadenceEventPayload();
        
        for(String targetId: targetIds){
            payload.addSendCadenceEventPayInputs(targetId, eventType);
        }
   
        if(!payload.inputs.isEmpty()){
            sendRequest(JSON.serialize(payload, true), UPDATE_TARGET_CADENCE_ENDPOINT);            
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

        //get a map of string concatenated cadence names + targetIds from related cadence step tracker to a set of commsQueue ids
        //that use them. This is based on the ActionCadenceStepTracker__c field of the commsQueue record. Note that said field is not a lookup
        Map<String, Set<String>> trackerNameTargetToCommsQueueIdsMap = getTrackerNameTargetToCommsQueueIdsMap(targetCadenceMap.keySet());
        
        //get the unsuccessfull completed cadence of the targetIds and cadence name
        Map<String, Completed_Cadence__c> completedCadenceStatusMap = getCompletedCadenceStatusMap(targetCadenceMap);
        
        List<Task> tasksToUpdateList = new List<Task>();
        List<Completed_Cadence__c> completedCadenceList = new List<Completed_Cadence__c>();
        List<Communication_Queue__c> cancelledCommsQueues = new List<Communication_Queue__c>();
        
        for(String recId: targetCadenceMap.keySet()){

            if(!completedCadenceStatusMap.containsKey(recId)){
                continue;
            }
            
            String cadenceName = targetCadenceMap.get(recId);
            String nurtureId =  nurtureMap.get(cadenceName);          
            String calculatedStatus = CompletedCadencesDAO.SUCCESSFUL_STATUS;
            String taskCadenceName = '';
            String taskStatus = '';
            
            if(mapTasks.containsKey(recId)){
                taskCadenceName = mapTasks.get(recId).ActionCadenceStepTracker.ActionCadenceName;
                taskStatus = mapTasks.get(recId).Status;            
            }

            boolean hasTaskAndTaskCadenceMatch = mapTasks.containsKey(recId) && taskCadenceName == cadenceName;

            if(hasTaskAndTaskCadenceMatch){
                calculatedStatus = setCacluatedStatus(taskStatus);
                tasksToUpdateList.add(mapTasks.get(recId));
            }
            
            completedCadenceList.add(
                new Completed_Cadence__c(
                    Nurture_Track_Configuration__c = nurtureId,
                    Contact__c = recId.startsWith('003') ? recId : null,
                    Lead__c = recId.startsWith('00Q') ? recId : null,
                    Completed_Cadence_Status__c = calculatedStatus,
                    Id = completedCadenceStatusMap.get(recId).Id
                )
            );

            if(calculatedStatus == CompletedCadencesDAO.SUCCESSFUL_STATUS) {
                processCancelledCommsQueues(trackerNameTargetToCommsQueueIdsMap, cadenceName + recId, cancelledCommsQueues);
            }
        }
        
        if(!completedCadenceList.isEmpty()){
            CompletedCadencesDAO.newInstance().updateRecords(completedCadenceList, false, AccessLevel.SYSTEM_MODE); 
        }
        
        if(!cancelledCommsQueues.isEmpty()) {
            CommunicationQueuesDAO.newInstance().updateRecords(cancelledCommsQueues, false, AccessLevel.SYSTEM_MODE);
        }

        updateTasksSyncOrAsync(tasksToUpdateList, completedCadenceStatusMap);
    }

    private static Map<String, Set<String>> getTrackerNameTargetToCommsQueueIdsMap(Set<String> targetIdsSet) {
        Map<String, String> trackerMap = new Map<String, String>();
        for(ActionCadenceStepTracker tracker : ActionCadenceStepTrackersDAO.newInstance().getCadenceStepTrackersByTargetId(targetIdsSet, AccessLevel.SYSTEM_MODE)) {
            trackerMap.put(
                tracker.Id,
                tracker.ActionCadenceName + tracker.TargetId
            );
        }
        Map<String, Set<String>> trackerNameTargetToCommsQueueIdsMap = new Map<String, Set<String>>();
        for(Communication_Queue__c commsQueue : CommunicationQueuesDAO.newInstance().getFutureScheduledCommsQueuesByCadenceStepTrackerIds(
            trackerMap.keySet(),
            AccessLevel.SYSTEM_MODE
        )) {
            String trackerNameTarget = trackerMap.get(commsQueue.ActionCadenceStepTrackerId__c);
            Set<String> commsQueueIds = new Set<String>();
            if(trackerNameTargetToCommsQueueIdsMap.containsKey(trackerNameTarget)) {
                commsQueueIds = trackerNameTargetToCommsQueueIdsMap.get(trackerNameTarget);
            }
            commsQueueIds.add(commsQueue.Id);
            trackerNameTargetToCommsQueueIdsMap.put(trackerNameTarget, commsQueueIds);
        }
        return trackerNameTargetToCommsQueueIdsMap;
    }

    private static void processCancelledCommsQueues(
        Map<String, Set<String>> trackerNameTargetToCommsQueueIdsMap,
        String nameAndTarget,
        List<Communication_Queue__c> cancelledCommsQueues
    ) {
        if(trackerNameTargetToCommsQueueIdsMap.containsKey(nameAndTarget)) {
            for(String commsQueueId : trackerNameTargetToCommsQueueIdsMap.get(nameAndTarget)) {
                cancelledCommsQueues.add(
                    new Communication_Queue__c(
                        Id = commsQueueId,
                        Status__c = CommunicationQueuesDAO.STATUS_CANCELLED
                    )
                );
            }
        }
    }

    private static void updateTasksSyncOrAsync(
        List<Task> tasksToUpdateList, 
        Map<String, Completed_Cadence__c> completedCadenceStatusMap
    ) {
        if(System.isBatch() || System.isFuture() || System.isQueueable()) {
            //The process is running asynchronously
            updateTasks(tasksToUpdateList, completedCadenceStatusMap);
        } else {
            //The process is running synchronously
            QueueableCall executeQueueable = new QueueableCall(tasksToUpdateList, completedCadenceStatusMap);
            System.enqueueJob(executeQueueable);
        }
    }

    private static String setCacluatedStatus(String taskStatus){
        if(taskStatus == TasksDAO.CLOSED_FOLLOW_UP_STATUS){
            return taskStatus;
        }else if(taskStatus == TasksDAO.CLOSED_NO_FURTHER_ACTION_REQUIRED_STATUS){
            return CompletedCadencesDAO.SUCCESSFUL_STATUS;
        }else{
            return CompletedCadencesDAO.UNSUCCESSFUL_STATUS;
        }
    }
    /**
     * @description: Update tasks fields for reports
     *
     * @param List<Task> tasksToUpdateList
     */ 
    private static void updateTasks(
        List<Task> tasksToUpdateList, 
        Map<String, Completed_Cadence__c> completedCadenceStatusMap
    ) {
        Set<Id> completedCadenceIdSet = new Set<Id>();

        for (Task task : tasksToUpdateList) {

            Decimal completionDateInMs = task.ActionCadenceStepTracker.CompletionDate.getTime();
            Decimal CreatedDateInMs = task.ActionCadenceStepTracker.CreatedDate.getTime();
            Decimal diffInHours = (completionDateInMs - CreatedDateInMs)/3600000; //convert ms to h

            task.Time_to_Complete__c = diffInHours.setScale(1, RoundingMode.HALF_UP);
            task.Action_Cadence_Name__c = task.ActionCadenceStepTracker.ActionCadenceName;
            if(CompletedCadenceStatusMap.get(task.WhoId).Application__c != null){
                task.QTAC_Offer_Round__c = completedCadenceStatusMap.get(task.WhoId).Application__r.Related_QTAC_Application__r.QTAC_Offer_Round__c;
            }
            task.Completed_Cadence__c = completedCadenceStatusMap.get(task.WhoId).Id;
            
            if(!completedCadenceIdSet.contains(task.Completed_Cadence__c)){
                completedCadenceIdSet.add(task.Completed_Cadence__c);
            }
        }

        if (!tasksToUpdateList.isEmpty()) {

            TasksDAO.newInstance().updateRecords(tasksToUpdateList, false, AccessLevel.SYSTEM_MODE);
            countTaskForRelatedCadences(completedCadenceIdSet);
        }
    }

    /**
     * @description private method to count the tasks under the completed cadence
     * the counter will increment when the task is associated to a completed cadence record
     * @param completedCadenceIdSet Set Completed Cadence Ids
     * @return - void
     */
    private static void countTaskForRelatedCadences (Set<Id> completedCadenceIdSet){

        try{
            // Task is currently on System Mode since the Automated User can't have access to the custom field
            // Completed_Cadence__c is under in the Activity Object that is related to the task
            List<Task> tasksToUpdate = TasksDAO.newInstance().getTaskByCompeltedCadence(completedCadenceIdSet, AccessLevel.SYSTEM_MODE);
    
            List<Completed_Cadence__c> completedCadenceList = CompletedCadencesDAO.newInstance().getCompletedCadencebyRecordId (completedCadenceIdSet , AccessLevel.SYSTEM_MODE);
            
            Map<Id, Integer> taskCountMap = new Map<Id, Integer>();
    
            //Iterate each task that relates to the Completed Cadence
            for (Task task : tasksToUpdate) {
                if (!taskCountMap.containsKey(task.Completed_Cadence__c)) {
                    taskCountMap.put(task.Completed_Cadence__c, 0);
                }
                taskCountMap.put(task.Completed_Cadence__c, taskCountMap.get(task.Completed_Cadence__c) + 1);
            }
    
            // Update the value of the Cadence Task as per the counter
            for (Completed_Cadence__c completedCadence : completedCadenceList) {
    
                completedCadence.Cadence_Tasks__c = taskCountMap.containsKey(completedCadence.Id) ? taskCountMap.get(completedCadence.Id) : 0;
            }
    
            if(!completedCadenceList.isEmpty()){
                CompletedCadencesDAO.newInstance().updateRecords(completedCadenceList, false, AccessLevel.SYSTEM_MODE);
            }
    
        }catch(Exception e){
            Logger.error('Exception caught in method count in Apex class SalesCadenceCalloutService.').setExceptionDetails(e);
        }finally{
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
   
    }
    
    /**
     * @description: send API request from Sales Cadences endpoint
     *
     * @param String requestBody - the content of the request
     * @param String endpoint - the endpoint of the callout request
     */ 
    public static Boolean sendRequest(String requestBody,String endpoint) {
        
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
            return true;
        }catch(Exception e){
            Logger.error('Exception caught in method execute in Apex class SalesCadenceCalloutService.').setExceptionDetails(e);
        } finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
        
        return true;
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
        private Map<String,String> assignCadenceMap = new Map<String,String>();
        private Map<String,String> removeCadenceMap = new Map<String,String>();
        private List<Task> tasksToUpdateList = new List<Task>();
        private Map<String, Completed_Cadence__c> completedCadenceStatusMap = new Map<String,Completed_Cadence__c>();
        
        public QueueableCall(Map<String,String> assignCadence,Map<String,String> removeCadence) {
            this.assignCadenceMap = assignCadence;
            this.removeCadenceMap = removeCadence;
        }
        public QueueableCall(List<Task> tasksUpdateList,Map<String, Completed_Cadence__c> completedCadencesStatusMap) {
            this.tasksToUpdateList = tasksUpdateList;
            this.completedCadenceStatusMap = completedCadencesStatusMap;
        }
        
        public void execute(QueueableContext context) {
            
            if(!assignCadenceMap.isEmpty()){
                assignTargetToCadence(assignCadenceMap);
            }
            if(!removeCadenceMap.isEmpty()){
                removeTargetToCadence(removeCadenceMap);
            } 
            if(tasksToUpdateList !=null && !tasksToUpdateList.isEmpty()){
                updateTasks(tasksToUpdateList, completedCadenceStatusMap);  
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
    * @return Map<String, Completed_Cadence__c> completedCadenceStatusMap
    */
    public static Map<String, Completed_Cadence__c> getCompletedCadenceStatusMap(Map<String,String> targetCadenceMap){
        
        Map<String, Completed_Cadence__c> completedCadenceStatusMap = new Map<String, Completed_Cadence__c>();
        
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
                completedCadence
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

   /**
    * @description: create the initial completed cadence on cadences assignment
    *
    * @param Map<String,String> cadenceMap
    */ 
    public static void createInitialCompletedCadences(Map<String,String> targetCadenceMap){
        
        //get the related nurture track config record of the targetIds
        Map<String,String> nurtureMap = getNurtureTrackConfigMap(new Set<String>(targetCadenceMap.values()));        
        Map<String, Completed_Cadence__c> completedCadenceStatusMap = getCompletedCadenceStatusMap(targetCadenceMap);       
        List<Completed_Cadence__c> completedCadenceList = new List<Completed_Cadence__c>();
        
        Map<String,String> appMap = getContactOrLeadApplicationMap(targetCadenceMap.keySet());

        for(String recId: targetCadenceMap.keySet()){           
            
            if(completedCadenceStatusMap.containsKey(recId)){
                continue;
            }
            
            String cadenceName = targetCadenceMap.get(recId);
            String nurtureId =  nurtureMap.get(cadenceName);
            boolean displayInListView = cadenceName.contains('(Automated)') ? false : true ;
            String appId = appMap.containsKey(recId)? appMap.get(recId): null;
            
            if(recId.startsWith('003')){
                completedCadenceList.add(
                    new Completed_Cadence__c(
                        Nurture_Track_Configuration__c = nurtureId,
                        Contact__c = recId,
                        Application__c = appId,
                        Displayed_in_List_View__c = displayInListView 
                    )
                );   
            }else{
                completedCadenceList.add(
                    new Completed_Cadence__c(
                        Nurture_Track_Configuration__c = nurtureId,
                        Lead__c = recId,
                        Application__c = appId,
                        Displayed_in_List_View__c = displayInListView
                    )
                );
            }
        }
        
        if(!completedCadenceList.isEmpty()){
            CompletedCadencesDAO.newInstance().insertRecords(completedCadenceList, false, AccessLevel.SYSTEM_MODE); 
        }        
    }    

    private static Map<String, String> getContactOrLeadApplicationMap(Set<String> recordIdString) {

        Map<String, String> appMap = new Map<String, String>();
        Set<Id> recordIds = new Set<Id>( (List<Id>)new List<String>( recordIdString ) );

        if (recordIds.isEmpty()) {
            return appMap;
        }

        for (
            Lead record : LeadsDAO.newInstance().getLeadsByIdSet(recordIds, AccessLevel.SYSTEM_MODE)
        ) {
            appMap.put(record.Id, record.Cadence_Application__c);
        }

        for (
            Contact record : ContactsDAO.newInstance()
                .getPersonContactsBySetIds(recordIds, AccessLevel.SYSTEM_MODE)
        ) {
            appMap.put(record.Id, record.Cadence_Application__c);
        }

        return appMap;
    }
    
    /**
     * Wrapper class for Send Cadence Event Payload
     */
    public class SendCadenceEventPayload{
        public List<SendCadenceEventPayInputs> inputs;

        public SendCadenceEventPayload() {
            inputs = new List<SendCadenceEventPayInputs>();
        }

        public void addSendCadenceEventPayInputs(String recordId, String eventType){
            SendCadenceEventPayInputs sendCadenceEventPayInputs = new SendCadenceEventPayInputs(recordId, eventType);
            inputs.add(sendCadenceEventPayInputs);
        }
    }

    /**
     * Wrapper class for Send Cadence Event Payload Body
     */
    public class SendCadenceEventPayInputs{
        public String recordId;
        public String eventType;

        public SendCadenceEventPayInputs(String recordId, String eventType){
            this.recordId = recordId;
            this.eventType = eventType;
        }
    }

    public static void updateCompletedCadences(Map<String, String> targetIdCadenceMap) {
        List<Completed_Cadence__c> ccList = new List<Completed_Cadence__c>(CompletedCadencesDAO.newInstance()
        .getCompletedCadenceByTargetIdsAndCadenceName(
            targetIdCadenceMap.keySet(),
            new Set<String>(targetIdCadenceMap.values()),
            'SYSTEM_MODE'
        ));

        Map<String, String> actMap = getRunningCallACTrackersMap(targetIdCadenceMap);

        for (Completed_Cadence__c cc : ccList) {

            // check if the Completed Cadence is the current cadence the contact/lead is in
            Boolean isSameCalculatedCadence =
                cc.Calculated_Cadence__c == cc.Cadence_Name__c;
            // check if contact/lead has a Running Call ActionCadenceTracker
            Boolean isSameTarget = actMap.containsKey(
                cc.Contact__c != null ? cc.Contact__c : cc.Lead__c
            );
            // check if the Running Call ActionCadenceTracker is for the respective Completed Cadence
            Boolean isSameCadence =
                actMap.get(cc.Contact__c != null ? cc.Contact__c : cc.Lead__c) ==
                cc.Cadence_Name__c;

            // remove the Completed Cadence in the report if there is a Running Call ActionCadenceTracker for that cadence
            // add the Completed Cadnece in the report if the contact/lead was assigned to the cadence
            if (isSameCalculatedCadence) {
                if (isSameTarget && isSameCadence) {
                    cc.Displayed_in_List_View__c = false;
                } else {
                    cc.Displayed_in_List_View__c = true;
                }
            }
        }

        if (!ccList.isEmpty()) {
            CompletedCadencesDAO.newInstance()
                .updateRecords(ccList, false, AccessLevel.SYSTEM_MODE);
        }
    }

    // get Running Call ActionCadenceTrackers then map TargetId and Action Cadence Name
    private static Map<String, String> getRunningCallACTrackersMap(Map<String, String> targetIdCadenceMap) {
        Map<String, String> actMap = new Map<String, String>();
        for (
            ActionCadenceTracker act : ActionCadenceTrackersDAO.newInstance()
                .getRunningACTrackerByTargetIdAndCadenceName(new Set<Id>((List<Id>) new List<String>(targetIdCadenceMap.keySet())), new Set<String>(targetIdCadenceMap.values()), 'SYSTEM_MODE')
        ) {
            actMap.put(act.TargetId, act.ActionCadence.Name);
        }
        return actMap;
    }
	/**
     * @description Create completed cadence when the assignedCadenceMap has value
     *              Update completed cadence status when the removedCadenceMap has value
     * 
     * @param Map<String, String> assignedCadenceMap
     * @param Map<String, String> removedCadenceMap
     */    
    public static void updateCreateCompletedCadenceRecords(Map<String, String> assignedCadenceMap, Map<String, String> removedCadenceMap) {      
        
        if(!assignedCadenceMap.isEmpty()){
            //create initial completed completed cadence without status
            createInitialCompletedCadences(assignedCadenceMap); 
            updateCompletedCadences(assignedCadenceMap);
        }
        
        if(!removedCadenceMap.isEmpty()){
            Boolean isNotExecutedByAutomatedProcess = !UserInfo.getUserName().contains('autoproc');
            Map<String,String> manualRemoveCadenceMap = new Map<String,String>();
            
            for(String key: removedCadenceMap.keySet()){
                if(!removedCadenceMap.get(key).containsIgnoreCase('automated')){                   
                    manualRemoveCadenceMap.put(key,removedCadenceMap.get(key));
                }
            }
            
            if(!manualRemoveCadenceMap.isEmpty() && isNotExecutedByAutomatedProcess){
                createCompletedCadence(manualRemoveCadenceMap,null);   
            }                
        } 
    }
} 