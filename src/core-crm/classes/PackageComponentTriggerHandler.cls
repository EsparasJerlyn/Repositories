/**
 * @description Package Component object trigger handler class
 * @see PackageComponentTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                                        |
      |---------------------------|-----------------------|--------------|-----------------------------------------------------------------------|
      | arsenio.jr.dayrit         | August 15,2023        | DEPP-6370    | Created file                                                          |
*/
public with sharing class PackageComponentTriggerHandler implements Disableable, BeforeInsert, BeforeUpdate {

    /**
   * @description beforeInsert trigger event
   * @param newItems - List of Package_Component__c.Trigger.new
   */
  public void beforeInsert(List<SObject> newItems) {
        PackageComponentTriggerHelper.updateStudyLinkApplicationCalculatedDateOnPackageComponent((List<Package_Component__c>) newItems,null);
  }

  /**
   * @description beforeUpdate trigger event
   * @param newItems - List of Package_Component__c.Trigger.new
   * @param oldItems - Map of Package_Component__c.Trigger.old
   */
  public void beforeUpdate( Map<Id, SObject> newItems,Map<Id, SObject> oldItems) {
      PackageComponentTriggerHelper.updateStudyLinkApplicationCalculatedDateOnPackageComponent((List<Package_Component__c>) newItems.values(),(Map<Id, Package_Component__c>) oldItems);
    
  }

    /**
     * @description indicates it the trigger is disabled
     * @return disabled bypass
     */
    public Boolean isDisabled() {
        final TriggerBypassStrategy bypass = new TriggerBypassStrategy();
        return bypass.isDisabled();
    }
}