/**
 * @description helper class for ServiceAppointmentTriggerHelper
 * @see ServiceAppointmentTriggerHelper
 *
 * @author Accenture-
 *
 * @history 
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                           |
 *    |--------------------------------|-----------------------|------------------------|----------------------------------------------------------|
 *    | arsenio.jr.dayrit              | November 21, 2023     | DEPP-7264              | Created file                                             |
 *    | nicole.genon                   | November 21, 2023     | DEPP-7259              | Added methods for email for confirmation and reminder    |
 *    | kenneth.f.alsay                | November 30, 2023     | DEPP-7265              | Added methods for existing lead and contact matching     |
 *    | ryan.j.a.dela.cruz             | December 6, 2023      | DEPP-7369              | Confirmation email sending fix                           |
 *    | kenneth.f.alsay                | December 11, 2023     | DEPP-7394              | Added convert email string to lower case before matching |
 *    | kenneth.f.alsay                | December 27, 2023     |                        | Removed unused variables                                 |
 */

public without sharing class ServiceAppointmentTriggerHelper {
// ADD COMMENT
    /**
     * @description update the Contact or Lead and its related Marketing Segmentation record from Service Appointment
     *
     * @param newItems  List of new Service Appointment records
     */
     public static void updateContactLeadLinkedtoServiceAppointment(List<ServiceAppointment> newItems) {
        try{
            Map<Id,Contact> contactToUpdateMap = new Map<Id,Contact>();
            Map<Id,Lead> leadToUpdateMap = new Map<Id,Lead>();
            Map<Id,ServiceAppointment> serviceAppointmentMap = new Map<Id,ServiceAppointment>();
            for(ServiceAppointment serviceAppointment : newItems){
                Boolean isContactEmpty = (String.isEmpty(serviceAppointment.Contact__c));
                Boolean isLeadEmpty = (String.isEmpty(serviceAppointment.LeadId__c));
                if(!isContactEmpty){
                    mapServiceAppointmentToRelatedContact(contactToUpdateMap, serviceAppointmentMap, serviceAppointment);
                }
                else if(!isLeadEmpty){
                    mapServiceAppointmentToRelatedLead(leadToUpdateMap, serviceAppointmentMap, serviceAppointment);
                }
            }

            if(!contactToUpdateMap.values().isEmpty()){
                ContactsDAO.newInstance().updateRecords(contactToUpdateMap.values(), false, AccessLevel.SYSTEM_MODE);
            }
            if(!leadToUpdateMap.values().isEmpty()){
                LeadsDAO.newInstance().updateRecords(leadToUpdateMap.values(), false, AccessLevel.SYSTEM_MODE);
            }
            
            updateMarketingSegLinkedToContactOrLead(contactToUpdateMap,leadToUpdateMap,serviceAppointmentMap);

        } catch (Exception e) {
            Logger.error('Exception caught in method updateContactLeadLinkedtoServiceAppointment in class ServiceAppointmentTriggerHelper.')
              .setExceptionDetails(e);
          } finally {
            if(Logger.getBufferSize() > 0) {
              Logger.saveLog();
            }
          }
     }

      /**
     * @description: get existing application preference Id from Package Component
     *
     * @param Set<Id>  Application Preference Id to evaluate
     */
    private static void updateMarketingSegLinkedToContactOrLead(Map<Id,Contact> contactMap, Map<Id,Lead> leadMap, Map<Id,ServiceAppointment> serviceAppointmentMap) {
        List<Marketing_Segmentation__c> marketingSegToUpdate = new List<Marketing_Segmentation__c>();
        List<Marketing_Segmentation__c> marketingSegList = MarketingSegmentationsDAO.newInstance().getMarketingSegmentationByContactOrLead(contactMap.keySet(),leadMap.keySet(), AccessLevel.SYSTEM_MODE);
        for(Marketing_Segmentation__c marketingSeg : marketingSegList){
            Boolean forContact = serviceAppointmentMap.containsKey(marketingSeg.Contact__c);
            Boolean forLead = serviceAppointmentMap.containsKey(marketingSeg.Lead__c);
            if(forContact){
                mapServiceAppointmentToContactMarketingSeg(marketingSeg, serviceAppointmentMap, marketingSegToUpdate);
            }
            else if(forLead){
                mapServiceAppointmentToLeadMarketingSeg(marketingSeg, serviceAppointmentMap, marketingSegToUpdate);
            }
        }

        if(!marketingSegToUpdate.isEmpty()){
            MarketingSegmentationsDAO.newInstance().updateRecords(marketingSegToUpdate,false, AccessLevel.SYSTEM_MODE);
        }
    }

    private static void mapServiceAppointmentToRelatedContact(Map<Id,Contact> contactToUpdateMap, Map<Id,ServiceAppointment> serviceAppointmentMap, ServiceAppointment serviceAppointment){
        Contact con = new Contact();
        con.id = serviceAppointment.Contact__c;
        if(serviceAppointment.Email != null){
            con.Email = serviceAppointment.Email;
        }
        if(serviceAppointment.Mobile_Locale__c != null){
            con.ContactMobile_Locale__c = serviceAppointment.Mobile_Locale__c;
        }
        if(serviceAppointment.Mobile_No_Locale__c != null){
            con.Mobile_No_Locale__c = serviceAppointment.Mobile_No_Locale__c;
        }
        if(serviceAppointment.Marketing_Consent__c){
            con.Email_Opt_In_DateTime__c = System.Now();
        }
        contactToUpdateMap.put(serviceAppointment.Contact__c,con);
        serviceAppointmentMap.put(serviceAppointment.Contact__c,serviceAppointment);
    }

    private static void mapServiceAppointmentToRelatedLead(Map<Id,Lead> leadToUpdateMap, Map<Id,ServiceAppointment> serviceAppointmentMap, ServiceAppointment serviceAppointment){
        Lead lead = new Lead();
        lead.id = serviceAppointment.LeadId__c;
        if(serviceAppointment.Email != null){
            lead.Email = serviceAppointment.Email;
        }
        if(serviceAppointment.Mobile_Locale__c != null){
            lead.LeadMobile_Locale__c = serviceAppointment.Mobile_Locale__c;
        }
        if(serviceAppointment.Mobile_No_Locale__c != null){
            lead.Mobile_No_Locale__c = serviceAppointment.Mobile_No_Locale__c;
        }
        if(serviceAppointment.Marketing_Consent__c){
            lead.Email_Opt_In_DateTime__c = System.Now();
        }
        leadToUpdateMap.put(serviceAppointment.LeadId__c,lead);
        serviceAppointmentMap.put(serviceAppointment.LeadId__c,serviceAppointment);
    }

    private static void mapServiceAppointmentToContactMarketingSeg(Marketing_Segmentation__c marketingSeg, Map<Id,ServiceAppointment> serviceAppointmentMap, List<Marketing_Segmentation__c> marketingSegToUpdate){
        boolean hasChanged = false;
        
        if(serviceAppointmentMap.get(marketingSeg.Contact__c).My_Citizenship_Status__c != null){
            marketingSeg.My_Citizenship_Status__c = serviceAppointmentMap.get(marketingSeg.Contact__c).My_Citizenship_Status__c;
            hasChanged = true;
        }
        if(serviceAppointmentMap.get(marketingSeg.Contact__c).My_Country_Of_Citizenship__c != null){
            marketingSeg.My_Country_Of_Citizenship__c = serviceAppointmentMap.get(marketingSeg.Contact__c).My_Country_Of_Citizenship__c;
            hasChanged = true;
        }
        if(serviceAppointmentMap.get(marketingSeg.Contact__c).My_Country_Of_Residency__c != null){
            marketingSeg.My_Country_Of_Residency__c = serviceAppointmentMap.get(marketingSeg.Contact__c).My_Country_Of_Residency__c;
            hasChanged = true;
        }
        if(hasChanged){
            marketingSegToUpdate.add(marketingSeg);
        }   
    }

    private static void mapServiceAppointmentToLeadMarketingSeg(Marketing_Segmentation__c marketingSeg, Map<Id,ServiceAppointment> serviceAppointmentMap, List<Marketing_Segmentation__c> marketingSegToUpdate){
        boolean hasChanged = false;
        
        if(serviceAppointmentMap.get(marketingSeg.Lead__c).My_Citizenship_Status__c != null){
            marketingSeg.My_Citizenship_Status__c = serviceAppointmentMap.get(marketingSeg.Lead__c).My_Citizenship_Status__c;
            hasChanged = true;
        }
        if(serviceAppointmentMap.get(marketingSeg.Lead__c).My_Country_Of_Citizenship__c != null){
            marketingSeg.My_Country_Of_Citizenship__c = serviceAppointmentMap.get(marketingSeg.Lead__c).My_Country_Of_Citizenship__c;
            hasChanged = true;
        }
        if(serviceAppointmentMap.get(marketingSeg.Lead__c).My_Country_Of_Residency__c != null){
            marketingSeg.My_Country_Of_Residency__c = serviceAppointmentMap.get(marketingSeg.Lead__c).My_Country_Of_Residency__c;
            hasChanged = true;
        }
        if(hasChanged){
            marketingSegToUpdate.add(marketingSeg);
        }  
    }

    //map of object type to the field api names of the fields to be matched
    private static final Map<SObjectType, List<String>> OBJECT_MAP = new Map<SObjectType, List<String>>{
        Lead.SObjectType => new List<String>{ 'Email', 'Work_Email__c' },
            Contact.SObjectType => new List<String>{
                'Email',
                    'Work_Email__c',
                    'QUT_Learner_Email__c',
                    'QUT_Staff_Email__c'
                    }
    };

	/**
    * @description: Match the case supplied email from an existing contact or lead email address to
    *               the new created case record
    * @param newItems - List of case record
    */
    public static void matchExistingContactOrLeadToAppointment(List<ServiceAppointment> newAppointmentList) {
        ServiceAppointmentTriggerHelperWithoutSharing withoutSharingInnerClass = new ServiceAppointmentTriggerHelperWithoutSharing();
        
        Set<String> suppliedEmails = new Set<String>();
        Map<String, ServiceAppointment> emailToAppointmentMap = new Map<String, ServiceAppointment>();
        Map<String, Id> appointmentToContactMap = new Map<String, Id>();
        Map<String, Id> appointmentToLeadMap = new Map<String, Id>();
        
        for (ServiceAppointment appointment : newAppointmentList) {
            Boolean isWithEmailAndContactAndLeadEmpty = (String.isEmpty(appointment.Contact__c) &&
                                                         String.isEmpty(appointment.LeadId__c)) && String.isNotEmpty(appointment.Email);
            
            if ( isWithEmailAndContactAndLeadEmpty) {
                //convert email to all lowercase
                String email = appointment.Email;
                appointment.Email = email.toLowerCase();
                suppliedEmails.add(appointment.Email);
                emailToAppointmentMap.put(appointment.Email, appointment);
            }
        }
        if (!suppliedEmails.isEmpty()) {
            appointmentToContactMap = withoutSharingInnerClass.processAppointmentRecordsToContactMatch(suppliedEmails, emailToAppointmentMap);
        }
        if(!appointmentToContactMap.isEmpty()){
            for(ServiceAppointment record: newAppointmentList){
                if(appointmentToContactMap.containsKey(record.Email)){
                    record.Contact__c = appointmentToContactMap.get(record.Email);
                }
            }
        }
        if(!emailToAppointmentMap.isEmpty()){
			appointmentToLeadMap = withoutSharingInnerClass.processAppointmentRecordsToLeadMatch(suppliedEmails, emailToAppointmentMap);   
        }
        if(!appointmentToLeadMap.isEmpty()){
            for(ServiceAppointment record: newAppointmentList){
                if(appointmentToLeadMap.containsKey(record.Email) && appointmentToContactMap.containsKey(record.Email)){
                    //remove assigned Contact Id if Lead match found
                    record.Contact__c = null;
                }else if(appointmentToLeadMap.containsKey(record.Email) && !appointmentToContactMap.containsKey(record.Email)){                    
                    record.LeadId__c = appointmentToLeadMap.get(record.Email);
                }
            }
        }
    }

    /**
     * @description Send email if status is cancelled or SchedStartTime and SchedEndTime is updated
     *
     * @param newItems  List of new ServiceAppointment records
     * @param oldItems  Map of old ServiceAppointment records
     */
    public static void sendEmailOnServiceAppointmentUpdate(List<ServiceAppointment> newItems, Map<Id, ServiceAppointment> oldItems) {
        checkCreatedAppointments(newItems,oldItems);
        checkCancelledAppointments(newItems,oldItems);
        checkRescheduledAppointments(newItems,oldItems);
    }

    /**
     * @description Generate GUID
     * @param newItems List of new ServiceAppointment records
     */
    public static void generateGUID(List<ServiceAppointment> newItems) {
        for(ServiceAppointment appointment : newItems) {
            if(appointment.GUID__c == null) {
                appointment.GUID__c = GenerateUniqueId.getUUID();
            }
        }
    }

    /**
     * @description Send email on Service Appointment record creation 
     * if work Type is either International Phone Calls or Domestic Phone Calls
     *
     * @param newItems  List of new Service Appointment records
     */
    public static void checkCreatedAppointments(List<ServiceAppointment> newItems, Map<Id, ServiceAppointment> oldItems){
        List<ServiceAppointment> internationalServiceAppointments = new List<ServiceAppointment>();
        List<ServiceAppointment> domesticServiceAppointments = new List<ServiceAppointment>();
        List<WorkType> internationalWorkType = WorkTypesDAO.newInstance().getWorkTypesBySetNames(new Set<String> {WorkTypesDAO.INTERNATIONAL_WORK_TYPE},AccessLevel.SYSTEM_MODE);
        List<WorkType> domesticWorkType = WorkTypesDAO.newInstance().getWorkTypesBySetNames(new Set<String> {WorkTypesDAO.DOMESTIC_WORK_TYPE},AccessLevel.SYSTEM_MODE);

        for(ServiceAppointment serviceAppointment : newItems){

            // Check if the Confirmation_Email_Sent__c has changed
            if (oldItems.containsKey(serviceAppointment.Id)) {
                ServiceAppointment oldItem = oldItems.get(serviceAppointment.Id);

                if (serviceAppointment.Confirmation_Email_Sent__c != oldItem.Confirmation_Email_Sent__c) {
                    if(serviceAppointment.WorkTypeId != null && String.IsNotBlank(serviceAppointment.Appointment_Email__c) && serviceAppointment.WorkTypeId == internationalWorkType.get(0).id){
                        internationalServiceAppointments.add(serviceAppointment);
                    }
        
                    if(serviceAppointment.WorkTypeId != null && String.IsNotBlank(serviceAppointment.Appointment_Email__c) && serviceAppointment.WorkTypeId == domesticWorkType.get(0).id){
                        domesticServiceAppointments.add(serviceAppointment);
                    }
                }
            }
        }

        if(!internationalServiceAppointments.isEmpty()){
            ServiceAppointmentService.sendConfirmationEmailToInternationalServiceAppointments(internationalServiceAppointments);
        }
        if(!domesticServiceAppointments.isEmpty()){
            ServiceAppointmentService.sendConfirmationEmailToDomesticServiceAppointments(domesticServiceAppointments);
        }
    }

    /**
     * Checks for cancelled appointments and processes them.
     *
     * @param newItems   List of new service appointments
     * @param oldItems   Map of old service appointments
     */
    private static void checkCancelledAppointments(List<ServiceAppointment> newItems, Map<Id, ServiceAppointment> oldItems) {
        // Lists to store international and domestic service appointments
        List<ServiceAppointment> internationalServiceAppointments = new List<ServiceAppointment>();
        List<ServiceAppointment> domesticServiceAppointments = new List<ServiceAppointment>();

        // Fetching international and domestic work types
        List<WorkType> internationalWorkType = WorkTypesDAO.newInstance().getWorkTypesBySetNames(new Set<String> {WorkTypesDAO.INTERNATIONAL_WORK_TYPE}, AccessLevel.SYSTEM_MODE);
        List<WorkType> domesticWorkType = WorkTypesDAO.newInstance().getWorkTypesBySetNames(new Set<String> {WorkTypesDAO.DOMESTIC_WORK_TYPE}, AccessLevel.SYSTEM_MODE);

        // Loop through new service appointments
        for (ServiceAppointment sa : newItems) {
            // Check if the appointment was not previously cancelled, is now cancelled, has a WorkTypeId, and Appointment_Email__c is not blank
            if (!oldItems.get(sa.Id).status.equals('Cancelled') && sa.status.equals('Cancelled') && sa.WorkTypeId != null && String.IsNotBlank(sa.Appointment_Email__c)) {
                // Categorize appointments based on work type
                if (sa.WorkTypeId == internationalWorkType.get(0).id) {
                    internationalServiceAppointments.add(sa);
                } else if (sa.WorkTypeId == domesticWorkType.get(0).id) {
                    domesticServiceAppointments.add(sa);
                }
            }
        }

        // Check if there are cancelled appointments
        Boolean withCancelledAppointments = !internationalServiceAppointments.isEmpty() || !domesticServiceAppointments.isEmpty();

        // If there are cancelled appointments, send emails
        if (withCancelledAppointments) {
            ServiceAppointmentService.sendEmailAfterServiceAppointmentCancellation(internationalServiceAppointments, domesticServiceAppointments);
        }
    }


    public static void checkRescheduledAppointments(List<ServiceAppointment> newItems, Map<Id, ServiceAppointment> oldItems) {
        List<ServiceAppointment> internationalServiceAppointments = new List<ServiceAppointment>();
        List<ServiceAppointment> domesticServiceAppointments = new List<ServiceAppointment>();
        
        List<WorkType> internationalWorkType = WorkTypesDAO.newInstance().getWorkTypesBySetNames(new Set<String> {WorkTypesDAO.INTERNATIONAL_WORK_TYPE},AccessLevel.SYSTEM_MODE);
        List<WorkType> domesticWorkType = WorkTypesDAO.newInstance().getWorkTypesBySetNames(new Set<String> {WorkTypesDAO.DOMESTIC_WORK_TYPE},AccessLevel.SYSTEM_MODE);

        Map<Id, String> workTypeMap = new Map<Id, String>{
            internationalWorkType.get(0).id => internationalWorkType.get(0).Name,
            domesticWorkType.get(0).id => domesticWorkType.get(0).Name
        };
        
        Boolean emailSent = false;

        for (ServiceAppointment sa : newItems) {
                          
            if((sa.SchedStartTime == null && sa.SchedEndTime == null) || !String.IsNotBlank(sa.Appointment_Email__c)){
                emailSent = false;
            }else if((sa.SchedEndTime != null && oldItems.get(sa.Id).SchedEndTime == null) || (sa.SchedStartTime != null && oldItems.get(sa.Id).SchedStartTime == null) || (!sa.SchedStartTime.isSameDay(oldItems.get(sa.Id).SchedStartTime) || !sa.SchedEndTime.isSameDay(oldItems.get(sa.Id).SchedEndTime) || 
            sa.SchedStartTime.time() != oldItems.get(sa.Id).SchedStartTime.time() || sa.SchedEndTime.time() != oldItems.get(sa.Id).SchedEndTime.time()) && 
            sa.WorkTypeId != null && String.IsNotBlank(sa.Appointment_Email__c) && !sa.status.equals('Cancelled') && workTypeMap.containsKey(sa.WorkTypeId)){
                if(sa.WorkTypeId == internationalWorkType.get(0).id){
                    internationalServiceAppointments.add(sa);
                }
                if(sa.WorkTypeId == domesticWorkType.get(0).id){
                    domesticServiceAppointments.add(sa);
                }
            }
        }

        if(!internationalServiceAppointments.isEmpty()){
            ServiceAppointmentService.sendConfirmationEmailToInternationalServiceAppointments(internationalServiceAppointments);
        }

        if(!domesticServiceAppointments.isEmpty()){
            ServiceAppointmentService.sendConfirmationEmailToDomesticServiceAppointments(domesticServiceAppointments);
        }
    }
    
    /**
	* @description: Check contact or lead records for any potential match of an existing contact
	* and returns a Map of the supplied email to the matching contact Id
	* @param Set<String> suppliedEmails
	* @param Map<String,ServiceAppointment> emailToAppointmentMap
	*/
    
    private static Map<String, Id> processAppointmentRecordsToContactMatch(
        Set<String> suppliedEmails,
        Map<String, ServiceAppointment> emailToAppointmentMap
    ) {
        List<ServiceAppointment> appointmentToUpdate = new List<ServiceAppointment>();
        DuplicateCheckerHelper.newItemsMatchCount = new Map<String, Integer>();
        Map<String,Id> appointmentToContactMap = new Map<String, Id>();
        List<Contact> existingContactsWithMatchingEmails = ContactsDAO.newInstance()
            .getExistingPersonContactsWithMatchingEmails(
                suppliedEmails,
                new Set<Id>(),
                'SYSTEM_MODE'
            );
        
        if (!existingContactsWithMatchingEmails.isEmpty()) {
            for (Contact newRecord : existingContactsWithMatchingEmails) {
                DuplicateCheckerHelper.countUniqueFieldsToMap(
                    newRecord,
                    new ContactsDAO().getSObjectType()
                );
            }
            
            if (!DuplicateCheckerHelper.newItemsMatchCount.isEmpty()) {
                //get unique contact record
                Map<String, String> uniqueContactMap = getUniqueRecords(
                    (List<sObject>) existingContactsWithMatchingEmails,
                    new ContactsDAO().getSObjectType()
                );
                appointmentToContactMap = mapAppointmentToContactRecord(
                    (List<ServiceAppointment>) emailToAppointmentMap.values(),
                    appointmentToUpdate,
                    uniqueContactMap
                );
            }
            
        }
        return appointmentToContactMap;
    }
    
    /**
    * @description: Check contact or lead records for any potential match of an existing contact
    *               or lead records
    * @param Set<String> suppliedEmails
    * @param List<ServiceAppointment> appointmentList
    */
    private static Map<String, Id> processAppointmentRecordsToLeadMatch(
        Set<String> suppliedEmails,
        Map<String, ServiceAppointment> emailToAppointmentMap
    ) {
        Map<String,Id> appointmentToLeadMap = new Map<String, Id>();
        List<ServiceAppointment> appointmentToUpdate = new List<ServiceAppointment>();
        DuplicateCheckerHelper.newItemsMatchCount = new Map<String, Integer>();
        List<Lead> existingLeadsWithMatchingEmails = LeadsDAO.newInstance()
            .getExistingUnconvertedLeads(suppliedEmails, 'SYSTEM_MODE');
        
        if (!existingLeadsWithMatchingEmails.isEmpty()) {
            for (Lead newRecord : existingLeadsWithMatchingEmails) {
                DuplicateCheckerHelper.countUniqueFieldsToMap(
                    newRecord,
                    new LeadsDAO().getSObjectType()
                );
            }
            if (!DuplicateCheckerHelper.newItemsMatchCount.isEmpty()) {
                //get unique record match to case email
                Map<String, String> uniqueLeadMap = getUniqueRecords(
                    (List<sObject>) existingLeadsWithMatchingEmails,
                    new LeadsDAO().getSObjectType()
                );
                appointmentToLeadMap = mapAppoinmentToLeadRecord(
                    (List<ServiceAppointment>) emailToAppointmentMap.values(),
                    appointmentToUpdate,
                    uniqueLeadMap
                );
            }
        }
        return appointmentToLeadMap;
    }
    
    /**
    * @description: link ServiceAppointment record to the match lead record
    * @param List<ServiceAppointment> appointmentList
    * @param List<ServiceAppointment> appointmentToUpdate
    * @param Map<String,String> uniqueLeadMap
    */
    public static Map<String,Id> mapAppoinmentToLeadRecord(
        List<ServiceAppointment> appointmentList,
        List<ServiceAppointment> appointmentToUpdate,
        Map<String, String> uniqueLeadMap
    ) {
        Map<String,Id> appointmentToLeadMap = new Map<String, Id>();
        for (ServiceAppointment appointmentRec : appointmentList) {
            if (uniqueLeadMap.containsKey(appointmentRec.Email)) {
                appointmentToLeadMap.put(appointmentRec.Email, (Id) uniqueLeadMap.get(appointmentRec.Email));
            }
        }
        return appointmentToLeadMap;
    }
    
    /**
    * @description: link ServiceAppointment record to the match contact record and returns a map of the supplied email 
    * and the matching contact
    * @param List<ServiceAppointment> appointmentList
    * @param List<ServiceAppointment> appointmentToUpdate
    * @param Map<String,String> uniqueContactMap
    */
    public static Map<String,Id> mapAppointmentToContactRecord(
        List<ServiceAppointment> appointmentList,
        List<ServiceAppointment> appointmentToUpdate,
        Map<String, String> uniqueContactMap
    ) {
        Map<String,Id> appointmentToContactMap = new Map<String, Id>();
        
        for (ServiceAppointment appointment : appointmentList) {
            if (uniqueContactMap.containsKey(appointment.Email)) {
                appointmentToContactMap.put(appointment.Email, ((Id) uniqueContactMap.get(appointment.Email)));
            }
        }
        return appointmentToContactMap;
    }
    
    /**
	* @description: get the unique records that is match to the existing email of contact or lead
	* @param List<sObject> recordList
	* @param SObjectType recordObjectType
	* @return Map<String,String> uniqueRecordMap
	*/
    public static Map<String, String> getUniqueRecords(
        List<sObject> recordList,
        SObjectType recordObjectType
    ) {
        Map<String, String> uniqueRecordMap = new Map<String, String>();
        for (sObject newRecord : recordList) {
            for (String field : OBJECT_MAP.get(recordObjectType)) {
                if (
                    DuplicateCheckerHelper.newItemsMatchCount?.get((String) newRecord.get(field)) ==
                    1
                ) {
                    uniqueRecordMap.put((String) newRecord.get(field), newRecord.Id);
                }
            }
        }
        return uniqueRecordMap;
    }
    
    public without sharing class ServiceAppointmentTriggerHelperWithoutSharing{
        /**
        * @description: Check contact or lead records for any potential match of an existing contact
        * and returns a Map of the supplied email to the matching contact Id
        * @param Set<String> suppliedEmails
        * @param Map<String,ServiceAppointment> emailToAppointmentMap
        */                
        public Map<String, Id> processAppointmentRecordsToContactMatch(
            Set<String> suppliedEmails,
            Map<String, ServiceAppointment> emailToAppointmentMap
        ) {
            List<ServiceAppointment> appointmentToUpdate = new List<ServiceAppointment>();
            DuplicateCheckerHelper.newItemsMatchCount = new Map<String, Integer>();
            Map<String,Id> appointmentToContactMap = new Map<String, Id>();
            List<Contact> existingContactsWithMatchingEmails = ContactsDAO.newInstance()
                .getExistingPersonContactsWithMatchingEmails(
                    suppliedEmails,
                    new Set<Id>(),
                    'SYSTEM_MODE'
                );
            
            if (!existingContactsWithMatchingEmails.isEmpty()) {
                for (Contact newRecord : existingContactsWithMatchingEmails) {
                    DuplicateCheckerHelper.countUniqueFieldsToMap(
                        newRecord,
                        new ContactsDAO().getSObjectType()
                    );
                }
                
                if (!DuplicateCheckerHelper.newItemsMatchCount.isEmpty()) {
                    //get unique contact record
                    Map<String, String> uniqueContactMap = getUniqueRecords(
                        (List<sObject>) existingContactsWithMatchingEmails,
                        new ContactsDAO().getSObjectType()
                    );
                    appointmentToContactMap = mapAppointmentToContactRecord(
                        (List<ServiceAppointment>) emailToAppointmentMap.values(),
                        appointmentToUpdate,
                        uniqueContactMap
                    );
                }
                
            }
            return appointmentToContactMap;
        }
        /**
        * @description: Check contact or lead records for any potential match of an existing contact
        *               or lead records
        * @param Set<String> suppliedEmails
        * @param List<ServiceAppointment> appointmentList
        */
        public Map<String, Id> processAppointmentRecordsToLeadMatch(
            Set<String> suppliedEmails,
            Map<String, ServiceAppointment> emailToAppointmentMap
        ) {
            Map<String,Id> appointmentToLeadMap = new Map<String, Id>();
            List<ServiceAppointment> appointmentToUpdate = new List<ServiceAppointment>();
            DuplicateCheckerHelper.newItemsMatchCount = new Map<String, Integer>();
            List<Lead> existingLeadsWithMatchingEmails = LeadsDAO.newInstance()
                .getExistingUnconvertedLeads(suppliedEmails, 'SYSTEM_MODE');
            
            if (!existingLeadsWithMatchingEmails.isEmpty()) {
                for (Lead newRecord : existingLeadsWithMatchingEmails) {
                    DuplicateCheckerHelper.countUniqueFieldsToMap(
                        newRecord,
                        new LeadsDAO().getSObjectType()
                    );
                }
                if (!DuplicateCheckerHelper.newItemsMatchCount.isEmpty()) {
                    //get unique record match to case email
                    Map<String, String> uniqueLeadMap = getUniqueRecords(
                        (List<sObject>) existingLeadsWithMatchingEmails,
                        new LeadsDAO().getSObjectType()
                    );
                    appointmentToLeadMap = mapAppointmentToContactRecord(
                        (List<ServiceAppointment>) emailToAppointmentMap.values(),
                        appointmentToUpdate,
                        uniqueLeadMap
                    );
                }
            }
            return appointmentToLeadMap;
        }
    }   
}