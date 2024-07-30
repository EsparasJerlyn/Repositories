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
      | roy.nino.s.regala              | July 25, 2024         | DEPP-8551              | Updated SMS to MC Transactional Messaging API     |
 */
public with sharing class SalesCadenceSMSRequestCommand implements IRequestCommand{
    
    private List<Communication_Queue__c> communicationQueueList;
    private static final String SMS_SUBJECT = 'Nurture Track SMS';
    private static final String NO_ANSWER_SMS_SUBJECT = 'Service Appt No Answer SMS';

    public SalesCadenceSMSRequestCommand(List<Communication_Queue__c> communicationQueueList) {
        this.communicationQueueList = communicationQueueList;
    }      

    public void execute() {
        if (stopSendingSMS()) {
            Logger.info('SalesCadenceSMSRequest Stop SMS Sending ');
            return;
        }

        Set<Id> failedCommsQueueIds = new Set<Id>();
        Map<String, Id> messageKeyMap = new Map<String, Id>();
        String messageKey;

        List<MCTransactionalMessagingService.SMSRecipient> recipientList = new List<MCTransactionalMessagingService.SMSRecipient>();

        MCTransactionalMessagingService.Content content = new MCTransactionalMessagingService.Content(
            '%%message%%'
        );

        MCTransactionalMessagingService.SMSRequest requestPayload;

        Map<String, String> attributes;

        for (Communication_Queue__c commsQueue : communicationQueueList) {
            // create message key - Communication Queue Id + Retry Count
            messageKey =
                commsQueue.Id +
                (commsQueue.Retry_Count__c != null
                    ? String.valueOf(commsQueue.Retry_Count__c)
                    : '0');
            // create a map to relate Communication Queue and Message Key
            messageKeyMap.put(messageKey, commsQueue.Id);
            attributes = new Map<String, String>{ 'message' => commsQueue.Message__c };

            recipientList.add(
                new MCTransactionalMessagingService.SMSRecipient(
                    commsQueue.Mobile__c,
                    messageKey,
                    attributes
                )
            );
        }

        requestPayload = new MCTransactionalMessagingService.SMSRequest(
            'TestDefinitionKey', // MC Definition Key
            recipientList, 
            content
        );

        // bulk mc messaging
        MCTransactionalMessagingService.SMSResponse smsResponse = MCTransactionalMessagingService.sendBulkSMS(
            requestPayload
        );

        Logger.info(
            'MC Transactional API Request Payload :' + JSON.serializePretty(requestPayload)
        );

        Logger.info('MC Transactional API Response:' + JSON.serializePretty(smsResponse));

        Logger.saveLog();

        // if over all request failed
        if (smsResponse.responses.isEmpty()) {
            failedCommsQueueIds.addAll(messageKeyMap.values());
        }

        for (
            MCTransactionalMessagingService.SMSMessageResponse smsMessageResponse : smsResponse.responses
        ) {
            // if some of the messages failed
            if (
                smsMessageResponse.errorcode != null &&
                messageKeyMap.containsKey(smsMessageResponse.messageKey)
            ) {
                failedCommsQueueIds.add(messageKeyMap.get(smsMessageResponse.messageKey));
            }
        }

        List<Communication_Queue__c> commsQueueListToUpdate = setupCommunicationQueueListToUpdate(
            communicationQueueList,
            failedCommsQueueIds
        );

        CommunicationQueuesDAO.newInstance()
            .updateRecords(commsQueueListToUpdate, false, AccessLevel.SYSTEM_MODE);
            
        createTaskRecords(commsQueueListToUpdate);
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

   /**
    * create Tasks for SMS
    */    
    private static void createTaskRecords(List<Communication_Queue__c> commsQueueListToUpdate ) {
        
        List<Task> insertTaskRecords = new List<Task>();   
        Id userId = UserInfo.getUserId();
        String senderNumber = getCommsQueueConfig().SMS_Messaging_Channel__c;
        senderNumber = senderNumber?.replace('TEXT_AU_', '');  

        for(Communication_Queue__c commsQueue : commsQueueListToUpdate){    
            if(commsQueue.Status__c == 'Retry Scheduled') {
                continue;
            }
            if(commsQueue.Business_Process__c == CommunicationQueuesDAO.BUSINESS_PROCESS_DOMESTIC_NO_ANSWER_SMS) {
                insertTaskRecords.add(
                    new Task(
                        Subject = NO_ANSWER_SMS_SUBJECT,
                        OwnerId = userId,
                        SMS_Outcome__c = commsQueue.Status__c,
                        Status = 'Completed',
                        WhoId = commsQueue.WhoId__c,
                        RecordTypeId = TasksDAO.SMS_RECTYPE_ID,
                        Message_Content__c =  commsQueue.Message__c,
                        ActivityDate = System.today(),
                        Sender__c = senderNumber,
                        Receiver__c = commsQueue.Mobile__c,
                        Priority = 'Normal'
                    )
                );
            } else {
                insertTaskRecords.add(
                    new Task(
                        Subject = SMS_SUBJECT,
                        OwnerId = userId,
                        SMS_Outcome__c = commsQueue.Status__c,
                        Status = 'Completed',
                        WhoId = commsQueue.WhoId__c,
                        RecordTypeId = TasksDAO.SMS_RECTYPE_ID,
                        Message_Content__c =  commsQueue.Message__c,
                        ActivityDate = System.today(),
                        Sender__c = senderNumber,
                        Receiver__c = commsQueue.Mobile__c,
                        Priority = 'Normal'
                    )
                );
            }
        }
        
        if(!insertTaskRecords.isEmpty()){
            TasksDAO.newInstance().insertRecords(insertTaskRecords, false, AccessLevel.SYSTEM_MODE);  
        }
    }
}