/**
 * @description Interface for Product DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file                 |
      | sebastianne.k.trias            | May 22, 2024          | DEPP-8410              | Added getProductsOnPage      |
 */
public interface IProductsDAO extends DmlInterface {

     List<Product2> getProductById(
        Set<Id> productIdSet,
        AccessLevel accessLevel
    ); 

    List<Product2> getProductsOnPage(
        Set<Id> productIdSet,
        Set<Id> priceBookIds,
        AccessLevel accessLevel
    ); 
}