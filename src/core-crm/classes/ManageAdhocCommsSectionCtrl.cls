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
            'WHERE ' + offeringField + ' = \'' + String.escapeSingleQuotes(productOfferingId) +
            '\' ORDER BY CreatedDate DESC'
        );
    }

    /**
     * @description fetches the email header & footer Document Ids
    * @return map of Document Name and Id
    */
    @AuraEnabled(cacheable=true)
    public static Map<String,Id> getHeaderAndFooterImageIds(List<String> fileNames){
        Map<String,Id> imageIdMap = new Map<String,Id>();
        for(Document doc : [SELECT Id, Name FROM Document WHERE Name IN : fileNames]){
            if(!imageIdMap.containsKey(doc.Name)){
                imageIdMap.put(doc.Name, doc.Id);
            }
        }
        return imageIdMap;
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
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = learnerEmails;
        message.subject = emailSubject;
        message.htmlBody = emailContent;
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        if (results[0].success) {
            System.debug('The email was sent successfully.');
            return 'success';
        }else {
            System.debug('The email failed to send: '
                + results[0].errors[0].message);
            return 'error';
        }
    }
}
