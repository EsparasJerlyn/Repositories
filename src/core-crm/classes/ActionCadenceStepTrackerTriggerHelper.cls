/**
 * @description helper for ActionCadenceStepTrackerTrigger Object
 * @see ActionCadenceStepTrackerTrigger
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | mark.majilum                   | September 4,2023      | DEPP-6138              | Created file                 |
      | eccarius.munoz                 | September 4,2023      | DEPP-6138              | Added to trigger handler     |
 */
public with sharing class ActionCadenceStepTrackerTriggerHelper {
    
    public static void insertCommunicationQueue(List<ActionCadenceStepTrackerChangeEvent> newItems){

        List<String> recordIds = new List<String>();  
        for(ActionCadenceStepTrackerChangeEvent event : newItems) {
            EventBus.ChangeEventHeader header = event.ChangeEventHeader;
            recordIds = header.getRecordIds();
            if(recordIds.size() == 0) {
                continue;
            }       
        }
        
        if(!recordIds.isEmpty()){
            try{
                
                // Get ActionCadenceStepTracker records for send an email steps
                List<ActionCadenceStepTracker> stepTrackers = ActionCadenceStepTrackersDAO.newInstance().getActionCadenceStepTrackerForEmail(recordIds, AccessLevel.USER_MODE);
                List<Communication_Queue__c> insertCommunicationQueue = createCommunicationQueueRecords(stepTrackers);
                if(!insertCommunicationQueue.isEmpty()){
                    CommunicationQueuesDAO.newInstance().insertRecords(insertCommunicationQueue, false, AccessLevel.SYSTEM_MODE);
                }
                
            }catch(Exception e){
                Logger.error('Exception caught in method execute in Apex class ActionCadenceStepTrackerChangeEvent.').setExceptionDetails(e);
            } finally {
                if(Logger.getBufferSize() > 0) {
                    Logger.saveLog();
                }
            }  
        }
    }

    private static List<Communication_Queue__c> createCommunicationQueueRecords(List<ActionCadenceStepTracker> stepTrackers){
        List<Communication_Queue__c> insertCommunicationQueue = new List<Communication_Queue__c>();
        if(stepTrackers != null && stepTrackers.size() > 0) {
            OrgWideEmailAddress orgWideEmailAddress = getOrgWideEmailAddress();
            //logic to create Communication Queue record here            
            for(ActionCadenceStepTracker ac: stepTrackers){
                // map Communication_Queue__c for insert
                insertCommunicationQueue.add(
                    new Communication_Queue__c(
                        ActionCadenceStepTrackerId__c = ac.Id,
                        Status__c = 'Scheduled',
                        Type__c = 'Email',
                        WhoId__c = ac.TargetId,
                        Business_Process__c = (ac.ActionCadenceName.containsIgnoreCase('Domestic'))?'Domestic Automated Cadence Email':'International Automated Cadence Email',
                        Sender__c = orgWideEmailAddress?.Id,
                        Template_Id__c = ac.ActionCadenceStep.TemplateId
                    )
                );
            }
        }
        return insertCommunicationQueue;
    }

    /**
     * retrieves org wide email address to be used in email sending
     */
    private static OrgWideEmailAddress getOrgWideEmailAddress(){
        return OrgWideEmailAddressesDAO.newInstance().getOrgWideEmailAddressByDisplayName(OrgWideEmailAddressesDAO.ORG_WIDE_EMAIL_ADD_QUTEX, 'USER_MODE');
    }
}