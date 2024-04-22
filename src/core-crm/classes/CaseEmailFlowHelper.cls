/**
 * @description Utility class for emails to be sent from Flows
 * 
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA      | Change Summary                  |
      |---------------------------|-----------------------|-----------|---------------------------------|
      | mark.j.mahilum            | Feb. 26, 2024         | DEPP-7866 | Created file                    |
*/
public with sharing class CaseEmailFlowHelper {

    /**
    * @description Invocable method for sending email from flows
    * @param emailParams - list of email parameters
    */
    @InvocableMethod(Label='Send Case Email (Custom)' Description='Email Case Helper for Flows')
    public static void sendCustomEmail(List<EmailParameters> emailParams){
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<String> emailTemplateDeveloperNames = new List<String>();
        Map<String,EmailTemplate> emailTemplates = new Map<String,EmailTemplate>();

        //get all email template names
        for(EmailParameters emailParam : emailParams){
            emailTemplateDeveloperNames.add(emailParam.emailTemplateDeveloperName);
        }
        
        //map email templates with developer name as key
        for(EmailTemplate template : EmailTemplatesDAO.newInstance().getEmailTemplatesByDeveloperNameSet( new Set<String>(emailTemplateDeveloperNames), 'SYSTEM_MODE')){ 
            if(!emailTemplates.containsKey(template.DeveloperName)){
                emailTemplates.put(template.DeveloperName,template);
            }
        }
        
        //send email
        for(EmailParameters emailParam : emailParams){
            Map<String,String> convertedParams = new Map<String,String>();
            //build map of merge fields for template replacement
            if(!emailParam.mergeFields.isEmpty()){
                for(FlowEmailMergeField param : emailParam.mergeFields){
                    if(!convertedParams.containsKey(param.mergeField)){
                        convertedParams.put(param.mergeField, String.isNotBlank(param.mergeFieldValue) ? param.mergeFieldValue : ' ' );
                    }
                }
            }
            EmailTemplate emailTemplate = emailTemplates.get(emailParam.emailTemplateDeveloperName);
            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
            msg.setToAddresses(emailParam.recipientEmailAddresses);
            msg.setSubject(!String.isBlank(emailParam.emailSubject) ? emailParam.emailSubject : emailTemplate.Subject);
            msg.setHtmlBody(EmailHelper.setBodyValues(emailTemplate.HtmlValue, convertedParams, false));
            msg.setOrgWideEmailAddressId(String.isNotBlank(emailParam.orgWideEmailAddressId)? Id.valueOf(emailParam.orgWideEmailAddressId) : null);
            msg.setWhatId(emailParam.recordId);
            msg.setTreatTargetObjectAsRecipient(false);
            msg.setUseSignature(false);
            msg.setSaveAsActivity(true);

            emails.add(msg);
        }

        Messaging.SendEmailResult[] results = Messaging.sendEmail(emails,false);
        
        if (!results[0].success) {
            Logger.error('The CaseEmailFlowHelper email failed to send: '
                        + results[0].errors[0].message);
        }
        
        //log any error result
        if (Logger.getBufferSize() > 0) {
            Logger.saveLog();
        } 
    }

    public class EmailParameters{
        @InvocableVariable(label='Record Id (Text)' required=true)
        public String recordId;
        @InvocableVariable(label='Recipient Email Addresses (Text Collection)' required=true)
        public List<String> recipientEmailAddresses;
        @InvocableVariable(label='Email Template Developer Name (Text)' required=true)
        public String emailTemplateDeveloperName;
        @InvocableVariable(label='Email Subject (Text)')
        public String emailSubject;
        @InvocableVariable(label='Merge Fields (FlowEmailMergeField Collection)')
        public List<FlowEmailMergeField> mergeFields;
        @InvocableVariable(label='Org Wide Email Address ID (Text)')
        public String orgWideEmailAddressId;
    }
}