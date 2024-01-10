/**
 * @description Mock DAO Class for Product Category object
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
public inherited sharing class ProductCategoriesDAOMock extends DmlBaseMock implements IProductCategoriesDAO {
    public Map<Id, ProductCategory> productCategoriesMap;

    public Schema.SObjectType getSObjectType() {
        return ProductCategory.SObjectType;
    } 

    public ProductCategoriesDAOMock() {
        super(new Map<Id, ProductCategory>(), Schema.ProductCategory.SObjectType);
        this.productCategoriesMap = (Map<Id, ProductCategory>) super.records;
    }

    public List<ProductCategory> getProductCategoriesByProduct2Category(
        List<String> prodCategories,
        AccessLevel accessLevel
    ){
        List<ProductCategory> productCategoriesList = new List<ProductCategory>();  
        for (ProductCategory record : productCategoriesMap.values()) {
            if (prodCategories.contains(record.Name)){
                productCategoriesList.add(record);
            }
        }
        return productCategoriesList;
    }
}
