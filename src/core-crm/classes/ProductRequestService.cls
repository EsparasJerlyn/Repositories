/**
 * @description service class for product request. contains reusable methods related to the product request object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | rhea.b.torres                  | April 25, 2023        | DEPP-5567              | Created file
 */
public with sharing class ProductRequestService {
    public static List<Database.SaveResult> completeProductRequests(
        Set<Id> productRequestsIdsToComplete
    ) {
        List<Product_Request__c> productRequestsToComplete = new List<Product_Request__c>();

        // Build Product Request List for completion
        for (Id recordId : productRequestsIdsToComplete) {
            productRequestsToComplete.add(
                new Product_Request__c(
                    Id = recordId,
                    Product_Request_Status__c = ProductRequestsDAO.PR_COMPLETED
                )
            );
        }

        return ProductRequestsDAO.newInstance()
            .updateRecords(productRequestsToComplete, false, AccessLevel.USER_MODE);
    }

    public class ProductRequestServiceException extends Exception {
    }
}
