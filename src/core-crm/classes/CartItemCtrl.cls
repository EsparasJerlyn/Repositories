/**
 * @description Controller Class for cartDetails LWC
 * @see ../lwc/productDetails
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                             |
      |---------------------------|-----------------------|----------------------|--------------------------------------------|
      | john.m.tambasen           | May 11, 2022          | DEPP-2060            | Created file                               |
      | john.m.tambasen           | May 17, 2022          | DEPP-1151            | added the updation of cart status          |
      | roy.nino.s.regala         | June 27, 2022         | DEPP-3252            | remove creation of course connection       |
      | roy.nino.s.regala         | June 29, 2022         | DEPP-3157            | fixed questionnare issues                  |
      | john.m.tambasen           | August 01, 2022       | DEPP-3616            | reworked logic for discount                |
      | john.m.tambasen           | August 04, 2022       | DEPP-3674            | added strikethrough for discounted items   |
      | john.m.tambasenb          | August 11, 2022       | DEPP-3738            | negative amount showing                    |
      | julie.jane.alegre         | September 07, 2022    | DEPP-3613            | Add validation on early bird               |
      | julie.jane.alegre         | September 17, 2022    | DEPP-4338            | Add validation for active offering         |
      | julie.jane.alegre         | September 20, 2022    | DEPP-4371            | Add validation for inactive EarlyBird      |

*/
public without sharing class CartItemCtrl {


  public static final Id STUDENT_RECTYPEID = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName()
        .get('Student')
        .getRecordTypeId();
    public static final Id PROG_STUDENT_RECTYPEID = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName()
        .get('Student_Program')
        .getRecordTypeId();
  
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
    List<Related_Answer__c> relatedAnswersList = new List<Related_Answer__c>();
    Map<Id, PricebookEntry> pbEntryMapStandard = new Map<Id, PricebookEntry>();
    Date earlyBirdDatePlusToday;


    Set<Id> pbentryIds = new Set<Id>();
    Set<Id> productIds = new Set<Id>();
    Set<Id> productReqIds = new Set<Id>();

    CartItemsData myCartItemsData = new CartItemsData();
    List<CartItemsWrapper> myCartItemsList = new List<CartItemsWrapper>();

    //get the contact ID of the user
    String contactId = [SELECT ContactId FROM User WHERE Id = :userId LIMIT 1]
    .ContactId;

    //retrieve cart items
    cartItemList = [
      SELECT
        Id,
        CartId,
        Cart.External_Id__c,
        Name,
        Product2Id,
        Pricebook_Entry_ID__c,
        Course_Offering__c,
        Course_Offering__r.hed__Course__r.ProductRequestID__c,
        Course_Offering__r.hed__Start_Date__c,
        Course_Offering__r.Delivery_Type__c,
        Course_Offering__r.Available_Seats__c,
        Course_Offering__r.IsActive__c,
        Course_Offering__r.Registration_End_Date__c,
        Program_Offering__c,
        Program_Offering__r.hed_Program_Plan__r.Product_Request__c,
        Program_Offering__r.Start_Date__c,
        Program_Offering__r.Delivery_Type__c,
        Program_Offering__r.Available_Seats__c,
        Program_Offering__r.IsActive__c,
        Program_Offering__r.Registration_End_Date__c,
        External_Id__c,
        Contact__r.Name
      FROM CartItem
      WHERE CartId = :cartId
    ];
   

    //loop on the returned list to populate price book entry and product IDs
    for (CartItem currentCart : cartItemList) {
 
      pbentryIds.add(currentCart.Pricebook_Entry_ID__c);
      productIds.add(currentCart.Product2Id);
      if(currentCart.Course_Offering__c != null){
        productReqIds.add(currentCart.Course_Offering__r.hed__Course__r.ProductRequestID__c);
      }else{
        productReqIds.add(currentCart.Program_Offering__r.hed_Program_Plan__r.Product_Request__c);
      }
      
    }

    //create list of standard pricebook for each cart item product
    List<PricebookEntry> pbEntryStandardList = new List<PricebookEntry>(
      [
        SELECT Id, Pricebook2.Name, Pricebook2.IsStandard, UnitPrice, Product2Id, Early_Bird_No_of_Days__c, IsActive
        FROM PricebookEntry
        WHERE Product2Id IN :productIds AND Pricebook2.IsStandard = true
      ]
    );

    //create map of standard pricebook with product id as the key
    for(PricebookEntry currentPbe: pbEntryStandardList){

      //create a map if it doesnt exist yet
      if(!pbEntryMapStandard.containsKey(currentPbe.Product2Id)){
        pbEntryMapStandard.put(currentPbe.Product2Id, currentPbe);
      }
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

    for (Id val :productReqIds){
        for(Related_Answer__c RA :relatedAnswerList){

          if (RA.Questionnaire__r.Parent_Record_ID__c == val){
            if (QuestionnaireMap.containsKey(val)){
              QuestionnaireMap.get(val).add(RA);
            }
            else
            {
               QuestionnaireMap.put(val, new List<Related_Answer__c>{RA});   
            }
          }
        }
    }

    //create map of price book entry for linking with the cart items
    Map<Id, PricebookEntry> pbEntryMap = new Map<Id, PricebookEntry>(
      [
        SELECT Id, Pricebook2.Name, UnitPrice,Early_Bird_No_of_Days__c,IsActive
        FROM PricebookEntry
        WHERE Id IN :pbentryIds
      ]
    );

    //create map of products payment options in cart
    Map<Id, Product2> prodPayOpt = new Map<Id, Product2>(
      [
        SELECT Id, Payment_Options__c,Available_on_Cart__c
        FROM Product2
        WHERE Id IN :productIds
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
      cartItemsWrapper.courseOfferingId =currentCart.Course_Offering__c;
      cartItemsWrapper.programOfferingId = currentCart.Program_Offering__c;
      cartItemsWrapper.contactFullName = currentCart.Contact__r.Name;

      cartItemsWrapper.paymentOptions = prodPayOpt.get(
        currentCart.Product2Id
      )
      .Payment_Options__c;

      cartItemsWrapper.availableToCart = prodPayOpt.get(
        currentCart.Product2Id
      ).Available_on_Cart__c;

      if(Integer.valueOf(pbEntryMap.get(
        currentCart.Pricebook_Entry_ID__c
      ).Early_Bird_No_of_Days__c) != null){

        cartItemsWrapper.earlyBirdNoOfDays = Integer.valueOf(pbEntryMap.get(
          currentCart.Pricebook_Entry_ID__c
        ).Early_Bird_No_of_Days__c);
      }else{
        cartItemsWrapper.earlyBirdNoOfDays = 0;
      }

      if( QuestionnaireMap.containsKey(currentCart.Course_Offering__r.hed__Course__r.ProductRequestID__c) || 
          QuestionnaireMap.containsKey(currentCart.Program_Offering__r.hed_Program_Plan__r.Product_Request__c)) {
        
            if(QuestionnaireMap.containsKey(currentCart.Program_Offering__r.hed_Program_Plan__r.Product_Request__c)){
              relatedAnswersList = QuestionnaireMap.get(currentCart.Program_Offering__r.hed_Program_Plan__r.Product_Request__c);
            }else{
              relatedAnswersList = QuestionnaireMap.get(currentCart.Course_Offering__r.hed__Course__r.ProductRequestID__c);
            }
        
          List<RelatedAnswersWrapper> relatedAnswerListWrap = new List<RelatedAnswersWrapper>();  //container for related answer
         
          for (Related_Answer__c ra2 : relatedAnswersList ) {
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
               relatedAnswerListSingle.Answer  = ra2.Question__r.Type__c == 'Checkbox' ? 'false':'';
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
               relatedAnswerListSingle.FileData  = new FileData(); 
               relatedAnswerListSingle.FileUploadSuccess  = false;     
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
        if (currentCart.Course_Offering__r.Available_Seats__c > 0 &&
            currentCart.Course_Offering__r.Registration_End_Date__c > Date.Today() &&
            currentCart.Course_Offering__r.IsActive__c == true
            ) {

            cartItemsWrapper.seatsAvailable = true;
        }
        if(cartItemsWrapper.earlyBirdNoOfDays != null){
          earlyBirdDatePlusToday = Date.Today() + cartItemsWrapper.earlyBirdNoOfDays;
        }

        if((pbEntryMap.get(currentCart.Pricebook_Entry_ID__c).Pricebook2.Name == 'Early Bird' && 
            cartItemsWrapper.earlyBirdNoOfDays > 0 &&
            currentCart.Course_Offering__r.hed__Start_Date__c <= earlyBirdDatePlusToday) ||
            pbEntryMap.get(currentCart.Pricebook_Entry_ID__c).IsActive == false
            ){
            cartItemsWrapper.isEarlyBirdPassed = true;
        }else{
          cartItemsWrapper.isEarlyBirdPassed = false;
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
        if (currentCart.Program_Offering__r.Available_Seats__c > 0 &&
            currentCart.Program_Offering__r.Registration_End_Date__c > Date.Today() &&
            currentCart.Program_Offering__r.IsActive__c == true
        ) {
          cartItemsWrapper.seatsAvailable = true;
        }
        if(cartItemsWrapper.earlyBirdNoOfDays != null){
          earlyBirdDatePlusToday = Date.Today() + cartItemsWrapper.earlyBirdNoOfDays;
        }

        if((pbEntryMap.get(currentCart.Pricebook_Entry_ID__c).Pricebook2.Name == 'Early Bird' &&
            cartItemsWrapper.earlyBirdNoOfDays > 0 &&
            currentCart.Program_Offering__r.Start_Date__c >= earlyBirdDatePlusToday) ||
            pbEntryMap.get(currentCart.Pricebook_Entry_ID__c).IsActive == false){
            cartItemsWrapper.isEarlyBirdPassed = true;
        }else{
          cartItemsWrapper.isEarlyBirdPassed = false;
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
      cartItemsWrapper.pbNameStandard = pbEntryMapStandard.get(
          currentCart.Product2Id
        )
        .Pricebook2.Name;
      cartItemsWrapper.unitPriceStandard = pbEntryMapStandard.get(
          currentCart.Product2Id
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
    public String courseOfferingId;
    @AuraEnabled
    public String programOfferingId;
    @AuraEnabled
    public String startDate;
    @AuraEnabled
    public String deliveryType;
    @AuraEnabled
    public String pbName;
    @AuraEnabled
    public Double unitPrice;
    @AuraEnabled
    public String pbNameStandard;
    @AuraEnabled
    public Double unitPriceStandard;
    @AuraEnabled
    public Boolean showStrikedStandardPb = false;
    @AuraEnabled
    public Double unitDiscountedPrice = 0;
    @AuraEnabled
    public Double unitDiscount = 0;
    @AuraEnabled
    public Boolean seatsAvailable = false;
    @AuraEnabled
    public Boolean isEarlyBirdPassed = false;
    @AuraEnabled
    public Boolean showInvalidDiscount = false;
    @AuraEnabled
    public String externalId;
    @AuraEnabled
    public List<RelatedAnswersWrapper> relatedAnswers;
    @AuraEnabled
    public String contactFullName;
    @AuraEnabled
    public String paymentOptions; 
    @AuraEnabled
    public Integer earlyBirdNoOfDays;
    @AuraEnabled
    public Date registeredEndDate;
    @AuraEnabled
    public Boolean availableToCart;   

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
    public FileData FileData;
    @AuraEnabled
    public Boolean FileUploadSuccess;
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
    @AuraEnabled
    public String recordId; 
  }
  /**
    * @description Wrapper class that holds the file uploaded by user
    */
    public class FileUpload{
      @AuraEnabled
      public String Base64;
      @AuraEnabled
      public String FileName;
      @AuraEnabled
      public String RelatedAnswerId;
  }

  /**
   * @description fetches cart items data and related registration questiosn for the product
   * @param cartId - id of the cart where coupon will be applied
   * @param couponCode - the code entered by the user
   * @param totalPrice - total price of the cart item
   * @return myCartItemsData - CartItemsData data type
   */
  @AuraEnabled(cacheable=true)
  public static List<DiscountData> getCartItemDiscount(
    String cartId,
    String couponCode
  ) {
    //create a list for Promotion, PromotionTarget, and Coupon
    List<CartItem> cartItemList = new List<CartItem>();
    Map<Id, PricebookEntry> cartItemPbeMap = new Map<Id, PricebookEntry>();
    Map<Id, PricebookEntry> cartItemPbeActualMap = new Map<Id, PricebookEntry>();
    List<Promotion> promotionList = new List<Promotion>();
    List<Coupon> couponList = new List<Coupon>();
    List<DiscountData> discountData = new List<DiscountData>();

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

    //create list of standard pricebook for each cart item product
    List<PricebookEntry> pbEntryStandardList = new List<PricebookEntry>(
      [
        SELECT Id, Pricebook2.Name, Pricebook2.IsStandard, UnitPrice, Product2Id
        FROM PricebookEntry
        WHERE Product2Id IN :productIds AND Pricebook2.IsStandard = true
      ]
    );

    //create list of the actual prices added by the user in the cart
    List<PricebookEntry> pbEntryActualList = new List<PricebookEntry>(
      [
        SELECT Id, Pricebook2.Name, UnitPrice, Product2Id
        FROM PricebookEntry
        WHERE Id IN :pbentryIds
      ]
    );

    //nested loop on the cartitem to create a map with its standard pricebook
    for (CartItem currentCartItem : cartItemList) {
      for(PricebookEntry currentPbe: pbEntryStandardList){

        //if product id of cart matches the pbe]
        if(currentCartItem.Product2Id == currentPbe.Product2Id){

          //create a map if it doesnt exist yet
          if(!cartItemPbeMap.containsKey(currentCartItem.Id)){
            cartItemPbeMap.put(currentCartItem.Id, currentPbe);
          }
        }
      }
    }

    //nested loop on the cartitem to create a map with its actual pricebook added by the user
    for (CartItem currentCartItem : cartItemList) {
      for(PricebookEntry currentPbe: pbEntryActualList){

        //if product id of cart matches the pbe]
        if(currentCartItem.Pricebook_Entry_ID__c == currentPbe.Id){

          //create a map if it doesnt exist yet
          if(!cartItemPbeActualMap.containsKey(currentCartItem.Id)){
            cartItemPbeActualMap.put(currentCartItem.Id, currentPbe);
          }
        }
      }
    }

    //retrieve Promotions for specific Coupon Code and Product
    promotionList = [
      SELECT
        Id,
        Name,
        IsActive,
        (SELECT Id, Name, CouponCode FROM PromotionCoupons),
        (SELECT Id, Name, AdjustmentType, AdjustmentPercent, AdjustmentAmount, TargetType, TargetId FROM PromotionTargets),
        (SELECT Id, Name, Promotion__c, IsActive__c, Product__c FROM Promotion_Products__r WHERE IsActive__c = true)
      FROM
        Promotion
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
          WHERE (TargetType = 'Product' AND TargetId IN :productIds)
          OR (TargetType = 'ProductCategory')
          OR TargetType = 'Transaction'
        )
    ];

    //loop on all the options
    for (Promotion currentPromotion : promotionList) {

      //loop in the PromotionTarget for in case of multiple promotions
      for (PromotionTarget currentPromotionTarget : currentPromotion.PromotionTargets) {

        //check if targetype is per product or total transaction
        if(currentPromotionTarget.TargetType == 'Transaction'){

          if (currentPromotionTarget.AdjustmentType == 'PercentageDiscount') {

            //loop on each cart item to get the discount per line
            for (CartItem currentCart : cartItemList) {
              DiscountData discountDataTemp = new DiscountData();
              Double calculatedDiscount = ((cartItemPbeMap.get(currentCart.Id).UnitPrice * currentPromotionTarget.AdjustmentPercent) / 100).setScale(2);

              discountDataTemp.cartItemId = currentCart.Id;
              discountDataTemp.discount = calculatedDiscount;
              discountDataTemp.standardPbe = cartItemPbeMap.get(currentCart.Id).Id;
              discountDataTemp.standardPbePrice = cartItemPbeMap.get(currentCart.Id).UnitPrice;
              discountDataTemp.promotionId = currentPromotion.Id;
              discountData.add(discountDataTemp);
            }
          }
    
        //else if for product specific
        } else if(currentPromotionTarget.TargetType == 'Product'){

          if (currentPromotionTarget.AdjustmentType == 'FixedAmountOffLineItemTotal') {

            //spread the FixedAmountOffLineItemTotal discount amount per line item
            Double discountPerLine = (currentPromotionTarget.AdjustmentAmount / cartItemList.size()).setScale(2);

            //loop on each cart item to get the discount per line
            for (CartItem currentCart : cartItemList) {
              DiscountData discountDataTemp = new DiscountData();

              discountDataTemp.cartItemId = currentCart.Id;
              discountDataTemp.discount = discountPerLine;
              discountDataTemp.promotionId = currentPromotion.Id;
              discountData.add(discountDataTemp);
            }
  
          } else {
            //loop on the current cart to search for the specific product
            for (CartItem currentCart : cartItemList) { 
              
              //checck if the cart product is for the promotion target id
              if(currentCart.Product2Id == currentPromotionTarget.TargetId){
                DiscountData discountDataTemp = new DiscountData();
                
                //popluate wrapper with the cart id if the produc matched the targetId
                discountDataTemp.cartItemId = currentCart.Id;

                Double standardPrice = cartItemPbeMap.get(currentCart.Id).UnitPrice;
                Double actualPrice = cartItemPbeActualMap.get(currentCart.Id).UnitPrice;
                Double discountedPrice = 0;
                Double unitDiscount = 0;

                if (currentPromotionTarget.AdjustmentType == 'PercentageDiscount') {
                  //set the discount amount
                  unitDiscount = (((standardPrice * currentPromotionTarget.AdjustmentPercent) / 100)).setScale(2);

                  //set the discounted price
                  discountedPrice = standardPrice - unitDiscount;

                  //if the actual price is still less than the discounted price
                  if(actualPrice <= discountedPrice){

                    //set discount to 0 since discount should not be applied
                    unitDiscount = 0;
                  } else {

                    discountDataTemp.standardPbe = cartItemPbeMap.get(currentCart.Id).Id;
                    discountDataTemp.standardPbePrice = cartItemPbeMap.get(currentCart.Id).UnitPrice;
                  }
        
                } else if (currentPromotionTarget.AdjustmentType == 'FixedAmountOffUnitPrice') {

                  //if the specified amount is greater than the standardPrice
                  if (currentPromotionTarget.AdjustmentAmount > standardPrice) {

                    //max discount should only be the unit price
                    unitDiscount = standardPrice;

                  } else{

                    //set the discount amount
                    unitDiscount =  currentPromotionTarget.AdjustmentAmount;
                  }   

                  //set the discounted price
                  discountedPrice = standardPrice - unitDiscount;

                  //if the actual price is still less than the discounted price
                  if(actualPrice <= discountedPrice){

                    //set discount to 0 since discount should not be applied
                    unitDiscount = 0;
                  }else {

                    discountDataTemp.standardPbe = cartItemPbeMap.get(currentCart.Id).Id;
                    discountDataTemp.standardPbePrice = cartItemPbeMap.get(currentCart.Id).UnitPrice;
                  }
                }

                //populate and add discount
                discountDataTemp.discount = unitDiscount;
                discountDataTemp.promotionId = currentPromotion.Id;
                discountData.add(discountDataTemp);
              }
            }
          }

        //else if for product category
        } else if(currentPromotionTarget.TargetType == 'ProductCategory'){

          //create a set of product Ids that are present in the Promotion_Products__r
          Set<String> productPromotionIds = new Set<String>();
          for (Promotion_Product__c currentPromotionProduct : currentPromotion.Promotion_Products__r) {
            productPromotionIds.add(currentPromotionProduct.Product__c);
          }

          if (currentPromotionTarget.AdjustmentType == 'FixedAmountOffLineItemTotal') {

            Boolean productFound = false;

            //loop on the cartitems to check if one of the cartitem is included in the Promotion Product
            for (CartItem currentCart : cartItemList) {
              if(productPromotionIds.contains(currentCart.Product2Id)){
                productFound = true;
                break;
              }
            }

            //if the product is found
            if(productFound){
              //spread the FixedAmountOffLineItemTotal discount amount per line item
              Double unitDiscount = (currentPromotionTarget.AdjustmentAmount / cartItemList.size()).setScale(2);

              //loop on each cart item to get the discount per line
              for (CartItem currentCart : cartItemList) {
                DiscountData discountDataTemp = new DiscountData();

                discountDataTemp.cartItemId = currentCart.Id;
                discountDataTemp.discount = unitDiscount;
                discountDataTemp.promotionId = currentPromotion.Id;
                discountData.add(discountDataTemp);
              }
            }

          } else {
            //loop on the current cart to search for the product
            for (CartItem currentCart : cartItemList) {

              //if the current cart item exitst in the Product Promotion list
              if(productPromotionIds.contains(currentCart.Product2Id)){

                DiscountData discountDataTemp = new DiscountData();

                //popluate wrapper with the cart id if the produc matched the targetId
                discountDataTemp.cartItemId = currentCart.Id;

                Double standardPrice = cartItemPbeMap.get(currentCart.Id).UnitPrice;
                Double actualPrice = cartItemPbeActualMap.get(currentCart.Id).UnitPrice;
                Double discountedPrice = 0;
                Double unitDiscount = 0;

                if (currentPromotionTarget.AdjustmentType == 'PercentageDiscount') {
                  //set the discount amount
                  unitDiscount = (((standardPrice * currentPromotionTarget.AdjustmentPercent) / 100)).setScale(2);

                  //set the discounted price
                  discountedPrice = standardPrice - unitDiscount;

                  //if the actual price is still less than the discounted price
                  if(actualPrice <= discountedPrice){

                    //set discount to 0 since discount should not be applied
                    unitDiscount = 0;
                  } else {

                    discountDataTemp.standardPbe = cartItemPbeMap.get(currentCart.Id).Id;
                    discountDataTemp.standardPbePrice = cartItemPbeMap.get(currentCart.Id).UnitPrice;
                  }

                } else if (currentPromotionTarget.AdjustmentType == 'FixedAmountOffUnitPrice') {

                  //if the specified amount is greater than the standardPrice
                  if (currentPromotionTarget.AdjustmentAmount > standardPrice) {

                    //max discount should only be the unit price
                    unitDiscount = standardPrice;

                  } else{

                    //set the discount amount
                    unitDiscount =  currentPromotionTarget.AdjustmentAmount;
                  }

                  //set the discounted price
                  discountedPrice = standardPrice - unitDiscount;

                  //if the actual price is still less than the discounted price
                  if(actualPrice <= discountedPrice){

                    //set discount to 0 since discount should not be applied
                    unitDiscount = 0;
                  } else {

                    discountDataTemp.standardPbe = cartItemPbeMap.get(currentCart.Id).Id;
                    discountDataTemp.standardPbePrice = cartItemPbeMap.get(currentCart.Id).UnitPrice;
                  }
                }

                //populate and add discount
                discountDataTemp.discount = unitDiscount;
                discountDataTemp.promotionId = currentPromotion.Id;
                discountData.add(discountDataTemp);
              }
            }  
          }   
        }
      }
    }

    return discountData;
  }

  public class DiscountData {
    @AuraEnabled public String cartItemId;
    @AuraEnabled public Double discount;
    @AuraEnabled public String standardPbe;
    @AuraEnabled public Double standardPbePrice;
    @AuraEnabled public String promotionId;
  }

  public class QuestionnaireResponseData{
    @AuraEnabled public String offeringId;
    @AuraEnabled public Boolean isPrescribed;
    @AuraEnabled public List<RelatedAnswersWrapper> relatedAnswerList;
    @AuraEnabled public List<Answer__c> answerList;
    @AuraEnabled public List<FileUpload> fileUploadData;
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
   * @description save questions from user
   * @param contactId - portal user answered the questions
   * @param cartItems - 
   */
  @AuraEnabled
  public static void saveCartSummaryQuestions(String questionnaireData, Id contactId) {
    List<QuestionnaireResponseData> qrsData = new List<QuestionnaireResponseData>();

    if (questionnaireData != '') {
      qrsData = (List<QuestionnaireResponseData>) JSON.deserialize(
        questionnaireData,
        List<QuestionnaireResponseData>.class
      );
    }
    List<Questionnaire_Response_Summary__c> qrsListToInsert = new List<Questionnaire_Response_Summary__c>();

    Map<String,String> questionnaireToQRSMap = new Map<String,String>();
    Map<String,String> relatedAnswerToQuestionnaireMap = new Map<String, String>();
    List<Answer__c> allAnswers = new List<Answer__c>();
    List<FileUpload> allFileData = new List<FileUpload>();
    List<Answer__c> answersToInsert = new List<Answer__c>();
    Map<String,String> relatedAnswerToAnswerMap = new Map<String, String>();
    Map<String, String> cvToRelatedAnswerMap = new Map<String, String>();
    List<ContentDocumentLink> contentDocLinkListToInsert = new List<ContentDocumentLink>();
    List<ContentVersion> cvListToInsertList = new List<ContentVersion>();
    Map<Id, Answer__c> answersToUpdate = new Map<Id, Answer__c>();

    Questionnaire_Response_Summary__c qResSummary;

    for(QuestionnaireResponseData qrs: qrsData){

      qResSummary = new Questionnaire_Response_Summary__c();
      qResSummary.Questionnaire__c = qrs.relatedAnswerList[0].QuestionnaireId;
      if (qrs.isPrescribed) {
        qResSummary.Program_Offering__c = qrs.offeringId;
      } else {
        qResSummary.Course_Offering__c = qrs.offeringId;
      }
      qResSummary.Registration_Status__c = 'Confirmed';
      qResSummary.Contact__c = contactId;
      qrsListToInsert.add(qResSummary);

      for(RelatedAnswersWrapper wrapper: qrs.relatedAnswerList){
        relatedAnswerToQuestionnaireMap.put(
          wrapper.Id,
          wrapper.QuestionnaireId
        );
      }
      if(!qrs.answerList.isEmpty()){
        allAnswers.addAll(qrs.answerList);
      }
      if(!qrs.fileUploadData.isEmpty()){
        allFileData.addAll(qrs.fileUploadData);
      }
    }

    if(!qrsListToInsert.isEmpty()){
      insert qrsListToInsert;
    }
    
    for(Questionnaire_Response_Summary__c qrs:qrsListToInsert){
      questionnaireToQRSMap.put(qrs.Questionnaire__c,qrs.Id);
    }


    if (!allAnswers.isEmpty()) {
      for (Answer__c a : allAnswers) {
        a.Questionnaire_Response_Summary__c = questionnaireToQRSMap.get(
          relatedAnswerToQuestionnaireMap.get(a.Related_Answer__c)
        );
        answersToInsert.add(a);
      }
      insert answersToInsert;
    }

    for (Answer__c ans : answersToInsert) {
      relatedAnswerToAnswerMap.put(ans.Related_Answer__c, ans.Id);
    }

    for (FileUpload file : allFileData) {
      if (relatedAnswerToAnswerMap.containsKey(file.RelatedAnswerId)) {
        ContentVersion cv = createContentVersion(file.Base64, file.FileName);
        cvToRelatedAnswerMap.put(cv.Title, file.RelatedAnswerId);
        cvListToInsertList.add(cv);
      }
    }

    if (!cvListToInsertList.isEmpty()) {
      insert cvListToInsertList;
    }

    List<ContentVersion> newContentVersionList = new List<ContentVersion>(
      [
        SELECT ContentDocumentId, Title
        FROM ContentVersion
        WHERE Id IN :cvListToInsertList
      ]
    );

    if (!newContentVersionList.isEmpty()) {
      ContentDocumentLink cdl;
      Answer__c updateAnswer;
      for (ContentVersion cv : newContentVersionList) {
        String test = relatedAnswerToAnswerMap.get(
          cvToRelatedAnswerMap.get(cv.Title)
        );
        cdl = new ContentDocumentLink(
          ContentDocumentId = cv.ContentDocumentId,
          LinkedEntityId = relatedAnswerToAnswerMap.get(
            cvToRelatedAnswerMap.get(cv.Title)
          ),
          ShareType = 'V'
        );
        updateAnswer = new Answer__c(
          Id = cdl.LinkedEntityId,
          Response__c = cv.ContentDocumentId
        );
        answersToUpdate.put(updateAnswer.Id, updateAnswer);
        contentDocLinkListToInsert.add(cdl);
      }
    }

    if (!contentDocLinkListToInsert.isEmpty()) {
      insert contentDocLinkListToInsert;
    }

    if (!answersToUpdate.keySet().isEmpty()) {
      update answersToUpdate.values();
    }
   
  }

  private static ContentVersion createContentVersion(String base64, String filename) {
    ContentVersion cv = new ContentVersion();
    cv.VersionData = EncodingUtil.base64Decode(base64);
    cv.Title = filename;
    cv.PathOnClient = filename;
    return cv;
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
   * @description closes the current active cart
   * @param cartId - cart item ID
   */
  @AuraEnabled
  public static void closeCart(String cartId) {
    //get the cart
    WebCart webCart = [SELECT Id, Name, Status FROM WebCart WHERE Id = :cartId LIMIT 1];

    //close cart
    webCart.Status = 'Closed';
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
   * @param paymentMethod - WebCart.Payment_Method__c
   */
  @AuraEnabled
  public static void updatePaymentMethod(String cartId, String paymentMethod, String cartPayment) {
    //get the cart
    WebCart webCart = [SELECT Id, Name, External_Id__c, Payment_Method__c FROM WebCart WHERE Id = :cartId LIMIT 1];

    //update the cart based on the status received
    webCart.Cart_Payment__c = cartPayment;
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