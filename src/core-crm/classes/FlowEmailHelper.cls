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
public class FlowEmailHelper {

    /**
    * @description Invocable method for sending email from flows
    * @param emailParams - list of email parameters
    */
    @InvocableMethod(Label='Send Email (Custom)' Description='Email Helper for Flows')
    public static void sendCustomEmail(List<EmailParameters> emailParams){
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<String> emailTemplateNames = new List<String>();
        Map<String,EmailTemplate> emailTemplates = new Map<String,EmailTemplate>();

        //get all email template names
        for(EmailParameters emailParam : emailParams){
            emailTemplateNames.add(emailParam.emailTemplateName);
        }

        //map email templates with name as key
        for(EmailTemplate template : [
            SELECT Name, Subject, HtmlValue
            FROM EmailTemplate
            WHERE Name IN :emailTemplateNames
        ]){ 
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
                        convertedParams.put(param.mergeField, param.mergeFieldValue);
                    }
                }
            }
            EmailTemplate emailTemplate = emailTemplates.get(emailParam.emailTemplateName);
            Messaging.SingleEmailMessage mail = EmailHelper.emailBuilder(
                emailParam.recipientEmailAddresses,
                !String.isBlank(emailParam.emailSubject) ? emailParam.emailSubject : emailTemplate.Subject,
                emailTemplate.HtmlValue,
                convertedParams,
                emailParam.orgWideEmailAddressId
            );
            emails.add(mail);
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
