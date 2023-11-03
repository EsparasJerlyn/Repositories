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
      | eugene.andrew.abuan       | October 10,2023       | DEPP-6612    | Updated the class to be usable for batch class         |
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
        List<Adhoc_Communication__c> adhocCommunicationRecords = new List<Adhoc_Communication__c>();
        adhocCommunicationRecords = AdhocCommunicationsDAO.newInstance().
                                    getAdhocCommunicationsByOfferingFieldAndProductOfferingId(productOfferingId,offeringField, AccessLevel.USER_MODE);
        return adhocCommunicationRecords;
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
    * @param adhocCommunications - list of Adhoc Communications that will be sent every 7AM
    * @return  boolean containing success or error
    */
    @AuraEnabled
    public static Boolean sendEmailToRegisteredLearners(List<Adhoc_Communication__c> adhocCommunications) {
        Boolean emailResult = true;

        try {
            List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
            Map<Id, List<String>> learnerEmailsMap = new Map<Id, List<String>>();
            List<OrgWideEmailAddress> orgWideEmailAddress = queryOrgWideEmailAddress();

            Set<Id> courseOfferingIdSet = new Set<Id>();
            Set<Id> programOfferingIdSet = new Set<Id>();

            List<hed__Course_Enrollment__c> courseConnectionRecordList = new List<hed__Course_Enrollment__c>();

            // Collect Course Offering and Program Offering IDs
            collectOfferingIds(adhocCommunications, courseOfferingIdSet, programOfferingIdSet);

            // Get learner email data based on offerings
            courseConnectionRecordList = getCourseConnectionRecords(courseOfferingIdSet, programOfferingIdSet);

            initializeLearnerEmailsMap(learnerEmailsMap, courseConnectionRecordList);

            for (Adhoc_Communication__c adhocCommunication : adhocCommunications) {
                String emailContentCentered = '<!--[if mso]><center><table><tr><td width="640"><![endif]-->' +
                    '<div style="max-width:640px; margin:0 auto;">' +
                    adhocCommunication.Email_Content__c +
                    '</div>' +
                    '<!--[if mso]></td></tr></table></center><![endif]-->';
            
                List<String> recipientEmails = getRecipientEmails(adhocCommunication, learnerEmailsMap);
            
                if (!recipientEmails.isEmpty()) {
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.subject = adhocCommunication.Subject__c;
                    message.htmlBody = emailContentCentered;
                    message.setOrgWideEmailAddressId(orgWideEmailAddress.get(0).Id);
            
                    List<String> emailGroup = new List<String>();
                    for (String email : recipientEmails) {
                        emailGroup.add(email);

                        if (emailGroup.size() >= 100) {
                            message.toAddresses = emailGroup;
                            messages.add(message);
                            emailGroup.clear();
                            message = new Messaging.SingleEmailMessage(); // Create a new message
                            message.subject = adhocCommunication.Subject__c;
                            message.htmlBody = emailContentCentered;
                        }
                    }

                    if (!emailGroup.isEmpty()) {
                        message.toAddresses = emailGroup;
                        messages.add(message);
                    }
                }
            }

            emailResult = sendEmails(messages);
        } catch (Exception e) {
            emailResult = handleException(e);
        }
        return emailResult;
    }

    /**
    * @description Private method that collects the Offering Id based on the Adhoc Communication records
    * @param courseOfferingIdSet - Set of Course Offering Ids
    * @param programOfferingIdSet - Set of Program Offering Ids
    * @return  void
    */
    private static void collectOfferingIds(List<Adhoc_Communication__c> adhocCommunications, Set<Id> courseOfferingIdSet, Set<Id> programOfferingIdSet) {
        for (Adhoc_Communication__c adhocRecord : adhocCommunications) {
            if (!String.isBlank(adhocRecord.Course_Offering__c)) {
                courseOfferingIdSet.add(adhocRecord.Course_Offering__c);
            }
            if (!String.isBlank(adhocRecord.Program_Offering__c)) {
                programOfferingIdSet.add(adhocRecord.Program_Offering__c);
            }
        }
    }

    /**
    * @description Private method that will get the related course enrollment per offering
    * @param courseOfferingIdSet - Set of Course Offering Ids
    * @param programOfferingIdSet - Set of Program Offering Ids
    * @return courseEnrollmentList - List of Course Enrollment Records
    */
    private static List<hed__Course_Enrollment__c> getCourseConnectionRecords(Set<Id> courseOfferingIdSet, Set<Id> programOfferingIdSet) {
        List<hed__Course_Enrollment__c> courseEnrollmentList = new List<hed__Course_Enrollment__c>();
        if (!courseOfferingIdSet.isEmpty() || !programOfferingIdSet.isEmpty()) {
            courseEnrollmentList = CourseConnectionsDAO.newInstance()
                .getRegisteredLearnersEmailByCourseOffering(courseOfferingIdSet, programOfferingIdSet, AccessLevel.USER_MODE);
        }
        return courseEnrollmentList;
    }

    /**
    * @description Private method that calls the addLearnerEmailToMap method to pass the values of
    * the course offeringId and the registred learners based on the course enrollment object
    * @param learnerEmailsMap - Map of Id that will have the offeringId as Key and List of String of registered learners
    * @param courseConnectionRecordList - List of offering per Adhoc Communications
    * @return  void
    */
    private static void initializeLearnerEmailsMap(Map<Id, List<String>> learnerEmailsMap, List<hed__Course_Enrollment__c> courseConnectionRecordList) {
        for (hed__Course_Enrollment__c courseConnectionRecord : courseConnectionRecordList) {
            if ((String.isNotEmpty(courseConnectionRecord.hed__Course_Offering__c) || String.isNotEmpty(courseConnectionRecord.Program_Offering__c)) 
                    && String.isNotEmpty(courseConnectionRecord.hed__Contact__r.Registered_Email__c)) {
                addLearnerEmailToMap(learnerEmailsMap, courseConnectionRecord.hed__Course_Offering__c, courseConnectionRecord.hed__Contact__r.Registered_Email__c);
                addLearnerEmailToMap(learnerEmailsMap, courseConnectionRecord.Program_Offering__c, courseConnectionRecord.hed__Contact__r.Registered_Email__c);
            }
        }
    }

    /**
    * @description Private method that adds the list of registered emails per offering
    * @param learnerEmailsMap - Map of Id that will have the offeringId as Key and List of String of registered learners
    * @param offeringId - Id of the course offering
    * @param email - Registered email of the Contact
    * @return  void
    */
    private static void addLearnerEmailToMap(Map<Id, List<String>> learnerEmailsMap, Id offeringId, String email) {
        if (String.isNotEmpty(offeringId)) {
            if (!learnerEmailsMap.containsKey(offeringId)) {
                learnerEmailsMap.put(offeringId, new List<String>());
            }
            learnerEmailsMap.get(offeringId).add(email);
        }
    }

    /**
     * retrieves org wide email address to be used in email sending
     */
    private static List<OrgWideEmailAddress> queryOrgWideEmailAddress(){
        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();

        Set<String> orgWideDisplayName = new Set<String>{OrgWideEmailAddressesDAO.ORG_WIDE_EMAIL_ADD_QUTEX};

        for(OrgWideEmailAddress orgWideEmailAddress : OrgWideEmailAddressesDAO.newInstance().getOrgWideEmailAddressByDisplayName(orgWideDisplayName, AccessLevel.USER_MODE)){
            owea.add(orgWideEmailAddress);
        }

        return owea;
    }

    /**
    * @description Private method that getsReceipientEmails based on the map
    * @param learnerEmailsMap - Map of Id that will have the offeringId as Key and List of String of registered learners
    * @param adhocCommunication - record
    * @param email - Registered email of the Contact
    * @return  void
    */
    private static List<String> getRecipientEmails(Adhoc_Communication__c adhocCommunication, Map<Id, List<String>> learnerEmailsMap) {
        Id offeringId = adhocCommunication.Course_Offering__c;
        if (String.isBlank(offeringId)) {
            offeringId = adhocCommunication.Program_Offering__c;
        }
        return learnerEmailsMap.get(offeringId);
    }
    
    /**
    * @description Private method that will send an email based on the added messages
    * @param messages -List of Messaging.SingleEmailMessage
    * @return  Boolean - true or false indicating a success email send or not.
    */
    private static Boolean sendEmails(List<Messaging.SingleEmailMessage> messages) {
        Boolean sendEmailResult = false;
        String errorResult;
        // Check email limits before sending
        if (!messages.isEmpty()) {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages, false);
            for (Messaging.SendEmailResult result : results) {
                if (result.isSuccess()) {
                    sendEmailResult = true; // Email sent successfully
                } else {
                    errorResult = result.getErrors()[0].getMessage();
                }
            }
            if(String.isNotBlank(errorResult)){
                Logger.error(errorResult);
            }
        } else {
            // Handle the case where email limits have been reached
            Logger.error('Sending email has reached and wasnt able to send an Adhoc Communication');
        }
        return sendEmailResult; 
    }

     /**
    * @description Private method that will handle the exception
    * @param e - Exeception value
    * @return  Boolean - true or false indicating a success email send or not.
    */
    private static Boolean handleException(Exception e) {
        Logger.error('Exception caught in sendEmailToRegisteredLearners method execute in class ManageAdhocCommsSectionCtrl.')
            .setExceptionDetails(e);
        if(Logger.getBufferSize() > 0) {
            Logger.saveLog();
        }
        return false;
    }
}