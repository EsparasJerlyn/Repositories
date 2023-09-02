/**
 * @description Interface for Product Request DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file
 */
public interface IProductRequestsDAO extends DmlInterface {
    List<Product_Request__c> getProductRequestsBySetNames(Set<String> productRequestNames);
}
