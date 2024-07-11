/**
 * @description Command Class for Communication Queue Email Request
 * CommunicationQueueEmailRequestCommand
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                    |
      |--------------------------------|-----------------------|------------------------|---------------------------------------------------|
      | mark.j.mahilum                 | May 16, 2024          | DEPP-8766              | Created file                                      |
 */
public with sharing class CommunicationQueueEmailRequestCommand implements IRequestCommand{
    
    private List<Communication_Queue__c> communicationQueueList;
	
    //constructor 
    public CommunicationQueueEmailRequestCommand(List<Communication_Queue__c> communicationQueueList) {
        this.communicationQueueList = communicationQueueList;
    }
    
   /**
    * @description main method to execute the email sending from communication queue list
    */
    public void execute() {
        		
        if(stopSendingEmails() && !Test.isRunningTest()){
            Logger.info('Communication Queue Daily Maximum Email Count has been reached.');
            return;
        }
        
        List<Communication_Queue__c> updateCommsQueue = new List<Communication_Queue__c>();
        Map<Id, SObject> recipientMap = setEmailRecipientMap(communicationQueueList);
        Map<Id,EmailTemplate> emailTemplateMap = getEmailTemplateMap(communicationQueueList);

        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        for(Communication_Queue__c commsQueue : communicationQueueList){
            if(recipientMap.containsKey(commsQueue.WhoId__c)){
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                
                if(emailTemplateMap.containsKey(commsQueue.Template_Id__c)){
                    email.setToAddresses(getCommunicationEndpointValues(recipientMap,commsQueue)); 
                    email.setTemplateId(commsQueue.Template_Id__c);
                }
                email.setOrgWideEmailAddressId(commsQueue.Sender__c);
                email.setTargetObjectId(commsQueue.WhoId__c);
                if(String.isNotBlank(commsQueue.WhatId__c)){
                    email.setWhatId(commsQueue.WhatId__c);
                    email.setTreatTargetObjectAsRecipient(false);
                    email.setSaveAsActivity(true);
                }
                
                emailList.add(email);                
                updateCommsQueue.add(commsQueue);
            }
        }

        List<Messaging.SendEmailResult> sendResults = Messaging.sendEmail(emailList, false);
        List<Messaging.SendEmailError> errorResults = getErrorResults(sendResults);
        Set<Id> failedCommsQueueIds = getFailedResultWhoIDs(errorResults);
        
        List<Communication_Queue__c> commsQueueListToUpdate = setupCommunicationQueueListToUpdate(updateCommsQueue, failedCommsQueueIds);
        CommunicationQueuesDAO.newInstance().updateRecords(commsQueueListToUpdate, false, AccessLevel.SYSTEM_MODE);

    }
    
   /*
    * @param key String representation of the field name to use as the Key.
    * This must be of type Id for this method.
    * @param incomingList Any list of objects that can be cast to a list of
    * sObjects
    * @return            `Map<Id, sObject>`
    */
    private static Map<Id, SObject> idMapFromCollectionByKey(
        String key,
        List<SObject> incomingList
    ) {
        String objType = getSobjectTypeFromList(incomingList);
        Type dynamicMapType = Type.forName('Map<Id,' + objType + '>');
        Map<Id, SObject> returnValues = (Map<Id, SObject>) dynamicMapType.newInstance();
        for (SObject current : incomingList) {
            if (current.get(key) != null) {
                returnValues.put((Id) current.get(key), current);
            }
        }
        return returnValues;
    }
    
   /**
    * @description get the sObject type from the given List<SObject>
    * @param incomingList Any list of objects that can be cast to a list of
    * @return string of sObject type
    */
    private static String getSobjectTypeFromList(List<SObject> incomingList) {
        return (!incomingList.isEmpty())
            ? String.valueOf(incomingList[0]?.getSObjectType())
            : 'sObject';
    }  
    
   /**
    * @description setup mapping of email recipient based on the Communication Endpoint value
    * @param Communication_Queue__c commsQueue communication queue record to set
    * @param Map<Id, SObject> recipientMap contact or lead record map
    * @return List<String> list of email or Ids from contact or lead
    */
    private List<String> getCommunicationEndpointValues(Map<Id, SObject> recipientMap, Communication_Queue__c commsQueue) {
        // Define the communication endpoint map
        Map<String, String> communicationEndpointMap = new Map<String, String>{
            'WhoId' => 'Id',
            'Contact.Email' => 'Email',
            'Contact.QUT_Staff_Email__c' => 'QUT_Staff_Email__c',
            'Contact.QUT_Learner_Email__c' => 'QUT_Learner_Email__c',
            'Contact.Work_Email__c' => 'Work_Email__c',
            'Lead.Email' => 'Email',
            'Lead.Work_Email__c' => 'Work_Email__c'
        };
    
        // Get the recipient's Id from the commsQueue
        Id recipientId = commsQueue.WhoId__c;
        
        // Check if the recipientMap contains the recipientId
        if (recipientMap.containsKey(recipientId)) {
            SObject recipient = recipientMap.get(recipientId);
            Schema.SObjectType recipientType = recipient.getSObjectType();
            String keyField = communicationEndpointMap.get(commsQueue.Communication_Endpoint__c);
    
            // Handle Contact recipient
            if (recipientType == Contact.getSObjectType()) {
                Contact contact = (Contact) recipient;
                String fieldValue = (String) contact.get(keyField);
                return new List<String>{fieldValue};
            }
    
            // Handle Lead recipient
            if (recipientType == Lead.getSObjectType()) {
                Lead lead = (Lead) recipient;
                String fieldValue = (String) lead.get(keyField);
                return new List<String>{fieldValue};
            }
        }
    
        // Return an empty list if no recipient found or no match
        return new List<String>();
    }

    
   /**
    * @description setup the contact or lead to send the email as a recipient
    * @param List<Communication_Queue__c> communicationQueueList communication queue records to process
    * @return Map<Id, SObject> recipientMap a map of contact or lead records
    */
    private static Map<Id, SObject> setEmailRecipientMap(List<Communication_Queue__c> communicationQueueList){
        
        Map<Id, SObject> recipientMap = new Map<Id, SObject>();
       
        Set<Id> whoIDset = new Set<Id>();
        for(Communication_Queue__c commsQueue : communicationQueueList){
            whoIDset.add(commsQueue.WhoId__c);
        }
        
        List<Contact> contacts = getContactListByIdSet(whoIDset);
        if(!contacts.isEmpty()){
            recipientMap.putAll(idMapFromCollectionByKey('id',contacts));
        }
        
        List<Lead> leads = getLeadListByIdSet(whoIDset);
               
        if(!leads.isEmpty()){
            recipientMap.putAll(idMapFromCollectionByKey('id',leads));
        }

        return recipientMap;
    }

   /**
    * @description retrieve contact records from whoIds
    * @param Set<Id> whoIDSet contact Ids from the communication queue list
    * @return List<Contact> return all the contact record from the whoIds
    */
    private static List<Contact> getContactListByIdSet(Set<Id> whoIDset){
        List<String> fields = new List<String>{'Email', 'Name', 'FirstName', 'QUT_Staff_Email__c', 'QUT_Learner_Email__c', 'Work_Email__c'};
        List<Contact> contactList =  
            (List<Contact>) DynamicQueryService.getRecordsWithFieldsByIdSet(
                new DynamicQueryService.FilterWrapper(whoIDset, Contact.getSObjectType(), fields), 
                AccessLevel.SYSTEM_MODE
            );
        return contactList;
    }

   /**
    * @description retrieve lead records from whoIds
    * @param Set<Id> whoIDSet lead Ids from the communication queue list
    * @return List<Lead> return all the lead record from the whoIds
    */
    private static List<Lead> getLeadListByIdSet(Set<Id> whoIDset){
        List<String> fields = new List<String>{'Email', 'Name', 'FirstName', 'Work_Email__c'};
        List<Lead> leadList =  
            (List<Lead>) DynamicQueryService.getRecordsWithFieldsByIdSet(
                new DynamicQueryService.FilterWrapper(whoIDset, Lead.getSObjectType(), fields), 
                AccessLevel.SYSTEM_MODE
            );
        return leadList;
    }

   /**
    * @description Sets the record status of communication queue list to updates
    * @param List<Communication_Queue__c> commsQueueList record to update the status if email is success or not
    * @param Set<Id> failedCommsQueueIds list of targetIds that fails to send the email
    * @return List<Communication_Queue__c> list of communication queue to update the status
    */
    private static List<Communication_Queue__c> setupCommunicationQueueListToUpdate(List<Communication_Queue__c> commsQueueMapValues, Set<Id> failedCommsQueueIds){
        List<Communication_Queue__c> commsQueueListToUpdate = new List<Communication_Queue__c>();
        for(Communication_Queue__c commsQueue : commsQueueMapValues){
            commsQueue.Status__c = CommunicationQueuesDAO.STATUS_FAILED;

            if(!failedCommsQueueIds.contains(commsQueue.WhoId__c)){
                commsQueue.Status__c = CommunicationQueuesDAO.STATUS_SENT; 

            }else if(commsQueue.Retry_Count__c == null || commsQueue.Retry_Count__c < getCommsQueueConfig().Maximum_Retry_Count__c){
                commsQueue.Retry_Count__c = commsQueue.Retry_Count__c == null ? 1 : commsQueue.Retry_Count__c + 1;
                commsQueue.Status__c = CommunicationQueuesDAO.STATUS_RETRY;

            }
            commsQueueListToUpdate.add(commsQueue);
        }
        return commsQueueListToUpdate;
    }

   /**
    * @description Retrieves the Custom Metadata Configuration record
    * @return Communication_Queue_Configuration__mdt commQueueMetadata configuration record
    */
    private static Communication_Queue_Configuration__mdt getCommsQueueConfig(){
        Communication_Queue_Configuration__mdt commQueueMetadata;        
		commQueueMetadata = Communication_Queue_Configuration__mdt.getInstance('Communication_Queue');
        return commQueueMetadata; 
    }

   /**
    * @description get the available email template from the communication queue email template Id
    * @param List<Communication_Queue__c> commsQueueList record to get the email template Id
    * @return Map<Id,EmailTemplate> emailTemplateMap the avaible email template from the given templateId
    */
    private static Map<Id,EmailTemplate> getEmailTemplateMap(List<Communication_Queue__c> communicationQueueList){
        
        Set<Id> emailTemplateIdSet = new Set<Id>();
        for(Communication_Queue__c commsQueue : communicationQueueList){
            emailTemplateIdSet.add(commsQueue.Template_Id__c);
        }

        Map<Id,EmailTemplate> emailTemplateMap = new Map<Id,EmailTemplate>();
        for(EmailTemplate emailTemplate : getEmailTemplates(emailTemplateIdSet)){
            emailTemplateMap.put(emailTemplate.Id, emailTemplate);
        }

        return emailTemplateMap;
    }

   /**
    * @description retrieves email template to be used in email sending
    * @param Set<Id> emailTemplateIdSet unique Email template Id set
    * @return List<EmailTemplate> emailTemplateList the evailable email template record from the set of Ids
    */
    private static List<EmailTemplate> getEmailTemplates(Set<Id> emailTemplateIdSet){
        List<String> fields = new List<String>{'Name, Subject, HtmlValue, Body'};
        List<EmailTemplate> emailTemplateList =  
            (List<EmailTemplate>) DynamicQueryService.getRecordsWithFieldsByIdSet(
                new DynamicQueryService.FilterWrapper(emailTemplateIdSet, EmailTemplate.getSObjectType(), fields), 
                AccessLevel.SYSTEM_MODE
            );
        return emailTemplateList;
    }

   /**
    * @description retrieves list of failed email sending results
    * @param List<Messaging.SendEmailResult> sendResults the result of email sending 
    * @return List<Messaging.SendEmailError> errorResults encountered error result from email sending
    */
    private static List<Messaging.SendEmailError> getErrorResults(List<Messaging.SendEmailResult> sendResults){
        List<Messaging.SendEmailError> errorResults = new List<Messaging.SendEmailError>();
        for (Messaging.SendEmailResult result : sendResults) {
            if (!result.isSuccess()) {
                errorResults = result.getErrors();
            } 
        }
        return errorResults;
    }

   /**
    * @description retrieves the list of targetIds who encountered an error
    * @param List<Messaging.SendEmailError> errorResults
    * @return Set<Id> failedCommsQueueIds the id's of contact or lead that encountered an error
    */
    private static Set<Id> getFailedResultWhoIDs(List<Messaging.SendEmailError> errorResults){
        Set<Id> failedCommsQueueIds = new Set<Id>();
        for(Messaging.SendEmailError err : errorResults) {
            failedCommsQueueIds.add(err.getTargetObjectId());
        }
        return failedCommsQueueIds;
    }
    
   /**
    * @description method to check if the singleEmail has reach the limit of configured limit or
    *              the daily limit of email sending
    * @return boolean stopSendingEmail flag use to stop email sending when the limit is reach
    */
    private static Boolean stopSendingEmails(){        
        Map<String,System.OrgLimit> limitsMap = OrgLimits.getMap();
        System.OrgLimit sendEmailLimit = limitsMap.get('SingleEmail');
       
        Set<String> processStatus = new Set<String>{CommunicationQueuesDAO.STATUS_SENT};
       	Integer recordCount = CommunicationQueuesDAO.newInstance().getCommsQueueRecordsByStatusAndLastModifiedToday(processStatus,AccessLevel.SYSTEM_MODE).size();
       
        return (getCommsQueueConfig().Maximum_Daily_Email_Count__c <= recordCount || sendEmailLimit.getValue() >= sendEmailLimit.getLimit());
    } 
}