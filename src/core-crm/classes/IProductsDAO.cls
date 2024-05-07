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
      | kenneth.f.alsay                | May 7, 2024           | DEPP-8203              | Removed Donation Cause references  |
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
}