/**
 * @description DAO Class for Associated Product object. Contains soql and constants related to the Associated Product object.
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               ---------------|
      |--------------------------------|-----------------------|------------------------|---------------------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file                                |
      | arsenio.jr.dayrit              | January 02, 2024      |  ApexCRUDViolationFix  | Added method for getAssociatedProductsById  |
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

    public List<Associated_Products__c> getAssociatedProductsById(
        Set<Id> associatedProdIds,
        AccessLevel accessLevel
    ){

        if(associatedProdIds.isEmpty()){
            return new List<Associated_Products__c>();
        }
        return Database.query(
            'SELECT Id, Product_Request__c, Product_Request__r.RecordTypeId ' +
            'FROM Associated_Products__c ' +
            'WHERE Id IN :associatedProdIds ',
            accessLevel
        );
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
