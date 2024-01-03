/**
 * @description Batch class that triggers final confiramtion email notification for a Virtual course offering
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
 */
public with sharing class EmailTriggerVirtualBatch implements Database.Batchable<EmailTriggerBatchHelper.EmailWrapper>{

    public Iterable<EmailTriggerBatchHelper.EmailWrapper> start(Database.BatchableContext bc) {
        final Id STUDENT_REC_TYPE = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName()
            .get('Student')
            .getRecordTypeId();
        List<EmailTriggerBatchHelper.EmailWrapper> wrapperList = new List<EmailTriggerBatchHelper.EmailWrapper>();
        Map<Id,String> productEmailTemplateMap = new Map<Id,String>();

        try{
            //Query all students
            Map<Id, hed__Course_Enrollment__c>  courseEnrollmentMap = new Map<Id, hed__Course_Enrollment__c>([SELECT Id,
                                                                            hed__Contact__c,
                                                                            hed__Contact__r.FirstName,
                                                                            hed__Contact__r.LastName,
                                                                            hed__Contact__r.Registered_Email__c,
                                                                            hed__Course_Offering__c,
                                                                            hed__Course_Offering__r.hed__Course__c,
                                                                            hed__Course_Offering__r.hed__Course__r.Name,
                                                                            Course_Offering_Start_Date__c,
                                                                            Offering_End_Date__c,
                                                                            hed__Course_Offering__r.Delivery_Type__c,
                                                                            RecordTypeId,
                                                                            Program_Offering__r.hed_Program_Plan__c,
                                                                            Paid_in_Full__c,
                                                                            Amount__c,
                                                                            hed__Contact__r.QUT_Student_Username__c
                                                                    FROM hed__Course_Enrollment__c
                                                                    WHERE Id != Null
                                                                        AND RecordTypeId =:STUDENT_REC_TYPE
                                                                        AND Course_Offering_Start_Date__c >= TODAY
                                                                        AND hed__Status__c = 'Active'
                                                                        AND hed__Course_Offering__r.Delivery_Type__c = 'Online Classroom']);

            Set<Id> courseIdSet= new Set<Id>();
            Set<Id> progPlanIdSet = new Set<Id>();
            for(Id courseConnectionId : courseEnrollmentMap.keySet()){
                hed__Course_Enrollment__c courseConnection = courseEnrollmentMap.get(courseConnectionId);
                // Get all Course IDs
                if(String.isNotBlank(courseConnection.hed__Course_Offering__r.hed__Course__c)){
                    courseIdSet.add(courseConnection.hed__Course_Offering__r.hed__Course__c);
                }
                // Get all ProgramPlan IDs
                if(String.isNotBlank(courseConnection.Program_Offering__r.hed_Program_Plan__c)){
                    progPlanIdSet.add(courseConnection.Program_Offering__r.hed_Program_Plan__c);
                }
            }

            //Get Communication Schedule of the all Courses and Program Plan
            Map<Id, Decimal> courseDaysBeforeMap = new Map<Id, Decimal>();
            if(!courseIdSet.isEmpty() || !progPlanIdSet.isEmpty()){
                for(Communication_Schedule__c commSched : [SELECT Id, Course__c,
                                                                Program_Plan__c,
                                                                Days_before_Start_Date__c,
                                                                Email_on_final_confirmation__c,
                                                                On_Final_Confirmation_Template__c
                                                            FROM Communication_Schedule__c
                                                            WHERE Email_on_final_confirmation__c = TRUE
                                                                AND (Course__c IN :courseIdSet OR Program_Plan__c IN :progPlanIdSet)]){
                    
                    Boolean isCourseBeforeStartDateNotNull = String.isNotBlank(commSched.Course__c) && commSched.Days_before_Start_Date__c != null;
                    Boolean isProgramPlanBeforeStartDateNotNull = String.isNotBlank(commSched.Program_Plan__c) && commSched.Days_before_Start_Date__c != null;
                    Boolean isCourseFinalConfirmationTemplateNotBlank =  String.isNotBlank(commSched.Course__c) && String.isNotBlank(commSched.On_Final_Confirmation_Template__c);
                    Boolean isProgramPlanFinalConfirmationTemplateNotBlank =  String.isNotBlank(commSched.Program_Plan__c) && String.isNotBlank(commSched.On_Final_Confirmation_Template__c);

                    if(isCourseBeforeStartDateNotNull){
                        courseDaysBeforeMap.put(commSched.Course__c, commSched.Days_before_Start_Date__c);
                    }
                    if(isProgramPlanBeforeStartDateNotNull){
                        courseDaysBeforeMap.put(commSched.Program_Plan__c, commSched.Days_before_Start_Date__c);
                    }

                    // Get email template
                    if(isCourseFinalConfirmationTemplateNotBlank){
                        productEmailTemplateMap.put(commSched.Course__c, commSched.On_Final_Confirmation_Template__c);
                    }
                    if(isProgramPlanFinalConfirmationTemplateNotBlank){        
                        productEmailTemplateMap.put(commSched.Program_Plan__c, commSched.On_Final_Confirmation_Template__c);
                    }
                }
            }

            // Get available Course Offering session
            Map<Id,List<Session__c>> courseSessionMap = new Map<Id,List<Session__c>>();
            for(Session__c session : [SELECT Id,
                                        Date__c,
                                        Course_Offering__c,
                                        Course_Offering__r.hed__Course__c
                                        FROM Session__c
                                        WHERE Course_Offering__r.hed__Course__c IN :courseIdSet]){
                if(courseSessionMap.containsKey(session.Course_Offering__r.hed__Course__c)){
                    courseSessionMap.get(session.Course_Offering__r.hed__Course__c).add(session);
                }else{
                    courseSessionMap.put(session.Course_Offering__r.hed__Course__c, new List<Session__c>{session});
                }
            }

            if (!courseDaysBeforeMap.isEmpty()){
                for(Id courseConnectionId : courseEnrollmentMap.keySet()){
                    hed__Course_Enrollment__c courseConnection = courseEnrollmentMap.get(courseConnectionId);
                    Integer daysBeforeStartDate = 0;
                    Boolean allowedEmailReminder = false;
                    String emailTemplateIdStr = '';

                    //Do not send email if Course has no related Sessions
                    Boolean isCourseDaysBeforeContainsCourse = courseSessionMap.containsKey(courseConnection.hed__Course_Offering__r.hed__Course__c) && courseDaysBeforeMap.containsKey(courseConnection.hed__Course_Offering__r.hed__Course__c);
                    Boolean isCourseDaysBeforeContainsProgramPlan = courseSessionMap.containsKey(courseConnection.hed__Course_Offering__r.hed__Course__c) &&
                                                                    courseDaysBeforeMap.containsKey(courseConnection.Program_Offering__r.hed_Program_Plan__c);
                    if(isCourseDaysBeforeContainsCourse){
                        allowedEmailReminder = true;
                            daysBeforeStartDate = (Integer)courseDaysBeforeMap
                                                                .get(courseConnection.hed__Course_Offering__r.hed__Course__c);
                            emailTemplateIdStr = productEmailTemplateMap.get(courseConnection.hed__Course_Offering__r.hed__Course__c);
                    }
                    else if(isCourseDaysBeforeContainsProgramPlan ){
                        allowedEmailReminder = true;
                                daysBeforeStartDate = (Integer)courseDaysBeforeMap
                                                                .get(courseConnection.Program_Offering__r.hed_Program_Plan__c);
                                emailTemplateIdStr = productEmailTemplateMap.get(courseConnection.Program_Offering__r.hed_Program_Plan__c);
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
                    Boolean isEmailReminderAllowedAndStartDateToday = allowedEmailReminder && String.isNotBlank(emailTemplateIdStr) &&
                                                                    (courseConnection.Course_Offering_Start_Date__c - daysBeforeStartDate) == Date.today();
                    if(isEmailReminderAllowedAndStartDateToday){
                        // Email reminder allowed
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
                        wrapper.attachmentType = 'Virtual';
                        wrapperList.add(wrapper);
                    
                    }
                }
            }
        }catch(Exception e){
            Logger.error('Exception caught in method start in class EmailTriggerVirtualBatch.')
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
            Logger.error('Exception caught in method execute in class EmailTriggerVirtualBatch.')
                .setExceptionDetails(e);
        } finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }

    }

    public void finish(Database.BatchableContext bc) {}//NOPMD
}