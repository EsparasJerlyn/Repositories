/**
 * @description Mock DAO Class for Product Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file
      | kenneth.f.alsay                | March 27, 2024        | DEPP-8209              | Added getProductByDonationCauseId
      | kenneth.f.alsay                | April 4, 2024         | DEPP-8399              | Added getProductByDesignationId
      | marygrace.li                   | May 2, 2024           | DEPP-8399              | Deleted getProductByDonationCauseId
      | kenneth.f.alsay                | May 7, 2024           | DEPP-8203              | Removed Donation Cause references
      | sebastianne.k.trias            | May 22, 2024          | DEPP-8410              | Added getProductsOnPage      |
 */
@isTest
public inherited sharing class ProductsDAOMock extends DmlBaseMock implements IProductsDAO {

	public Map<Id, Product2> productsMap;

    public Schema.SObjectType getSObjectType()
	{
		return Product2.SObjectType;
	}

	public ProductsDAOMock() {
		super(new Map<Id, Product2>(), Schema.Product2.SObjectType);
		this.productsMap = (Map<Id, Product2>) super.records;
	}

	public List<Product2> getProductById(
        Set<Id> productIdSet,
        AccessLevel accessLevel
    ){
        List<Product2> productList = new List<Product2>();
        for (Product2 record : productsMap.values()) {
            if (productIdSet.contains(record.Id)){
                productList.add(record);
            }
        }
        return productList;
    }


    public List<Product2> getProductByDesignationId(
        Set<Id> designationIds,
        AccessLevel accessLevel
    ){
        List<Product2> productList = new List<Product2>();
        for (Product2 record : productsMap.values()) {
            if (designationIds.contains(record.Designation__c)){
                productList.add(record);
            }
        }
        return productList;
    }

    public List<Product2> getProductsOnPage(
        Set<Id> productIdSet,
        Set<Id> priceBookIds,
        AccessLevel accessLevel
    ){
        List<Product2> productList = new List<Product2>();
        for (Product2 record : productsMap.values()) {
            if (productIdSet.contains(record.Id)){
                productList.add(record);
            }
        }
        return productList;
    }
}