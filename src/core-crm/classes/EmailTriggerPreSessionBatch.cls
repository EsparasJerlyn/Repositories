public with sharing class EmailTriggerPreSessionBatch implements Database.Batchable<EmailWrapper>{          

    public Iterable<EmailWrapper> start(Database.BatchableContext bc) {
        final Id STUDENT_REC_TYPE = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName()
            .get('Student')
            .getRecordTypeId();
        List<EmailWrapper> wrapperList = new List<EmailWrapper>();

        try{
            //Query all students
            Map<Id, hed__Course_Enrollment__c>  courseEnrollmentMap = new Map<Id, hed__Course_Enrollment__c>([SELECT Id,
                                                                            hed__Contact__r.FirstName, 
                                                                            hed__Contact__r.LastName,
                                                                            hed__Contact__r.Email,
                                                                            hed__Course_Offering__c,
                                                                            hed__Course_Offering__r.hed__Course__r.Name,
                                                                            hed__Course_Offering__r.hed__Course__c,
                                                                            Program_Offering__r.hed_Program_Plan__c
                                                                    FROM hed__Course_Enrollment__c 
                                                                    WHERE RecordTypeId =:STUDENT_REC_TYPE  
                                                                        AND Id != Null
                                                                        AND Course_Offering_Start_Date__c >= TODAY]);

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
            Map<Id, Boolean> courseAllowedEmailMap = new Map<Id, Boolean>();
            if(!courseIdSet.isEmpty() || !progPlanIdSet.isEmpty()){
                for(Communication_Schedule__c commSched : [SELECT Id, Course__c,
                                                                Program_Plan__c,
                                                                Send_email_before_session__c
                                                            FROM Communication_Schedule__c 
                                                            WHERE Send_email_before_session__c = TRUE
                                                                AND (Course__c IN :courseIdSet OR Program_Plan__c IN :progPlanIdSet)]){
                    if(String.isNotBlank(commSched.Course__c)){
                        courseAllowedEmailMap.put(commSched.Course__c, commSched.Send_email_before_session__c);
                    }
                    if(String.isNotBlank(commSched.Program_Plan__c)){
                        courseAllowedEmailMap.put(commSched.Program_Plan__c, commSched.Send_email_before_session__c);
                    }
                }
            }

            if (!courseAllowedEmailMap.isEmpty()){
                //Get all sessions which will starts tomorrow
                Set<Id> offeringWithSessionTomorrow = new Set<Id>();
                for(Session__c session : [SELECT Id,
                                            Date__c,
                                            Course_Offering__c,
                                            Course_Offering__r.hed__Course__c 
                                            FROM Session__c 
                                            WHERE Date__c =:Date.today()+1
                                                AND Course_Offering__r.hed__Course__c IN :courseIdSet]){
                    offeringWithSessionTomorrow.add(session.Course_Offering__r.hed__Course__c);
                }
                
                //Loop through all course connections and check if associated CourseOffering has sessions tomorrow
                //and email reminder is allowed
                for(Id courseConnectionId : courseEnrollmentMap.keySet()){
                    hed__Course_Enrollment__c courseConnection = courseEnrollmentMap.get(courseConnectionId);
                    Boolean allowedEmailReminder = false;

                    //Do not send email if Course has no related Sessions
                    if(offeringWithSessionTomorrow.contains(courseConnection.hed__Course_Offering__r.hed__Course__c)){
                        if(courseAllowedEmailMap.containsKey(courseConnection.hed__Course_Offering__r.hed__Course__c)){
                            allowedEmailReminder = true;
                        } else {
                            // Course is for a Program
                            if(courseAllowedEmailMap.containsKey(courseConnection.Program_Offering__r.hed_Program_Plan__c)){
                                allowedEmailReminder = true;
                            }
                        }
                    }

                    if(allowedEmailReminder){
                        //Send email to this student
                        EmailWrapper wrapper;
                        wrapper = new EmailWrapper();
                        wrapper.recordId = courseConnection.Id;
                        wrapper.name = courseConnection.hed__Course_Offering__r.hed__Course__r.Name;
                        wrapper.firstName = courseConnection.hed__Contact__r.FirstName;
                        wrapper.lastName = courseConnection.hed__Contact__r.LastName;
                        wrapper.toAddress = courseConnection.hed__Contact__r.Email;
                        wrapperList.add(wrapper);
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
                // Get Org Wide Email Address
                List<OrgWideEmailAddress> owea = [SELECT Id, Address, DisplayName
                                                    FROM OrgWideEmailAddress
                                                    WHERE DisplayName = 'QUTeX'LIMIT 1];
                List<EmailWrapper> temp =  (List<EmailWrapper>)records;
                for (EmailWrapper val : temp){  

                    final String STR_QUTEX = 'QUTeX';
                    final String PRE_SESSION_EMAIL_TEMPLATE = 'Pre-Session Reminder Email';
                    final String FILE_NAME = 'Pre-Session Reminder.pdf';

                    String recordId;
                    String name;
                    String firstName;
                    String lastName;
                    String toAddress;
                    /**
                     * Set course connection fields in the email templates
                     **/
                    recordId = val.recordId;
                    name =  val.name;
                    firstName = val.firstName;
                    lastName =  val.lastName;
                    toAddress =  val.toAddress;
                
                    PageReference pdf = new PageReference(
                        '/apex/SessionSchedulePDFView?courseConnectionId=' + recordId);

                    Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                    attachment.setContentType('application/pdf');
                    attachment.setFileName(FILE_NAME);
                    if (Test.isRunningTest()) {
                        attachment.body = blob.valueOf('Unit.Test');
                    } else {
                        attachment.body = pdf.getContent();
                    }
                    attachment.setInline(false);
                
                    EmailTemplate emailTemplate = EmailTemplateSelector.getEmailTemplate(
                                                                                PRE_SESSION_EMAIL_TEMPLATE);
                    String subject = STR_QUTEX + ' ' + name;
                    if (emailTemplate != null) {
                        Map<String, String> emailParams = new Map<String, String>{
                                                                            '{fullname}' => firstName + ' ' + lastName,
                                                                            '{name}' => name};
                
                        //Build the email
                        Messaging.SingleEmailMessage mail = EmailHelper.emailBuilder(
                            toAddress,
                            subject,
                            emailTemplate.HtmlValue,
                            emailParams
                        );

                        if(!owea.isEmpty()){
                            mail.setOrgWideEmailAddressId(owea[0].Id);
                        }
                
                        // Send the email with attachment
                        mail.setFileAttachments(
                            new List<Messaging.EmailFileAttachment>{ attachment }
                        );
                        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
                    }
                }
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
    }   
}