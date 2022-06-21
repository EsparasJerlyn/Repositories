public with sharing class EmailTriggerPostCourseBatch implements Database.Batchable<EmailWrapper>{          

    public Iterable<EmailWrapper> start(Database.BatchableContext bc) {
        List<EmailWrapper> wrapperList = new List<EmailWrapper>();
        try{
            // Get all records from Course Connection (API Name: hed__Course_Enrollment__c)
            Date yesterday = Date.today()-1;
            List<hed__Course_Enrollment__c>  courseEnrollmentList = 
                                                    [SELECT Id, 
                                                            Course_Offering_End_Date__c,
                                                            hed__Course_Offering__r.hed__Course__r.Id,
                                                            hed__Course_Offering__r.Name,
                                                            hed__Contact__r.FirstName,
                                                            hed__Contact__r.LastName,
                                                            hed__Contact__r.Email
                                                    FROM hed__Course_Enrollment__c
                                                    WHERE Id != Null AND Course_Offering_End_Date__c =:yesterday];

            Set<Id> courseIdList = new Set<Id>();
            for(hed__Course_Enrollment__c loopCourseEnroll : courseEnrollmentList){  
                courseIdList.add(loopCourseEnroll.hed__Course_Offering__r.hed__Course__r.Id);      
            }

            if(!courseIdList.isEmpty()){
                // Set to contain Courses which allows email to be set
                Set<Id> coursesAllowedEmail = new Set<Id>();
                for(Communication_Schedule__c commSched : [SELECT Id, Course__c 
                                                            FROM Communication_Schedule__c 
                                                            WHERE Course__c IN :courseIdList AND Email_on_completion__c = true]){
                    coursesAllowedEmail.add(commSched.Course__c);
                }

                // We got courses which allows email to be sent to learner
                if(!coursesAllowedEmail.isEmpty()){
                    for(hed__Course_Enrollment__c courseConnection : courseEnrollmentList){
                        // Check if the course of this learner allows email
                        if(coursesAllowedEmail.contains(courseConnection.hed__Course_Offering__r.hed__Course__r.Id)){
                            EmailWrapper wrapper = new EmailWrapper();
                            wrapper.recordId = courseConnection.Id;
                            wrapper.courseOfferingName = courseConnection.hed__Course_Offering__r.Name;
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
                List<EmailWrapper> temp =  (List<EmailWrapper>)records;
                for (EmailWrapper val : temp){  

                    final String STR_QUTEX = 'QUTeX';
                    final String POST_COURSE_COMPLETION_EMAIL_TEMPLATE = 'Post Course Completion Email';
                    /**
                     * Set course connection fields in the email templates
                     **/
                    String courseOfferingName = val.courseOfferingName;
                    String firstName = val.firstName;
                    String toAddress = val.toAddress;
                
                    EmailTemplate emailTemplate = EmailTemplateSelector.getEmailTemplate(
                        POST_COURSE_COMPLETION_EMAIL_TEMPLATE
                    );
                    String subject = STR_QUTEX + ' ' + courseOfferingName;
                
                    if (emailTemplate != null) {
                        Map<String, String> emailParams = new Map<String, String>{'{firstname}' => firstName,
                                                                                  '{courseOfferingName}' => courseOfferingName};
                
                        //Build the email
                        Messaging.SingleEmailMessage mail = EmailHelper.emailBuilder(
                                                                                    toAddress,
                                                                                    subject,
                                                                                    emailTemplate.HtmlValue,
                                                                                    emailParams
                                                                                    );
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
        public String courseOfferingName;
        public String firstName;
        public String lastName;
        public String toAddress;
    }   
}