/**
 * @description Batch class that triggers email a day before the session start date of a Face-To-Face Course Offerings
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
public with sharing class EmailTriggerFaceToFaceBatch implements Database.Batchable<EmailWrapper>{          

    public Iterable<EmailWrapper> start(Database.BatchableContext bc) {
        final Id STUDENT_REC_TYPE = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName()
            .get('Student')
            .getRecordTypeId();
        List<EmailWrapper> wrapperList = new List<EmailWrapper>();
        Set<String> faceToFaceSet = new Set<String>{'Brisbane Classroom',
                                                    'Canberra Classroom',
                                                    'Melbourne Classroom',
                                                    'Sydney Classroom'};
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
                                                                        AND hed__Course_Offering__r.Delivery_Type__c IN :faceToFaceSet];

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
                for(Communication_Schedule__c commSched : [SELECT Id, Course__c, Days_before_Start_Date__c, Course__r.Id
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
                    final String FILE_NAME = 'Face-to-Face(Final Confirmation).pdf';
                    final String FACE2FACE_CONFIRMATION_EMAIL_TEMPLATE = 'Face-Face Final Confirmation Email';

                    /**
                     * Set course connection fields in the email templates
                     **/
                    String recordId = val.recordId;
                    String name = val.name;
                    String firstName = val.firstName;
                    String lastName = val.lastName;
                    String toAddress = val.toAddress;
                    
                    PageReference pdf = new PageReference(
                    '/apex/FacetoFaceFinalConfirmationPDFView?courseConnectionId=' + recordId
                    );
                    Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                    attachment.setContentType('application/pdf');
                    attachment.setFileName(FILE_NAME);
                    if (Test.isRunningTest()) {
                        attachment.body = blob.valueOf('Unit.Test');
                    } else {
                        attachment.body = pdf.getContent();
                    }
                    attachment.setInline(false);
                
                    EmailTemplate emailTemplate = EmailTemplateSelector.getEmailTemplate(FACE2FACE_CONFIRMATION_EMAIL_TEMPLATE);
                    String subject = STR_QUTEX + ' ' + name;
                
                    if (emailTemplate != null) {
                        Map<String, String> emailParams = new Map<String, String>{
                            '{fullname}' => firstName +
                            ' ' +
                            lastName,
                            '{name}' => name
                        };
                    
                        //Build the email
                        Messaging.SingleEmailMessage mail = EmailHelper.emailBuilder(
                                                                                toAddress,
                                                                                subject,
                                                                                emailTemplate.HtmlValue,
                                                                                emailParams);

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