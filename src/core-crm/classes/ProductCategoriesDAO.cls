/**
 * @description DAO Class for Product Category object. Contains soql and constants related to the Product Category object.
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | arsenio.jr.dayrit              | January 02, 2024      |  ApexCRUDViolationFix  | Created file                 |
 */
public inherited sharing class ProductCategoriesDAO extends DmlBase implements IProductCategoriesDAO {

    public static final String CCE_CATALOG = 'CCE Catalog';

    public Schema.SObjectType getSObjectType() {
        return ProductCategory.SObjectType;
    } 

    public static IProductCategoriesDAO newInstance() {
        return (IProductCategoriesDAO) ImplementationSelector.DAO.newInstance(
            ProductCategory.SObjectType
        );
    }

    public List<ProductCategory> getProductCategoriesByProduct2Category(
        List<String> prodCategories,
        AccessLevel accessLevel
    ){

        if(prodCategories.isEmpty()){
            return new List<ProductCategory>();
        }
        return Database.query(
            'SELECT Id, Name, CatalogId, Catalog.Name ' +
            'FROM ProductCategory ' +
            'WHERE Name IN :prodCategories ' +
            'AND Catalog.Name =: CCE_CATALOG ',
            accessLevel
        );
    }

}
