/**
 * @description Controller Class for LWC Product Details Advancement
 * @see ../lwc/productDetailsAdvancement
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                    |
      |--------------------------------|-----------------------|------------------------|---------------------------------------------------|
      | kenneth.f.alsay                | August 7, 2024        | DEPP-9140              | Created file                                      |
 */
public with sharing class DesignationProductCtrl {
    	/**
	 * @description fetches product information using provided productId
	 * @param productId - Product Id on productdetailpage
	 * @return prodDetailsData - Product Details
	 */
     @AuraEnabled(cacheable=true)
     public static DesignationProductDetails getDesignationProductDetails(Id productId) {
          DesignationProductDetails designationProdDetails = new DesignationProductDetails();
          //List<ProductWrapper> productWrapper = new List<ProductWrapper>();

          		// Product
		List<Product2> productsOnPageList = ProductsDAO.newInstance().getDesignationProductById(new Set<Id>{productId}, AccessLevel.SYSTEM_MODE);
		if(productsOnPageList.isEmpty()){ 
			throw new AuraHandledException('No Product');
		}else{
               designationProdDetails.productOnPage = productsOnPageList[0];
          }
          
          return designationProdDetails;
     }

     /**
	 * @description wrapper that contains the fields for Product2
	 */
     public class DesignationProductDetails{
          @AuraEnabled
		public Product2 productOnPage;
     }
}