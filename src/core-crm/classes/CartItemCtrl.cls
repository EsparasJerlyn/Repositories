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
  @AuraEnabled(cacheable=true)
  public static CartItemsData getCartItemsByCart(String cartId, String userId) {
    //instantiate variables
    List<CartItem> cartItemList = new List<CartItem>();
    List<Related_Answer__c> relatedAnswerList = new List<Related_Answer__c>();
    List<Answer__c> answerList = new List<Answer__c>();

    Set<Id> pbentryIds = new Set<Id>();
    Set<Id> productIds = new Set<Id>();
    Set<Id> relatedAnswerIds = new Set<Id>();

    CartItemsData myCartItemsData = new CartItemsData();
    List<CartItemsWrapper> myCartItemsList = new List<CartItemsWrapper>();
    List<QuestionsWrapper> myQuestionsList = new List<QuestionsWrapper>();

    //get the contact ID of the user
    String contactId = [SELECT ContactId FROM User WHERE Id = :userId LIMIT 1]
    .ContactId;

    //retrieve cart items
    cartItemList = [
      SELECT
        Id,
        Name,
        Product2Id,
        Pricebook_Entry_ID__c,
        Course_Offering__c,
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

      if (currentCart.External_Id__c!=null){
        cartItemsWrapper.externalId = currentCart.External_Id__c;
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

    
    //retrieve related answers for the current products in cart
    // relatedAnswerList = [SELECT Id, Name, Question__r.Label__c, Question__r.Type__c, Questionnaire__r.Questionnaire_Type__c, Questionnaire__r.Object_Type__c, Sequence__c FROM Related_Answer__c WHERE Questionnaire__r.Questionnaire_Type__c = 'Registration Questions' AND Questionnaire__r.Parent_Record_ID__c IN :productIds ORDER BY Related_Answer__c.Sequence__c];
    relatedAnswerList = [
      SELECT Id
      FROM Related_Answer__c
      WHERE
        Questionnaire__r.Questionnaire_Type__c = 'Registration Questions'
        AND Questionnaire__r.Parent_Record_ID__c IN :productIds
      ORDER BY Related_Answer__c.Sequence__c
    ];

    //loop on related answers to get the IDS
    for (Related_Answer__c currentRelatedAnswer : relatedAnswerList) {
      relatedAnswerIds.add(currentRelatedAnswer.Id);
    }

    //retrieve answers
    answerList = [
      SELECT
        Id,
        Name,
        Related_Answer__r.Question__r.Label__c,
        Related_Answer__r.Question__r.Type__c,
        Related_Answer__r.Question__r.Dropdown_Options__c,
        Questionnaire_Response_Summary__r.Contact__c,
        Response__c
      FROM Answer__c
      WHERE
        Related_Answer__r.Id IN :relatedAnswerIds
        AND Questionnaire_Response_Summary__r.Contact__c = :contactId
    ];

    //loop for popoulating the returned object
    for (Answer__c currentAnswer : answerList) {
      QuestionsWrapper questionsWrapper = new QuestionsWrapper();

      //populate data
      questionsWrapper.answerId = currentAnswer.Id;
      questionsWrapper.label = currentAnswer.Related_Answer__r.Question__r.Label__c;
      questionsWrapper.inputType = currentAnswer.Related_Answer__r.Question__r.Type__c;
      questionsWrapper.stringResponse = currentAnswer.Response__c;
      questionsWrapper.newStringResponse = currentAnswer.Response__c;

      //check the input type of the question and set property accordingly
      //for text, number and date, set isText to true to use normal input field
      if (
        questionsWrapper.inputType == 'Text' ||
        questionsWrapper.inputType == 'Number' ||
        questionsWrapper.inputType == 'Date'
      ) {
        questionsWrapper.isText = true;
      } else if (questionsWrapper.inputType == 'Checkbox') {
        questionsWrapper.isCheckbox = true;
        questionsWrapper.booleanResponse = Boolean.valueOf(
          currentAnswer.Response__c
        );

        //for picklist and multi select picklist
      } else if (
        questionsWrapper.inputType == 'Picklist' ||
        questionsWrapper.inputType == 'Multi-Select Picklist'
      ) {
        //set specific variable
        if (questionsWrapper.inputType == 'Picklist') {
          questionsWrapper.isPicklist = true;
        } else if (questionsWrapper.inputType == 'Multi-Select Picklist') {
          questionsWrapper.isMultiPicklist = true;

          //store the response of the multi pick list into a list
          List<String> multiPicklistResponse = currentAnswer.Response__c != null
            ? currentAnswer.Response__c.split(';')
            : null;

          //set the value
          questionsWrapper.multiPicklistResponse = multiPicklistResponse;
        }

        //instantiate the list for picklist
        List<PicklistOptions> picklistList = new List<PicklistOptions>();

        //store pick list options in list
        List<String> picklistOptions = currentAnswer.Related_Answer__r.Question__r.Dropdown_Options__c !=
          null
          ? currentAnswer.Related_Answer__r.Question__r.Dropdown_Options__c.split(
              ';'
            )
          : null;

        //loop on all the options
        for (String currentOption : picklistOptions) {
          PicklistOptions picklist = new PicklistOptions();

          //set label and key
          picklist.label = currentOption;
          picklist.value = currentOption;

          //add current option to the list
          picklistList.add(picklist);
        }

        //set the list
        questionsWrapper.picklistOptions = picklistList;
      } else if (questionsWrapper.inputType == 'File Upload') {
        questionsWrapper.isFileUpload = true;
      }

      myQuestionsList.add(questionsWrapper);
    }

    myCartItemsData.cartItemsList = myCartItemsList;
    myCartItemsData.questionsList = myQuestionsList;

    return myCartItemsData;
  }

  public class CartItemsData {
    @AuraEnabled
    public List<CartItemsWrapper> cartItemsList;
    @AuraEnabled
    public List<QuestionsWrapper> questionsList;
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
  }

  public class QuestionsWrapper {
    @AuraEnabled
    public String answerId;
    @AuraEnabled
    public String label;
    @AuraEnabled
    public String inputType;
    @AuraEnabled
    public String stringResponse;
    @AuraEnabled
    public String newStringResponse;
    @AuraEnabled
    public Boolean booleanResponse;
    @AuraEnabled
    public Boolean isText;
    @AuraEnabled
    public Boolean isCheckbox;
    @AuraEnabled
    public Boolean isPicklist;
    @AuraEnabled
    public Boolean isMultiPicklist;
    @AuraEnabled
    public Boolean isFileUpload;
    @AuraEnabled
    public List<PicklistOptions> picklistOptions;
    @AuraEnabled
    public List<String> multiPicklistResponse;
  }

  public class PicklistOptions {
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
   * @param productId - id of the product where coupon will be applied
   * @param couponCode - the code entered by the user
   * @param unitPrice - unit price of the cart item
   * @return myCartItemsData - CartItemsData data type
   */
  @AuraEnabled(cacheable=true)
  public static Double getCartItemDiscount(
    String productId,
    String couponCode,
    Double unitPrice
  ) {
    //create a list for Promotion, PromotionTarget, and Coupon
    List<Promotion> promotionList = new List<Promotion>();
    List<PromotionTarget> promotionTargetList = new List<PromotionTarget>();
    List<Coupon> couponList = new List<Coupon>();
    Double totalDiscount = 0;

    //retrieve proomotion targets for the spcific product
    // promotionTargerList = [SELECT Id, Name, PromotionId, TargetType, TargetId, AdjustmentType,  ]

    //retrieve Promotions for specific Coupon Code and Product
    promotionList = [
      SELECT
        Id,
        Name,
        IsActive,
        (SELECT Id, Name, CouponCode FROM PromotionCoupons),
        (
          SELECT Id, Name, AdjustmentType, AdjustmentPercent, AdjustmentAmount
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
          WHERE TargetType = 'Product' AND TargetId = :productId
        )
    ];

    //loop on all the options
    for (Promotion currentPromotion : promotionList) {
      //loop in the PromotionTarget for in case of multiple promotions
      for (
        PromotionTarget currentPromotionTarget : currentPromotion.PromotionTargets
      ) {
        if (currentPromotionTarget.AdjustmentType == 'PercentageDiscount') {
          //set the discount amount
          totalDiscount =
            totalDiscount +
            ((unitPrice * currentPromotionTarget.AdjustmentPercent) / 100);
        } else if (
          currentPromotionTarget.AdjustmentType == 'FixedAmountOffUnitPrice'
        ) {
          //set the discount amount
          totalDiscount =
            totalDiscount + currentPromotionTarget.AdjustmentAmount;
        }
      }
    }

    //if the totalDiscount exceeds the unit price, set it to 0
    if (totalDiscount > unitPrice) {
      totalDiscount = unitPrice;
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
    WebCart webCart = [SELECT Id, Name, Status__c FROM WebCart WHERE Id = :cartId];

    //update the cart based on the status received
    webCart.Status__c = cartStatus;
    update webCart;
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
      WHERE Name = 'Products'
      LIMIT 1
    ];

    return prodCateg;
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
