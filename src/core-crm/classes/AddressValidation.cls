/**
 * @description Apex Class for Address Information Validation to ge
 * @see AddressValidationManager
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | mark.j.mahilum            | May 30, 2024          | DEPP-8954            | Created file                 |
 */
public inherited sharing class AddressValidation {
    
    private List<hed__address__c> addresses;
    
    public AddressValidation(List<hed__address__c> addresses) {
        this.addresses = addresses;
    }
    
    public Map<Id, hed__address__c> validateAddresses(){
        Map<Id, hed__address__c> mapOfContactAddress = new Map<Id, hed__address__c>();     
        Set<String> australiaMailingCountry = new Set<String>{'AU','AUS','Australia'};
        
        for(hed__address__c address: addresses){
            
            if(australiaMailingCountry.contains(address.hed__MailingCountry__c)){
                
                AddressValidationResult addressResponse = loqateAddressValidation(address);             
                String isValidAddress = (addressResponse!=null && addressResponse.isValid) ? AddressesDAO.VALID_ADDRESS : AddressesDAO.NOT_VALID_ADDRESS;
                
                hed__address__c addressValidated = new hed__address__c();
                addressValidated.Id = address.Id;
                addressValidated.Validated__c = isValidAddress;   

                if(isValidAddress == AddressesDAO.VALID_ADDRESS){
                    addressValidated.Statistical_Area_1_Id__c = addressResponse.statisticalArea1;
                    addressValidated.Meshblock_Id__c = addressResponse.meshBlockId;
                    addressValidated.Socio_Economic_Percentile__c = addressResponse.socioEconomicPercentile;
                    addressValidated.Remoteness_Class__c = addressResponse.remotenessClass;
                }
                  
                mapOfContactAddress.put(address.hed__Parent_Contact__c, addressValidated);
            }
        }
        
        return mapOfContactAddress;
    }
    
    private AddressValidationResult loqateAddressValidation(hed__address__c address){
        try {
            AddressValidationResult addressResponse = new AddressValidationResult();
            
            // temporary request body as the API specification is not yet define
            String requestBody = JSON.serialize(address);
            
            // endpoint is not yet given and the named credential needed
            HttpResponse response = sendRequest(requestBody,'');

            switch on response.getStatusCode() {
                when 200 {
                    return addressResponse.parse(response.getBody());
                }
                when else {
                    throw new CalloutException('Unexpected Response code: ' + response.getStatusCode());
                }
            }
        } catch (Exception e) {
            Logger.error('Exception caught in method loqateAddressValidation in Apex class AddressValidation.').setExceptionDetails(e);
            return null;  
        }
    }
    
    private HttpResponse sendRequest(String requestBody,String endpoint) {
        
        HttpRequest httpReq = new HttpRequest();
        httpReq.setMethod('POST');
        httpReq.setEndpoint(endpoint);
        httpReq.setHeader('Content-Type', 'application/json');
        httpReq.setBody(requestBody);
        
        Http http = new Http();
        HttpResponse httpResponse = http.send(httpReq);

        return httpResponse;
    }
    
   /**
    * Wrapper class for AddressValidation Result
    */
    public class AddressValidationResult {
        String statisticalArea1;
        String meshBlockId;
        Integer socioEconomicPercentile;
        String remotenessClass;
        Boolean isValid;
        
        public AddressValidationResult parse(String json) {
            return (AddressValidationResult) System.JSON.deserialize(
                json,
                AddressValidationResult.class
            );
        }
    }   
}