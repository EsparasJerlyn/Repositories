/**
 * @description Helper class all Email Trigger Batch classes
 *
 * @author Accenture
 *
* @history
*     | Developer                 | Date                  | JIRA                | Change Summary                                                   |
      |---------------------------|-----------------------|---------------------|------------------------------------------------------------------|
      | rhea.b.torres             | November 29, 2022     | DEPP-4199           | Created file                                                     |
*/
public with sharing class EmailTriggerBatchHelper {

    public static void sendEmailWithoutAttachment(List<Object> records){
        if (!records.isEmpty()){
            List<EmailWrapper> wrapperList =  (List<EmailWrapper>)records;
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();

            // Get Org Wide Email Address
            List<OrgWideEmailAddress> owea = [SELECT Id, Address, DisplayName
                                                FROM OrgWideEmailAddress
                                                WHERE DisplayName = 'QUTeX'
                                                WITH SECURITY_ENFORCED LIMIT 1 ];

            // Get all email templates for new learners
            Map<Id,EmailTemplate> emailTemplateMap = getEmailTemplates(wrapperList);

            for (EmailWrapper emailWrapper : wrapperList){
                EmailTemplate emailTemplate  = resolveEmailTemplate(emailWrapper.emailTemplateIdStr, emailTemplateMap);
                Messaging.SingleEmailMessage mail = buildMail(emailWrapper, emailTemplate, owea);
                mailList.add(mail);
            }
            Messaging.sendEmail(mailList);
        }
    }

    public static void sendEmailWithAttachment(List<Object> records){
        if (!records.isEmpty()){
            List<EmailWrapper> wrapperList =  (List<EmailWrapper>)records;
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();

            // Get Org Wide Email Address
            List<OrgWideEmailAddress> owea = [SELECT Id, Address, DisplayName
                                                FROM OrgWideEmailAddress
                                                WHERE DisplayName = 'QUTeX'
                                                WITH SECURITY_ENFORCED LIMIT 1 ];

            // Get all email templates for new learners
            Map<Id,EmailTemplate> emailTemplateMap = EmailTriggerBatchHelper.getEmailTemplates(wrapperList);

            for (EmailWrapper emailWrapper : wrapperList){
                String filename = getAttachmentFilename(emailWrapper.attachmentType);
                PageReference pdf = resolvePageReference(emailWrapper.recordId, emailWrapper.attachmentType);
                EmailTemplate emailTemplate  = resolveEmailTemplate(emailWrapper.emailTemplateIdStr, emailTemplateMap);
                Messaging.SingleEmailMessage mail = buildMail(emailWrapper, emailTemplate, owea);
                Messaging.EmailFileAttachment attachment = buildAttachment(filename, pdf);
                // Send the email with attachment
                mail.setFileAttachments(new List<Messaging.EmailFileAttachment>{ attachment });
                mailList.add(mail);
            }
            Messaging.sendEmail(mailList);
        }
    }

    private static Messaging.SingleEmailMessage buildMail(EmailWrapper emailWrapper, EmailTemplate emailTemplate, List<OrgWideEmailAddress> owea){
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        
        // Set course connection fields in the email templates
        String recordId = emailWrapper.recordId;
        String contactId = emailWrapper.contactId;
        String name = emailWrapper.name;
        String firstName = emailWrapper.firstName;
        String lastName = emailWrapper.lastName;
        String toAddress = emailWrapper.toAddress;
        String amount = emailWrapper.amount;
        String paidInFull = emailWrapper.paidInFull;
        String storeLink = emailWrapper.storeLink;
        String userName = emailWrapper.userName;
        String startDate = (emailWrapper.startDate != null) ? emailWrapper.startDate.format(): '';
        String endDate = (emailWrapper.endDate != null) ? emailWrapper.endDate.format() : '';
        String subject = 'QUTeX' + ' ' + name;

        if (emailTemplate != null) {
            Map<String, String> emailParams = new Map<String, String>{
                '{fullname}' => firstName + ' ' + lastName,
                '{fullName}' => firstName + ' ' + lastName,
                '{name}' => name,
                '{courseOfferingName}' => name,
                '{productOfferingName}' => name,
                '{productName}' => name,
                '{startDate}' => startDate,
                '{startdate}' => startDate,
                '{endDate}' => endDate,
                '{firstname}' => firstName,
                '{firstName}' => firstName,
                '{contactFirstName}' => firstName,
                '{lastname}' => lastName,
                '{contactLastName}' => lastName,
                '{paid}' => paidInFull,
                '{amount}' => amount,
                '{storeLink}' => storeLink,
                '{username}' => userName
            };

            //Build the email
            msg.setToAddresses(new String[]{toAddress});
            msg.setSubject(subject);
            msg.setHtmlBody(EmailHelper.setBodyValues(emailTemplate.HtmlValue, emailParams, true));
            msg.setOrgWideEmailAddressId(owea[0]?.Id);
            msg.setWhatId((Id)recordId);
            msg.setTargetObjectId((Id)contactId);
            msg.setSaveAsActivity(true);
            msg.setTreatTargetObjectAsRecipient(false);
            msg.setUseSignature(false);
        }
        return msg;
    }

    private static EmailTemplate resolveEmailTemplate(String emailTemplateIdStr, Map<Id,EmailTemplate> emailTemplateMap){
        EmailTemplate emailTemplate;
        if(emailTemplateMap.containsKey(Id.valueOf(emailTemplateIdStr))){
            emailTemplate = emailTemplateMap.get(Id.valueOf(emailTemplateIdStr));
        }
        return emailTemplate;
    }

    /**
     * Get all email templates for new learners 
     * */
    private static Map<Id,EmailTemplate> getEmailTemplates(List<EmailWrapper> wrapperList){
        // Get all email template ids
        Set<String> emailTemplateIdSet = new Set<String>();
        for(EmailWrapper wrapper : wrapperList){
            emailTemplateIdSet.add(wrapper.emailTemplateIdStr);
        }
        // Get all email templates for new learners
        Map<Id,EmailTemplate> emailTemplateMap = new Map<Id,EmailTemplate>([SELECT Id,
                                                                                    Name,
                                                                                    Subject,
                                                                                    HtmlValue,
                                                                                    Body
                                                                            FROM EmailTemplate
                                                                            WHERE Id IN :emailTemplateIdSet]);
        return emailTemplateMap;
    }

    private static Messaging.EmailFileAttachment buildAttachment(String filename, PageReference pdf){
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setContentType('application/pdf');
        attachment.setFileName(filename);
        if (Test.isRunningTest()) {
            attachment.body = blob.valueOf('Unit.Test');
        } else {
            attachment.body = pdf.getContent();
        }
        attachment.setInline(false);
        return attachment;
    }

    private static PageReference resolvePageReference(String recordId, String attachmentType){
        PageReference pdf = null;
        if(attachmentType == 'Virtual'){
            pdf = new PageReference('/apex/VirtualClassFinalConfirmationPDFView?courseConnectionId=' + recordId);
        }else if(attachmentType == 'PreSession'){
            pdf = new PageReference('/apex/SessionSchedulePDFView?courseConnectionId=' + recordId);
        }else if(attachmentType == 'FaceToFace'){
            pdf = new PageReference('/apex/FacetoFaceFinalConfirmationPDFView?courseConnectionId=' + recordId);
        }
        return pdf;
    }

    private static String getAttachmentFilename(String attachmentType){
        String filename = '';
        if(attachmentType == 'Virtual'){
            filename = 'Virtual Class(Final Confirmation).pdf';
        }else if(attachmentType == 'PreSession'){
            filename = 'Pre-Session Reminder.pdf';
        }else if(attachmentType == 'FaceToFace'){
            filename = 'Face-to-Face(Final Confirmation).pdf';
        }
        return filename;
    }

    public class EmailWrapper {
        public String recordId;
        public String contactId;
        public String name;
        public String courseOfferingName;
        public String productOfferingName;
        public String firstName;
        public String lastName;
        public String toAddress;
        public String emailTemplateIdStr;
        public Date startDate;
        public Date endDate;
        public String paidInFull;
        public String amount;
        public String storeLink;
        public String userName;
        public String attachmentType;
    }
}
