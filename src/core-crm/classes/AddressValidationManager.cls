/**
 * @description Apex Class for Address Validation 
 * @see AddressValidationManager
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                 |
      |---------------------------|-----------------------|----------------------|--------------------------------|
      | mark.j.mahilum            | May 30, 2024          | DEPP-8956            | Created file                   |
      | eugene.andrew.abuan       | July 08, 2024         | DEPP-9798            | Added first admission to false |
      | eugene.andrew.abuan       | July 09, 2024         | DEPP-9818            | Added checking for QUT Student |
 */
public with sharing class AddressValidationManager {
    
    private List<hed__address__c> addresses;
    private Map<Id, Contact> contactMap;
    private Boolean isUpdatedMailingAddress;


    public AddressValidationManager(List<hed__address__c> addresses) {
        this.addresses = addresses;
    }

    public AddressValidationManager(List<hed__address__c> addresses, Map<Id, Contact> contactMap, Boolean isUpdatedMailingAddress) {
        this.addresses = addresses;
        this.contactMap = contactMap;
        this.isUpdatedMailingAddress = isUpdatedMailingAddress;

    }
    
    /**
     * Executes the address validation process.
     *
     * This method orchestrates the address validation process.
     * It sets up necessary data structures, such as the remoteness map,
     * and retrieves addresses to be validated.
     * It then validates the addresses, determines additional data,
     * updates contact and address records accordingly, and handles exceptions.
     *
     * Note: This method assumes that ABS categorization data is available.
     */   
    public void executeAddressValidation(){

        try {
            
            Map<Id,hed__Address__c> contactOtherAddresses = new Map<Id,hed__Address__c>();
            
            for(hed__Address__c address: addresses){
				 contactOtherAddresses.put(address.hed__Parent_Contact__c,address);
            }

            //get the number of program enrollment associated with contact
            Map<Id, Integer> contactProgramEnrollmentCounts = getAllProgramEnrollmentsOfContacts(contactOtherAddresses.keySet());            
            // get the latest 'First Admitted' addresses of the contacts and add the latest address to Map                      
            Map<Id, hed__Address__c> contactFirstAdmittedAddress = getContactFirstAdmittedAddresses(contactOtherAddresses.keySet());            
            
            List<hed__Address__c> addressToValidate = new List<hed__Address__c>();
            List<hed__Address__c> addressToInsert = new List<hed__Address__c>();
            
            
            for(Id contactId: contactOtherAddresses.keySet()){
                
                hed__Address__c otherAdress = contactOtherAddresses.get(contactId);                
                Boolean contactHasFirstAdmittedAddress = contactFirstAdmittedAddress.containsKey(contactId);
                Boolean contactHaveMultipleProgramEnrollment = (contactProgramEnrollmentCounts.containsKey(contactId) && contactProgramEnrollmentCounts.get(contactId) > 1);
     
                //checking if contact has multiple program enrollment OR already has existing First Admitted Address               
                if(contactHaveMultipleProgramEnrollment || contactHasFirstAdmittedAddress){                   
                    if(contactHasFirstAdmittedAddress){
                        hed__Address__c firstAdmittedAddress = contactFirstAdmittedAddress.get(contactId);
                        if(firstAdmittedAddress.Validated__c != AddressesDAO.VALID_ADDRESS){                                                        
                            // send the first admitted addres for validation if not yet validated
                            addressToValidate.add(firstAdmittedAddress);   
                        }                        
                    }else{
                        // Log an error if the first admitted address is not found
                        String logMessage = 'First Admitted Address not found for the following contact';
                        Logger.error(logMessage, contactId);
                    }                   
                }else{
                    //Other Program Enrollment with Status = Admitted
                    //Check if the Address is Australia
                    if(!AddressesDAO.MAILING_COUNTRY_AU.contains(otherAdress.hed__MailingCountry__c)){                                                        
                        //clone "Other" address type and set to First Admitted
                        hed__address__c newAddress = otherAdress.clone();
                        newAddress.Is_First_Admission_Address__c = false; 
                        newAddress.hed__Address_Type__c = AddressesDAO.FIRST_ADMITTED_ADDRESS;
                        addressToInsert.add(newAddress);
                    }else{
                        //set isFirstAdmissionAddress to true
                        otherAdress.Is_First_Admission_Address__c = true;
                    }

                }
                
                addressToValidate.add(otherAdress);
                
            }
            
            Map<Id,hed__Address__c> validatedAddressesMap = validateContactAddressMap(addressToValidate);
            
            //Update address
            updateAddressRecords(validatedAddressesMap.values());

            //Insert cloned address
            insertAddressRecords(addressToInsert);

        } catch (Exception e) {
            Logger.error('Exception caught in class AddressValidationManager.').setExceptionDetails(e);
        } finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    }
    
    /**
     * Processes and validates address records based on ABS categorisation and updates related contact records.
     * 
     * This method performs the following steps:
     * 1. Checks if the ABS categorisation list is empty and returns if it is.
     * 2. Creates a remoteness mapping using the first ABS categorisation entry.
     * 3. Initializes maps and lists for storing contacts to update and addresses to update or insert.
     * 4. Iterates over the address records to:
     *    a. Update 'Other' address types with ABS categorisation and determine low socio-economic status.
     *       i. If the address is marked as first admission, clone it to create a new address of type 'First Admitted'.
     *       ii. Set the regional remote value for the contact.
     *       iii. Update the 'First Admission Address' to false'
     *    b. Update 'First Admitted' address types by setting the regional remote value from the ABS categorisation.
     * 5. Updates contact records with the new low socio-economic and regional remote values.
     * 6. Updates and inserts address records accordingly.
     */  
    public void processValidateAddress(){
        
        List<ABS_Categorisation__c> absCategorisation = ABSCategorisationsDAO.newInstance().getLatestUpdatedActiveCategorisationRecord('USER_MODE');
        
        if(absCategorisation.isEmpty()){
            return;
        }
  
		Map<String, Boolean> remotenessMap = new Map<String, Boolean>{
            AddressesDAO.OUTER_REGIONAL_AUSTRALIA => absCategorisation[0].Remoteness_Outer_Regional__c,
            AddressesDAO.INNER_REGIONAL_AUSTRALIA => absCategorisation[0].Remoteness_Inner_Regional__c,
            AddressesDAO.REMOTE => absCategorisation[0].Remoteness_Remote__c,
            AddressesDAO.VERY_REMOTE => absCategorisation[0].Remoteness_Very_Remote__c
        };
            
        Map<Id,Contact> contactToUpdateMap = new Map<Id,Contact>();
        List<hed__Address__c> addressToUpdate = new List<hed__Address__c>();
        List<hed__Address__c> addressToInsert = new List<hed__Address__c>();
        hed__Address__c addressCopy;
        
        try {
        
            for(hed__Address__c address : addresses){
                
                Id contactId = address.hed__Parent_Contact__c;
                Contact con = contactToUpdateMap.containsKey(contactId)? contactToUpdateMap.get(contactId) : new Contact(Id = contactId);
                addressCopy = address.clone();
                switch on address.hed__Address_Type__c {
                    
                    when 'Other' {
                        //Address to update and associate ABS Categorisation 
                        addressCopy.Id = address.Id;
                        addressCopy.ABS_Categorisation__c = absCategorisation[0].Id;
                        
                        // Determine and set low socio-economic status
                        String lowSocioEconomicStatus = setLowSocioEconomicStatus(address, absCategorisation[0]);
                        //Contact to update the low socio economic value
                        if(String.isNotBlank(lowSocioEconomicStatus)){
                            con.Low_Socio_Economic_Status__c = lowSocioEconomicStatus;
                            contactToUpdateMap.put(contactId,con);
                        }
                        if(address.Is_First_Admission_Address__c){
                            //clone "Other" address type and set to First Admitted
                            hed__address__c newAddress = address.clone();
                            newAddress.Is_First_Admission_Address__c = false; 
                            newAddress.hed__Address_Type__c = AddressesDAO.FIRST_ADMITTED_ADDRESS;
                            addressToInsert.add(newAddress);
                            
                            // Determine and set regional remote value
                            String regionalRemoteValue = setRegionalRemoteValue(address, remotenessMap);
                            con.Regional_Remote__c = regionalRemoteValue;
                            contactToUpdateMap.put(contactId,con);

                            //Update the 'First Admission Address' to false
                            addressCopy.Is_First_Admission_Address__c = false;
                        }
                        addressToUpdate.add(addressCopy);

                    }
                    when 'First Admitted' {
                        //get regional Remote from ABS and Remoteness Class
                        String regionalRemoteValue = setRegionalRemoteValue(address, remotenessMap);  
                        con.Regional_Remote__c = regionalRemoteValue;                    
                        contactToUpdateMap.put(contactId,con);
                    }
                }
            }
            
            //Update the contact records
            updateContactRecords(contactToUpdateMap.values());
            
            //Update address
            updateAddressRecords(addressToUpdate);
            
            //Insert address
            insertAddressRecords(addressToInsert);
            
        } catch (Exception e) {
            Logger.error('Exception caught in class AddressValidationManager. Method: processValidateAddress')
                .setExceptionDetails(e);
        } finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    }

    /**
     * Retrieves the count of program enrollments for contacts.
     *
     * This method takes a set of contact IDs and Program Enrollment Statuses then retrieves all program enrollments
     * associated with those contacts in specified enrollment statuses.
     * It then counts the number of program enrollments for each contact
     * and returns a map of contact IDs to their respective enrollment counts.
     *
     * @param contactIds A set of contact IDs for which program enrollments are to be retrieved.
     * @return A map of contact IDs to the count of program enrollments.
     */    
    private Map<Id, Integer> getAllProgramEnrollmentsOfContacts(Set<Id> contactIds){       
        Set<String> enrollmentStatuses = new Set<String>{'Admitted'}; 
        List<hed__Program_Enrollment__c> programEnrollmentList = ProgramEnrollmentsDAO.newInstance().getProgramEnrollmentsByContactIdAndEnrollmentStatuses(contactIds,enrollmentStatuses, AccessLevel.SYSTEM_MODE);       
        Map<Id, Integer> contactProgramEnrollmentCounts = new Map<Id, Integer>();
                    
        for (hed__Program_Enrollment__c pr : programEnrollmentList) {          
            Integer currentCount = (contactProgramEnrollmentCounts.containsKey(pr.hed__Contact__c)) ? contactProgramEnrollmentCounts.get(pr.hed__Contact__c) : 0;
            contactProgramEnrollmentCounts.put(pr.hed__Contact__c, ++currentCount);
        }
       
        return contactProgramEnrollmentCounts;
    }
    
	/**
     * Updates the given list of Contact records.
     * This method uses the ContactsDAO to update the records in the provided list.
     *
     * @param updateContactList A list of Contact records to be updated.
     */
    private void updateContactRecords(List<Contact> updateContactList) {
        if(!updateContactList.isEmpty()){
            ContactsDAO.newInstance().updateRecords(updateContactList, false, AccessLevel.SYSTEM_MODE);
        }
    }

    /**
     * Updates the given list of Address records.
     * This method checks if the provided list of Address records is not empty.
     * If the list is not empty, it uses the AddressesDAO to update the records.
     *
     * @param updateAddressList A list of Address records to be updated.
     */
    private void updateAddressRecords(List<hed__Address__c> updateAddressList) {
        if(!updateAddressList.isEmpty()){
            AddressesDAO.newInstance().updateRecords(updateAddressList, false, AccessLevel.SYSTEM_MODE);         
        }
    }
    
    /**
     * Insert the given list of Address records.
     * This method checks if the provided list of Address records is not empty.
     * If the list is not empty, it uses the AddressesDAO to insert the records.
     *
     * @param insertAddressList A list of Address records to be created.
     */
    private void insertAddressRecords(List<hed__Address__c> insertAddressList) {
        if(!insertAddressList.isEmpty()){
            AddressesDAO.newInstance().insertRecords(insertAddressList, false, AccessLevel.SYSTEM_MODE);         
        }
    } 

    /**
     * Validates the addresses associated with contacts.
     *
     * This method takes a list of addresses and initiates the address validation process.
     * It creates an AddressValidation instance with the provided addresses and executes the validation.
     * The result is a map of contact IDs to their corresponding validated addresses.
     *
     * @param addresses A list of addresses to be validated.
     * @return A map of contact IDs to their validated addresses.
     */
    private Map<Id, hed__address__c> validateContactAddressMap(List<hed__address__c> addresses) {
        // Run address validation
        AddressValidation executeAddressValidation = new AddressValidation(addresses);
        Map<Id, hed__address__c> contactAddressMap = executeAddressValidation.validateAddresses();
        
        return contactAddressMap;
    }
    
    /**
     * Sets the low socio-economic status for the given address.
     *
     * This method takes an address and ABS categorization information.
     * It calculates whether the address falls within the low socio-economic percentile boundaries
     * specified in the ABS categorization.
     *
     * @param address The address for which low socio-economic status is to be determined.
     * @param absCategorisation The ABS categorization containing low socio-economic boundaries.
     * @return A string indicating whether the address has low socio-economic status ('Yes' or 'No').
     */
    private String setLowSocioEconomicStatus(hed__address__c address, ABS_Categorisation__c absCategorisation) {
        
        if(address.Socio_Economic_Percentile__c == null){
            return '';
        }
        
        Boolean isLowSocioEconomicAddress = address.Socio_Economic_Percentile__c >= absCategorisation.Low_SES_Lower_Boundary__c &&
                                            address.Socio_Economic_Percentile__c <= absCategorisation.Low_SES_Upper_Boundary__c;
        return (isLowSocioEconomicAddress) ? ContactsDAO.LOW_SOCIO_ECONOMIC_STATUS_YES : ContactsDAO.LOW_SOCIO_ECONOMIC_STATUS_NO;
    }
    
    /**
     * Sets the regional remote value for the given address.
     *
     * This method takes an address and a map containing remoteness classification information.
     * It checks if the address's remoteness classification exists in the map and if it indicates regional remoteness.
     * If so, it returns 'Yes', otherwise 'No'.
     *
     * @param address The address for which regional remote value is to be determined.
     * @param remotenessMap A map containing remoteness classification information.
     *                      Key: remoteness classification, Value: boolean indicating if it's regional remote.
     * @return A string indicating whether the address has regional remoteness ('Yes' or 'No').
     */
    private String setRegionalRemoteValue(hed__address__c address, Map<String, Boolean> remotenessMap) {
        return (remotenessMap.containsKey(address.Remoteness_Class__c) && remotenessMap.get(address.Remoteness_Class__c)) ? ContactsDAO.REGIONAL_REMOTE_YES : ContactsDAO.REGIONAL_REMOTE_NO;
    }
    
    /**
     * Retrieves the latest 'First Admitted' addresses for a given set of contact IDs.
     *
     * @param contactIds Set of contact IDs for which to retrieve the 'First Admitted' addresses.
     * @return Map<Id, hed__Address__c> where the key is the contact ID and the value is the latest 'First Admitted' address.
     */
    private Map<Id, hed__Address__c> getContactFirstAdmittedAddresses(Set<Id> contactIds) {
        Map<Id, hed__Address__c> contactFirstAdmittedAddress = new Map<Id, hed__Address__c>();
        
        // Get the latest 'First Admitted' addresses of the contacts and add the latest address to Map
        for (hed__Address__c firstAdmittedAddress : AddressesDAO.newInstance().getAddressesByContactIdsAndAddressType(contactIds, new Set<String>{AddressesDAO.FIRST_ADMITTED_ADDRESS}, 'USER_MODE')) {
            if (!contactFirstAdmittedAddress.containsKey(firstAdmittedAddress.hed__Parent_Contact__c)) {
                contactFirstAdmittedAddress.put(firstAdmittedAddress.hed__Parent_Contact__c, firstAdmittedAddress);
            }
        }
        
        return contactFirstAdmittedAddress;
    }    

    /**
     * Process Address Validation triggered from Address object
     * @param List<hed__Address__c> addressList - List of address to validate
     * @param Map<Id, Contact> contactDetailsMap - Map of contact related to address
     */
    public void processValidationForAddress(){
        try{ 
            ABS_Categorisation__c absCategorisation = getABSCategorisation();  

            Map<Id,Contact> contactMapToUpdate = new Map<Id,Contact>();
            List<hed__Address__c> validatedAddressToUpdate = new List<hed__Address__c>();
            List<hed__Address__c> addressUpdateIntegrationFieldsToNull = new List<hed__Address__c>();
            hed__Address__c addressCopy;

            Map<Id, hed__Address__c> contactFirstAdmittedAddress = getContactFirstAdmittedAddresses(contactMap.keySet());  

            for(hed__Address__c address : addresses){
                //if current has no parent contact, skip whole process
                if(!contactMap.containsKey(address.hed__Parent_Contact__c)){
                    continue;
                }

                Contact parentContact = contactMap.get(address.hed__Parent_Contact__c);

                addressCopy = address.clone();
                addressCopy.Id = address.Id;

                setAddressValuesToNull(addressCopy);

                //checks if address is AU
                boolean isAUAddress = AddressesDAO.MAILING_COUNTRY_AU.contains(addressCopy.hed__MailingCountry__c);
                boolean hasNoFirstAdmittedAddress = !contactFirstAdmittedAddress.containsKey(address.hed__Parent_Contact__c);
                boolean isCitizen = parentContact.hed__Citizenship_Status__c == ContactsDAO.CITIZENSHIP_STATUS_DOMESTIC;
                
                // when Contact is not a QUT Student 
                // OR there is no existing first admitted address and contact is not an au citizen
                // update integration fields to null
                boolean isNotStudentAndCitizen = parentContact.QUT_Student__c || (hasNoFirstAdmittedAddress && !isCitizen);
                if(isNotStudentAndCitizen){
                    addressUpdateIntegrationFieldsToNull.add(addressCopy);
                    continue;
                }

                //when contact is an au citizen, has no existing first admitted address and other address is au
                //update first admitted to true
                boolean isAUCitizenAndResident = isCitizen && hasNoFirstAdmittedAddress && isAUAddress;
                if(isAUCitizenAndResident){
                    addressCopy.Is_First_Admission_Address__c = true;
                }

                addressCopy.ABS_Categorisation__c = absCategorisation.Id;
                validatedAddressToUpdate.add(addressCopy);
                
                String lowSocioEconomicStatus = setLowSocioEconomicStatus(address, absCategorisation);
                updateContactEconomicStatus(contactMapToUpdate,parentContact,lowSocioEconomicStatus);
            }
            
            // Updates the hed Address when Contact is QUT Student and will fire a Validation for the Integration Status
            Map<Id, hed__Address__c> validatedAddressToUpdateMap = new AddressValidation(validatedAddressToUpdate).validateAddresses();
            AddressesDAO.newInstance().updateRecords(validatedAddressToUpdateMap.values(), true, AccessLevel.SYSTEM_MODE);
            // Updates the hed Address Integration fields to null when QUT Student is false or Address is not AU
            AddressesDAO.newInstance().updateRecords(addressUpdateIntegrationFieldsToNull, true, AccessLevel.SYSTEM_MODE);
            // Update contact related fields
            ContactsDAO.newInstance().updateRecords(contactMapToUpdate.values(), true, AccessLevel.SYSTEM_MODE);

        }catch(Exception e){
            NebulaLoggerService.logExceptionDetails('Exception caught in execute method in Apex class AddressesValidationBatch.',e);
        }
    }

    private static void updateContactEconomicStatus(Map<Id, Contact> contactMapToUpdate, Contact parentContact, String lowSocioEconomicStatus){
        Id contactId = parentContact.Id;
        Boolean isContactForUpdate = String.isNotBlank(lowSocioEconomicStatus) && 
        (parentContact.Low_Socio_Economic_Status__c == null || parentContact.Low_Socio_Economic_Status__c != lowSocioEconomicStatus);

        if(isContactForUpdate){
            contactMapToUpdate.put(
                contactId,
                new Contact(
                    Id = contactId,
                    Low_Socio_Economic_Status__c = lowSocioEconomicStatus
                )
            );
        }
    }

    /**
     * Retrieves latest ABS_Categorisation__c
     * @return ABS_Categorisation__c absCategorisation
     */
    private static ABS_Categorisation__c getABSCategorisation(){
        ABS_Categorisation__c absCategorisation = new ABS_Categorisation__c();
        List<ABS_Categorisation__c> absCategorisationList = ABSCategorisationsDAO.newInstance().getLatestUpdatedActiveCategorisationRecord('SYSTEM_MODE');
        for(ABS_Categorisation__c absCateg : absCategorisationList){
            absCategorisation = absCateg;
        }
        return absCategorisation;
    }

    /**
     * Retrieves sets the values of the Address to null
     * @return void
     */
    public void setAddressValuesToNull(hed__Address__c address){
        if(isUpdatedMailingAddress){
            address.Statistical_Area_1_Id__c = null;
            address.Meshblock_Id__c = null;                
            address.Socio_Economic_Percentile__c = null;
            address.Remoteness_Class__c = null;
            address.GNAF_Id__c = null;
            address.Validated__c = null;
            address.ABS_Categorisation__c = null;
            address.Address_Integration_Status__c = null;
        }
    }
}