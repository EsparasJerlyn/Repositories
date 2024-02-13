/**
 * @description Utility class for emails to be sent from Flows
 * 
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA      | Change Summary                  |
      |---------------------------|-----------------------|-----------|---------------------------------|
      | angelika.j.s.galang       | April 22, 2022        | DEPP-2156 | Created file                    | 
      |                           |                       |           |                                 | 
*/
public without sharing class FlowEmailHelper {

    /**
    * @description Invocable method for sending email from flows
    * @param emailParams - list of email parameters
    */
    @InvocableMethod(Label='Send Email (Custom)' Description='Email Helper for Flows')
    public static void sendCustomEmail(List<EmailParameters> emailParams){
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Set<String> emailTemplateNames = new Set<String>();
        Map<String,EmailTemplate> emailTemplates = new Map<String,EmailTemplate>();

        //get all email template names
        for(EmailParameters emailParam : emailParams){
            emailTemplateNames.add(emailParam.emailTemplateName);
        }

        //map email templates with name as key
        for(EmailTemplate template : EmailTemplatesDAO.newInstance().getEmailTemplatesByNameSet(emailTemplateNames, AccessLevel.SYSTEM_MODE)){ 
            if(!emailTemplates.containsKey(template.Name)){
                emailTemplates.put(template.Name,template);
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
            EmailTemplate emailTemplate = emailTemplates.get(emailParam.emailTemplateName);
            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
            msg.setToAddresses(emailParam.recipientEmailAddresses);
            msg.setSubject(!String.isBlank(emailParam.emailSubject) ? emailParam.emailSubject : emailTemplate.Subject);
            msg.setHtmlBody(EmailHelper.setBodyValues(emailTemplate.HtmlValue, convertedParams, true));
            msg.setOrgWideEmailAddressId(String.isNotBlank(emailParam.orgWideEmailAddressId)? Id.valueOf(emailParam.orgWideEmailAddressId) : null);
            msg.setTreatTargetObjectAsRecipient(false);
            msg.setUseSignature(false);

            emails.add(msg);
        }
        
        Messaging.sendEmail(emails);
    }

    public class EmailParameters{
        @InvocableVariable(label='Recipient Email Addresses (Text Collection)' required=true)
        public List<String> recipientEmailAddresses;
        @InvocableVariable(label='Email Template Name (Text)' required=true)
        public String emailTemplateName;
        @InvocableVariable(label='Email Subject (Text)')
        public String emailSubject;
        @InvocableVariable(label='Merge Fields (FlowEmailMergeField Collection)')
        public List<FlowEmailMergeField> mergeFields;
        @InvocableVariable(label='Org Wide Email Address ID (Text)')
        public String orgWideEmailAddressId;
    }
}
