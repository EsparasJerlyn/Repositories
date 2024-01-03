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
    public Map<Id, ProductCategory> ProductCategoriesMap;

    public Schema.SObjectType getSObjectType() {
        return ProductCategory.SObjectType;
    }

    public ProductCategoriesDAOMock() {
        super(new Map<Id, ProductCategory>(), Schema.ProductCategory.SObjectType);
        this.ProductCategoriesMap = (Map<Id, ProductCategory>) super.records;
    }

    public List<ProductCategory> getProductCategoriesByProduct2Category(
        List<String> prodCategories,
        AccessLevel accessLevel
    ){
        List<ProductCategory> ProductCategoriesList = new List<ProductCategory>();
        for (ProductCategory record : ProductCategoriesMap.values()) {
            if (prodCategories.contains(record.Name)){
                ProductCategoriesList.add(record);
            }
        }
        return ProductCategoriesList;
    }
}
