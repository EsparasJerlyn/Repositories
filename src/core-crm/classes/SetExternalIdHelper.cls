/**
 * @description helper to Update External Id to the selected Object when called by the trigger
 * @see CourseConnection, CourseOffering, Course, Cart, CartItem TriggerHandlers
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | johnbo.pineda@qut.edu.au       | March 22, 2022        | DEPP-1991              | Created file                 |
      |                                |                       |                        |                              |
 */

public with sharing class SetExternalIdHelper {
  
  /**
  * @description sets the External Id of the SObject
  * @param newItems - List of SObjects.Trigger.new
  */
  public static void updateExternalId(List<SObject> newItems) {
      for (SObject sObjectItem : newItems) {
        if(String.IsBlank(String.valueOf(sObjectItem.get('External_Id__c')))){
          sObjectItem.put('External_Id__c', GenerateUniqueId.getUUID());
        }
    }
  }
}