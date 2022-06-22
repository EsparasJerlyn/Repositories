public with sharing class EmailTriggerFaceToFaceBatch implements Database.Batchable<EmailWrapper>{          

    public Iterable<EmailWrapper> start(Database.BatchableContext bc) {
        Id studentRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        List<EmailWrapper> wrapperList = new List<EmailWrapper>();
        Set<String> faceToFaceSet = new Set<String>{'Brisbane Classroom',
                                                    'Canberra Classroom',
                                                    'Melbourne Classroom',
                                                    'Sydney Classroom'};
        try{
           List<hed__Course_Enrollment__c>  courseEnrollmentList = [SELECT Id, 
                                                                            hed__Course_Offering__r.Delivery_Type__c, 
                                                                            Course_Offering_Start_Date__c,
                                                                            hed__Course_Offering__r.hed__Course__r.Id 
                                                                    FROM hed__Course_Enrollment__c 
                                                                    WHERE RecordTypeId =:studentRecTypeId  
                                                                        AND Id != Null
                                                                        AND Course_Offering_Start_Date__c >= TODAY 
                                                                        AND hed__Course_Offering__r.Delivery_Type__c IN :faceToFaceSet];
           List<Id> courseIdList = new List<Id>();
           for(hed__Course_Enrollment__c loopCourseEnroll : courseEnrollmentList){ 
              courseIdList.add(loopCourseEnroll.hed__Course_Offering__r.hed__Course__r.Id);
           }

           if (!courseIdList.isEmpty()){
            List<Communication_Schedule__c>  courseList = [SELECT Id, 
                                                                Email_on_final_confirmation__c 
                                                            FROM Communication_Schedule__c 
                                                            WHERE Course__c IN :courseIdList 
                                                                AND Email_on_final_confirmation__c = true];
                if (!courseList.isEmpty()){
                    List<Session__c>  sessionList = [SELECT Id, 
                                                            Date__c, 
                                                            Course_Offering__r.hed__Course__r.Name,
                                                            Course_Connection__r.hed__Contact__r.FirstName, 
                                                            Course_Connection__r.hed__Contact__r.LastName, 
                                                            Course_Connection__r.hed__Contact__r.Email 
                                                    FROM Session__c WHERE Course_Offering__r.hed__Course__r.Id IN :courseIdList ];
                    if (!sessionList.isEmpty()){
                        List<Session__c> sessionList2 = new List<Session__c>();  
                        for (Session__c  val : sessionList ){
                            Date mydate = val.Date__c;
                            Date today = Date.today();
                            Integer noOfDays = mydate.daysBetween(today);
                            if (noOfdays== -1){  
                                sessionList2.add(val);    
                            }
                        }      

                        if (!sessionList2.isEmpty()){
                            EmailWrapper wrapper;
                            for (Session__c  val : sessionList2 ){ 
                                wrapper = new EmailWrapper();
                                wrapper.recordId = val.Course_Connection__c;
                                wrapper.name = val.Course_Offering__r.hed__Course__r.Name;
                                wrapper.firstName = val.Course_Connection__r.hed__Contact__r.FirstName;
                                wrapper.lastName = val.Course_Connection__r.hed__Contact__r.LastName;
                                wrapper.toAddress = val.Course_Connection__r.hed__Contact__r.Email;
                                wrapperList.add(wrapper);
                            }      
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

                    String STR_QUTEX = 'QUTeX';
                    String FILE_NAME = 'Face-to-Face(Final Confirmation).pdf';
                    String FACE2FACE_CONFIRMATION_EMAIL_TEMPLATE = 'Face-Face Final Confirmation Email';

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