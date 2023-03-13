/**
 * @description Class to handle calls to ConnectApi Commerce
 * 
 * 
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | marygrace.li@qut.edu.au        | December 8, 2021      | DEPP-174               | Created file                 | 
      |                                |                       |                        |                              | 
 */
  public with sharing class B2BGetInfo {
    
  /**
  * @description method to call ConnectApi.CommerceCatalog.getProduct
  * @param communityId The Id of the community from which the call originated
  * @param productId The Id of the product
  * @param @param effectiveAccountId ID of the account for which the request is made. If null, defaults to the account ID for the context user.
  */  
  @AuraEnabled(cacheable=true)
  public static ConnectApi.ProductDetail getProduct(
    String communityId,
    String productId,
    String effectiveAccountId
  ) {
    // Lookup the webstore ID associated with the community
    String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);

    if(Test.isRunningTest()){
      return null;
    }else{
      //https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCatalog_static_methods.htm#apex_ConnectAPI_CommerceCatalog_static_methods
      return ConnectApi.CommerceCatalog.getProduct( webstoreId, productId, effectiveAccountID, null, false, null, false, true, false);
    }
    
  }

  /**
  * @description method to call ConnectApi.CommerceCart.getCartSummary
  * @param communityId The Id of the community from which the call originated
  * @param @param effectiveAccountId ID of the account for which the request is made. If null, defaults to the account ID for the context user.
  */    
  @AuraEnabled
  public static ConnectApi.CartSummary getCartSummary(
    String communityId,
    String effectiveAccountId
  ) {
    // Lookup the webstore ID associated with the community
    String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
    List<User> currentUserDetails = getUserContactDetails(effectiveAccountID);

    if(!currentUserDetails.isEmpty() && currentUserDetails[0].Contact.hed__Primary_Organization__c != null){
      effectiveAccountId = currentUserDetails[0].Contact.hed__Primary_Organization__c;
    }
    //'current' is available in version 50.0 and later and indicates a cart with a status that isn’t Closed or PendingDelete
    //This is important for the product detail page since we are using the cart summary to check if the status is "Processing" or "Checkout"
    String activeCartOrId = 'current';
    
    if(Test.isRunningTest()){
      return null;
    }else{ 
      //https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
      return ConnectApi.CommerceCart.getCartSummary(webstoreId, effectiveAccountId, activeCartOrId);}
  }
  /**
  * @description method to call ConnectApi.CommerceCart.getOrCreateActiveCartSummary
  * @param communityId
  * @param effectiveAccountId
  */    

  @AuraEnabled
  public static ConnectApi.CartSummary getOrCreateActiveCartSummary(
    String communityId,
    String effectiveAccountId
  ) {
    // Lookup the webstore ID associated with the community
    String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
    List<User> currentUserDetails = getUserContactDetails(effectiveAccountID);

    if(!currentUserDetails.isEmpty() && currentUserDetails[0].Contact.hed__Primary_Organization__c != null){
      effectiveAccountId = currentUserDetails[0].Contact.hed__Primary_Organization__c;
    }
    //'current' is available in version 50.0 and later and indicates a cart with a status that isn’t Closed or PendingDelete
    //This is important for the product detail page since we are using the cart summary to check if the status is "Processing" or "Checkout"
    String activeCartOrId = 'current';
    if(Test.isRunningTest()){
      return null;
    }else{
      //https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
      return ConnectApi.CommerceCart.getOrCreateActiveCartSummary(webstoreId, effectiveAccountId, activeCartOrId);
    }
  }

  /**
  * @description method to call ConnectApi.CartItem.addToCart
  * @param communityId The Id of the community from which the call originated
  * @param productId The Id of the product
  * @param quantity The Quantity of the cart item
  * @param @param effectiveAccountId ID of the account for which the request is made. If null, defaults to the account ID for the context user.
  */   
  @AuraEnabled
  public static ConnectApi.CartItem addToCart(
    String communityId,
    String productId,
    String quantity,
    String effectiveAccountId
  ) {
    // Lookup the webstore ID associated with the community
    String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);

    ConnectApi.CartItemInput cartInput = new ConnectApi.CartItemInput();
    cartInput.productId = productId;
    cartInput.quantity = quantity;
    cartInput.type = ConnectApi.CartItemType.PRODUCT;

    if(Test.isRunningTest()){
      return null;
    }else{
      //https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm#apex_ConnectAPI_CommerceCart_static_methods
      return ConnectApi.CommerceCart.addItemToCart(webstoreId, effectiveAccountId, 'active', cartInput);}
    }

  /**
  * @description method to call ConnectApi.Wishlist.createAndAddToList
  * @param communityId The Id of the community from which the call originated
  * @param productId The Id of the product
  * @param wishlistName The Name of the wishlist
  * @param @param effectiveAccountId ID of the account for which the request is made. If null, defaults to the account ID for the context user.
  */    
  @AuraEnabled
  public static ConnectApi.Wishlist createAndAddToList(
    String communityId,
    String productId,
    String wishlistName,
    String effectiveAccountId
  ) {
    // Lookup the webstore ID associated with the community
    String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);

    // Store the product in a WishlistItemInput to pass to the Wishlist
    ConnectApi.WishlistItemInput wishlistItemInput = new ConnectApi.WishlistItemInput();
    wishlistItemInput.productId = productId;

    //Create a wishlistInput to be created
    ConnectApi.WishlistInput wishlistInput = new ConnectApi.WishlistInput();
    wishlistInput.name = wishlistName;
    wishlistInput.products = new List<ConnectApi.WishlistItemInput>{
      wishlistItemInput
    };

    if(Test.isRunningTest()){
      return null;
    }else{ 
      //https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceWishlist_static_methods.htm#apex_ConnectAPI_CommerceWishlist_static_methods    
      return ConnectApi.CommerceWishlist.createWishlist(webstoreId,effectiveAccountId, wishlistInput);}
  }

  /**
  * @description method to call ConnectApi.ProductPrice.getProductPrice
  * @param communityId The Id of the community from which the call originated
  * @param productId The Id of the product
  * @param @param effectiveAccountId ID of the account for which the request is made. If null, defaults to the account ID for the context user.
  */  
  @AuraEnabled(cacheable=true)
  public static ConnectApi.ProductPrice getProductPrice(
    String communityId,
    String productId,
    String effectiveAccountId
  ) {
    // Lookup the webstore ID associated with the community
    String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);

    if(Test.isRunningTest()){
      return null;
    }else{ 
      //https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceStorePricing_static_methods.htm#apex_ConnectAPI_CommerceStorePricing_static_methods
      return ConnectApi.CommerceStorePricing.getProductPrice( webstoreId, productId, effectiveAccountId);}
  }

  /**
  * @description method to get current user details using the effective id
  * @param @param effectiveAccountId ID of the account for which the request is made. If null, defaults to the account ID for the context user.
  */  
  @AuraEnabled(cacheable=true)
  public static List<User> getUserContactDetails(
    String effectiveAccountId
  ) {

    List<User> currentUser =  [
        SELECT Contact.hed__Primary_Organization__c 
        FROM User 
        WHERE AccountId =: effectiveAccountID
        AND Profile.Name = 'Corporate Partner'
        Limit 1];

    return currentUser;
  }
}