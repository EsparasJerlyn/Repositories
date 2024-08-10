/**
 * @description Interface for Product Category DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | arsenio.jr.dayrit              | January 02, 2024      |  ApexCRUDViolationFix  | Created file                 |
 */
public interface IProductCategoriesDAO extends DmlInterface {

    List<ProductCategory> getProductCategoriesByProduct2Category(
        List<String> prodCategories,
        AccessLevel accessLevel
    );  
}
