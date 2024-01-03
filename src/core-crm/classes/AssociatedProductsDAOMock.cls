/**
 * @description Mock DAO Class for Associated Product object
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                              |
      |--------------------------------|-----------------------|------------------------|---------------------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file                                |   
      | arsenio.jr.dayrit              | January 02, 2024      |  ApexCRUDViolationFix  | Added method for getAssociatedProductsById  |
 */
@isTest
public inherited sharing class AssociatedProductsDAOMock extends DmlBaseMock implements IAssociatedProductsDAO {
    public Map<Id, Associated_Products__c> associatedProductsMap;

    public Schema.SObjectType getSObjectType() {
        return Associated_Products__c.SObjectType;
    }

    public AssociatedProductsDAOMock() {
        super(new Map<Id, Associated_Products__c>(), Schema.Associated_Products__c.SObjectType);
        this.associatedProductsMap = (Map<Id, Associated_Products__c>) super.records;
    }

    public List<Associated_Products__c> getActiveAssociatedProductsByProductRequest(
        Set<Id> productRequestIds
    ) {
        List<Associated_Products__c> associatedProductsList = new List<Associated_Products__c>();

        for (Associated_Products__c record : associatedProductsMap.values()) {
            if (productRequestIds.contains(record.Product_Request__c) && record.IsActive__c) {
                associatedProductsList.add(record);
            }
        }

        return associatedProductsList;
    }

    public List<Associated_Products__c> getAssociatedProductsById(
        Set<Id> associatedProdIds,
        AccessLevel accessLevel
    ){
        List<Associated_Products__c> associatedProductsList = new List<Associated_Products__c>();
        for (Associated_Products__c record : associatedProductsMap.values()) {
            if (associatedProdIds.contains(record.Id)){
                associatedProductsList.add(record);
            }
        }
        return associatedProductsList;
    }
}
