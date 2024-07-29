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
      | mark.j.mahilum                 | Oct 25, 2023          | DEPP-6985              | Added SMS logic               |
      | mark.j.mahilum                 | Nov 11, 2023          | DEPP-7110              | Added logic to delete SMS     |
      |                                |                       |                        | completed tasks               |
      | mark.j.mahilum                 | April 01, 2024        | DEPP-8370              | Added checking for mobilephone|
      | mark.j.mahilum                 | April 08, 2024        | DEPP-8307              | Removed -1 days to duedate    |
 */
public with sharing class ActionCadenceStepTrackerTriggerHelper {

    private static final String DOMESTIC_AUTOMATED_CADENCE = 'Domestic Automated Cadence ';
    private static final String INTERNATIONAL_AUTOMATED_CADENCE = 'International Automated Cadence ';
    private static final String SMS_TYPE = 'SMS';
    private static final String EMAIL_TYPE = 'Email';
    private static final String NO_MOBILEPHONE_MSG = 'Contact or Lead does not have a valid mobile number';
    
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
                
                //get the completed tasks created by SMS Cadence Step
                List<Task> completedTaskList = TasksDAO.newInstance().getCompletedSMSTasksByActionCadenceStepTrackerId(new Set<String>(recordIds));
                if (!completedTaskList.isEmpty()) {
                    TasksDAO.newInstance().deleteRecords(completedTaskList, false, AccessLevel.SYSTEM_MODE);
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

        //SMS variables
        Map<String,SMS_Template__c> smsTemplateMap = getSMSTemplateMap();
        List<ActionCadenceStepTracker> smsActionCadenceStepTrackerList = new List<ActionCadenceStepTracker>();
        Set<Id> smsTargetIds = new Set<Id>();
        
        for(ActionCadenceStepTracker ac: stepTrackers){

            if(smsTemplateMap.containsKey(ac.StepTitle)){
                smsActionCadenceStepTrackerList.add(ac);
                smsTargetIds.add(ac.TargetId);
                continue;
            }

            if(ac.StepType =='SendAnEmail'){
                Id emailAddressId = resolveOrgWideEmailAddress(ac, orgWideEmailAddress);
                Date dueDate = ac.DueDateTime != NULL? Date.valueOf(ac.DueDateTime):Date.today(); 
                commsQueueToInsert.add(
                    new Communication_Queue__c(
                        ActionCadenceStepTrackerId__c = ac.Id,
                        Status__c = 'Scheduled',
                        Type__c = 'Email',
                        WhoId__c = ac.TargetId,
                        Template_Id__c = ac.ActionCadenceStep.TemplateId,
                        Due_Date__c = dueDate,
                        Sender__c = emailAddressId,
                        Business_Process__c = ((ac.ActionCadenceName.containsIgnoreCase('Domestic'))? DOMESTIC_AUTOMATED_CADENCE : INTERNATIONAL_AUTOMATED_CADENCE) + EMAIL_TYPE
                    )
                );
            }
        }

        //Add all SMS communicationQueue records
        if(!smsActionCadenceStepTrackerList.isEmpty()){
            commsQueueToInsert.addAll(
                createSMSCommunicationQueueRecords(smsActionCadenceStepTrackerList,smsTargetIds,smsTemplateMap)
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

    /**
     * retrieves active SMS Templates
     */
    private static Map<String,SMS_Template__c> getSMSTemplateMap(){
        Map<String,SMS_Template__c> smsTemplateMap = new Map<String,SMS_Template__c>();
        for(SMS_Template__c sms: SMSTemplatesDAO.newInstance().getActiveSMSTemplates(AccessLevel.SYSTEM_MODE)){
            smsTemplateMap.put(sms.Cadence_Step_Name__c,sms);
        }
        return smsTemplateMap;
    }

    /**
     * retrieves Mobile phones from contact or leads
     */
    private static Map<Id,String> getTargetMobilePhones(Set<Id> targetIds){
        Map<Id, Contact> contactMap = new Map<Id, Contact>(ContactsDAO.newInstance().getContactMobilePhoneByRecordIds(targetIds,AccessLevel.SYSTEM_MODE));
        Map<Id, Lead> leadMap = new Map<Id, Lead>(LeadsDAO.newInstance().getLeadMobilePhoneByRecordIds(targetIds,AccessLevel.SYSTEM_MODE));        
        Map<Id,String> targetMobilePhones = new Map<Id,String>();
        
        for(Id targetId: targetIds){
            if(contactMap.containsKey(targetId)){
                String mobilePhoneNumber = contactMap.get(targetId).MobilePhone;                
                //Trim the mobilePhoneNumber string to remove leading and trailing whitespace
                //check if max character for mobile number exceeded
                Boolean isExceeded = (mobilePhoneNumber.trim().length() > 13);
                if(!isExceeded){
                   targetMobilePhones.put(targetId,mobilePhoneNumber); 
                }
            }
            if(leadMap.containsKey(targetId)){
                String mobilePhoneNumber = leadMap.get(targetId).MobilePhone;                
                //Trim the mobilePhoneNumber string to remove leading and trailing whitespace
                //check if max character for mobile number exceeded
                Boolean isExceeded = (mobilePhoneNumber.trim().length() > 13);
                if(!isExceeded){
                    targetMobilePhones.put(targetId,mobilePhoneNumber); 
                }
            }
        }
        return targetMobilePhones;
    }

    /**
     * create SMS Communication Queue
     */
    private static List<Communication_Queue__c> createSMSCommunicationQueueRecords(List<ActionCadenceStepTracker> stepTrackers, Set<Id> smsTargetIds,Map<String,SMS_Template__c> smsTemplateMap){
        
        List<Communication_Queue__c> smsComsQueueList = new List<Communication_Queue__c>();
        Map<Id,String> targetMobilePhoneMap = getTargetMobilePhones(smsTargetIds);
        List<Task> createNoMobilePhoneTasks = new List<Task>();
        
        for(ActionCadenceStepTracker ac: stepTrackers){
            if(targetMobilePhoneMap.containsKey(ac.TargetId)){
                Communication_Queue__c comsQueue = createCommunicationQueueSMS(ac);
                comsQueue.Mobile__c = targetMobilePhoneMap.get(ac.TargetId);
                comsQueue.Message__c = smsTemplateMap.get(ac.StepTitle).Message_Content__c;
                comsQueue.Status__c = 'Scheduled';
                smsComsQueueList.add(comsQueue); 
            }else{
                createNoMobilePhoneTasks.add(createTaskRecords(ac));
                Communication_Queue__c comsQueue = createCommunicationQueueSMS(ac);
                comsQueue.Status__c = 'Failed';
                smsComsQueueList.add(comsQueue); 
            }            
        }
        
        createCompletedTask(createNoMobilePhoneTasks);        
        
        return smsComsQueueList;
    }

    /**
     * Insert Tasks for no mobile targetIds
     */
    private static void createCompletedTask(List<Task> taskRecords) {
        if(!taskRecords.isEmpty()){
            TasksDAO.newInstance().insertRecords(taskRecords,false,AccessLevel.SYSTEM_MODE);  
        }   
    }

    /**
     * create createCommunicationQueueSMS record mapping
     */
    private static Communication_Queue__c createCommunicationQueueSMS(ActionCadenceStepTracker ac){
        return new Communication_Queue__c(
            ActionCadenceStepTrackerId__c = ac.Id,            
            Type__c = SMS_TYPE,
            WhoId__c = ac.TargetId,
            Business_Process__c = ((ac.ActionCadenceName.containsIgnoreCase('Domestic'))? DOMESTIC_AUTOMATED_CADENCE : INTERNATIONAL_AUTOMATED_CADENCE) + SMS_TYPE
        );       
    }
    /**
     * create Tasks for no mobile targetIds
     */    
    private static Task createTaskRecords(ActionCadenceStepTracker ac) {       
        return new Task(
            Subject = NO_MOBILEPHONE_MSG,
            OwnerId = ac.ActionCadenceTracker.OwnerId,
            Status = 'Completed',
            WhoId = ac.TargetId,
            Description = NO_MOBILEPHONE_MSG
        );       
    }
}