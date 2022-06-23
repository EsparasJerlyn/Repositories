public with sharing class EmailTriggerOnlineSelfPacedBatch implements Database.Batchable<EmailWrapper>{          

    public Iterable<EmailWrapper> start(Database.BatchableContext bc) {
        Id studentRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        List<EmailWrapper> wrapperList = new List<EmailWrapper>();
        try{
            // Get all records from Course Connection (API Name: hed__Course_Enrollment__c)
            List<hed__Course_Enrollment__c>  courseEnrollmentList = 
                                                    [SELECT Id, 
                                                            Course_Offering_End_Date__c,
                                                            hed__Course_Offering__r.hed__Course__r.Id,
                                                            hed__Course_Offering__r.Name,
                                                            hed__Contact__r.FirstName,
                                                            hed__Contact__r.LastName,
                                                            hed__Contact__r.Email,
                                                    		hed__Course_Offering__r.hed__Course__r.Name,
                                                            hed__Course_Offering__r.hed__Start_Date__c
                                                    FROM hed__Course_Enrollment__c
                                                    WHERE Id != Null AND RecordTypeId =:studentRecTypeId 
                                                        AND Course_Offering_Start_Date__c >= TODAY
                                                        AND hed__Course_Offering__r.Delivery_Type__c = 'Online Self-paced'];

            Set<Id> courseIdList = new Set<Id>();
            for(hed__Course_Enrollment__c loopCourseEnroll : courseEnrollmentList){  
                courseIdList.add(loopCourseEnroll.hed__Course_Offering__r.hed__Course__r.Id);      
            }

            if(!courseIdList.isEmpty()){
                // Set to contain Courses which allows email to be set
                Set<Id> coursesAllowedEmail = new Set<Id>();
                for(Communication_Schedule__c commSched : [SELECT Id, Course__c 
                                                            FROM Communication_Schedule__c 
                                                            WHERE Course__c IN :courseIdList 
                                                                AND Email_on_final_confirmation__c = true]){
                    coursesAllowedEmail.add(commSched.Course__c);
                }

                // We got courses which allows email to be sent to learner
                if(!coursesAllowedEmail.isEmpty()){
                    for(hed__Course_Enrollment__c courseConnection : courseEnrollmentList){
                        // Check if the course of this learner allows email
                        if(coursesAllowedEmail.contains(courseConnection.hed__Course_Offering__r.hed__Course__r.Id)){
                            EmailWrapper wrapper = new EmailWrapper();
                            wrapper.recordId = courseConnection.Id;
                            wrapper.courseOfferingName = courseConnection.hed__Course_Offering__r.hed__Course__r.Name;
                            wrapper.firstName = courseConnection.hed__Contact__r.FirstName;
                            wrapper.lastName = courseConnection.hed__Contact__r.LastName;
                            wrapper.toAddress = courseConnection.hed__Contact__r.Email;
                            wrapper.startdate = courseConnection.hed__Course_Offering__r.hed__Start_Date__c;
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
                    final String ONLINE_SELF_PACED_CONFIRMATION_EMAIL_TEMPLATE = 'Online Self-paced Final Confirmation Email';

                    String recordId;
                    String courseOfferingName;
                    String firstName;
                    String lastName;
                    String toAddress;
                    String startdate;

                    /**
                     * Set course connection fields in the email templates
                     **/
                    recordId = val.recordId;
                    courseOfferingName =  val.courseOfferingName;
                    firstName = val.firstName;
                    lastName =  val.lastName;
                    toAddress =  val.toAddress;
                    DateTime dt = DateTime.newInstance(val.startdate.year(), val.startdate.month(),val.startdate.day());
                    startdate = dt.format('MM/dd/yyyy');

                    EmailTemplate emailTemplate = EmailTemplateSelector.getEmailTemplate(
                        ONLINE_SELF_PACED_CONFIRMATION_EMAIL_TEMPLATE
                      );

                    String subject = STR_QUTEX + ' ' + courseOfferingName;
                    if (emailTemplate != null) {
                        Map<String, String> emailParams = new Map<String, String>{
                          '{firstname}' => firstName,
                          '{startdate}' => startdate
                    };

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

    public void finish(Database.BatchableContext bc) {

    }

    public class EmailWrapper {
        public String recordId;
        public String courseOfferingName;
        public String firstName;
        public String lastName;
        public String toAddress;
        public Date startdate;
    }   
}