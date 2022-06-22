/**
 * @description Retrieve Questionnaire Response Summary Details
 *
 * @see ../lwc/questionnaireResponseSummary
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | john.bo.a.pineda          | March 14, 2022        | DEPP-1643            | Created file                 |
      |                           |                       |                      |                              |
 */
public without sharing class QuestionnaireResponseSummaryCtrl {
  /**
   * @description Method to check if Email exists
   * @param qrsId - Questionare Response Summary Id
   * @return QuestionnaireResponseSummaryWrapper - returns Questionare Response Summary Details
   */
  @AuraEnabled(cacheable=true)
  public static QuestionnaireResponseSummaryWrapper getQuestionnaireResponseSummaryDetails(
    String qrsId
  ) {
    QuestionnaireResponseSummaryWrapper wrapper = new QuestionnaireResponseSummaryWrapper();

    if (String.isNotBlank(qrsId)) {
      Questionnaire_Response_Summary__c qrs = [
        SELECT
          Id,
          Contact__c,
          Contact__r.Name,
          Application_Status__c,
          Registration_Status__c,
          Questionnaire__r.Questionnaire_Type__c,
          Questionnaire__r.Parent_Record_ID__c
        FROM Questionnaire_Response_Summary__c
        WHERE Id = :qrsId 
        LIMIT 1
      ];

      Id prId = qrs.Questionnaire__r.Parent_Record_ID__c;
      Product2 product = [  SELECT Id, Name 
                            FROM Product2 
                            WHERE Course__r.ProductRequestID__c =: prId 
                            OR Program_Plan__r.Product_Request__c =: prId LIMIT 1];



      wrapper.qrsType = qrs.Questionnaire__r.Questionnaire_Type__c;
      if (String.isNotBlank(qrs.Questionnaire__r.Parent_Record_ID__c)) {
        wrapper.qrsProduct = product.Name;
        wrapper.qrsProductURL = '/' + qrs.Questionnaire__r.Parent_Record_ID__c;
      }
      if (String.isNotBlank(qrs.Contact__c)) {
        wrapper.qrsContact = qrs.Contact__r.Name;
        wrapper.qrsContactURL = '/' + qrs.Contact__c;
      }
      if (
        qrs.Questionnaire__r.Questionnaire_Type__c == 'Application Questions'
      ) {
        wrapper.qrsStatus = qrs.Application_Status__c;
      } else if (
        qrs.Questionnaire__r.Questionnaire_Type__c == 'Registration Questions'
      ) {
        wrapper.qrsStatus = qrs.Registration_Status__c;
      } else {
        wrapper.qrsStatus = qrs.Registration_Status__c;
      }

      List<Answer__c> ansList = [
        SELECT
          Id,
          Related_Answer__r.Question__c,
          Related_Answer__r.Question__r.Label__c,
          Related_Answer__r.Question__r.Type__c,
          Response__c,
          Related_Answer__r.Sequence__c
        FROM Answer__c
        WHERE Questionnaire_Response_Summary__c = :qrsId
        ORDER BY Related_Answer__r.Sequence__c ASC
      ];

      List<QuestionAnswerWrapper> qaWrapperList = new List<QuestionAnswerWrapper>();
      if (ansList.size() > 0) {
        for (Answer__c ans : ansList) {
          QuestionAnswerWrapper qaWrapper = new QuestionAnswerWrapper();
          qaWrapper.qId = ans.Related_Answer__r.Question__c;
          qaWrapper.question = ans.Related_Answer__r.Question__r.Label__c;
          qaWrapper.aId = ans.Id;
          if(ans.Related_Answer__r.Question__r.Type__c == 'File Upload'){
            qaWrapper.answer = '/' + ans.Response__c;
            qaWrapper.isFile = true;
          }else{
            qaWrapper.answer = ans.Response__c;
            qaWrapper.isFile = false;
          }
          qaWrapper.qaSequence = String.valueOf(
            ans.Related_Answer__r.Sequence__c
          );
          qaWrapperList.add(qaWrapper);
        }
      }

      if (qaWrapperList.size() > 0) {
        wrapper.qaList = qaWrapperList;
      }
    }

    return wrapper;
  }

  /**
   * @description Method to update Query Response Summary Application Status
   * @param qrsId - Questionare Response Summary Id
   * @param qrsStatus - Questionare Response Summary Application Status value
   */
  @AuraEnabled(cacheable=false)
  public static void updateApplicationStatus(String qrsId, String qrsStatus) {
    if (String.isNotBlank(qrsId)) {
      Id cartDeliveryGroupId;
      Questionnaire_Response_Summary__c qrs = [
        SELECT Id, Application_Status__c, Contact__c, 
        Pricebook_Entry_ID__c, Program_Offering__c,
        Course_Offering__c, Course_Name__c,
        Questionnaire__r.Parent_Record_ID__c
        FROM Questionnaire_Response_Summary__c
        WHERE Id = :qrsId
        LIMIT 1
      ];

      if (qrs.Application_Status__c == 'Pending') {
        qrs.Application_Status__c = qrsStatus;

        if(qrsStatus == 'Approved'){
          User portalUser = [ SELECT Id, Contact.AccountId
          FROM User 
          WHERE ContactId =: qrs.Contact__c 
          LIMIT 1];

        Id offeringId = qrs.Course_Offering__c!=null?qrs.Course_Offering__c:qrs.Program_Offering__c;
        Boolean isPrescribed = qrs.Course_Offering__c!=null?false:true;

        PricebookEntry pbEntry = [SELECT Id, UnitPrice, Product2Id FROM PricebookEntry WHERE Id=: qrs.Pricebook_Entry_ID__c LIMIT 1];


        WebCart newCart = createWebCart(portalUser.Id);
        
        insert newCart;

       
        CartDeliveryGroup cartDeliveryGroup = [SELECT Id FROM CartDeliveryGroup WHERE Name ='Default Delivery' AND Cart.OwnerId =: portalUser.Id Limit 1];

        CartItem newCartItem = createCartItem(offeringId,newCart.Id,pbEntry,isPrescribed,cartDeliveryGroup.Id);

        insert newCartItem;

        Study_Store_URL_Settings__c storeLinkSettings = Study_Store_URL_Settings__c.getOrgDefaults();

        String communityUrl = storeLinkSettings.Study_Store_Link__c != null?String.valueOf(storeLinkSettings.Study_Store_Link__c):'';

        qrs.Cart_URL__c = communityUrl + 'cart/'; 
        qrs.Cart_URL__c += newCart != null?newCart.Id:'';  
          
        }  
      

      try {
      update qrs;

       } catch (Exception e) {
          System.debug(LoggingLevel.WARN, 'updateApplicationStatus ERROR: ' + e.getMessage());//NOPMD
        }
        
      }
    }
  }


  /**
     * Creates commerce user based on contact details
     * @param <Id> userId
     * @return WebCart
     */
    private static WebCart createWebCart(Id userId){
      Id opeCatalougeAccountId;
      List<Account> opeCatalougeAccounts = [SELECT Id FROM Account WHERE Name = 'OPE Catalogue' LIMIT 1];
      for(Account account : opeCatalougeAccounts){ opeCatalougeAccountId = account.Id; }

      Id studyWebStoreId;
      List<WebStore> studyWebStoreList = [SELECT Id FROM WebStore WHERE Name = 'Study' LIMIT 1];
      for(WebStore webStore : studyWebStoreList){ studyWebStoreId = webStore.Id; }

      // DEPP-3152 close any carts already opened from OPE portal.
      List<WebCart> existingCart = [Select Id, Status FROM WebCart WHERE Status='Active' and OwnerId = : userId LIMIT 1];
      if(existingCart.size()>0){
           existingCart[0].Status = 'Closed';
           update existingCart;
      }

      WebCart webCart = new WebCart();
      webCart.Name = 'Cart';
      webCart.AccountId = opeCatalougeAccountId;
      webCart.Status__c = 'Active';
      webCart.OwnerId = userId;
      webCart.WebStoreId = studyWebStoreId;
      return webCart;
 }


 /**
     * Creates cartitem based on parameters passed
     * @param <Id> offeringId - course/program offering
     * @param <Id> newWebCartId - new cart created
     * @param <PricebookEntry> pbEntry - price book entry
     * @param <Boolean> prescribedProgram
     * @param <Id>  cartDeliveryGroupId
     * @return CartItem
     */
    private static CartItem createCartItem(Id offeringId, Id newWebCartId,  PricebookEntry pbEntry, Boolean prescribedProgram, Id cartDeliveryGroupId){
      
      CartItem cartItem = new CartItem();
      cartItem.CartId = newWebCartId;
      cartItem.Name = 'Cart Item';
      cartItem.CartDeliveryGroupId = cartDeliveryGroupId;
      if(!prescribedProgram){
           cartItem.Course_Offering__c = offeringId;
      }else{
           cartItem.Program_Offering__c = offeringId;
      }
      cartItem.Product2Id = pbEntry.Product2Id;
      cartItem.Pricebook_Entry_ID__c = pbEntry.Id;
      cartItem.Quantity = 1;
      cartItem.TotalPrice = pbEntry.UnitPrice;
      cartItem.Type = 'Product';
      return cartItem;
 }

  /**
   * @description wrapper that contains the Quesionnaire Response Summary list
   */
  public class QuestionnaireResponseSummaryWrapper {
    @AuraEnabled
    public String qrsType;
    @AuraEnabled
    public String qrsProduct;
    @AuraEnabled
    public String qrsProductURL;
    @AuraEnabled
    public String qrsContact;
    @AuraEnabled
    public String qrsContactURL;
    @AuraEnabled
    public String qrsStatus;
    @AuraEnabled
    public List<QuestionAnswerWrapper> qaList;
  }

  /**
   * @description wrapper that contains the Quesionnaire Response Summary Question & Answers
   */
  public class QuestionAnswerWrapper {
    @AuraEnabled
    public String qId;
    @AuraEnabled
    public String question;
    @AuraEnabled
    public String aId;
    @AuraEnabled
    public String answer;
    @AuraEnabled
    public Boolean isFile;
    @AuraEnabled
    public String qaSequence;
  }
}
