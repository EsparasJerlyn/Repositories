/**
 * @description Service class for associated products object
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 25, 2023        |DEPP-5567               | Created file
 */
public with sharing class AssociatedProductsService {
    public static List<Database.SaveResult> deactivateByProductRequest(
        Set<Id> parentProductRequestIds
    ) {
        List<Database.SaveResult> databaseResult;
        List<Associated_Products__c> activeAssociatedProducts = AssociatedProductsDAO.newInstance()
            .getActiveAssociatedProductsByProductRequest(parentProductRequestIds);

        for (Associated_Products__c associatedProduct : activeAssociatedProducts) {
            associatedProduct.IsActive__c = false;
        }

        if (!activeAssociatedProducts.isEmpty()) {
            databaseResult = AssociatedProductsDAO.newInstance()
                .updateRecords(activeAssociatedProducts, false, AccessLevel.USER_MODE);
        }

        return databaseResult;
    }

    public class AssociatedProductsServiceException extends Exception {
    }
}
