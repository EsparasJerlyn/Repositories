/**
 * @description trigger for product specification
 * @see ProductSpecificationTrigger
 *
 * @author Accenture
 *
  * @history
 *    | Developer                 | Date                  | JIRA      | Change Summary                              |
      |---------------------------|-----------------------|-----------|---------------------------------------------|
      | sebastianne.k.trias       | January 19, 2023      | DEPP-5087 | Created file                                |
*/
public with sharing class ProductSpecificationTriggerHandler implements Disableable, beforeInsert, beforeUpdate {
    
    public static Boolean isRunning = false;
    
    /**
     * @description performs beforeInsert event for product specification object
     * @param newItems - List of Product_Specification__c.Trigger.new
     */
    public void beforeInsert(List<SObject> newItems){
        validateRelatedOpportunity((List<Product_Specification__c>) newItems, null);
    }
    
    public void beforeUpdate( Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        validateRelatedOpportunity((List<Product_Specification__c>) newItems.values(),(Map<Id, Product_Specification__c>) oldItems );
    }
    
    /**
     * @description validate related Opportunity
     * @param prodSpecNew - List of Product_Specification__c.Trigger.new
     * @param prodSpecOld - List of Product_Specification__c.Trigger.old
     */
    public void validateRelatedOpportunity(
    	List<Product_Specification__c> prodSpecNew,
        Map<Id, Product_Specification__c> prodSpecOld
    ){
        
        Set<Id> opportunitySetId = new Set<Id>();
        
        for(Product_Specification__c prodSpec : prodSpecNew){
            if(prodSpecOld == null && prodSpec.Opportunity_Name__c != null){
                opportunitySetId.add(prodSpec.Opportunity_Name__c);
            }
            else if(prodSpecOld != null && (prodSpecOld.get(prodSpec.Id).Opportunity_Name__c != prodSpec.Opportunity_Name__c)){
                opportunitySetId.add(prodSpec.Opportunity_Name__c);
            }
        }
        
        if(!opportunitySetId.isEmpty()){
            
            Map<Id, Product_Specification__c> oppLists = new Map<Id, Product_Specification__c>(); 
            
            for(Product_Specification__c ps : [SELECT Id, Name, Opportunity_Name__c FROM Product_Specification__c Where Opportunity_Name__c IN: opportunitySetId]){
                oppLists.put(ps.Opportunity_Name__c, ps);
            }
            
            for(Product_Specification__c prodSpec : prodSpecNew){
            	if(oppLists.containsKey(prodSpec.Opportunity_Name__c)){
                    prodSpec.Opportunity_Name__c.addError('A Product Specification is already linked to this Opportunity');
                }
            }
        }
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