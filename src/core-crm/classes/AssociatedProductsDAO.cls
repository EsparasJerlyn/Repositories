/**
 * @description DAO Class for Associated Product object. Contains soql and constants related to the Associated Product object.
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file
 */
public inherited sharing class AssociatedProductsDAO extends DmlBase implements IAssociatedProductsDAO {
    public List<Associated_Products__c> getActiveAssociatedProductsByProductRequest(
        Set<Id> productRequestIds
    ) {
        return [
            SELECT Id, IsActive__c
            FROM Associated_Products__c
            WHERE Product_Request__c IN :productRequestIds AND IsActive__c = TRUE
            WITH USER_MODE
        ];
    }

    public Schema.SObjectType getSObjectType() {
        return Associated_Products__c.SObjectType;
    }

    public static IAssociatedProductsDAO newInstance() {
        return (IAssociatedProductsDAO) ImplementationSelector.DAO.newInstance(
            Associated_Products__c.SObjectType
        );
    }
}
