/**
 * @description Batch class that triggers email a day before the session start date of a Virtual Course Offerings
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | marlon.vasquez  		       | June 20,2022          | DEPP-3188              | Created file                 | 
      | rhea.b.torres   		       | June 22,2022          | DEPP-3188              | Updated logic to send email  | 
      |    	                  	       |                       |                        | to the Student               | 
 */
public with sharing class EmailTriggerVirtualBatch implements Database.Batchable<EmailWrapper>{          

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
                                                                            hed__Course_Offering__r.hed__Course__c,
                                                                            hed__Course_Offering__r.hed__Course__r.Name,
                                                                            Course_Offering_Start_Date__c,
                                                                            hed__Course_Offering__r.Delivery_Type__c,
                                                                            RecordTypeId,
                                                                            Program_Offering__r.hed_Program_Plan__c
                                                                    FROM hed__Course_Enrollment__c 
                                                                    WHERE Id != Null 
                                                                        AND RecordTypeId =:STUDENT_REC_TYPE
                                                                        AND Course_Offering_Start_Date__c >= TODAY 
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
                                                                Email_on_final_confirmation__c
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

                    //Do not send email if Course has no related Sessions
                    if(courseSessionMap.containsKey(courseConnection.hed__Course_Offering__r.hed__Course__c)){
                        //Get DaysBeforeStartDate
                        if(courseDaysBeforeMap.containsKey(courseConnection.hed__Course_Offering__r.hed__Course__c)){
                            allowedEmailReminder = true;
                            daysBeforeStartDate = (Integer)courseDaysBeforeMap
                                                                .get(courseConnection.hed__Course_Offering__r.hed__Course__c);
                        } else {
                            // Course is for a Program
                            if(courseDaysBeforeMap.containsKey(courseConnection.Program_Offering__r.hed_Program_Plan__c)){
                                allowedEmailReminder = true;
                                daysBeforeStartDate = (Integer)courseDaysBeforeMap
                                                                .get(courseConnection.Program_Offering__r.hed_Program_Plan__c);
                            }
                        }
                    }

                    if(allowedEmailReminder){
                        // Email reminder allowed
                        if((courseConnection.Course_Offering_Start_Date__c - daysBeforeStartDate) == Date.today()){
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
                    final String FILE_NAME = 'Virtual Class(Final Confirmation).pdf';
                    final String VIRTUAL_CONFIRMATION_EMAIL_TEMPLATE = 'Virtual Final Confirmation Email';

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
                                            '/apex/VirtualClassFinalConfirmationPDFView?courseConnectionId=' + recordId);
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
                                                                            VIRTUAL_CONFIRMATION_EMAIL_TEMPLATE);
                    String subject = STR_QUTEX + ' ' + name;
                
                    if (emailTemplate != null) {
                        Map<String, String> emailParams = new Map<String, String>{
                                                                        '{firstname}' => firstName,
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
                        mail.setFileAttachments(new List<Messaging.EmailFileAttachment>{ attachment });
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