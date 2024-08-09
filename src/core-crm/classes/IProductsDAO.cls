/**
 * @description Interface for Product DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                     |
      |--------------------------------|-----------------------|------------------------|------------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file                       |
      | kenneth.f.alsay                | March 27, 2024        | DEPP-8209              | Added getProductByDonationCauseId  |
      | kenneth.f.alsay                | April 4, 2024         | DEPP-8399              | Added getProductByDesignationId    |
      | marygrace.li                   | May 2, 2024           | DEPP-8209              | Deleted getProductByDonationCauseId  |
      | kenneth.f.alsay                | May 7, 2024           | DEPP-8203              | Removed Donation Cause references  |
      | sebastianne.k.trias            | May 22, 2024          | DEPP-8410              | Added getProductsOnPage            |
      | kenneth.f.alsay                | August 8, 2024        | DEPP-9140              | Added getDesignationProductById    |
*/
public interface IProductsDAO extends DmlInterface {

     List<Product2> getProductById(
        Set<Id> productIdSet,
        AccessLevel accessLevel
     );

     List<Product2> getProductByDesignationId(
          Set<Id> designationIds,
          AccessLevel accessLevel
     );

    List<Product2> getProductsOnPage(
        Set<Id> productIdSet,
        Set<Id> priceBookIds,
        AccessLevel accessLevel
    );

    List<Product2> getDesignationProductById(
          Set<Id> productIdSet,
          AccessLevel accessLevel
    );
}