/**
 * @description Apex Class for Address Information Validation to ge
 * @see AddressValidationManager
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                   |
      |---------------------------|-----------------------|----------------------|----------------------------------|
      | mark.j.mahilum            | May 30, 2024          | DEPP-8954            | Created file                     |
      | eccarius.munoz            | June 11, 2024         | DEPP-8954            | Added handling for integ status  |
 */
public inherited sharing class AddressValidation {
    
    private static final String ESB_ENDPOINT_PROCESS_ADDRESS = System.Label.ESBEndpointProcessAddress;
    private List<hed__address__c> addresses;
    
    public AddressValidation(List<hed__address__c> addresses) {
        this.addresses = addresses;
    }
    
    /**
     * Validates list of address
     * 1. Checks if address is in Australia by checking the mailing country.
     * 2. Callout ESB Process Address endpoint (This will update the address)
     * 3. Set the Integration Status of address based on the ESB callout response
     */
    public Map<Id, hed__address__c> validateAddresses(){

        Map<Id, hed__address__c> mapOfAddresses = new Map<Id, hed__address__c>();     

        List<hed__address__c> validAddressList = new List<hed__address__c> ();   
        List<AddressValidationPayloadRequest> addressValidationRequest = new List<AddressValidationPayloadRequest>();
        hed__Address__c addressCopy;

        for(hed__address__c address: addresses){        
            if(AddressesDAO.MAILING_COUNTRY_AU.contains(address.hed__MailingCountry__c)){
                validAddressList.add(address);
                addressValidationRequest.add(new AddressValidationPayloadRequest(address.Id));                
            }
            mapOfAddresses.put(address.Id,address); // store address to update initially, mostlikely, loqate fields are nullified
        }

        if(!addressValidationRequest.isEmpty()){

            Boolean isCalloutSuccess = addressValidationRequest(addressValidationRequest);

            for(hed__address__c address: validAddressList){
                addressCopy = address.clone();
                String integrationStatus = isCalloutSuccess ? AddressesDAO.INTEGRATION_STATUS_SENT : AddressesDAO.INTEGRATION_STATUS_RETRY;
                if(String.isNotBlank(address.Address_Integration_Status__c) && address.Address_Integration_Status__c == AddressesDAO.INTEGRATION_STATUS_RETRY){
                    integrationStatus = AddressesDAO.INTEGRATION_STATUS_FAILED;
                }
                addressCopy.Id = address.Id;
                addressCopy.Address_Integration_Status__c = integrationStatus;
                mapOfAddresses.put(address.Id, addressCopy); // add integration status update
            }
            
            return mapOfAddresses;     
        }
        
        return mapOfAddresses;
    }
    
    public static boolean addressValidationRequest(List<AddressValidationPayloadRequest> addressValidationRequest){

        boolean response = false;
        HttpResponse httpResponse;

        try {     
            String requestBody = JSON.serialize(addressValidationRequest,true);
            String endpoint = 'callout:ESB' + ESB_ENDPOINT_PROCESS_ADDRESS;    
            String httpMethod = 'POST';

            httpResponse = IntegrationCallOutCtrl.doCallout(endpoint, httpMethod, requestBody);
            
            switch on httpResponse.getStatusCode() {
                when 200 {
                    response = true;
                }
                when else {
                    throw new CalloutException('Unexpected Response code: ' + httpResponse.getStatusCode());
                }
            }

        } catch (Exception e) {
            Logger.error('Callout Exception caught in method addressValidationRequest in Apex class AddressValidation.').setExceptionDetails(e).setHttpResponseDetails(httpResponse);
        } finally {
            Logger.saveLog();
        }

        return response;
    }
    
   /**
    * Wrapper class for AddressValidation Request Payload
    */
    public class AddressValidationPayloadRequest{
        private Id sfid;
        public AddressValidationPayloadRequest(Id sfid){
            this.sfid = sfid;
        }
    } 
}