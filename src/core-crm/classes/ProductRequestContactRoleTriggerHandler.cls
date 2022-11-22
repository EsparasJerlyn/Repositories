/**
 * @description  Trigger for Product Request Contact Role Trigger Handler
 * @see ProductRequestContactRoleTrigger
 *
 * @author Accenture
 *
  * @history
 *    | Developer                 | Date                  | JIRA      | Change Summary                              |
      |---------------------------|-----------------------|-----------|---------------------------------------------|
      | alexander.cadalin         | Nov 15, 2022          | DEPP-4099 | Created file                                |
*/

public with sharing class ProductRequestContactRoleTriggerHandler 
implements Disableable, BeforeInsert, BeforeUpdate {
    public void beforeInsert (List<SObject> newItems) {
        checkForExistingFacultyLeads(newItems);
    }

    public void beforeUpdate (
        Map<Id, SObject> newItems, 
        Map<Id, SObject> oldItems
    ) {
        checkForExistingFacultyLeads(newItems.values());
    }

    /**
     * @description indicates it the trigger is disabled
     * @return disabled bypass
     */
    public Boolean isDisabled() {
        final TriggerBypassStrategy bypass = new TriggerBypassStrategy();
        return bypass.isDisabled();
    }
    
    // DEPP-4099 Checks for existing Faculty Leads and prevents them from being saved when there is
    private void checkForExistingFacultyLeads(List<SObject> newItems) {
        // convert from SObject to Product_Request_Contact_Role__c
        List<Product_Request_Contact_Role__c> newConRoles = (List<Product_Request_Contact_Role__c>)newItems;
        // contains all new product request contact roles that have 'Faculty Lead' roles
        List<Product_Request_Contact_Role__c> newFacultyLeads = getFacultyLeadProductRequestContactRoles(newConRoles);
        // a set of product request Ids that are found in facultyLeads
        Set<Id> prodReqsFromFacultyLeads = new Set<Id>();
        // map PR Ids to how many times it is assigned in Faculty Leads
        Map<Id, Integer> mapPrIdsToOccurence = new Map<Id, Integer>();
        for(Product_Request_Contact_Role__c newFacultyLead : newFacultyLeads) {
            prodReqsFromFacultyLeads.add(newFacultyLead.Product_Request__c);
            if(!mapPrIdsToOccurence.containsKey(newFacultyLead.Product_Request__c)) {
                mapPrIdsToOccurence.put(newFacultyLead.Product_Request__c, 0);
            }
            mapPrIdsToOccurence.put(
                newFacultyLead.Product_Request__c, 
                mapPrIdsToOccurence.get(
                    newFacultyLead.Product_Request__c
                ) + 1
            );
        }
        // contains all the active faculty leads already in the database that has the same product requests
        // from the new faculty lead contact roles
        Set<Id> prIdsInExistingFacultyLeads = new Set<Id>();
        for(Product_Request_Contact_Role__c existingFacultyLead : [
            SELECT Id, Product_Request__c, IsActive__c, Role__c
            FROM Product_Request_Contact_Role__c 
            WHERE IsActive__c = true AND
            Role__c = 'Faculty Lead' AND
            Product_Request__c IN :prodReqsFromFacultyLeads
            WITH SECURITY_ENFORCED
        ]) {
            prIdsInExistingFacultyLeads.add(existingFacultyLead.Product_Request__c);
        }
        // loop through every new faculty lead
        for(Product_Request_Contact_Role__c newFacultyLead : newFacultyLeads) {
            // validate if there is already an existing and active faculty lead in the database
            if(prIdsInExistingFacultyLeads.contains(newFacultyLead.Product_Request__c)) {
                newFacultyLead.addError('An existing and active Faculty Lead contact role is ' + 
                                        'already associated with this Product Request.');
                break; // no need to keep checking. one error is enough
            }
            // validate if there is also an existing faculty lead within the batch itself.
            if(mapPrIdsToOccurence.get(newFacultyLead.Product_Request__c) > 1) {
                newFacultyLead.addError('Another active Faculty Lead contact role in the batch ' +
                                        'is associated with the same Product Request,');
            }
        }
    }
    
    // Gets only all the active contact roles with Faculty Lead roles from the new contact roles
    // *needed to reduce complexity
    private List<Product_Request_Contact_Role__c> getFacultyLeadProductRequestContactRoles(
        List<Product_Request_Contact_Role__c> newConRoles
    ) {
        List<Product_Request_Contact_Role__c> newFacultyLeads = new List<Product_Request_Contact_Role__c>();
        for(Product_Request_Contact_Role__c newConRole : newConRoles) {
            if(newConRole.Role__c == 'Faculty Lead' && newConRole.IsActive__c == true){
                newFacultyLeads.add(newConRole);
            }
        }
        return newFacultyLeads;
    }
}