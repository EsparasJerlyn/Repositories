/**
 * @description Interface for Associated Product DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                              |
      |--------------------------------|-----------------------|------------------------|---------------------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file                                |
      | arsenio.jr.dayrit              | January 02, 2024      |  ApexCRUDViolationFix  | Added method for getAssociatedProductsById  |   
 */
public interface IAssociatedProductsDAO extends DmlInterface {
    List<Associated_Products__c> getActiveAssociatedProductsByProductRequest(
        Set<Id> productRequestIds
    );

    List<Associated_Products__c> getAssociatedProductsById(
        Set<Id> associatedProdIds,
        AccessLevel accessLevel
    ); 
}
