/**
 * @description Command Class for Email Request
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | August 29, 2023       | DEPP-6138              | Created file                 |
      | eccarius.munoz                 | September 18, 2023    | sit dep fix            | added handling for new email |
      |                                |                       |                        | templates (int and dom)      |
      |                                |                       |                        |                              |
 */
public with sharing class SalesCadenceEmailRequestCommand implements IRequestCommand{
    
    private List<Communication_Queue__c> communicationQueueList;

    public SalesCadenceEmailRequestCommand(List<Communication_Queue__c> communicationQueueList) {
        this.communicationQueueList = communicationQueueList;
    }      

    public void execute() {

        Map<Id, Communication_Queue__c> commsQueueMap = new Map<Id, Communication_Queue__c>();
        Map<String, String> recipientMap = setEmailRecipientMap(communicationQueueList);
        EmailTemplate emailTemplateDom = getEmailTemplate(EmailTemplatesDAO.TEMPLATE_NURTURE_MANAGEMENT_DOM);
        EmailTemplate emailTemplateInt = getEmailTemplate(EmailTemplatesDAO.TEMPLATE_NURTURE_MANAGEMENT_INT);

        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        for(Communication_Queue__c commsQueue : communicationQueueList){
            if(recipientMap.containsKey(commsQueue.WhoId__c)){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new List<String>(recipientMap.keySet()));
                if(commsQueue.Business_Process__c == 'Domestic Automated Cadence Email'){
                    email.setSubject(emailTemplateDom.Subject);  
                    email.setHtmlBody(
                        EmailHelper.setBodyValues(
                            emailTemplateDom.HtmlValue, 
                            setupHTMLBodyParams(commsQueue, recipientMap), 
                            true 
                        )
                    );
                }else{
                    email.setSubject(emailTemplateInt.Subject);  
                    email.setHtmlBody(
                        EmailHelper.setBodyValues(
                            emailTemplateInt.HtmlValue, 
                            setupHTMLBodyParams(commsQueue, recipientMap), 
                            true 
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
        CommunicationQueuesDAO.newInstance().updateRecords(commsQueueListToUpdate, false, AccessLevel.USER_MODE);

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
            Boolean isContactForProcessing = contact.Can_Nurture__c && String.isNotBlank(contact.Calculated_Cadence__c);
            if(!emailMap.containsKey(contact.Id) && isContactForProcessing && contact.Email != null){
                emailMap.put(contact.Id, contact.FirstName);
            }
        }

        for(Lead lead : getLeadListByIdSet(whoIDset)){
            Boolean isLeadForProcessing = lead.Can_Nurture__c && String.isNotBlank(lead.Calculated_Cadence__c); 
            if(!emailMap.containsKey(lead.Id) && isLeadForProcessing){
                emailMap.put(lead.Id, lead.FirstName);
            }
        }
        
        return emailMap;
    }

    /**
     * retrieve contact list by who id set
     */
    private static List<Contact> getContactListByIdSet(Set<Id> whoIDset){
        List<String> fields = new List<String>{'Email', 'FirstName', 'Can_Nurture__c', 'Calculated_Cadence__c'};
        List<Contact> contactList =  
            (List<Contact>) DynamicQueryService.getRecordsWithFieldsByIdSet(
                new DynamicQueryService.FilterWrapper(whoIDset, Contact.getSObjectType(), fields), 
                AccessLevel.USER_MODE
            );
        return contactList;
    }

    /**
     * retrieve lead list by who id set
     */
    private static List<Lead> getLeadListByIdSet(Set<Id> whoIDset){
        List<String> fields = new List<String>{'Email', 'FirstName', 'Can_Nurture__c', 'Calculated_Cadence__c'};
        List<Lead> leadList =  
            (List<Lead>) DynamicQueryService.getRecordsWithFieldsByIdSet(
                new DynamicQueryService.FilterWrapper(whoIDset, Lead.getSObjectType(), fields), 
                AccessLevel.USER_MODE
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
        Map<String, Communication_Queue_Configuration__mdt> commsQueueMetadataMap = Communication_Queue_Configuration__mdt.getAll();
        for(Communication_Queue_Configuration__mdt cqm : commsQueueMetadataMap.values()){
            commQueueMetadata = cqm;
        }
        return commQueueMetadata; 
    }
    
    /**
     * retrieves email template to be used in email sending
     */
    private static EmailTemplate getEmailTemplate(String name){
        EmailTemplate response = new EmailTemplate();
        List<EmailTemplate> emailTemplates = EmailTemplatesDAO.newInstance().getEmailTemplatesByNameSet(new Set<String>{name}, 'USER_MODE');
        for(EmailTemplate emaailTemp : emailTemplates){
            response = emaailTemp;
        }
        return response;
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
        }
       return bodyParams;
    }
    
}