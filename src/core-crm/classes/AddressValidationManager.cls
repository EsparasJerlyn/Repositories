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
    
    public void executeAddressValidation(){
                        
        if(absCategorisation.isEmpty()){
            return;
        }
        
		remotenessMap = new Map<String, Boolean>{
            'Outer Regional Australia' => absCategorisation[0].Remoteness_Outer_Regional__c,
            'Inner Regional Australia' => absCategorisation[0].Remoteness_Inner_Regional__c,
            'Remote' => absCategorisation[0].Remoteness_Remote__c,
            'Very Remote' => absCategorisation[0].Remoteness_Very_Remote__c
        };
            
        List<hed__address__c> addressToInsert = new List<hed__address__c>();
        Map<Id,Contact> contactToUpdateMap = new Map<Id,Contact>();
        Map<Id,hed__address__c> addressToUpdateMap = new Map<Id,hed__address__c>();
        
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
            
            Map<Id, hed__address__c> contactAddressMap = validateContactAddressMap(contactNotValidatedAddress.values());      
            Map<Id, Integer> contactProgramEnrollmentCounts = getOtherProgramEnrollments(contactAddressMap.keySet());              
            
            for(Id contactId: contactAddressMap.keySet()){ 
                
                //Address to update and associate ABS Categorisation 
                hed__address__c address = contactAddressMap.get(contactId);
                address.ABS_Categorisation__c = absCategorisation[0].Id;
                addressToUpdateMap.put(address.Id,address);
                
                //contact to update that determines the low socio economic status
                Contact con = new Contact(Id = contactId);           
                Boolean isLowSocioEconomicAddress = address.Socio_Economic_Percentile__c >= absCategorisation[0].Low_SES_Lower_Boundary__c &&
                    								address.Socio_Economic_Percentile__c <= absCategorisation[0].Low_SES_Upper_Boundary__c;           
                con.Low_Socio_Economic_Status__c = isLowSocioEconomicAddress ? 'Yes':'No';
                contactToUpdateMap.put(contactId,con);
                
                if(contactProgramEnrollmentCounts.containsKey(contactId) && contactProgramEnrollmentCounts.get(contactId) > 1){
                    contactValidatedAddress.put(contactId,contactAddressMap.get(contactId));                   
                }else{
                    //clone "Other" address type and set to First Admitted
                    hed__address__c newAddress = address.clone();
                    newAddress.hed__Address_Type__c = AddressesDAO.FIRST_ADMITTED_ADDRESS;
                    addressToInsert.add(newAddress);
                    
                    //Determine the Regional Remote value by checking if Remoteness from ABS Categorisation value
                    con.Regional_Remote__c = (remotenessMap.containsKey(address.Remoteness_Class__c) && remotenessMap.get(address.Remoteness_Class__c))?'Yes':'No';                            
                }
            }
            
            //run validation on contact with First Admitted Address
            validateContactWithFirstAdmittedAddress(contactValidatedAddress,addressToUpdateMap,contactToUpdateMap);
            
        
            if(!contactToUpdateMap.values().isEmpty()){
                ContactsDAO.newInstance().updateRecords(contactToUpdateMap.values(), false, AccessLevel.USER_MODE);
            } 
            
            if(!addressToInsert.isEmpty()){
                AddressesDAO.newInstance().insertRecords(addressToInsert, false, AccessLevel.USER_MODE);
            }
            
            if(!addressToUpdateMap.values().isEmpty()){
                AddressesDAO.newInstance().updateRecords(addressToUpdateMap.values(), false, AccessLevel.USER_MODE);
            }
            
        } catch (Exception e) {
            Logger.error('Exception caught in class AddressValidationManager.')
              .setExceptionDetails(e);
        } finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    }
    
    private void validateContactWithFirstAdmittedAddress(Map<Id,hed__Address__c> contactValidatedAddress,Map<Id,hed__address__c> addressToUpdateMap,Map<Id,Contact> contactToUpdateMap){
        Map<Id, hed__address__c> contactValidatedFirstAdmittedAddress = evaluateContactWithFirstAdmittedAddress(contactValidatedAddress);
        
        for(Id contactId : contactValidatedFirstAdmittedAddress.keySet()){
            
            hed__address__c address = contactValidatedFirstAdmittedAddress.get(contactId);
            address.ABS_Categorisation__c = absCategorisation[0].Id;
            addressToUpdateMap.put(address.Id,address);
            
            //get regional Remote from ABS and Remoteness Class
            String regionalRemote = (remotenessMap.containsKey(address.Remoteness_Class__c) && remotenessMap.get(address.Remoteness_Class__c))?'Yes':'No';
            
            if(contactToUpdateMap.containsKey(contactId)){
                Contact con = contactToUpdateMap.get(contactId);
                con.Regional_Remote__c = regionalRemote;
                contactToUpdateMap.put(contactId,con);
            }else{
                Contact con = new Contact(Id = contactId);
                con.Regional_Remote__c = regionalRemote;
                contactToUpdateMap.put(contactId,con);
            }           
        }
        
    }
    
    private Map<Id, hed__address__c> evaluateContactWithFirstAdmittedAddress(Map<Id, hed__address__c> contactAddressMap){
        
        Map<Id, hed__address__c> contactToUpdateMap = new Map<Id, hed__address__c>();
        List<hed__Address__c> notValidatedAddress = getNotValidFirstAdmittedContactAddresses(contactAddressMap);
        
        if(!notValidatedAddress.isEmpty()){
            //run address validation
			return validateContactAddressMap(notValidatedAddress);           
        }  
        
        return contactToUpdateMap;
    }
    
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

    // Method to get the validated contact address map
    private Map<Id, hed__address__c> validateContactAddressMap(List<hed__address__c> addresses) {
        // Run address validation
        AddressValidation executeAddressValidation = new AddressValidation(addresses);
        Map<Id, hed__address__c> contactAddressMap = executeAddressValidation.validateAddresses();
        
        return contactAddressMap;
    }

    /**
     * Validates contact addresses and returns a list of addresses that are not validated.
     * 
     * @param contactValidatedAddress Map of contact addresses to validate.
     * @return List of hed__Address__c records that are not validated.
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
                    if (firstAdmittedAddress.Validated__c != 'Valid') {
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