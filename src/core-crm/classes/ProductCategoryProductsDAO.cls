/**
 * @description DAO Class for Product Category Product object. Contains soql and constants related to the Product Category Product object.
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | arsenio.jr.dayrit              | January 02, 2024      |  ApexCRUDViolationFix  | Created file                 |
 */
public inherited sharing class ProductCategoryProductsDAO extends DmlBase implements IProductCategoryProductsDAO {

    public Schema.SObjectType getSObjectType() {
        return ProductCategoryProduct.SObjectType;
    } 

    public static IProductCategoryProductsDAO newInstance() {
        return (IProductCategoryProductsDAO) ImplementationSelector.DAO.newInstance(
            ProductCategoryProduct.SObjectType
        );
    }

    public List<ProductCategoryProduct> getProductCategoryProductByProdCatalogIdAndProdCategoryId(
        Set<Id> prodCatalogIdSet,
        Set<Id> prodCategIdSet,
        AccessLevel accessLevel
    ){

        if(prodCatalogIdSet.isEmpty() || prodCategIdSet.isEmpty()){
            return new List<ProductCategoryProduct>();
        }
        return Database.query(
            'SELECT ProductCategory.Name, ProductId, ProductCategoryId '+
            'FROM ProductCategoryProduct '+
            'WHERE CatalogId IN :prodCatalogIdSet '+
            'AND ProductCategoryId IN :prodCategIdSet ',
            accessLevel
        );
    }

}
