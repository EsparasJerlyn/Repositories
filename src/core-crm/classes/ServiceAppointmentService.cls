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
 */
public inherited sharing class ServiceAppointmentService {
    private static final String INTERNATIONAL_WORK_TYPE = 'International team';
    private static final String DOMESTIC_WORK_TYPE = 'Domestic team';
    private static final Map<String, String> CONFIRMATION_EMAIL_TEMPLATE_MAP = new Map<String, String>{
        'International team' => 'Bookable_Appointment_International_Confirmation_1700639088819',
        'Domestic team' => 'Bookable_Appointment_Domestic_Confirmation_1700702503498'
    };
    private static final Map<String, String> REMINDER_EMAIL_TEMPLATE_MAP = new Map<String, String>{
        'International team' => 'International_Reminder_1700703819733',
        'Domestic team' => 'Domestic_Reminder_1700703497776'
    };
    private static final Map<String, String> CANCELLED_EMAIL_TEMPLATE_MAP = new Map<String, String>{
        'International team' => 'International_Cancellation_1701248664023',
        'Domestic team' => 'Domestic_Cancellation_1701248527521'
    };
    private static final Map<String, String> ORG_WIDE_EMAIL_ADDRESS_MAP = new Map<String, String>{
        'International team' => 'International Future Student Enquiries',
        'Domestic team' => 'Domestic Future Student Enquiries'
    };
    private static final List<String> MONTH_NAMES = new List<String>{'January','February','March','April','May','June','July','August','September','October','November','December'
    };

    /**
     * @description Send email on Service Appointment record creation or reschedule 
     * if work type is Internation team
     *
     * @param internationalServiceAppointments  List of new Service Appointment records 
     * with International team work type
     */
    public static void sendEmailToInternationalServiceAppointments(List<ServiceAppointment> internationalServiceAppointments){
        List<ServiceAppointment> reminderEmailRecords = new List<ServiceAppointment>();
        List<OrgWideEmailAddress> owea = OrgWideEmailAddressesDAO.newInstance().getOrgWideEmailAddressByDisplayName(new Set<String>{ORG_WIDE_EMAIL_ADDRESS_MAP.get(INTERNATIONAL_WORK_TYPE)},AccessLevel.SYSTEM_MODE);

        // Get Email Template
        List<EmailTemplate> emailTemplate = EmailTemplatesDAO.newInstance().getEmailTemplatesByDeveloperNameSet(new Set<String>{CONFIRMATION_EMAIL_TEMPLATE_MAP.get(INTERNATIONAL_WORK_TYPE)},'SYSTEM_MODE');
        List<EmailTemplate> reminderEmailTemplate = EmailTemplatesDAO.newInstance().getEmailTemplatesByDeveloperNameSet(new Set<String>{REMINDER_EMAIL_TEMPLATE_MAP.get(INTERNATIONAL_WORK_TYPE)},'SYSTEM_MODE');

        for(ServiceAppointment serviceAppointment : internationalServiceAppointments){
            if(serviceAppointment.SchedStartTime != null && calculateSchedStartDateRange(INTERNATIONAL_WORK_TYPE,serviceAppointment.SchedStartTime)){
                reminderEmailRecords.add(serviceAppointment);
            }    
        }

        sendEmail(internationalServiceAppointments,owea,emailTemplate.get(0));
        sendEmail(reminderEmailRecords,owea,reminderEmailTemplate.get(0));
    }

    /**
     * @description Send email on Service Appointment record creation or reschedule 
     * if work type is Internation team
     *
     * @param internationalServiceAppointments  List of new Service Appointment records 
     * with International team work type
     */
    public static void sendEmailToDomesticServiceAppointments(List<ServiceAppointment> domesticServiceAppointments){
        List<ServiceAppointment> reminderEmailRecords = new List<ServiceAppointment>();
        List<OrgWideEmailAddress> owea = OrgWideEmailAddressesDAO.newInstance().getOrgWideEmailAddressByDisplayName(new Set<String>{ORG_WIDE_EMAIL_ADDRESS_MAP.get(DOMESTIC_WORK_TYPE)},AccessLevel.SYSTEM_MODE);

        // Get Email Template
        List<EmailTemplate> emailTemplate = EmailTemplatesDAO.newInstance().getEmailTemplatesByDeveloperNameSet(new Set<String>{CONFIRMATION_EMAIL_TEMPLATE_MAP.get(DOMESTIC_WORK_TYPE)},'SYSTEM_MODE');
        List<EmailTemplate> reminderEmailTemplate = EmailTemplatesDAO.newInstance().getEmailTemplatesByDeveloperNameSet(new Set<String>{REMINDER_EMAIL_TEMPLATE_MAP.get(DOMESTIC_WORK_TYPE)},'SYSTEM_MODE');

        for(ServiceAppointment serviceAppointment : domesticServiceAppointments){
            if(serviceAppointment.SchedStartTime != null && calculateSchedStartDateRange(DOMESTIC_WORK_TYPE,serviceAppointment.SchedStartTime)){
                reminderEmailRecords.add(serviceAppointment);
            }    
        }

        sendEmail(domesticServiceAppointments,owea,emailTemplate.get(0));
        sendEmail(reminderEmailRecords,owea,reminderEmailTemplate.get(0));
    }

    /**
     * @description Send email if status is cancelled or SchedStartTime and SchedEndTime is updated
     *
     * @param internationalServiceAppointments  List of updated ServiceAppointment records 
     * with International team work type
     * @param domesticServiceAppointments  List of updated ServiceAppointment records 
     * with Domestic team work type
     */
    public static void sendEmailAfterServiceAppointmentCancellation(List<ServiceAppointment> internationalServiceAppointments,List<ServiceAppointment> domesticServiceAppointments) {
        List<OrgWideEmailAddress> owea = OrgWideEmailAddressesDAO.newInstance().getOrgWideEmailAddressByDisplayName(new Set<String>{ORG_WIDE_EMAIL_ADDRESS_MAP.get(INTERNATIONAL_WORK_TYPE),ORG_WIDE_EMAIL_ADDRESS_MAP.get(DOMESTIC_WORK_TYPE)},AccessLevel.SYSTEM_MODE);
        List<EmailTemplate> emailTemplate = EmailTemplatesDAO.newInstance().getEmailTemplatesByDeveloperNameSet(new Set<String>{CANCELLED_EMAIL_TEMPLATE_MAP.get(INTERNATIONAL_WORK_TYPE),CANCELLED_EMAIL_TEMPLATE_MAP.get(DOMESTIC_WORK_TYPE)},'USER_MODE');
        
        if(!internationalServiceAppointments.isEmpty()){
            sendEmail(internationalServiceAppointments,owea,emailTemplate.get(0));
        }
        if(!domesticServiceAppointments.isEmpty()){
            sendEmail(domesticServiceAppointments,new List<OrgWideEmailAddress> {owea[1]},emailTemplate.get(0));
        }
    }

    public static void sendEmail(List<ServiceAppointment> serviceAppointments, List<OrgWideEmailAddress> owea, EmailTemplate emailTemplate){
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
                    '{{{ServiceAppointment.SchedStartTime}}}' => schedStartTime
                };
    
                //Build the email
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

        // Send Email only when list it's not empty
        if(!sendEmailList.isEmpty()){
            Messaging.sendEmail(sendEmailList);
        }
    }

    public static Boolean calculateSchedStartDateRange(String workTypeName, DateTime startDate){
        Datetime todayDate = DateTime.now();
        Boolean sched = false;

        // Calculate the difference between end and start dates
        Long timeDifferenceInMilliseconds = startDate.getTime() - todayDate.getTime();

        // Convert milliseconds to hours
        Integer hoursDifference = (Integer)Math.floor(timeDifferenceInMilliseconds / (1000 * 60 * 60));

        if(workTypeName.equals('International team') && hoursDifference < 48){
            sched = true;
        }else if(workTypeName.equals('Domestic team') && hoursDifference < 24){
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

            return fieldsOnEmail;
    }
}