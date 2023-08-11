
/**
 * @description Service Class for Sales Cadence API callout use in assigning and removing target to existing cadences
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                               |
 *    |--------------------------------|-----------------------|------------------------|----------------------------------------------|
 *    | mark.j.mahilum                 | June 26, 2023         | DEPP-6107              | created file                                 |
 *    | roy.nino.s.regala              | Aug 09, 2023          | DEPP-5677              | made sendRequest public and add type checking|
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
        String requestBody = '';
        
        for(String key: assignCadenceMap.keySet()){
           wrapper.addInputData(assignCadenceMap.get(key), key,null);
        }
        
        requestBody = JSON.serialize(wrapper,true);
        
        if(requestBody !=''){
            sendRequest(requestBody, ASSIGN_TARGET_CADENCE_ENDPOINT);            
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
        String requestBody = '';
        
        for(String key: removeCadenceMap.keySet()){
            wrapper.addInputData(null, key,'ManuallyRemoved');                                     
        }
             
        requestBody = JSON.serialize(wrapper,true);
        
        if(requestBody !=''){
            sendRequest(requestBody,REMOVE_TARGET_CADENCE_ENDPOINT);
			createCompletedCadence(removeCadenceMap);            
        }
    }
    
    /**
     * @description: Create completed cadence record
     *
     * @param Map<String,String> removeCadenceMap
     */ 
    private static void createCompletedCadence(Map<String,String> removeCadenceMap){
        List<Nurture_Track_Configuration__c> nurtureList = NurtureTrackConfigurationsDAO.newInstance().getNurtureTrackByCadenceNames(new Set<String>(removeCadenceMap.values()),'SYSTEM_MODE');
        Map<String,String> nurtureMap = new Map<String,String>();
        List<Completed_Cadence__c> completedCadenceList = new List<Completed_Cadence__c>();
        
        for (Nurture_Track_Configuration__c rec: nurtureList) {   
            if(rec.Criteria_Type__c == 'Entry'){
                nurtureMap.put(rec.Cadence_Name__c,rec.Id); 
            }               
        }
                
        for(String recId: removeCadenceMap.keySet()){           
            String cadenceName = removeCadenceMap.get(recId);
            String nurtureId =  nurtureMap.get(cadenceName);
            
            if(recId.startsWith('003')){
                completedCadenceList.add(
                    new Completed_Cadence__c(
                        Nurture_Track_Configuration__c = nurtureId,
                        Contact__c = recId
                    )
                );   
            }else{
                completedCadenceList.add(
                    new Completed_Cadence__c(
                        Nurture_Track_Configuration__c = nurtureId,
                        Lead__c = recId
                    )
                );
            }
        }
        
        if(!completedCadenceList.isEmpty()){
            CompletedCadencesDAO.newInstance().insertRecords(completedCadenceList, false, AccessLevel.SYSTEM_MODE); 
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

}
