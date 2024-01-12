/**
 * @description Mock DAO Class for Product Category Product object
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | arsenio.jr.dayrit              | January 02, 2024      |  ApexCRUDViolationFix  | Created file                 |
 */
@isTest
public inherited sharing class ProductCategoryProductsDAOMock extends DmlBaseMock implements IProductCategoryProductsDAO {
    public Map<Id, ProductCategoryProduct> productCategoryProductsMap;

    public Schema.SObjectType getSObjectType() {
        return ProductCategoryProduct.SObjectType;
    } 

    public ProductCategoryProductsDAOMock() {
        super(new Map<Id, ProductCategoryProduct>(), Schema.ProductCategoryProduct.SObjectType);
        this.productCategoryProductsMap = (Map<Id, ProductCategoryProduct>) super.records;
    }

    public List<ProductCategoryProduct> getProductCategoryProductByProdCatalogIdAndProdCategoryId(
        Set<Id> prodCatalogIdSet,
        Set<Id> prodCategIdSet,
        AccessLevel accessLevel
    ){
        List<ProductCategoryProduct> productCategoryProductList = new List<ProductCategoryProduct>();
        for (ProductCategoryProduct record : productCategoryProductsMap.values()) {
            if (prodCatalogIdSet.contains(record.CatalogId) && prodCategIdSet.contains(record.ProductCategoryId) ){
                productCategoryProductList.add(record);
            }
        }
        return productCategoryProductList;
    }
}
