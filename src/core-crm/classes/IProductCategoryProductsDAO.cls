/**
 * @description Interface for Product Category Product DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | arsenio.jr.dayrit              | January 02, 2024      |  ApexCRUDViolationFix  | Created file                 |
 */
public interface IProductCategoryProductsDAO extends DmlInterface {

    List<ProductCategoryProduct> getProductCategoryProductByProdCatalogIdAndProdCategoryId(
        Set<Id> prodCatalogIdSet,
        Set<Id> prodCategIdSet,
        AccessLevel accessLevel
    );  
}
