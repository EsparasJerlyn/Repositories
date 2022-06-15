/**
 * @description Controller Class for cartDetails LWC
 * @see ../lwc/productDetails
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                             |
      |---------------------------|-----------------------|----------------------|--------------------------------------------|
      | john.m.tambasen           | May 11, 2022          | DEPP-2060            | Created file                               |
      | john.m.tambasen           | May 17, 2022          | DEPP-1151            | added the updation of cart status          |

*/
public without sharing class CartItemCtrl {
  /**
   * @description fetches cart items data and related registration questiosn for the product
   * @param cartId - id of the current active cart
   * @return myCartItemsData - CartItemsData data type
   */
  @AuraEnabled
  public static CartItemsData getCartItemsByCart(String cartId, String userId) {
    //instantiate variables
    List<CartItem> cartItemList = new List<CartItem>();
    List<Answer__c> answerList = new List<Answer__c>();

    Set<Id> pbentryIds = new Set<Id>();
    Set<Id> productIds = new Set<Id>();
    Set<Id> productReqIds = new Set<Id>();
    Set<Id> relatedAnswerIds = new Set<Id>();

    CartItemsData myCartItemsData = new CartItemsData();
    List<CartItemsWrapper> myCartItemsList = new List<CartItemsWrapper>();

    //get the contact ID of the user
    String contactId = [SELECT ContactId FROM User WHERE Id = :userId LIMIT 1]
    .ContactId;

    //retrieve cart items
    cartItemList = [
      SELECT
        Id,
        Cart.External_Id__c,
        Name,
        Product2Id,
        Pricebook_Entry_ID__c,
        Course_Offering__c,
        Course_Offering__r.hed__Course__r.ProductRequestID__c,
        Course_Offering__r.hed__Start_Date__c,
        Course_Offering__r.Delivery_Type__c,
        Course_Offering__r.Available_Seats__c,
        Program_Offering__c,
        Program_Offering__r.Start_Date__c,
        Program_Offering__r.Delivery_Type__c,
        Program_Offering__r.Available_Seats__c,
        External_Id__c
      FROM CartItem
      WHERE CartId = :cartId
    ];

    //loop on the returned list to populate price book entry and product IDs
    for (CartItem currentCart : cartItemList) {
      pbentryIds.add(currentCart.Pricebook_Entry_ID__c);
      productIds.add(currentCart.Product2Id);
      productReqIds.add(currentCart.Course_Offering__r.hed__Course__r.ProductRequestID__c);
    }

    List<Related_Answer__c> relatedAnswerList = new List<Related_Answer__c>();     
    //retrieve relatedAnswerList
    relatedAnswerList = [
      SELECT
      Id,
      Question__r.Type__c,
      Question__r.Label__c,
      Sequence__c,
      Questionnaire__r.Parent_Record_ID__c,
      Question__r.Acceptable_Response__c,
      Question__r.Message__c,
      Questionnaire__r.Questionnaire_Type__c,
      Question__r.Dropdown_Options__c
    FROM Related_Answer__c
    WHERE
      Questionnaire__r.Parent_Record_ID__c IN :productReqIds
      AND Questionnaire__r.Questionnaire_Type__c = 'Registration Questions'
    ORDER BY Questionnaire__r.Questionnaire_Type__c, Sequence__c
    ];

    Map<id, List<Related_Answer__c>> QuestionnaireMap = new Map<id, List<Related_Answer__c>>();
    for(Related_Answer__c RA :relatedAnswerList){
       //RelatedAnswerForKey = new List<Related_Answer__c>();
       QuestionnaireMap.put(RA.Questionnaire__r.Parent_Record_ID__c, relatedAnswerList);
    }

    //create map of price book entry for linking with the cart items
    Map<Id, PricebookEntry> pbEntryMap = new Map<Id, PricebookEntry>(
      [
        SELECT Id, Pricebook2.Name, UnitPrice
        FROM PricebookEntry
        WHERE Id IN :pbentryIds
      ]
    );

    //loop for popoulating the returned object
    for (CartItem currentCart : cartItemList) {
      CartItemsWrapper cartItemsWrapper = new CartItemsWrapper();

      //populate data
      cartItemsWrapper.cartItemId = currentCart.Id;
      cartItemsWrapper.productName = currentCart.Name;
      cartItemsWrapper.productId = currentCart.Product2Id;
      cartItemsWrapper.contactId = contactId;
      cartItemsWrapper.CourseOfferingId =currentCart.Course_Offering__c;

      if(QuestionnaireMap.containsKey(currentCart.Course_Offering__r.hed__Course__r.ProductRequestID__c)) {
        
        List<Related_Answer__c> relatedAnswersList2 = QuestionnaireMap.get(currentCart.Course_Offering__r.hed__Course__r.ProductRequestID__c);
          List<RelatedAnswersWrapper> relatedAnswerListWrap = new List<RelatedAnswersWrapper>();  //container for related answer
         
          for (Related_Answer__c ra2 : relatedAnswersList2 ) {
               RelatedAnswersWrapper relatedAnswerListSingle = new RelatedAnswersWrapper(); 
               List<OptionsWrapper> OptionsWrapperList = new List<OptionsWrapper>();
               List<String> tempStrList = ra2.Question__c != null ? (ra2.Question__r.Dropdown_Options__c != null ? ra2.Question__r.Dropdown_Options__c.split(';') : new List<String>()) : new List<String>();
                      for (String opp : tempStrList) 
                      {
                        OptionsWrapper oppWrapper = new OptionsWrapper();
                          oppWrapper.label = opp;
                          oppWrapper.value = opp;
                          OptionsWrapperList.add(oppWrapper);
                      }
                      relatedAnswerListSingle.Options = OptionsWrapperList;
               relatedAnswerListSingle.Id  = ra2.Id;
               relatedAnswerListSingle.QuestionId  = ra2.Question__r.Id;
               relatedAnswerListSingle.Label  = ra2.Question__r.Label__c;
               relatedAnswerListSingle.MandatoryResponse  = ra2.Question__r.Acceptable_Response__c;
               relatedAnswerListSingle.Message  = ra2.Question__r.Message__c;
               relatedAnswerListSingle.Type  = ra2.Question__r.Type__c;
               relatedAnswerListSingle.IsText = ra2.Question__r.Type__c == 'Text' ? true : false;
               relatedAnswerListSingle.IsCheckbox = ra2.Question__r.Type__c == 'Checkbox' ? true : false;
               relatedAnswerListSingle.IsNumber = ra2.Question__r.Type__c == 'Number' ? true : false;
               relatedAnswerListSingle.IsDate = ra2.Question__r.Type__c == 'Date' ? true : false;              
               relatedAnswerListSingle.IsPicklist = ra2.Question__r.Type__c == 'Picklist' ? true : false;
               relatedAnswerListSingle.IsCheckbox = ra2.Question__r.Type__c == 'Checkbox' ? true : false;
               relatedAnswerListSingle.IsMultiPicklist = ra2.Question__r.Type__c == 'Multi-Select Picklist' ? true : false;                                           
               relatedAnswerListSingle.Answer  = '';
               relatedAnswerListSingle.IsFileUpload = ra2.Question__r.Type__c == 'File Upload'?true:false;
               relatedAnswerListSingle.QuestionnaireId  = ra2.Questionnaire__c;
               relatedAnswerListSingle.IsCriteria  = ra2.Questionnaire__r.Questionnaire_Type__c == 'Registration Criteria'
               ? true
               : false;
               relatedAnswerListSingle.IsQuestion  = ra2.Questionnaire__r.Questionnaire_Type__c == 'Application Questions'
               ? true
               : false;
               relatedAnswerListSingle.Sequence  = ra2.Sequence__c;
               relatedAnswerListSingle.ErrorMessage  = '';
               relatedAnswerListSingle.FileData  = '';         
               relatedAnswerListWrap.add(relatedAnswerListSingle);      
          }
          cartItemsWrapper.relatedAnswers = relatedAnswerListWrap;

      }

      //if course offering field is not empty (Course offering product)
      if(currentCart.Course_Offering__c != null){

        //set data from the Course_Offering__c
        cartItemsWrapper.startDate = Datetime.newInstance(
          currentCart.Course_Offering__r.hed__Start_Date__c,
          Time.newInstance(0, 0, 0, 0)
        )
        .format('dd MMM yyyy');
        cartItemsWrapper.deliveryType = currentCart.Course_Offering__r.Delivery_Type__c;

        //check if seats are still available
        if (currentCart.Course_Offering__r.Available_Seats__c > 0) {
          cartItemsWrapper.seatsAvailable = true;
        }

      //else it is a program offering product
      } else {

        //set data from the Program_Offering__c
        cartItemsWrapper.startDate = Datetime.newInstance(
          currentCart.Program_Offering__r.Start_Date__c,
          Time.newInstance(0, 0, 0, 0)
        )
        .format('dd MMM yyyy');
        cartItemsWrapper.deliveryType = currentCart.Program_Offering__r.Delivery_Type__c;

        //check if seats are still available
        if (currentCart.Program_Offering__r.Available_Seats__c > 0) {
          cartItemsWrapper.seatsAvailable = true;
        }
      }

      cartItemsWrapper.pbName = pbEntryMap.get(
          currentCart.Pricebook_Entry_ID__c
        )
        .Pricebook2.Name;
      cartItemsWrapper.unitPrice = pbEntryMap.get(
          currentCart.Pricebook_Entry_ID__c
        )
        .UnitPrice;
      cartItemsWrapper.unitDiscount = 0;

      if (currentCart.Cart.External_Id__c != null){
        cartItemsWrapper.externalId = currentCart.Cart.External_Id__c;
      }

      // check if pricebook is staff
      if (cartItemsWrapper.pbName == 'Current Staff') {
        //showthe staff ID
        myCartItemsData.showStaffId = true;
      }

      //check if pricebook is current learner or alumni
      if (
        cartItemsWrapper.pbName == 'Current Learner' ||
        cartItemsWrapper.pbName == 'Alumni'
      ) {
        //showthe student ID
        myCartItemsData.showStudentId = true;
      }

      myCartItemsList.add(cartItemsWrapper);
    }

    myCartItemsData.cartItemsList = myCartItemsList;

    return myCartItemsData;
  }

  public class CartItemsData {
    @AuraEnabled
    public List<CartItemsWrapper> cartItemsList;
    @AuraEnabled
    public Boolean showStaffId = false;
    @AuraEnabled
    public Boolean showStudentId = false;
  }

  public class CartItemsWrapper {
    @AuraEnabled
    public String cartItemId;
    @AuraEnabled
    public String productName;
    @AuraEnabled
    public String productId;
    @AuraEnabled   
    public String contactId;
    @AuraEnabled
    public String CourseOfferingId;
    @AuraEnabled
    public String startDate;
    @AuraEnabled
    public String deliveryType;
    @AuraEnabled
    public String pbName;
    @AuraEnabled
    public Double unitPrice;
    @AuraEnabled
    public Double unitDiscount = 0;
    @AuraEnabled
    public Boolean seatsAvailable = false;
    @AuraEnabled
    public Boolean showInvalidDiscount = false;
    @AuraEnabled
    public String externalId;
    @AuraEnabled
    public List<RelatedAnswersWrapper> relatedAnswers;
  }
  public class RelatedAnswersWrapper {
    @AuraEnabled
    public String Id;
    @AuraEnabled
    public String QuestionId;
    @AuraEnabled
    public String Label;
    @AuraEnabled
    public String MandatoryResponse;
    @AuraEnabled
    public String Message;
    @AuraEnabled
    public String Type;
    @AuraEnabled
    public Boolean IsText;
    @AuraEnabled
    public Boolean IsCheckbox;
    @AuraEnabled
    public Boolean IsNumber;
    @AuraEnabled
    public Boolean IsDate;
    @AuraEnabled
    public Boolean IsPicklist;
    @AuraEnabled
    public Boolean IsMultiPicklist;                                          
    @AuraEnabled
    public Boolean IsFileUpload;
    @AuraEnabled 
    public String Answer;
    @AuraEnabled
    public String QuestionnaireId;
    @AuraEnabled
    public Boolean IsCriteria;
    @AuraEnabled
    public Boolean IsQuestion;
    @AuraEnabled
    public Decimal Sequence;
    @AuraEnabled
    public String ErrorMessage;
    @AuraEnabled
    public String FileData;
    @AuraEnabled
    public List<OptionsWrapper> Options;
  }

  public class OptionsWrapper {
    @AuraEnabled
    public String label;
    @AuraEnabled
    public String value;
  }

  public class FileData {
    @AuraEnabled
    public String fileName;
    @AuraEnabled
    public String base64;
  }

  /**
   * @description fetches cart items data and related registration questiosn for the product
   * @param cartId - id of the cart where coupon will be applied
   * @param couponCode - the code entered by the user
   * @param totalPrice - total price of the cart item
   * @return myCartItemsData - CartItemsData data type
   */
  @AuraEnabled(cacheable=true)
  public static Double getCartItemDiscount(
    String cartId,
    String couponCode,
    Double totalPrice
  ) {
    //create a list for Promotion, PromotionTarget, and Coupon
    List<CartItem> cartItemList = new List<CartItem>();
    List<Promotion> promotionList = new List<Promotion>();
    List<PromotionTarget> promotionTargetList = new List<PromotionTarget>();
    List<Coupon> couponList = new List<Coupon>();
    Double totalDiscount = 0;

    //retrieve cart items
    cartItemList = [
      SELECT
        Id,
        Name,
        Product2Id,
        Pricebook_Entry_ID__c
      FROM CartItem
      WHERE CartId = :cartId
    ];

    Set<Id> productIds = new Set<Id>();
    Set<Id> pbentryIds = new Set<Id>();


    //loop on the returned list to populate price book entry and product IDs
    for (CartItem currentCart : cartItemList) {
      productIds.add(currentCart.Product2Id);
      pbentryIds.add(currentCart.Pricebook_Entry_ID__c);
    }

    //create map of price book entry for linking with the cart items
    Map<Id, PricebookEntry> pbEntryMap = new Map<Id, PricebookEntry>(
      [
        SELECT Id, Pricebook2.Name, UnitPrice
        FROM PricebookEntry
        WHERE Id IN :pbentryIds
      ]
    );

    //retrieve Promotions for specific Coupon Code and Product
    promotionList = [
      SELECT
        Id,
        Name,
        IsActive,
        (SELECT Id, Name, CouponCode FROM PromotionCoupons),
        (
          SELECT Id, Name, AdjustmentType, AdjustmentPercent, AdjustmentAmount, TargetType, TargetId
          FROM PromotionTargets
        )
      FROM Promotion
      WHERE
        IsActive = TRUE
        AND Promotion.Id IN (
          SELECT PromotionId
          FROM Coupon
          WHERE
            CouponCode = :couponCode
            AND Status = 'Active'
            AND StartDateTime < :system.now()
            AND EndDateTime > :system.now()
        )
        AND Promotion.Id IN (
          SELECT PromotionId
          FROM PromotionTarget
          WHERE (TargetType = 'Product' AND TargetId IN :productIds) OR TargetType = 'Transaction'
        )
    ];

    //loop on all the options
    for (Promotion currentPromotion : promotionList) {

      //loop in the PromotionTarget for in case of multiple promotions
      for (PromotionTarget currentPromotionTarget : currentPromotion.PromotionTargets) {

        //check if targetype is per product or total transaction
        if(currentPromotionTarget.TargetType == 'Transaction'){

          if (currentPromotionTarget.AdjustmentType == 'PercentageDiscount') {
            //set the discount amount
            totalDiscount = totalDiscount + ((totalPrice * currentPromotionTarget.AdjustmentPercent) / 100);
          }
    
        //else if for product specific
        } else if(currentPromotionTarget.TargetType == 'Product'){

          if (currentPromotionTarget.AdjustmentType == 'FixedAmountOffLineItemTotal') {
            //set the discount amount
            totalDiscount = totalDiscount + currentPromotionTarget.AdjustmentAmount;
  
          } else {
            //loop on the current cart to search for the specific product
            for (CartItem currentCart : cartItemList) {
              
              //checck if the cart product is for the promotion target id
              if(currentCart.Product2Id == currentPromotionTarget.TargetId){

                Double unitPrice = pbEntryMap.get(currentCart.Pricebook_Entry_ID__c).UnitPrice;

                if (currentPromotionTarget.AdjustmentType == 'PercentageDiscount') {
                  //set the discount amount
                  totalDiscount = totalDiscount + ((unitPrice * currentPromotionTarget.AdjustmentPercent) / 100);
        
                } else if (currentPromotionTarget.AdjustmentType == 'FixedAmountOffUnitPrice') {

                  //if the specified amount is greater than the unitPrice
                  if (currentPromotionTarget.AdjustmentAmount > unitPrice) {

                    //max discount should only be the unit price
                    totalDiscount = totalDiscount + unitPrice;

                  } else{

                    //set the discount amount
                    totalDiscount = totalDiscount + currentPromotionTarget.AdjustmentAmount;

                  }   
                }
              }
            }  
          }   
        }
      }
    }

    //discount can not be greater than the price
    if(totalDiscount > totalPrice){
      totalDiscount = totalPrice;
    }

    return totalDiscount;
  }

  /**
   * @description fetches cart items data and related registration questiosn for the product
   * @param communityId - @salesforce/community/Id
   * @param activeCartOrId - current cart ID
   * @param cartItemId - cart item ID
   * @return ConnectApi.CommerceCart.getCartItems() - https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_connectapi_output_cart_item_collection.htm
   */
  @AuraEnabled
  public static void deleteCartItem(
    String communityId,
    String activeCartOrId,
    String cartItemId
  ) {
    // Lookup the webstore ID associated with the community
    String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);

    // For more details, see:
    // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
    ConnectApi.CommerceCart.deleteCartItem(
      webstoreId,
      null,
      activeCartOrId,
      cartItemId
    );
  }

  /**
   * @description updates the cart status
   * @param cartId - cart item ID
   * @param cartStatus - cart status
   */
  @AuraEnabled
  public static void updateCartStatus(String cartId, String cartStatus) {
    //get the cart
    WebCart webCart = [SELECT Id, Name, Status__c FROM WebCart WHERE Id = :cartId LIMIT 1];

    //update the cart based on the status received
    webCart.Status__c = cartStatus;
    update webCart;
  }

  /**
   * @description updates the cart status
   * @param cartId - cart item ID
   * @param cartStatus - cart status
   */
  @AuraEnabled
  public static boolean checkCartOwnerShip(String cartId, String userId) {
    //get the cart
    List<WebCart> ownedCart = [SELECT Id FROM WebCart WHERE Id = :cartId AND OwnerId =: userId LIMIT 1];
    return !ownedCart.isEmpty();
  }

  /**
   * @description get OPE Product Category Id
   * @return OPE Product Category Id
   */
  @AuraEnabled
  public static ProductCategory getOPEProductCateg() {
    ProductCategory prodCateg = new ProductCategory();
    prodCateg = [
      SELECT Id
      FROM ProductCategory
      WHERE Name = 'Products' AND Catalog.Name = 'Study Catalog'
      LIMIT 1
    ];

    return prodCateg;
  }

  /**
   * @description updates the cart discount applied field
   * @param cartId - cart item ID
   * @param discountAmount - cart status
   */
  @AuraEnabled
  public static void updateCartDiscount(String cartId, Double discountAmount) {
    //get the cart
    WebCart webCart = [SELECT Id, Name, Discount_Applied__c FROM WebCart WHERE Id = :cartId LIMIT 1];

    //update the cart based on the status received
    webCart.Discount_Applied__c = discountAmount;
    update webCart;
  }

  /**
   * @description updates the payment method selected by the user
   * @param cartId - WebCart.Id
   * @param paymentMethod - WebCart.Payment_Method__c
   */
  @AuraEnabled
  public static void updatePaymentMethod(String cartId, String paymentMethod) {
    //get the cart
    WebCart webCart = [SELECT Id, Name, External_Id__c, Payment_Method__c FROM WebCart WHERE Id = :cartId LIMIT 1];

    //update the cart based on the status received
    webCart.Payment_Method__c = paymentMethod;
    update webCart;
  }

  /**
   * @description updates the payment method selected by the user
   * @param cartId - WebCart.Id
   */
  @AuraEnabled(cacheable=true)
  public static String getCartExternaId(String cartId) {
    //get the cart
    WebCart webCart = [SELECT Id, Name, External_Id__c FROM WebCart WHERE Id = :cartId LIMIT 1];
    return webCart.External_Id__c;
  }

  // /**
  //  * @description fetches cart items data and related registration questiosn for the product
  //  * @param communityId - @salesforce/community/Id
  //  * @param activeCartOrId - current cart ID
  //  * @return ConnectApi.CommerceCart.getCartItems() - https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_connectapi_output_cart_item_collection.htm
  //  */
  // @AuraEnabled(cacheable=true)
  // public static ConnectApi.CartItemCollection getCartItems(String communityId, String activeCartOrId){

  //     // Lookup the webstore ID associated with the community
  //     String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);

  //     // For more details, see:
  //     // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
  //     ConnectApi.CartItemCollection cartItemCollection = ConnectApi.CommerceCart.getCartItems(webstoreId, null, activeCartOrId);

  //     return cartItemCollection;
  // }

  // @AuraEnabled(cacheable=true)
  // public static ConnectApi.CartCouponCollection getCartCoupons(String communityId, String activeCartOrId){

  //     // Lookup the webstore ID associated with the community
  //     String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);

  //     // For more details, see:
  //     // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
  //     ConnectApi.CartItemCollection cartItemCollection = ConnectApi.CommerceCart.getCartItems(webstoreId, null, activeCartOrId);

  //     return ConnectApi.CommerceCart.getCartCoupons(webstoreId, null, activeCartOrId);
  // }

  // @AuraEnabled(cacheable=true)
  // public static ConnectApi.CartCouponCollection applyCartCoupon(String communityId, String activeCartOrId, String couponCode){

  //     ConnectApi.cartCouponInput cartCouponInput = new ConnectApi.cartCouponInput();
  //     cartCouponInput.couponCode = couponCode;

  //     // Lookup the webstore ID associated with the community
  //     String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);

  //     // For more details, see:
  //     // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
  //     // ConnectApi.CartItemCollection cartItemCollection = ConnectApi.CommerceCart.getCartItems(webstoreId, null, activeCartOrId);

  //     return ConnectApi.CommerceCart.applyCartCoupon(webstoreId, null, activeCartOrId, cartCouponInput);
  // }
}