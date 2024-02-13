/**
 * @description Batch class that triggers email a day before the session start date of a Course Offerings
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                 |
      |--------------------------------|-----------------------|------------------------|----------------------------------------------------------------|
      | marlon.vasquez                 | June 20,2022          | DEPP-3188              | Created file                                                   |
      | rhea.b.torres                  | June 22,2022          | DEPP-3188              | Updated logic to send email to the Student                     |
      | rhea.b.torres                  | July 23,2022          | DEPP-3557              | Add logic to use email template set in Communication Schedule  |
      | rhea.b.torres                  | July 27,2022          | DEPP-3590              | Add logic to include merge fields from other email template    |
      | rhea.b.torres                  | November 11,2022      | DEPP-4759              | Refactor logic for sending pre-session emails to learners      |
 */
public with sharing class EmailTriggerPreSessionBatch implements Database.Batchable<EmailTriggerBatchHelper.EmailWrapper>{

    public Iterable<EmailTriggerBatchHelper.EmailWrapper> start(Database.BatchableContext bc) {
        final Id STUDENT_REC_TYPE = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName()
            .get('Student')
            .getRecordTypeId();
        List<EmailTriggerBatchHelper.EmailWrapper> wrapperList = new List<EmailTriggerBatchHelper.EmailWrapper>();
        Map<Id,String> productEmailTemplateMap = new Map<Id,String>();

        try{
            // Get all Sessions which will start tomorrow
            List<Session__c> sessionsTomorrow = [SELECT Id, Date__c, Course_Offering__c FROM Session__c WHERE Date__c =:Date.TODAY()+1];
            
            // Get the related Course Offerings of the fetched sessions
            Set<Id> offeringsWithSessionTomorrow = new Set<Id>();
            for(Session__c session : sessionsTomorrow){
                offeringsWithSessionTomorrow.add(session.Course_Offering__c);
            }

            // Get all Course Connection records with Course Offerings having session which will start tomorrow
            List<hed__Course_Enrollment__c>  courseConnections = new List<hed__Course_Enrollment__c>(
                                                                    [SELECT Id,
                                                                            hed__Contact__c,
                                                                            hed__Contact__r.FirstName,
                                                                            hed__Contact__r.LastName,
                                                                            hed__Contact__r.Registered_Email__c,
                                                                            hed__Course_Offering__c,
                                                                            hed__Course_Offering__r.hed__Course__r.Name,
                                                                            hed__Course_Offering__r.hed__Course__c,
                                                                            Program_Offering__r.hed_Program_Plan__c,
                                                                            Course_Offering_Start_Date__c,
                                                                            Offering_End_Date__c,
                                                                            Paid_in_Full__c,
                                                                            Amount__c,
                                                                            hed__Contact__r.QUT_Student_Username__c
                                                                    FROM hed__Course_Enrollment__c
                                                                    WHERE Id != NULL
                                                                        AND RecordTypeId =:STUDENT_REC_TYPE
                                                                        AND hed__Status__c = 'Active'
                                                                        AND hed__Course_Offering__c IN :offeringsWithSessionTomorrow]);

            // Get the Course or Program Plan info from the Course Connection records
            Set<Id> courseIdSet= new Set<Id>();
            Set<Id> progPlanIdSet = new Set<Id>();
            for(hed__Course_Enrollment__c courseConnection : courseConnections){
                // When a Course Connection is registered to a Program
                if(String.IsNotBlank(courseConnection.Program_Offering__r.hed_Program_Plan__c)){
                    progPlanIdSet.add(courseConnection.Program_Offering__r.hed_Program_Plan__c);
                } else {
                    // When a Course Connection is registered to a single course
                    courseIdSet.add(courseConnection.hed__Course_Offering__r.hed__Course__c);
                }
            }

            //Get Communication Schedule of the all Courses and Program Plan
            Map<Id, Boolean> courseAllowedEmailMap = new Map<Id, Boolean>();
            if(!courseIdSet.isEmpty() || !progPlanIdSet.isEmpty()){
                for(Communication_Schedule__c commSched : [SELECT Id, Course__c,
                                                                Program_Plan__c,
                                                                Send_email_before_session__c,
                                                                Notification_Before_Session_Template__c
                                                            FROM Communication_Schedule__c
                                                            WHERE Send_email_before_session__c = TRUE
                                                                AND (Course__c IN :courseIdSet OR Program_Plan__c IN :progPlanIdSet)]){
                    
                    Boolean isCourseNotBlank = String.isNotBlank(commSched.Course__c);
                    Boolean isProgramPlanNotBlank = String.isNotBlank(commSched.Program_Plan__c);
                    Boolean isCourseNotificationNotBlank = String.isNotBlank(commSched.Course__c) && String.isNotBlank(commSched.Notification_Before_Session_Template__c);
                    Boolean isProgramPlanNotificationNotBlank = String.isNotBlank(commSched.Program_Plan__c) && String.isNotBlank(commSched.Notification_Before_Session_Template__c);
                    
                    if(isCourseNotBlank){
                        courseAllowedEmailMap.put(commSched.Course__c, commSched.Send_email_before_session__c);
                    }
                    // Get email template for Course
                    if(isCourseNotificationNotBlank){
                        productEmailTemplateMap.put(commSched.Course__c,
                                                    String.valueOf(commSched.Notification_Before_Session_Template__c));
                    }
                    
                    if(isProgramPlanNotBlank){
                        courseAllowedEmailMap.put(commSched.Program_Plan__c, commSched.Send_email_before_session__c);
                    }
                    // Get email template for Program
                    if(isProgramPlanNotificationNotBlank){
                        productEmailTemplateMap.put(commSched.Program_Plan__c,
                                                    String.valueOf(commSched.Notification_Before_Session_Template__c));
                    }
                }
            }

            // Loop through all Course Connection records and verify if Course/Program Plan allows communication to be sent
            for(hed__Course_Enrollment__c courseConnection : courseConnections){
                Boolean isAllowedReminder = false;
                String emailTemplateIdStr = '';

                // Check first if Course Connection records has related Program Offering. This means that the course connection is registered to a Program
                if(String.IsNotBlank(courseConnection.Program_Offering__c)){
                    // Program
                    if(courseAllowedEmailMap.containsKey(courseConnection.Program_Offering__r.hed_Program_Plan__c)){
                        isAllowedReminder = true;
                        // get email template
                        emailTemplateIdStr = productEmailTemplateMap.get(courseConnection.Program_Offering__r.hed_Program_Plan__c);
                    }
                }else{
                    // Single
                    if(courseAllowedEmailMap.containsKey(courseConnection.hed__Course_Offering__r.hed__Course__c)){
                        isAllowedReminder = true;
                        // get email template
                        emailTemplateIdStr = productEmailTemplateMap.get(courseConnection.hed__Course_Offering__r.hed__Course__c);
                    }
                }

                String paidInFull = 'No';
                if (String.isNotBlank(courseConnection.Paid_in_Full__c)) {
                    paidInFull = courseConnection.Paid_in_Full__c;
                }
                String amount = '0.00';
                if (String.isNotBlank(String.valueof(courseConnection.Amount__c))) {
                    amount = String.valueof(courseConnection.Amount__c);
                }

                // Get Study Store URL Custom Setting
                Study_Store_URL_Settings__c storeLinkSettings = Study_Store_URL_Settings__c.getOrgDefaults();

                if(isAllowedReminder && String.isNotBlank(emailTemplateIdStr)){
                    //Send email to this student
                    EmailTriggerBatchHelper.EmailWrapper wrapper;
                    wrapper = new EmailTriggerBatchHelper.EmailWrapper();
                    wrapper.recordId = courseConnection.Id;
                    wrapper.contactId = courseConnection.hed__Contact__c;
                    wrapper.name = courseConnection.hed__Course_Offering__r.hed__Course__r.Name;
                    wrapper.firstName = courseConnection.hed__Contact__r.FirstName;
                    wrapper.lastName = courseConnection.hed__Contact__r.LastName;
                    wrapper.toAddress = courseConnection.hed__Contact__r.Registered_Email__c;
                    wrapper.emailTemplateIdStr = emailTemplateIdStr;
                    wrapper.startDate = courseConnection.Course_Offering_Start_Date__c;
                    wrapper.endDate = courseConnection.Offering_End_Date__c;
                    wrapper.amount = amount;
                    wrapper.paidInFull = paidInFull;
                    wrapper.storeLink = storeLinkSettings.Study_Store_Link__c != null
                                                        ? String.valueOf(storeLinkSettings.Study_Store_Link__c)
                                                        : '';
                    wrapper.userName = courseConnection.hed__Contact__r.QUT_Student_Username__c!=null
                                                        ? courseConnection.hed__Contact__r.QUT_Student_Username__c
                                                        : '';
                    wrapper.attachmentType = 'PreSession';
                    wrapperList.add(wrapper);
                }
            }
        }catch(Exception e){
            Logger.error('Exception caught in method start in class EmailTriggerPreSessionBatch.')
                .setExceptionDetails(e);
        } finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }

        return wrapperList;
    }

    public void execute(Database.BatchableContext bc, List<Object> records) {

        try{
            EmailTriggerBatchHelper.sendEmailWithAttachment(records);
        }catch(Exception e){
            Logger.error('Exception caught in method execute in class EmailTriggerPreSessionBatch.')
                .setExceptionDetails(e);
        } finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }

    }

    public void finish(Database.BatchableContext bc) {}//NOPMD 
}