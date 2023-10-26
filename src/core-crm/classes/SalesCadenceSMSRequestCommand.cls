/**
 * @description Command Class for SMS Request
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                    |
      |--------------------------------|-----------------------|------------------------|---------------------------------------------------|
      | mark.j.mahilum                 | October 25, 2023      | DEPP-6985              | Created file                                      |
 */
public with sharing class SalesCadenceSMSRequestCommand implements IRequestCommand{
    
    private List<Communication_Queue__c> communicationQueueList;

    public SalesCadenceSMSRequestCommand(List<Communication_Queue__c> communicationQueueList) {
        this.communicationQueueList = communicationQueueList;
    }      

    public void execute() {
        		
        if(stopSendingSMS()){
            Logger.info('SalesCadenceSMSRequest Stop SMS Sending ');
            return;
        }
        
        Set<Id> failedCommsQueueIds = new Set<Id>();
        
        for(Communication_Queue__c commsQueue : communicationQueueList){
            Map<String, Object> flowParameters = new Map<String, Object>();
            flowParameters.put('CommunicationQueueRecordId',commsQueue.Id);
            flowParameters.put('MessagingChannel',getCommsQueueConfig().SMS_Messaging_Channel__c);
            flowParameters.put('MobilePhoneNumber',commsQueue.Mobile__c);
            flowParameters.put('RecipientRecordID',commsQueue.WhoId__c);
            
            String flowResult = callFlow('Communication_Queue_Send_SMS',flowParameters);
            
            if(flowResult =='Success'){
                Logger.info('Sucess FlowResult ' + flowResult);
            }else{
                Logger.info('Failed FlowResult ' + flowResult);
                failedCommsQueueIds.add(commsQueue.Id);
            }
        }

        List<Communication_Queue__c> commsQueueListToUpdate = setupCommunicationQueueListToUpdate(communicationQueueList, failedCommsQueueIds);
        CommunicationQueuesDAO.newInstance().updateRecords(commsQueueListToUpdate, false, AccessLevel.SYSTEM_MODE);

    }    
    
    /**
     * Sets the record status of communication queue list to update
     */
    private static List<Communication_Queue__c> setupCommunicationQueueListToUpdate(List<Communication_Queue__c> commsQueueMapValues, Set<Id> failedCommsQueueIds){
        List<Communication_Queue__c> commsQueueListToUpdate = new List<Communication_Queue__c>();
        for(Communication_Queue__c commsQueue : commsQueueMapValues){
            commsQueue.Status__c = CommunicationQueuesDAO.STATUS_FAILED;

            if(!failedCommsQueueIds.contains(commsQueue.Id)){
                commsQueue.Status__c = CommunicationQueuesDAO.STATUS_SENT; 

            }else if(commsQueue.Retry_Count__c == null || commsQueue.Retry_Count__c < getCommsQueueConfig().SMS_Retry_Count__c){
                commsQueue.Retry_Count__c = commsQueue.Retry_Count__c == null ? 1 : commsQueue.Retry_Count__c + 1;
                commsQueue.Status__c = CommunicationQueuesDAO.STATUS_RETRY;

            }
            commsQueueListToUpdate.add(commsQueue);
        }
        return commsQueueListToUpdate;
    }

    /**
     * Retrieves Max Retry from Communication Queue Config Metadata
     */
    private static Communication_Queue_Configuration__mdt getCommsQueueConfig(){
        Communication_Queue_Configuration__mdt commQueueMetadata;        
		commQueueMetadata = Communication_Queue_Configuration__mdt.getInstance('Sales_Cadence');
        return commQueueMetadata; 
    }
    
    /**
     * call flow and get the return value
     */    
    private static String callFlow(String flowName, Map <String, Object> flowParameters) {
        if(Test.isRunningTest()){
            return '';
        }
		Flow.Interview smsFlow = Flow.Interview.createInterview(flowName, flowParameters);
        smsFlow.start();
        return (String) smsFlow?.getVariableValue('FlowResult');
    }
    
    /**
     * check if SMS needs to be stop sending
     */     
    private static Boolean stopSendingSMS() {        
        Integer startHour = (Integer) getCommsQueueConfig().SMS_Send_Hours_Start__c;
        Integer endHour = (Integer) getCommsQueueConfig().SMS_Send_Hours_End__c;
        Time currentTime = DateTime.now().time();
        Time startTime = Time.newInstance(startHour, 0, 0, 0);
        Time endTime = Time.newInstance(endHour, 0, 0, 0);
        
        if(Test.isRunningTest()){
            return false;
        }
        
        return getCommsQueueConfig().Supress_SMS__c || !(currentTime >= startTime && currentTime <= endTime);
    }
}