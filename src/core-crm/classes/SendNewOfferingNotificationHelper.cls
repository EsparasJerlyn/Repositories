/**
 * @description helper to send email notification to contacts that expressed there interest to a product
 * @see
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 22, 2022        | DEPP-1687              | Created file                 |
      | mary.grace.li                  | July 02, 2022         | DEPP-3124              | Update product detail url    |
      | john.bo.a.pineda               | July 12, 2022         | DEPP-3453              | Update URL in Email to       |
      |                                |                       |                        | Product2.Detail_Full_URL__c  |
      | kenneth.f.alsay                | December 27, 2023     |                        | Removed unused               |    
 */

public without sharing class SendNewOfferingNotificationHelper {
    /**
     * @description process new course offerings and check if email will be sent
     * @param crseOfferingNew - list of course offerings
     */
    public static void sendCourseOfferingAvailabiltyNotification(
        Map<Id, hed__Course_Offering__c> courseToOfferingMap
    ) {
        //course to expression map
        //potential courses for interest notification
        Map<Id, List<Id>> mapOfCourseToInterests = new Map<Id, List<Id>>();
        //courses with offering 24 hrs ago
        Set<Id> coursesWithOldOfferingSet = new Set<Id>();
        //final set of interest for notifcation
        Set<Id> interestEmailRecipientsSet = new Set<Id>();

        DateTime dt = System.Now().addHours(-24);

        //get all expression of interests related to the course of the newly created offering
        Map<Id, Expression_of_Interest__c> expresionOfInterestMap = new Map<Id, Expression_of_Interest__c>(
            [
                SELECT
                    Id,
                    Product__r.Course__c,
                    Product__r.Detail_Full_URL__c,
                    Product__c,
                    Product__r.Name,
                    Contact__r.Registered_Email__c,
                    Contact__r.FirstName,
                    Contact__r.LastName
                FROM Expression_of_Interest__c
                WHERE
                    Product__r.IsActive = TRUE
                    AND Product__r.Course__c IN :courseToOfferingMap.keySet()
                    AND Status__c = 'Active'
                    AND Contact__r.Registered_Email__c != NULL
                    AND Type__c = 'Register Interest'
            ]
        );

        //loop through the interests
        for (
            Expression_of_Interest__c interest : expresionOfInterestMap.values()
        ) {
            //construct map, this relates and groups expression of interests for each course
            if (
                !mapOfCourseToInterests.containsKey(
                    interest.Product__r.Course__c
                )
            ) {
                mapOfCourseToInterests.put(
                    interest.Product__r.Course__c,
                    new List<Id>()
                );
            }
            mapOfCourseToInterests.get(interest.Product__r.Course__c)
                .add(interest.Id);
        }

        //check for courseoffering created against the course 24hrs ago
        List<hed__Course_Offering__c> oldCourseOfferingList = new List<hed__Course_Offering__c>(
            [
                SELECT Id, hed__Course__c
                FROM hed__Course_Offering__c
                WHERE
                    Id NOT IN :courseToOfferingMap.values()
                    AND hed__Course__c IN :mapOfCourseToInterests.keySet()
                    AND (CreatedDate >= :dt
                    OR LastModifiedDate >= :dt)
                    AND Registration_Start_Date__c <= TODAY
                    AND (Registration_End_Date__c = NULL
                    OR Registration_End_Date__c > TODAY)
                    AND IsActive__c = TRUE
                    AND Available_Seats__c > 0
            ]
        );

        for (hed__Course_Offering__c offering : oldCourseOfferingList) {
            coursesWithOldOfferingSet.add(offering.hed__Course__c);
        }
        //loop through newly created course offering
        for (Id courseId : courseToOfferingMap.keySet()) {
            if (
                mapOfCourseToInterests.containsKey(courseId) &&
                !coursesWithOldOfferingSet.contains(courseId)
            ) {
                interestEmailRecipientsSet.addAll(
                    mapOfCourseToInterests.get(courseId)
                );
            }
        }

        if (!interestEmailRecipientsSet.isEmpty()) {
            sendOfferingNotification(
                interestEmailRecipientsSet,
                expresionOfInterestMap
            );
        }
    }

    /**
     * @description process new program offerings and check if email will be sent
     * @param programOfferingNew - list of program offerings
     */
    public static void sendProgramOfferingAvailabiltyNotification(
        Map<Id, Program_Offering__c> programToOfferingMap
    ) {
        //course to expression map
        //potential programs for interest notification
        Map<Id, List<Id>> mapOfProgramToInterests = new Map<Id, List<Id>>();
        //programs with offering 24 hrs ago
        Set<Id> programWithOldOfferingSet = new Set<Id>();
        //final set of interest for notifcation
        Set<Id> interestEmailRecipientsSet = new Set<Id>();

        DateTime dt = System.Now().addHours(-24);

        Map<Id, Expression_of_Interest__c> expresionOfInterestMap = new Map<Id, Expression_of_Interest__c>(
            [
                SELECT
                    Id,
                    Product__r.Program_Plan__c,
                    Product__r.Detail_Full_URL__c,
                    Product__c,
                    Product__r.Name,
                    Contact__r.Registered_Email__c,
                    Contact__r.FirstName,
                    Contact__r.LastName
                FROM Expression_of_Interest__c
                WHERE
                    Product__r.IsActive = TRUE
                    AND Product__r.Program_Plan__c IN :programToOfferingMap.keySet()
                    AND Status__c = 'Active'
                    AND Contact__r.Registered_Email__c != NULL
                    AND Type__c = 'Register Interest'
            ]
        );

        for (
            Expression_of_Interest__c interest : expresionOfInterestMap.values()
        ) {
            //construct map, this relates and groups expression of interests for each course
            if (
                !mapOfProgramToInterests.containsKey(
                    interest.Product__r.Program_Plan__c
                )
            ) {
                mapOfProgramToInterests.put(
                    interest.Product__r.Program_Plan__c,
                    new List<Id>()
                );
            }
            mapOfProgramToInterests.get(interest.Product__r.Program_Plan__c)
                .add(interest.Id);
        }

        //check for programoffering created against the course 24hrs ago
        List<Program_Offering__c> oldProgramOfferingList = new List<Program_Offering__c>(
            [
                SELECT Id, hed_Program_Plan__c
                FROM Program_Offering__c
                WHERE
                    Id NOT IN :programToOfferingMap.values()
                    AND hed_Program_Plan__c IN :mapOfProgramToInterests.keySet()
                    AND (CreatedDate >= :dt
                    OR LastModifiedDate >= :dt)
                    AND Registration_Start_Date__c <= TODAY
                    AND (Registration_End_Date__c = NULL
                    OR Registration_End_Date__c > TODAY)
                    AND IsActive__c = TRUE
                    AND Available_Seats__c > 0
            ]
        );

        for (Program_Offering__c offering : oldProgramOfferingList) {
            programWithOldOfferingSet.add(offering.hed_Program_Plan__c);
        }

        for (Id programId : programToOfferingMap.keySet()) {
            if (
                mapOfProgramToInterests.containsKey(programId) &&
                !programWithOldOfferingSet.contains(programId)
            ) {
                interestEmailRecipientsSet.addAll(
                    mapOfProgramToInterests.get(programId)
                );
            }
        }

        if (!interestEmailRecipientsSet.isEmpty()) {
            sendOfferingNotification(
                interestEmailRecipientsSet,
                expresionOfInterestMap
            );
        }
    }

    /**
     * @description sets the External Id of the SObject
     * @param interestEmailRecipientsSet - list of email recipients
     * @param  expresionOfInterestMap - details needed for the email to be sent to user
     */
    public static void sendOfferingNotification(
        Set<Id> interestEmailRecipientsSet,
        Map<Id, Expression_of_Interest__c> expresionOfInterestMap
    ) {
        List<EmailTemplate> emailTemplateList = new List<EmailTemplate>(
            [
                SELECT Id, HTMLValue
                FROM EmailTemplate
                WHERE DeveloperName = 'Offering_Available_Email_Notification'
            ]
        );

        List<OrgWideEmailAddress> owea = [
            SELECT Id, Address, DisplayName
            FROM OrgWideEmailAddress
            WHERE DisplayName = 'QUTeX'
            LIMIT 1
        ];

        List<Messaging.SingleEmailMessage> lstEmails = new List<Messaging.SingleEmailMessage>();
        Map<String, String> emailContent = new Map<String, String>();

        if (!emailTemplateList.isEmpty()) {
            for (Id interestId : interestEmailRecipientsSet) {
                //Prepare SendToEmail List
                emailContent.put(
                    '{contactLastName}',
                    expresionOfInterestMap.get(interestId).Contact__r.LastName
                );
                if (
                    expresionOfInterestMap.get(interestId)
                        .Contact__r.FirstName != null
                ) {
                    emailContent.put(
                        '{contactFirstName}',
                        expresionOfInterestMap.get(interestId)
                            .Contact__r.FirstName
                    );
                } else {
                    emailContent.put('{contactFirstName}', '');
                }
                emailContent.put(
                    '{productName}',
                    expresionOfInterestMap.get(interestId).Product__r.Name
                );
                String productUrl = expresionOfInterestMap.get(interestId)
                    .Product__r.Detail_Full_URL__c;
                emailContent.put('{productURL}', productUrl);
                emailContent.put(
                    '{optOutURL}',
                    'https://qut.tfaforms.net/f/notification-opt-out' +
                    '?id=' +
                    interestId
                );

                Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                msg.setToAddresses(new String[]{expresionOfInterestMap.get(interestId).Contact__r.Registered_Email__c});
                msg.setSubject(expresionOfInterestMap.get(interestId).Product__r.Name);
                msg.setHtmlBody(EmailHelper.setBodyValues(emailTemplateList[0].HTMLValue, emailContent, true));
                msg.setOrgWideEmailAddressId(owea[0].Id);
                msg.setSaveAsActivity(true);
                msg.setTreatTargetObjectAsRecipient(false);
                msg.setUseSignature(false);
                lstEmails.add(msg);
                //make sure email is not null
            }
        }

        String errorLocation = 'On method sendOfferingNotification on class SendNewOfferingNewNotificationHelper: ';
        if (!lstEmails.isEmpty()) {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(lstEmails);
            if(!results[0].success) {
                Logger.error(errorLocation + 'The email failed to send: ' + results[0].errors[0].message);
            }
        } else {
            Logger.error(errorLocation + 'No emails to be sent.');
        }

        if(Logger.getBufferSize() > 0) {
            Logger.saveLog();
        }
    }
}
