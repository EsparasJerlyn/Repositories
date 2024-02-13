/**
 * @description Interface for Product DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file
 */
public interface IProductsDAO extends DmlInterface {

     List<Product2> getProductById(
        Set<Id> productIdSet,
        AccessLevel accessLevel
    ); 
}
