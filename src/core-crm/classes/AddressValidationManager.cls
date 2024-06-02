/**
 * @description Apex Class for Address Validation 
 * @see AddressValidationManager
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | mark.j.mahilum            | May 30, 2024          | DEPP-8956            | Created file                 |
 */
public with sharing class AddressValidationManager {
    
    private List<hed__address__c> addresses;
    private List<ABS_Categorisation__c> absCategorisation;
    private Map<String, Boolean> remotenessMap;

    public AddressValidationManager(List<hed__address__c> addresses) {
        this.addresses = addresses;
        this.absCategorisation = ABSCategorisationsDAO.newInstance().getLatestUpdatedActiveCategorisationRecord('USER_MODE');             
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
                        
        if(absCategorisation.isEmpty()){
            return;
        }
  
		remotenessMap = new Map<String, Boolean>{
            AddressesDAO.OUTER_REGIONAL_AUSTRALIA => absCategorisation[0].Remoteness_Outer_Regional__c,
            AddressesDAO.INNER_REGIONAL_AUSTRALIA => absCategorisation[0].Remoteness_Inner_Regional__c,
            AddressesDAO.REMOTE => absCategorisation[0].Remoteness_Remote__c,
            AddressesDAO.VERY_REMOTE => absCategorisation[0].Remoteness_Very_Remote__c
        };
            
        List<hed__address__c> addressToInsert = new List<hed__address__c>();
        Map<Id,Contact> contactToUpdateMap = new Map<Id,Contact>();
        List<hed__address__c> addressToUpdate = new List<hed__address__c>();
        
        try {
            
            Map<Id,hed__Address__c> contactValidatedAddress = new Map<Id,hed__Address__c>();
            Map<Id,hed__Address__c> contactNotValidatedAddress = new Map<Id,hed__Address__c>();      
            
            for(hed__Address__c address: addresses){
                if(address.Validated__c == AddressesDAO.VALID_ADDRESS){
                    contactValidatedAddress.put(address.hed__Parent_Contact__c,address);
                }else{
                    contactNotValidatedAddress.put(address.hed__Parent_Contact__c,address);
                }
            }
            
            //validate the not validated address of contact 
            Map<Id, hed__address__c> contactAddressMap = validateContactAddressMap(contactNotValidatedAddress.values()); 
            //get the number of program enrollment associated with contact
            Map<Id, Integer> contactProgramEnrollmentCounts = getOtherProgramEnrollments(contactAddressMap.keySet());              
            
            for(Id contactId: contactAddressMap.keySet()){ 
                
                //Address to update and associate ABS Categorisation 
                hed__address__c address = contactAddressMap.get(contactId);
                address.ABS_Categorisation__c = absCategorisation[0].Id;
                addressToUpdate.add(address);
                
                // Determine and set low socio-economic status
                String lowSocioEconomicStatus = setLowSocioEconomicStatus(address, absCategorisation[0]);
                
                //Contact to update the low socio economic value
                Contact con = new Contact(Id = contactId);  
                if(address.hed__Parent_Contact__r.Low_Socio_Economic_Status__c != lowSocioEconomicStatus){
                    con.Low_Socio_Economic_Status__c = lowSocioEconomicStatus;
                    contactToUpdateMap.put(contactId,con);
                }
                
                if(contactProgramEnrollmentCounts.containsKey(contactId) && contactProgramEnrollmentCounts.get(contactId) > 1){
                    contactValidatedAddress.put(contactId,contactAddressMap.get(contactId));                   
                }else{
                    //clone "Other" address type and set to First Admitted
                    hed__address__c newAddress = address.clone();
                    newAddress.hed__Address_Type__c = AddressesDAO.FIRST_ADMITTED_ADDRESS;
                    addressToInsert.add(newAddress);
                    
                    // Determine and set regional remote value
                    String regionalRemoteValue = setRegionalRemoteValue(address, remotenessMap);
                    if(address.hed__Parent_Contact__r.Regional_Remote__c != regionalRemoteValue){
                       con.Regional_Remote__c = regionalRemoteValue;
                       contactToUpdateMap.put(contactId,con);
                    }                   
                }
            }
            
            //run validation on contact with First Admitted Address
            validateContactWithFirstAdmittedAddress(contactValidatedAddress,addressToUpdate,contactToUpdateMap);
                    	
            //Update the contact records
            updateContactRecords(contactToUpdateMap.values());
            
            //Update address
            updateAddressRecords(addressToUpdate);
			
            //Insert address
            insertAddressRecords(addressToInsert);

        } catch (Exception e) {
            Logger.error('Exception caught in class AddressValidationManager.')
              .setExceptionDetails(e);
        } finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    }

    /**
     * Validates the association of contacts with their first admitted address.
     *
     * This method takes a map of contact IDs to their corresponding validated addresses,
     * a list of addresses to be updated, and a map of contact IDs to Contact objects to be updated.
     * It evaluates the association of contacts with their first admitted address,
     * updates the addresses with ABS categorization, and sets the regional remote value for contacts.
     *
     * @param contactValidatedAddress A map of contact IDs to their validated first admitted addresses.
     * @param addressToUpdate A list of addresses to be updated with ABS categorization.
     * @param contactToUpdateMap A map of contact IDs to Contact objects to be updated with regional remote values.
     */    
    private void validateContactWithFirstAdmittedAddress(Map<Id,hed__Address__c> contactValidatedAddress,List<hed__address__c> addressToUpdate,Map<Id,Contact> contactToUpdateMap){
        Map<Id, hed__address__c> contactValidatedFirstAdmittedAddress = evaluateContactWithFirstAdmittedAddress(contactValidatedAddress);
        
        for(Id contactId : contactValidatedFirstAdmittedAddress.keySet()){
            
            hed__address__c address = contactValidatedFirstAdmittedAddress.get(contactId);
            address.ABS_Categorisation__c = absCategorisation[0].Id;
            addressToUpdate.add(address);
            
            //get regional Remote from ABS and Remoteness Class
            String regionalRemoteValue = setRegionalRemoteValue(address, remotenessMap);
            
            if(contactToUpdateMap.containsKey(contactId)){
                Contact con = contactToUpdateMap.get(contactId);
                con.Regional_Remote__c = regionalRemoteValue;
                contactToUpdateMap.put(contactId,con);
            }else{
                if(address.hed__Parent_Contact__r.Regional_Remote__c != regionalRemoteValue){
                    Contact con = new Contact(Id = contactId);
                    con.Regional_Remote__c = regionalRemoteValue;                    
                    contactToUpdateMap.put(contactId,con);
                }                 
            }           
        }       
    }

    /**
     * Evaluates contacts with their first admitted addresses for validation.
     *
     * This method takes a map of contact IDs to their corresponding addresses.
     * It identifies addresses that have not been validated as first admitted addresses,
     * retrieves them for validation, and returns a map of contact IDs to addresses
     * that need to be updated based on validation results.
     *
     * @param contactAddressMap A map of contact IDs to their addresses.
     * @return A map of contact IDs to addresses requiring validation or updates.
     */    
    private Map<Id, hed__address__c> evaluateContactWithFirstAdmittedAddress(Map<Id, hed__address__c> contactAddressMap){
        
        Map<Id, hed__address__c> contactToUpdateMap = new Map<Id, hed__address__c>();
        List<hed__Address__c> notValidatedAddress = getNotValidFirstAdmittedContactAddresses(contactAddressMap);
        
        if(!notValidatedAddress.isEmpty()){
            //run address validation
			return validateContactAddressMap(notValidatedAddress);           
        }  
        
        return contactToUpdateMap;
    }
    
    /**
     * Retrieves the count of program enrollments for contacts.
     *
     * This method takes a set of contact IDs and retrieves all program enrollments
     * associated with those contacts in specified enrollment statuses.
     * It then counts the number of program enrollments for each contact
     * and returns a map of contact IDs to their respective enrollment counts.
     *
     * @param contactIds A set of contact IDs for which program enrollments are to be retrieved.
     * @return A map of contact IDs to the count of program enrollments.
     */    
    private Map<Id, Integer> getOtherProgramEnrollments(Set<Id> contactIds){       
        Set<String> enrollmentStatuses = new Set<String>{'Admitted','Passed','Leave of Absence','Withdrawn'};
        List<hed__Program_Enrollment__c> programEnrollmentList = ProgramEnrollmentsDAO.newInstance().getAllProgramEnrollmentsByContactId(contactIds, AccessLevel.SYSTEM_MODE);       
        Map<Id, Integer> contactProgramEnrollmentCounts = new Map<Id, Integer>();
                    
        for (hed__Program_Enrollment__c pr : programEnrollmentList) {
            
            if(String.isNotEmpty(pr.hed__Contact__c) && enrollmentStatuses.contains(pr.Enrollment_Status__c)){                
                Integer currentCount = (contactProgramEnrollmentCounts.containsKey(pr.hed__Contact__c)) ? contactProgramEnrollmentCounts.get(pr.hed__Contact__c) : 0;
                contactProgramEnrollmentCounts.put(pr.hed__Contact__c, ++currentCount);
            }               
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
     * Retrieves addresses of contacts with unvalidated first admitted status.
     *
     * This method takes a map of contact IDs to their validated addresses.
     * It retrieves the latest 'First Admitted' addresses of the contacts
     * and identifies addresses that are not yet validated.
     * If no 'First Admitted' address is found for a contact, it logs an error.
     *
     * @param contactValidatedAddress A map of contact IDs to their validated addresses.
     * @return A list of addresses with unvalidated 'First Admitted' status.
     */
    private List<hed__Address__c> getNotValidFirstAdmittedContactAddresses(Map<Id, hed__Address__c> contactValidatedAddress) {
        // Initialize a list to store addresses that are not validated
        List<hed__Address__c> notValidatedAddress = new List<hed__Address__c>();
        
        // Check if the input map is not empty
        if (!contactValidatedAddress.values().isEmpty()){
            
            Map<Id, hed__Address__c> contactFirstAdmittedAddress = new Map<Id, hed__Address__c>();
            // get the latest 'First Admitted' addresses of the contacts and add the latest address to Map          
            for(hed__Address__c firstAdmittedAddress: AddressesDAO.newInstance().getAddressesByContactIdsAndAddressType(contactValidatedAddress.keySet(),new Set<String>{'First Admitted'},'USER_MODE')){
                if(!contactFirstAdmittedAddress.containsKey(firstAdmittedAddress.hed__Parent_Contact__c)){
                    contactFirstAdmittedAddress.put(firstAdmittedAddress.hed__Parent_Contact__c,firstAdmittedAddress);
                }
            }
            
            // Iterate through each contactValidatedAddress and check if contact has existing 'First Admitted' address
            // log an error if no 'First Admitted' address found
            for(Id contactId : contactValidatedAddress.keySet()){
                
                if(contactFirstAdmittedAddress.containsKey(contactId)){
                    hed__Address__c firstAdmittedAddress = contactFirstAdmittedAddress.get(contactId);
                    // Check if the address is not validated
                    if (firstAdmittedAddress.Validated__c != AddressesDAO.VALID_ADDRESS) {
                        // Add the address to the not validated list
                        notValidatedAddress.add(firstAdmittedAddress);
                    }
                }else{
                    // Log an error if the first admitted address is not found
                    String logMessage = 'First Admitted Address not found for the following contact';
                    Logger.error(logMessage, contactId);
                }
            }               
        }

        // Return the list of not validated addresses
        return notValidatedAddress;
    }
}