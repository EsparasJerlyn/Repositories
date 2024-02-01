/**
 * @description DAO Class for Product Request Object. Contains soql and constants related to the Product Request object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file
 */
public inherited sharing class ProductRequestsDAO extends DmlBase implements IProductRequestsDAO {
    public static final String PR_CORP_BUNDLE = System.Label.RT_ProductRequest_Corporate_Bundle;
    public static final Id PR_CORP_BUNDLE_ID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName()
        .get(PR_CORP_BUNDLE)
        .getRecordTypeId();
    public static final String PR_EDUC_CONS = System.Label.RT_ProductRequest_Educ_Consultancy;
    public static final Id PR_EDUC_CONS_ID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName()
        .get(PR_EDUC_CONS)
        .getRecordTypeId();
    public static final String PR_SOA = System.Label.RT_ProductRequest_SOA; 
    public static final Id PR_SOA_ID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName()
        .get(PR_SOA)
        .getRecordTypeId();
    public static final String PR_COMPLETED = System.Label.PL_ProductRequest_Completed;
    public static final String PR_NOT_PROCEEDING = System.Label.PL_ProductRequest_Not_Proceeding;

    public static IProductRequestsDAO newInstance() {
        return (IProductRequestsDAO) ImplementationSelector.DAO.newInstance(
            Product_Request__c.SObjectType
        );
    }

    public Schema.SObjectType getSObjectType() {
        return Product_Request__c.SObjectType;
    }

    public List<Product_Request__c> getProductRequestsBySetNames(Set<String> productRequestNames) {
        return [
            SELECT Id
            FROM Product_Request__c
            WHERE Product_Request_Name__c IN :productRequestNames
            WITH USER_MODE
        ];
    }
}
