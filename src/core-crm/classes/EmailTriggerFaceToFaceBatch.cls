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
        Id studentRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
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
                                                                            hed__Course_Offering__r.hed__Course__r.Name,
                                                                            hed__Course_Offering__r.hed__Course__r.Id
                                                                    FROM hed__Course_Enrollment__c 
                                                                    WHERE RecordTypeId =:studentRecTypeId  
                                                                        AND Id != Null
                                                                        AND Course_Offering_Start_Date__c >= TODAY 
                                                                        AND hed__Course_Offering__r.Delivery_Type__c IN :faceToFaceSet];

            Set<Id> courseIdSet = new Set<Id>();
            for(hed__Course_Enrollment__c loopCourseEnroll : courseEnrollmentList){ 
                courseIdSet.add(loopCourseEnroll.hed__Course_Offering__r.hed__Course__r.Id);
            }

            if (!courseIdSet.isEmpty()){
                //Query Courses which allows email notifications
                Set<Id> coursesEmailAllowed = new Set<Id>();
                for(Communication_Schedule__c commSched : [SELECT Id, Course__c 
                                                            FROM Communication_Schedule__c 
                                                            WHERE Course__c IN :courseIdSet AND Email_on_final_confirmation__c = TRUE]){
                    coursesEmailAllowed.add(commSched.Course__c);
                }

                if (!coursesEmailAllowed.isEmpty()){
                    //Get all sessions that starts tomorrow
                    Set<Id> offeringWithSessionTomorrow = new Set<Id>();
                    for(Session__c session : [SELECT Id, Date__c, Course_Offering__c 
                                                FROM Session__c 
                                                WHERE Date__c =:Date.today()+1 AND Course_Offering__r.hed__Course__r.Id IN :courseIdSet]){
                        offeringWithSessionTomorrow.add(session.Course_Offering__c);
                    }
                    
                    //Loop through all course connections and check if associated CourseOffering has sessions tomorrow
                    //and email reminder is allowed
                    for(hed__Course_Enrollment__c courseConnection : courseEnrollmentList){
                        if(offeringWithSessionTomorrow.contains(courseConnection.hed__Course_Offering__c)
                            && coursesEmailAllowed.contains(courseConnection.hed__Course_Offering__r.hed__Course__r.Id )){
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
                List<EmailWrapper> temp =  (List<EmailWrapper>)records;
                for (EmailWrapper val : temp){  

                    final String STR_QUTEX = 'QUTeX';
                    final String FILE_NAME = 'Face-to-Face(Final Confirmation).pdf';
                    final String FACE2FACE_CONFIRMATION_EMAIL_TEMPLATE = 'Face-Face Final Confirmation Email';

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
                
                    EmailTemplate emailTemplate = EmailTemplateSelector.getEmailTemplate(
                    FACE2FACE_CONFIRMATION_EMAIL_TEMPLATE
                    );
                
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
                        emailParams
                    );
                
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