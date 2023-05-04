/**
 * @description Interface for Associated Product DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file
 */
public interface IAssociatedProductsDAO extends DmlInterface {
    List<Associated_Products__c> getActiveAssociatedProductsByProductRequest(
        Set<Id> productRequestIds
    );
}
