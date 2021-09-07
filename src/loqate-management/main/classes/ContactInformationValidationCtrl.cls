/**
 * @description Controller class for Contact Information Validation custom component
 *
 * @see ../lwc/contactInformationValidation
 * 
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA     | Change Summary               |
      |---------------------------|-----------------------|----------|------------------------------|
      | angelika.j.s.galang       | September 3, 2021     | DEP1-156 | Created file                 | 
      |                           |                       |          |                              | 
 */

public with sharing class ContactInformationValidationCtrl {

   /**
    * @description Method for getting the Field Mapping set in Loqate Component metadata
    * @param objApiName - API name of object passed from component
    * @return fieldMapping - the JSON string of field mapping 
    */
    @AuraEnabled(cacheable=true)
    public static String getFieldMapping(String objApiName){
        String fieldMapping;

        try{
            fieldMapping = [SELECT Field_Mapping__c FROM Loqate_Component__mdt WHERE Object_Type__c=:objApiName LIMIT 1].Field_Mapping__c;
        }catch(Exception ex){
            AuraHandledException auraEx = new AuraHandledException(ex.getMessage());
            auraEx.setMessage('Error while getting field mapping.');
            throw auraEx;
        }

        return fieldMapping;
    }

}