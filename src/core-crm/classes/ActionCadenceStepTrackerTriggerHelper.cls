/**
 * @description helper for ActionCadenceStepTrackerTrigger Object
 * @see ActionCadenceStepTrackerTrigger
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                |
      |--------------------------------|-----------------------|------------------------|-------------------------------|
      | mark.majilum                   | September 4,2023      | DEPP-6138              | Created file                  |
      | eccarius.munoz                 | September 4,2023      | DEPP-6138              | Added to trigger handler      |
      | eccarius.munoz                 | September 28, 2023    | DEPP-6763              | Updated handling of event     |
      |                                |                       |                        | listener to map all action    |
      |                                |                       |                        | cadence step tracker to C.Q.  |
      | mark.j.mahilum                 | Oct 05, 2023          | DEPP-6781              | Added field mapping to duedate|
 */
public with sharing class ActionCadenceStepTrackerTriggerHelper {
    
    public static void insertCommunicationQueue(List<ActionCadenceStepTrackerChangeEvent> newItems){
        
        List<String> recordIds = new List<String>();  
        for(ActionCadenceStepTrackerChangeEvent event : newItems) {
            EventBus.ChangeEventHeader header = event.ChangeEventHeader;
            
            recordIds.addAll(header.getRecordIds());
            if(recordIds.size() == 0) {
                continue;
            }       
        }

        if(!recordIds.isEmpty()){
            try{
                
                // Get ActionCadenceStepTracker records for send an email steps
                List<ActionCadenceStepTracker> stepTrackers = ActionCadenceStepTrackersDAO.newInstance().getActionCadenceStepTrackerForEmail(recordIds, AccessLevel.SYSTEM_MODE);
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

        Map<String, OrgWideEmailAddress>  orgWideEmailAddress = queryOrgWideEmailAddress();
        List<Communication_Queue__c> commsQueueToInsert = new List<Communication_Queue__c>();
        
        for(ActionCadenceStepTracker ac: stepTrackers){
            Id emailAddressId = resolveOrgWideEmailAddress(ac, orgWideEmailAddress);
            Date dueDate = ac.DueDateTime != NULL? Date.valueOf(ac.DueDateTime).addDays(-1):Date.today(); 
            commsQueueToInsert.add(
                new Communication_Queue__c(
                    ActionCadenceStepTrackerId__c = ac.Id,
                    Status__c = 'Scheduled',
                    Type__c = 'Email',
                    WhoId__c = ac.TargetId,
                    Template_Id__c = ac.ActionCadenceStep.TemplateId,
                    Due_Date__c = dueDate,
                    Sender__c = emailAddressId,
                    Business_Process__c = (ac.ActionCadenceName.containsIgnoreCase('Domestic'))?'Domestic Automated Cadence Email':'International Automated Cadence Email'
                )
            );
        }
        return commsQueueToInsert;
    }

    private static Id resolveOrgWideEmailAddress(ActionCadenceStepTracker actionCadenceStepTracker, Map<String, OrgWideEmailAddress> orgWideEmailAddressMap){
        Id orgWideEmailId;
        String displayName = '';

        if(actionCadenceStepTracker.ActionCadenceName.containsIgnoreCase('Domestic')){
            displayName = OrgWideEmailAddressesDAO.ORG_WIDE_EMAIL_DOMESTIC_FUTURE_STUDENT_ENQUIRIES;
        }
        else if(actionCadenceStepTracker.ActionCadenceName.containsIgnoreCase('International')){
            displayName = OrgWideEmailAddressesDAO.ORG_WIDE_EMAIL_INTERNATIONAL_FUTURE_STUDENT_ENQUIRIES;
        }

        if(orgWideEmailAddressMap.containsKey(displayName)){
            orgWideEmailId = orgWideEmailAddressMap.get(displayName).Id;
        }
        else{
            orgWideEmailId = orgWideEmailAddressMap.get(OrgWideEmailAddressesDAO.ORG_WIDE_EMAIL_NO_REPLY).Id;
        }
        
        return orgWideEmailId;
    }

    /**
     * retrieves org wide email address to be used in email sending
     */
    private static Map<String, OrgWideEmailAddress> queryOrgWideEmailAddress(){
        Map<String, OrgWideEmailAddress> orgWideEmailMap = new Map<String, OrgWideEmailAddress>();
        Set<String> orgWideDisplayName = new Set<String>{OrgWideEmailAddressesDAO.ORG_WIDE_EMAIL_DOMESTIC_FUTURE_STUDENT_ENQUIRIES,
                                                            OrgWideEmailAddressesDAO.ORG_WIDE_EMAIL_INTERNATIONAL_FUTURE_STUDENT_ENQUIRIES,
                                                            OrgWideEmailAddressesDAO.ORG_WIDE_EMAIL_NO_REPLY};

        for(OrgWideEmailAddress orgWideEmailAddress : OrgWideEmailAddressesDAO.newInstance().getOrgWideEmailAddressByDisplayName(orgWideDisplayName, AccessLevel.USER_MODE)){
            orgWideEmailMap.put(orgWideEmailAddress.DisplayName, orgWideEmailAddress);
        }

        return orgWideEmailMap;
    }

}