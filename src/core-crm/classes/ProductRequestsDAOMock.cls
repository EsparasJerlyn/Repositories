/**
 * @description Mock DAO Class for Product Request Object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file
 */
@isTest
public inherited sharing class ProductRequestsDAOMock extends DmlBaseMock implements IProductRequestsDAO {
    public Map<Id, Product_Request__c> productRequestsMap;

    public Schema.SObjectType getSObjectType() {
        return Product_Request__c.SObjectType;
    }

    public ProductRequestsDAOMock() {
        super(new Map<Id, Product_Request__c>(), Schema.Product_Request__c.SObjectType);
        this.productRequestsMap = (Map<Id, Product_Request__c>) super.records;
    }

    public List<Product_Request__c> getProductRequestsBySetNames(Set<String> productRequestNames) {
        List<Product_Request__c> productRequestList = new List<Product_Request__c>();

        for (Product_Request__c record : productRequestsMap.values()) {
            if (productRequestNames.contains(record.Product_Request_Name__c)) {
                productRequestList.add(record);
            }
        }

        return productRequestList;
    }
}
