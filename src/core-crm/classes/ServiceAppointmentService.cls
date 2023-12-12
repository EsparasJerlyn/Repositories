/**
 * @description Service Class for ServiceAppointmentTriggerHelper class
 *
 * @see ServiceAppointmentTriggerHelper
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------|
 *    | nicole.genon                   | December 4,2023       | DEPP-7259	            | Created File                  |
 *    | ryan.j.a.dela.cruz             | December 12,2023      | DEPP-7259	            | Updated template merge fields |
 */
public inherited sharing class ServiceAppointmentService {
    private static final Map<String, String> CONFIRMATION_EMAIL_TEMPLATE_MAP = new Map<String, String>{
        'International Phone Calls' => 'Bookable Appointment - International Confirmation',
        'Domestic Phone Calls' => 'Bookable Appointment - Domestic Confirmation'
    };
    private static final Map<String, String> REMINDER_EMAIL_TEMPLATE_MAP = new Map<String, String>{
        'International Phone Calls' => 'International Reminder',
        'Domestic Phone Calls' => 'Domestic Reminder'
    };
    private static final Map<String, String> CANCELLED_EMAIL_TEMPLATE_MAP = new Map<String, String>{
        'International Phone Calls' => 'International Cancellation',
        'Domestic Phone Calls' => 'Domestic Cancellation'
    };
    private static final List<String> MONTH_NAMES = new List<String>{'January','February','March','April','May','June','July','August','September','October','November','December'
    };

    /**
     * @description Send email on Service Appointment record creation or reschedule 
     * if work type is Internation team
     *
     * @param internationalServiceAppointments  List of new Service Appointment records 
     * with International Phone Calls work type
     */
    public static void sendEmailToInternationalServiceAppointments(List<ServiceAppointment> internationalServiceAppointments){
        List<ServiceAppointment> reminderEmailRecords = new List<ServiceAppointment>();
        List<OrgWideEmailAddress> owea = OrgWideEmailAddressesDAO.newInstance().getOrgWideEmailAddressByDisplayName(new Set<String>{OrgWideEmailAddressesDAO.ORG_WIDE_EMAIL_INTERNATIONAL_FUTURE_STUDENT_ENQUIRIES},AccessLevel.SYSTEM_MODE);

        // Get Email Template
        List<EmailTemplate> emailTemplate = EmailTemplatesDAO.newInstance().getEmailTemplatesByNameSet(new Set<String>{CONFIRMATION_EMAIL_TEMPLATE_MAP.get(WorkTypesDAO.INTERNATIONAL_WORK_TYPE)},'SYSTEM_MODE');
        List<EmailTemplate> reminderEmailTemplate = EmailTemplatesDAO.newInstance().getEmailTemplatesByNameSet(new Set<String>{REMINDER_EMAIL_TEMPLATE_MAP.get(WorkTypesDAO.INTERNATIONAL_WORK_TYPE)},'SYSTEM_MODE');

        for(ServiceAppointment serviceAppointment : internationalServiceAppointments){
            if(serviceAppointment.SchedStartTime != null && calculateSchedStartDateRange(WorkTypesDAO.INTERNATIONAL_WORK_TYPE,serviceAppointment.SchedStartTime)){
                reminderEmailRecords.add(serviceAppointment);
            }    
        }

        buildEmail(internationalServiceAppointments,owea,emailTemplate.get(0));
        buildEmail(reminderEmailRecords,owea,reminderEmailTemplate.get(0));
    }

    /**
     * @description Send email on Service Appointment record creation or reschedule 
     * if work type is Internation team
     *
     * @param internationalServiceAppointments  List of new Service Appointment records 
     * with International Phone Calls work type
     */
    public static void sendEmailToDomesticServiceAppointments(List<ServiceAppointment> domesticServiceAppointments){
        List<ServiceAppointment> reminderEmailRecords = new List<ServiceAppointment>();
        List<OrgWideEmailAddress> owea = OrgWideEmailAddressesDAO.newInstance().getOrgWideEmailAddressByDisplayName(new Set<String>{OrgWideEmailAddressesDAO.ORG_WIDE_EMAIL_DOMESTIC_FUTURE_STUDENT_ENQUIRIES},AccessLevel.SYSTEM_MODE);

        // Get Email Template
        List<EmailTemplate> emailTemplate = EmailTemplatesDAO.newInstance().getEmailTemplatesByNameSet(new Set<String>{CONFIRMATION_EMAIL_TEMPLATE_MAP.get(WorkTypesDAO.DOMESTIC_WORK_TYPE)},'SYSTEM_MODE');
        List<EmailTemplate> reminderEmailTemplate = EmailTemplatesDAO.newInstance().getEmailTemplatesByNameSet(new Set<String>{REMINDER_EMAIL_TEMPLATE_MAP.get(WorkTypesDAO.DOMESTIC_WORK_TYPE)},'SYSTEM_MODE');

        for(ServiceAppointment serviceAppointment : domesticServiceAppointments){
            if(serviceAppointment.SchedStartTime != null && calculateSchedStartDateRange(WorkTypesDAO.DOMESTIC_WORK_TYPE,serviceAppointment.SchedStartTime)){
                reminderEmailRecords.add(serviceAppointment);
            }
        }

        buildEmail(domesticServiceAppointments,owea,emailTemplate.get(0));
        buildEmail(reminderEmailRecords,owea,reminderEmailTemplate.get(0));
    }

    /**
     * @description Send email if status is cancelled or SchedStartTime and SchedEndTime is updated
     *
     * @param internationalServiceAppointments  List of updated ServiceAppointment records 
     * with International Phone Calls work type
     * @param domesticServiceAppointments  List of updated ServiceAppointment records 
     * with Domestic Phone Calls work type
     */
    public static void sendEmailAfterServiceAppointmentCancellation(List<ServiceAppointment> internationalServiceAppointments,List<ServiceAppointment> domesticServiceAppointments) {
        List<OrgWideEmailAddress> owea = OrgWideEmailAddressesDAO.newInstance().getOrgWideEmailAddressByDisplayName(new Set<String>{OrgWideEmailAddressesDAO.ORG_WIDE_EMAIL_INTERNATIONAL_FUTURE_STUDENT_ENQUIRIES,OrgWideEmailAddressesDAO.ORG_WIDE_EMAIL_DOMESTIC_FUTURE_STUDENT_ENQUIRIES},AccessLevel.SYSTEM_MODE);
        List<EmailTemplate> emailTemplate = EmailTemplatesDAO.newInstance().getEmailTemplatesByNameSet(new Set<String>{CANCELLED_EMAIL_TEMPLATE_MAP.get(WorkTypesDAO.INTERNATIONAL_WORK_TYPE),CANCELLED_EMAIL_TEMPLATE_MAP.get(WorkTypesDAO.DOMESTIC_WORK_TYPE)},'SYSTEM_MODE');
        
        if(!internationalServiceAppointments.isEmpty()){
            buildEmail(internationalServiceAppointments,owea,emailTemplate.get(0));
        }
        if(!domesticServiceAppointments.isEmpty()){
            buildEmail(domesticServiceAppointments,new List<OrgWideEmailAddress> {owea[1]},emailTemplate.get(0));
        }
    }

    public static void buildEmail(List<ServiceAppointment> serviceAppointments, List<OrgWideEmailAddress> owea, EmailTemplate emailTemplate){
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();
        String schedStartTime = '';

        for(ServiceAppointment sa: serviceAppointments){
            if(sa.SchedStartTime != null){
                schedStartTime = formatSchedStartDate(sa.SchedStartTime);
            }
            
            // Set course connection fields in the email templates
            List<String> fieldsOnEmail = setFieldsOnEmailTemplate(sa);
    
            if (emailTemplate != null) {
                Map<String, String> emailParams = new Map<String, String>{
                    '{{{ServiceAppointment.Description}}}' => fieldsOnEmail.get(0),
                    '{{{ServiceAppointment.First_Name__c}}}' => fieldsOnEmail.get(1),
                    '{{{ServiceAppointment.Last_Name__c}}}' => fieldsOnEmail.get(2),
                    '{{{ServiceAppointment.Mobile_Locale__c}}}' => fieldsOnEmail.get(3),
                    '{{{ServiceAppointment.Mobile_No_Locale__c}}}' => fieldsOnEmail.get(4),
                    '{{{ServiceAppointment.Appointment_Topic__c}}}' => fieldsOnEmail.get(5),
                    '{{{ServiceAppointment.Alteration_URL__c}}}' => fieldsOnEmail.get(6),
                    '{{{ServiceAppointment.SchedStartTime}}}' => schedStartTime
                };
    
                // Build the email
                msg.setToAddresses(new String[]{sa.Appointment_Email__c});
                msg.setSubject(emailTemplate.Subject);
                msg.setHtmlBody(EmailHelper.setBodyValues(emailTemplate.HtmlValue, emailParams, false));
                msg.setOrgWideEmailAddressId(owea[0]?.Id);
                msg.setSaveAsActivity(true);
                msg.setTreatTargetObjectAsRecipient(false);
                msg.setUseSignature(false);
    
                sendEmailList.add(msg);
            }
        }

        sendEmail(sendEmailList);
    }

    public static void sendEmail(List<Messaging.SingleEmailMessage> sendEmailList){
        if(!stopSendingEmails()){
            Logger.info('Service Appointment Daily Maximum Email Count has been reached.');
            return;
        }
        
        // make checker if org limit is reached
        // Send Email only when list it's not empty
        if(!sendEmailList.isEmpty()){
            Messaging.SendEmailResult[] results = Messaging.sendEmail(sendEmailList, false);
            getErrorResults((List<Messaging.SendEmailResult>) results);
        }
    }

    /**
     * check limit for email sending
     */
    private static Boolean stopSendingEmails(){        
        Map<String,System.OrgLimit> limitsMap = OrgLimits.getMap();
        System.OrgLimit sendEmailLimit = limitsMap.get('SingleEmail');
       
        return (sendEmailLimit.getValue() >= sendEmailLimit.getLimit());
    } 

    /**
     * retrieves list of failed email sending results
     */
    public static void getErrorResults(List<Messaging.SendEmailResult> sendResults){
        List<Messaging.SendEmailError> errorResults = new List<Messaging.SendEmailError>();
        for (Messaging.SendEmailResult result : sendResults) {
            if (!result.isSuccess()) {
                errorResults = result.getErrors();
                Logger.error('Exception caught in method execute in Apex class ServiceAppointmentService.').addTag(errorResults.toString());
            } 
        }
        if(Logger.getBufferSize() > 0) {
            Logger.saveLog();
        }
    }

    public static Boolean calculateSchedStartDateRange(String workTypeName, DateTime startDate){
        Datetime todayDate = DateTime.now();
        Boolean sched = false;

        // Calculate the difference between end and start dates
        Long timeDifferenceInMilliseconds = startDate.getTime() - todayDate.getTime();

        // Convert milliseconds to hours
        Integer hoursDifference = (Integer)Math.floor(timeDifferenceInMilliseconds / (1000 * 60 * 60));

        if(workTypeName.equals(WorkTypesDAO.INTERNATIONAL_WORK_TYPE) && hoursDifference < 48){
            sched = true;
        }else if(workTypeName.equals(WorkTypesDAO.DOMESTIC_WORK_TYPE) && hoursDifference < 24){
            sched = true;
        }

        return sched;
    }

    public static String formatSchedStartDate(DateTime schedStartTime){
        String minute = String.valueOf(schedStartTime.minute());
        String hourCheck = String.valueOf(math.MOD(schedStartTime.hour(),12));

        if(schedStartTime.minute() < 10){
            minute = '0' + String.valueOf(schedStartTime.minute());
        }

        if(hourCheck.equals('0')){
            hourCheck = '12' ;
        }

        String timeFrame = (schedStartTime.hour() > 11)? 'PM' : 'AM';
        String dateTimeString = MONTH_NAMES.get(schedStartTime.month()-1) + ' ' + schedStartTime.day() + ', ' + schedStartTime.year() + ' ' + hourCheck + ':' + minute + ' ' + timeFrame;

        return dateTimeString;
    }

    public static List<String> setFieldsOnEmailTemplate(ServiceAppointment serviceAppointment){
            List<String> fieldsOnEmail = new List<String>();

            fieldsOnEmail.add((serviceAppointment.Description != null)? serviceAppointment.Description : '');
            fieldsOnEmail.add((serviceAppointment.First_Name__c != null)? serviceAppointment.First_Name__c : '');
            fieldsOnEmail.add((serviceAppointment.Last_Name__c != null)? serviceAppointment.Last_Name__c : '');
            fieldsOnEmail.add((serviceAppointment.Mobile_Locale__c != null)? serviceAppointment.Mobile_Locale__c : '');
            fieldsOnEmail.add((serviceAppointment.Mobile_No_Locale__c != null)? serviceAppointment.Mobile_No_Locale__c : '');
            fieldsOnEmail.add((serviceAppointment.Appointment_Topic__c != null)? serviceAppointment.Appointment_Topic__c : '');
            fieldsOnEmail.add((serviceAppointment.Alteration_URL__c != null)? serviceAppointment.Alteration_URL__c : '');

            return fieldsOnEmail;
    }
}