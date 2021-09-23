/**
 * @description Controller class for Company Information Validation custom component
 *
 * @see ../lwc/companyInformationValidation
 * 
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary     |
      |---------------------------|-----------------------|--------------|--------------------|
      | angelika.j.s.galang       | September 17, 2021    | DEP1-518     | Created file       | 
      |                           |                       |              |                    | 
 */

public with sharing class CompanyInformationValidationCtrl {

    /**
    * @description Method for getting the Company Mapping set in Loqate Component metadata
    * @param objApiName - API name of object passed from component
    * @param fieldToQuery - metadata field to query
    * @return the JSON string of company mapping 
    */
    @AuraEnabled(cacheable=true)
    public static String getCompanyMapping(String objApiName, String fieldToQuery){
        return ContactInformationValidationCtrl.getMapping(objApiName, fieldToQuery);
    }

    /**
    * @description Collates all fields to be validated
    * @param validateRequestList - serialized list of fields to be validated
    * @return serialized list of payload responses
    */
    @AuraEnabled(cacheable=true)
    public static String validateCompany(String validateRequestList){
        return ContactInformationValidationCtrl.validateFields(validateRequestList);
    }

}
