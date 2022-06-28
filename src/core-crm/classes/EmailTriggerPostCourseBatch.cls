/**
 * @description Batch class that triggers email a day after a Course Offering has ended and sends email to the students
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | rhea.b.torres   		       | June 20,2022          | DEPP-3118/DEPP-3225    | Created file                 | 
      | rhea.b.torres   		       | June 27,2022          | DEPP-3275              | Process Program Offering     |
    
 */
public with sharing class EmailTriggerPostCourseBatch implements Database.Batchable<EmailWrapper>{          

    public Iterable<EmailWrapper> start(Database.BatchableContext bc) {
        final Id STUDENT_REC_TYPE = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName()
            .get('Student')
            .getRecordTypeId();
        List<EmailWrapper> wrapperList = new List<EmailWrapper>();
        try{
            // Get all records from Course Connection (API Name: hed__Course_Enrollment__c)
            List<hed__Course_Enrollment__c>  courseEnrollmentList = 
                                                    [SELECT Id, 
                                                            Offering_End_Date__c,
                                                            hed__Course_Offering__r.hed__Course__c,
                                                            hed__Course_Offering__r.hed__Course__r.Name,
                                                            hed__Contact__r.FirstName,
                                                            hed__Contact__r.LastName,
                                                            hed__Contact__r.Email
                                                    FROM hed__Course_Enrollment__c
                                                    WHERE Id != Null 
                                                        AND RecordTypeId =:STUDENT_REC_TYPE
                                                        AND Offering_End_Date__c =:Date.today()-1];

            Set<Id> courseIdSet= new Set<Id>();
            for(hed__Course_Enrollment__c courseConnection : courseEnrollmentList){
                // Add course Id to courseIdSet
                if(String.isNotBlank(courseConnection.hed__Course_Offering__r.hed__Course__c)){
                    courseIdSet.add(courseConnection.hed__Course_Offering__r.hed__Course__c);
                }
            }

            if (!courseIdSet.isEmpty()){
                // Query Courses which allows email notifications
                Set<Id> coursesEmailAllowed = new Set<Id>();
                for(Communication_Schedule__c commSched : [SELECT Id, Course__c, Email_on_completion__c 
                                                            FROM Communication_Schedule__c 
                                                            WHERE Course__c IN :courseIdSet AND Email_on_completion__c = TRUE]){
                    coursesEmailAllowed.add(commSched.Course__c);
                }

                if(!coursesEmailAllowed.isEmpty()){
                    for(hed__Course_Enrollment__c courseConnection : courseEnrollmentList){
                        if(coursesEmailAllowed.contains(courseConnection.hed__Course_Offering__r.hed__Course__c)){
                            //Send email to this student
                            EmailWrapper wrapper;
                            wrapper = new EmailWrapper();
                            wrapper.recordId = courseConnection.Id;
                            wrapper.productOfferingName = courseConnection.hed__Course_Offering__r.hed__Course__r.Name;
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
                    final String POST_COURSE_COMPLETION_EMAIL_TEMPLATE = 'Post Course Completion Email';
                    /**
                     * Set course connection fields in the email templates
                     **/
                    String productOfferingName = val.productOfferingName;
                    String firstName = val.firstName;
                    String toAddress = val.toAddress;
                
                    EmailTemplate emailTemplate = EmailTemplateSelector.getEmailTemplate(
                        POST_COURSE_COMPLETION_EMAIL_TEMPLATE
                    );
                    String subject = STR_QUTEX + ' ' + productOfferingName;
                
                    if (emailTemplate != null) {
                        Map<String, String> emailParams = new Map<String, String>{'{firstname}' => firstName,
                                                                                  '{courseOfferingName}' => productOfferingName};
                
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
                        // Send the email
                        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
                    }
                }
            }
        }catch(Exception e){  
            System.debug(e);
        }           

    }

    public void finish(Database.BatchableContext bc) {}

    public class EmailWrapper {
        public String recordId;
        public String productOfferingName;
        public String firstName;
        public String lastName;
        public String toAddress;
    }   
}