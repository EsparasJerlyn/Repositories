/**
 * @description Batch class that triggers email a day after a Course Offering has ended and sends email to the students
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | marlon.vazquez   		       | June 20,2022          | DEPP-3118/DEPP-3225    | Created file                 | 
      | rhea.b.torres   		       | June 28,2022          | DEPP-3275              | Process Program Offering     |
    
 */
public with sharing class EmailTriggerOnlineSelfPacedBatch implements Database.Batchable<EmailWrapper>{          

    public Iterable<EmailWrapper> start(Database.BatchableContext bc) {
        final Id STUDENT_REC_TYPE = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName()
            .get('Student')
            .getRecordTypeId();
        List<EmailWrapper> wrapperList = new List<EmailWrapper>();

        try{
            //Query all students
            List<hed__Course_Enrollment__c>  courseEnrollmentList = [SELECT Id,
                                                                            hed__Contact__r.FirstName, 
                                                                            hed__Contact__r.LastName,
                                                                            hed__Contact__r.Email,
                                                                            hed__Course_Offering__c,
                                                                            hed__Course_Offering__r.hed__Course__c,
                                                                            hed__Course_Offering__r.hed__Course__r.Name,
                                                                            Course_Offering_Start_Date__c,
                                                                            hed__Course_Offering__r.Delivery_Type__c,
                                                                            RecordTypeId
                                                                    FROM hed__Course_Enrollment__c 
                                                                    WHERE Id != Null 
                                                                        AND RecordTypeId =:STUDENT_REC_TYPE
                                                                        AND Course_Offering_Start_Date__c >= TODAY 
                                                                        AND hed__Course_Offering__r.Delivery_Type__c  = 'Online Self-paced'];

            Set<Id> courseIdSet= new Set<Id>();
            for(hed__Course_Enrollment__c courseConnection : courseEnrollmentList){
                // Add course Id to courseIdSet
                if(String.isNotBlank(courseConnection.hed__Course_Offering__r.hed__Course__c)){
                    courseIdSet.add(courseConnection.hed__Course_Offering__r.hed__Course__c);
                }
            }

            //Get Communication Schedule of the all Courses
            Map<Id, Decimal> courseDaysBeforeMap = new Map<Id, Decimal>();
            if(!courseIdSet.isEmpty()){
                for(Communication_Schedule__c commSched : [SELECT Id,
                                                                Course__c,
                                                                Days_before_Start_Date__c,
                                                                Course__r.Id,
                                                                Email_on_final_confirmation__c
                                                            FROM Communication_Schedule__c 
                                                            WHERE Email_on_final_confirmation__c = TRUE AND Course__c IN :courseIdSet]){
                    courseDaysBeforeMap.put(commSched.Course__r.Id, commSched.Days_before_Start_Date__c);
                }
            }

            if (!courseDaysBeforeMap.isEmpty()){
                for(hed__Course_Enrollment__c courseConnection : courseEnrollmentList){
                    if(courseDaysBeforeMap.containsKey(courseConnection.hed__Course_Offering__r.hed__Course__c)){
                        // Email reminder allowed
                        Integer daysBeforeStartDate = (Integer)courseDaysBeforeMap.get(courseConnection.hed__Course_Offering__r.hed__Course__c);
                        if((courseConnection.Course_Offering_Start_Date__c - daysBeforeStartDate) == Date.today()){
                            //Send email to this student
                            EmailWrapper wrapper = new EmailWrapper();
                            wrapper.recordId = courseConnection.Id;
                            wrapper.courseOfferingName = courseConnection.hed__Course_Offering__r.hed__Course__r.Name;
                            wrapper.firstName = courseConnection.hed__Contact__r.FirstName;
                            wrapper.lastName = courseConnection.hed__Contact__r.LastName;
                            wrapper.toAddress = courseConnection.hed__Contact__r.Email;
                            wrapper.startdate = courseConnection.Course_Offering_Start_Date__c;
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
                        '{startdate}' => startdate};

                        //Build the email
                        Messaging.SingleEmailMessage mail = EmailHelper.emailBuilder(
                                                                            toAddress,
                                                                            subject,
                                                                            emailTemplate.HtmlValue,
                                                                            emailParams);

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