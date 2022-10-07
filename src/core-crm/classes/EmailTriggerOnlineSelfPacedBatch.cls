/**
 * @description Batch class that triggers final confiramtion email notification for a Online Self-Paced course offering
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
public with sharing class EmailTriggerOnlineSelfPacedBatch implements Database.Batchable<EmailWrapper>{

    public Iterable<EmailWrapper> start(Database.BatchableContext bc) {
        final Id STUDENT_REC_TYPE = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName()
            .get('Student')
            .getRecordTypeId();
        List<EmailWrapper> wrapperList = new List<EmailWrapper>();
        Map<Id,String> productEmailTemplateMap = new Map<Id,String>();

        try{
            //Query all students
            Map<Id, hed__Course_Enrollment__c>  courseEnrollmentMap = new Map<Id, hed__Course_Enrollment__c>([SELECT Id,
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
                                                                        AND hed__Course_Offering__r.Delivery_Type__c = 'Online Self-paced']);

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
                    if(commSched.Days_before_Start_Date__c != null){
                        if(String.isNotBlank(commSched.Course__c)){
                            courseDaysBeforeMap.put(commSched.Course__c, commSched.Days_before_Start_Date__c);
                        }
                        if(String.isNotBlank(commSched.Program_Plan__c)){
                            courseDaysBeforeMap.put(commSched.Program_Plan__c, commSched.Days_before_Start_Date__c);
                        }
                    }

                    // Get email template
                    if(String.isNotBlank(commSched.On_Final_Confirmation_Template__c)){
                        if(String.isNotBlank(commSched.Course__c)){
                            productEmailTemplateMap.put(commSched.Course__c, String.valueOf(commSched.On_Final_Confirmation_Template__c));
                        }
                        if(String.isNotBlank(commSched.Program_Plan__c)){
                            productEmailTemplateMap.put(commSched.Program_Plan__c, String.valueOf(commSched.On_Final_Confirmation_Template__c));
                        }
                    }
                }
            }

            if (!courseDaysBeforeMap.isEmpty()){
                for(Id courseConnectionId : courseEnrollmentMap.keySet()){
                    hed__Course_Enrollment__c courseConnection = courseEnrollmentMap.get(courseConnectionId);
                    Integer daysBeforeStartDate = 0;
                    Boolean allowedEmailReminder = false;
                    String emailTemplateIdStr = '';

                    //Get DaysBeforeStartDate
                    if(courseDaysBeforeMap.containsKey(courseConnection.hed__Course_Offering__r.hed__Course__c)){
                        allowedEmailReminder = true;
                        daysBeforeStartDate = (Integer)courseDaysBeforeMap
                                                            .get(courseConnection.hed__Course_Offering__r.hed__Course__c);
                        emailTemplateIdStr = productEmailTemplateMap.get(courseConnection.hed__Course_Offering__r.hed__Course__c);
                    } else {
                        // Course is for a Program
                        if(courseDaysBeforeMap.containsKey(courseConnection.Program_Offering__r.hed_Program_Plan__c)){
                            allowedEmailReminder = true;
                            daysBeforeStartDate = (Integer)courseDaysBeforeMap
                                                            .get(courseConnection.Program_Offering__r.hed_Program_Plan__c);
                            emailTemplateIdStr = productEmailTemplateMap.get(courseConnection.Program_Offering__r.hed_Program_Plan__c);
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

                    if(allowedEmailReminder && String.isNotBlank(emailTemplateIdStr)){
                        // Email reminder allowed
                        if((courseConnection.Course_Offering_Start_Date__c - daysBeforeStartDate) == Date.today()){
                            //Send email to this student
                            EmailWrapper wrapper = new EmailWrapper();
                            wrapper.recordId = courseConnection.Id;
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
                            wrapperList.add(wrapper);
                        }
                    }
                }
            }
        }catch(Exception e){
            System.debug(e);
        }

        return wrapperList;
    }

    public void execute(Database.BatchableContext bc, List<Object> records) {
        try{
            if (!records.isEmpty()){
                List<EmailWrapper> wrapperList =  (List<EmailWrapper>)records;
                List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();

                // Get Org Wide Email Address
                List<OrgWideEmailAddress> owea = [SELECT Id, Address, DisplayName
                                                    FROM OrgWideEmailAddress
                                                    WHERE DisplayName = 'QUTeX'LIMIT 1];

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

                for (EmailWrapper emailWrapper : wrapperList){
                    final String STR_QUTEX = 'QUTeX';

                    /**
                     * Set course connection fields in the email templates
                     **/
                    String recordId = emailWrapper.recordId;
                    String name =  emailWrapper.name;
                    String firstName = emailWrapper.firstName;
                    String lastName =  emailWrapper.lastName;
                    String toAddress =  emailWrapper.toAddress;
                    String amount = emailWrapper.amount;
                    String paidInFull = emailWrapper.paidInFull;
                    String storeLink = emailWrapper.storeLink;
                    String userName = emailWrapper.userName;
                    String startDate = '';
                    if(emailWrapper.startDate != null){
                        startDate = emailWrapper.startDate.format();
                    }

                    String endDate = '';
                    if(emailWrapper.endDate != null){
                        endDate = emailWrapper.endDate.format();
                    }
                    String subject = STR_QUTEX + ' ' + name;

                    EmailTemplate emailTemplate;
                    if(emailTemplateMap.containsKey(Id.valueOf(emailWrapper.emailTemplateIdStr))){
                        emailTemplate = emailTemplateMap.get(Id.valueOf(emailWrapper.emailTemplateIdStr));
                    }

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
                        '{username}' => userName};

                        //Build the email
                        Messaging.SingleEmailMessage mail = EmailHelper.emailBuilder(
                                                                            toAddress,
                                                                            subject,
                                                                            emailTemplate.HtmlValue,
                                                                            emailParams);

                        if(!owea.isEmpty()){
                            mail.setOrgWideEmailAddressId(owea[0].Id);
                        }
                        mailList.add(mail);
                    }
                }
                Messaging.sendEmail(mailList);
            }
        }catch(Exception e){
            System.debug(e);
        }

    }

    public void finish(Database.BatchableContext bc) {

    }

    public class EmailWrapper {
        public String recordId;
        public String name;
        public String firstName;
        public String lastName;
        public String toAddress;
        public Date startdate;
        public String emailTemplateIdStr;
        public Date endDate;
        public String paidInFull;
        public String amount;
        public String storeLink;
        public String userName;
    }
}