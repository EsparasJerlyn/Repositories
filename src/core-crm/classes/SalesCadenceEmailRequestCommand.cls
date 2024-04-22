/**
 * @description Command Class for Email Request
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                    |
      |--------------------------------|-----------------------|------------------------|---------------------------------------------------|
      | eccarius.munoz                 | August 29, 2023       | DEPP-6138              | Created file                                      |
      | eccarius.munoz                 | September 18, 2023    | sit dep fix            | added handling for new email                      |
      |                                |                       |                        | templates (int and dom)                           |
      | eccarius.munoz                 | September 26, 2023    | DEPP-6741              | added handling for new emails                     |      
      | ken.marvin.narido              | October 12, 2023      | DEPP-6885              | added handling for null                           |
      |                                |                       |                        | whoIds' firstName                                 |
      | mark.j.mahilum                 | Oct 17, 2023          | DEPP-6926              | Added filter condition to stop email sending when |
      |                                |                       |                        | the maximum daily email count is reached          |
      |marygrace.li                    | Oct 24, 2023          | DEPP-7006              | set flag to false to turn-off header/footer banner|
 */
public with sharing class SalesCadenceEmailRequestCommand implements IRequestCommand{
    
    private List<Communication_Queue__c> communicationQueueList;

    public SalesCadenceEmailRequestCommand(List<Communication_Queue__c> communicationQueueList) {
        this.communicationQueueList = communicationQueueList;
    }      

    public void execute() {
        		
        if(stopSendingEmails() && !Test.isRunningTest()){
            Logger.info('Communication Queue Daily Maximum Email Count has been reached.');
            return;
        }
        
        Map<Id, Communication_Queue__c> commsQueueMap = new Map<Id, Communication_Queue__c>();
        Map<String, String> recipientMap = setEmailRecipientMap(communicationQueueList);
        Map<Id,EmailTemplate> emailTemplateMap = getEmailTemplateMap(communicationQueueList);

        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        for(Communication_Queue__c commsQueue : communicationQueueList){
            if(recipientMap.containsKey(commsQueue.WhoId__c)){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                if(emailTemplateMap.containsKey(commsQueue.Template_Id__c)){
                    email.setToAddresses(new List<String>{commsQueue.WhoId__c});
                    email.setSubject(emailTemplateMap.get(commsQueue.Template_Id__c).Subject);  
                        email.setHtmlBody(
                            EmailHelper.setBodyValues(
                                emailTemplateMap.get(commsQueue.Template_Id__c).HtmlValue, 
                                setupHTMLBodyParams(commsQueue, recipientMap), 
                                false 
                            )
                        );
                }
                email.setOrgWideEmailAddressId(commsQueue.Sender__c);
                email.setTargetObjectId(commsQueue.WhoId__c);
                emailList.add(email);
                commsQueueMap.put(commsQueue.WhoId__c, commsQueue);
            }
        }

        List<Messaging.SendEmailResult> sendResults = Messaging.sendEmail(emailList, false);
        List<Messaging.SendEmailError> errorResults = getErrorResults(sendResults);
        Set<Id> failedCommsQueueIds = getFailedResultWhoIDs(errorResults);
        
        List<Communication_Queue__c> commsQueueListToUpdate = setupCommunicationQueueListToUpdate(commsQueueMap.values(), failedCommsQueueIds);
        CommunicationQueuesDAO.newInstance().updateRecords(commsQueueListToUpdate, false, AccessLevel.SYSTEM_MODE);

    }    

    /**
     * setup email map for email address
     */
    private static Map<String, String> setEmailRecipientMap(List<Communication_Queue__c> communicationQueueList){
        Set<Id> whoIDset = new Set<Id>();
        for(Communication_Queue__c commsQueue : communicationQueueList){
            whoIDset.add(commsQueue.WhoId__c);
        }

        Map<String, String> emailMap = new Map<String, String>();
        for(Contact contact : getContactListByIdSet(whoIDset)){    
            Boolean isContactForProcessing = contact.Can_Nurture__c;
            if(!emailMap.containsKey(contact.Id) && isContactForProcessing && contact.Email != null){
                String recipientName = String.isNotBlank(contact.FirstName)
                                     ? contact.FirstName
                                     : contact.Name;
                emailMap.put(contact.Id, recipientName);
                if(contact.Lead_Source_Category__c =='Partner Sourced'){
                    emailMap.put(contact.Id + contact.Lead_Source_Category__c, contact.LeadSource);
                }
            }
        }

        for(Lead lead : getLeadListByIdSet(whoIDset)){
            Boolean isLeadForProcessing = lead.Can_Nurture__c;
            if(!emailMap.containsKey(lead.Id) && isLeadForProcessing){
                String recipientName = String.isNotBlank(lead.FirstName)
                                     ? lead.FirstName
                                     : lead.Name;
                emailMap.put(lead.Id, recipientName);
                if(lead.Lead_Source_Category__c =='Partner Sourced'){
                    emailMap.put(lead.Id + lead.Lead_Source_Category__c, lead.LeadSource);
                }
            }
        }

        return emailMap;
    }

    /**
     * retrieve contact list by who id set
     */
    private static List<Contact> getContactListByIdSet(Set<Id> whoIDset){
        List<String> fields = new List<String>{'Email', 'Name', 'FirstName', 'Can_Nurture__c', 'Calculated_Cadence__c', 'LeadSource','Lead_Source_Category__c'};
        List<Contact> contactList =  
            (List<Contact>) DynamicQueryService.getRecordsWithFieldsByIdSet(
                new DynamicQueryService.FilterWrapper(whoIDset, Contact.getSObjectType(), fields), 
                AccessLevel.SYSTEM_MODE
            );
        return contactList;
    }

    /**
     * retrieve lead list by who id set
     */
    private static List<Lead> getLeadListByIdSet(Set<Id> whoIDset){
        List<String> fields = new List<String>{'Email', 'Name', 'FirstName', 'Can_Nurture__c', 'Calculated_Cadence__c','LeadSource','Lead_Source_Category__c'};
        List<Lead> leadList =  
            (List<Lead>) DynamicQueryService.getRecordsWithFieldsByIdSet(
                new DynamicQueryService.FilterWrapper(whoIDset, Lead.getSObjectType(), fields), 
                AccessLevel.SYSTEM_MODE
            );
        return leadList;
    }

    /**
     * Sets the record status of communication queue list to update
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
     * Retrieves Max Retry from Communication Queue Config Metadata
     */
    private static Communication_Queue_Configuration__mdt getCommsQueueConfig(){
        Communication_Queue_Configuration__mdt commQueueMetadata;        
		commQueueMetadata = Communication_Queue_Configuration__mdt.getInstance('Sales_Cadence');
        return commQueueMetadata; 
    }

    /**
     * retrieve email template map by comms queue
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
     * retrieves email template to be used in email sending
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
     * retrieves list of failed email sending results
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
     * retrieves contact/lead ids of failed email sending results
     */
    private static Set<Id> getFailedResultWhoIDs(List<Messaging.SendEmailError> errorResults){
        Set<Id> failedCommsQueueIds = new Set<Id>();
        for(Messaging.SendEmailError err : errorResults) {
            failedCommsQueueIds.add(err.getTargetObjectId());
        }
        return failedCommsQueueIds;
    }

    /**
     * setup email params
     */
    private static Map<String, String> setupHTMLBodyParams(Communication_Queue__c commsQueue, Map<String, String> recipientMap){
        Map<String, String> bodyParams = new Map<String, String>();
        if(recipientMap.containsKey(commsQueue.WhoId__c)){
            bodyParams = new Map<String, String> {
                '{{{Recipient.FirstName}}}' => recipientMap.get(commsQueue.WhoId__c)
           };
           if(recipientMap.containsKey(commsQueue.WhoId__c +'Partner Sourced')){
               String leadSourceValue = recipientMap.get(commsQueue.WhoId__c +'Partner Sourced');
               bodyParams.put('{{{Recipient.LeadSource}}}',String.isNotBlank(leadSourceValue) ? leadSourceValue : ' ');
           }

        }
       return bodyParams;
    }
    
    /**
     * check limit for email sending
     */
    private static Boolean stopSendingEmails(){        
        Map<String,System.OrgLimit> limitsMap = OrgLimits.getMap();
        System.OrgLimit sendEmailLimit = limitsMap.get('SingleEmail');
       
        Set<String> processStatus = new Set<String>{CommunicationQueuesDAO.STATUS_SENT};
       	Integer recordCount = CommunicationQueuesDAO.newInstance().getCommsQueueRecordsByStatusAndLastModifiedToday(processStatus,AccessLevel.SYSTEM_MODE).size();
       
        return (getCommsQueueConfig().Maximum_Daily_Email_Count__c <= recordCount || sendEmailLimit.getValue() >= sendEmailLimit.getLimit());
    }    
    
}