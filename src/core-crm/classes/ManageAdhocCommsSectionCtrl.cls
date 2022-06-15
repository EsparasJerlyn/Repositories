/**
 * @description Controller for the Manage Ad-hoc Communication under Product Offering
 *
 * @see ../lwc/manageAdhocCommsSection
 * 
 * @author Accenture
 *      
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                         |
      |---------------------------|-----------------------|--------------|--------------------------------------------------------|
      | angelika.j.s.galang       | April 6, 2022         | DEPP-2229    | Created file                                           | 
      |                           |                       |              |                                                        |
*/
public with sharing class ManageAdhocCommsSectionCtrl {
    /**
     * @description fetches all related adhoc communication records of product offering
    * @param productOfferingId - id of related product offering
    * @param offeringField - field api name of related product offering (either Course/Program_Offering__c)
    * @return list of adhoc communication records
    */
    @AuraEnabled(cacheable=true)
    public static List<Adhoc_Communication__c> getAdhocCommunications(
        String productOfferingId, 
        String offeringField
    ){
        return (List<Adhoc_Communication__c>) Database.query(
            'SELECT Id, Name, IsSent__c, Subject__c, CreatedDate, Email_Content__c ' +
            'FROM Adhoc_Communication__c ' +
            'WHERE ' + String.escapeSingleQuotes(offeringField) + ' = \'' + String.escapeSingleQuotes(productOfferingId) +
            '\' ORDER BY CreatedDate DESC'
        );
    }

    /**
     * @description fetches the email header & footer Document Ids
    * @return map of Document Name and Id
    */
    @AuraEnabled(cacheable=true)
    public static List<GenerateImageServerURL.ImageURL> getHeaderAndFooterImageUrls(String imageInfos){
        List<GenerateImageServerURL.ImageInfo> infos = (List<GenerateImageServerURL.ImageInfo>) JSON.deserialize(
            imageInfos, 
            List<GenerateImageServerURL.ImageInfo>.class
        );
        return GenerateImageServerURL.generateURL(infos);
    }

    /**
     * @description sends custom email to registered learners
    * @param emailSubject - subject of the email
    * @param emailContent - content of the email
    * @param learnerEmails - list of email addresses to send to
    * @return string containing success or error
    */
    @AuraEnabled
    public static String sendEmailToRegisteredLearners(
        String emailSubject, 
        String emailContent,
        List<String> learnerEmails
    ){
        String emailContentCentered = 
            '<!--[if mso]><center><table><tr><td width="640"><![endif]-->' +
            '<div style="max-width:640px; margin:0 auto;">' +
                emailContent +
            '</div>' +
            '<!--[if mso]></td></tr></table></center><![endif]-->';
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();

        for(String learnerEmail : learnerEmails){
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = new List<String>{learnerEmail};
            message.subject = emailSubject;
            message.htmlBody = emailContentCentered;
            messages.add(message);
        }

        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        for(Messaging.SendEmailResult result : results){
            if (!result.isSuccess()) {
                return 'error';
            }
        }

        return 'success';
    }
}
