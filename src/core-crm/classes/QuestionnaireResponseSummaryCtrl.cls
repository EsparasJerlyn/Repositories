/**
 * @description Retrieve Questionnaire Response Summary Details
 *
 * @see ../lwc/questionnaireResponseSummary
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer                 | Date                  | JIRA                 | Change Summary                                            |
      |---------------------------|-----------------------|----------------------|-----------------------------------------------------------|
      | john.bo.a.pineda          | March 14, 2022        | DEPP-1643            | Created file                                              |
      | roy.nino.s.regala         | June 23,2022          | DEPP-3252            | added logic to create cartitems and construct pay now url |
      | john.m.tambasen           | September 06, 2022    | DEPP-2928            | create own cartdeliverygroup and use cart_payment__c      |
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
  public static void updateApplicationStatus(String qrsId, String qrsStatus, String reasonForRejection) {
    if (String.isNotBlank(qrsId)) {
      List<Questionnaire_Response_Summary__c> qrs = [
        SELECT Id, Application_Status__c, Contact__c, 
        Contact__r.Registered_Email__c, Contact__r.Name,
        Pricebook_Entry_ID__c, Program_Offering__c,
        Course_Offering__c, Course_Name__c,
        Questionnaire__r.Parent_Record_ID__c
        FROM Questionnaire_Response_Summary__c
        WHERE Id = :qrsId
        AND Contact__r.Registered_Email__c != null
        LIMIT 1
      ];

      if(!qrs.isEmpty()){
        qrs[0].Application_Status__c = qrsStatus;
        qrs[0].Reason_For_Rejection__c = reasonForRejection != null?reasonForRejection:'';

        if(qrsStatus == 'Approved'){
          User portalUser = [ SELECT Id, Contact.AccountId, ContactId, AccountId
          FROM User
          WHERE ContactId =: qrs[0].Contact__c
          LIMIT 1];

        Id offeringId = qrs[0].Course_Offering__c!=null?qrs[0].Course_Offering__c:qrs[0].Program_Offering__c;
        Boolean isPrescribed = qrs[0].Course_Offering__c!=null?false:true;

        PricebookEntry pbEntry = [SELECT Id, UnitPrice, Product2Id, Product2.Name FROM PricebookEntry WHERE Id=: qrs[0].Pricebook_Entry_ID__c LIMIT 1];

        WebCart newCart = createWebCart(portalUser);
        insert newCart;

        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(
          CartId = newCart.Id,
          Name = 'Default Delivery'
        );
        insert cartDeliveryGroup;
        
        CartItemHelper.CartItemDetails details = new CartItemHelper.CartItemDetails();
        details.offeringId = offeringId;
        details.newWebCartId = newCart.Id;
        details.pbEntry = pbEntry;
        details.prescribedProgram = isPrescribed;
        details.cartDeliveryGroupId = cartDeliveryGroup.Id;
        CartItem newCartItem = CartItemHelper.createCartItem(details);
        newCartItem.Contact__c = portalUser.ContactId;
        insert newCartItem;

        //Cart_Payment__c updateCartPayment = new Cart_Payment__c(Id = cartPayment.Id, Payment_Status__c ='Aprroved');
        //update cart payment to invoiced after it has webcart and cartitems
        //update updateCartPayment;
        
        PaymentGatewayUrlDetails urlDetails = new PaymentGatewayUrlDetails();
        urlDetails.cartExternalId = [SELECT Id, External_Id__c FROM WebCart WHERE Id =: newCart.Id]?.External_Id__c;
        urlDetails.email = qrs[0].Contact__r.Registered_Email__c;
        urlDetails.name = qrs[0].Contact__r.Name;
        urlDetails.amount = pbEntry.UnitPrice;
        urlDetails.productName = qrs[0].Course_Name__c;
        qrs[0].Payment_URL__c = paymentGatewayURLBuilder(urlDetails);
        }

        update qrs;
      }

    }
  }

  //must used custom settings for the other hard coded query params
     /**
      * Generates Payment Gateway URL based on the provided parameters
      * @param PaymentGatewayUrlDetails
      * @return String - URL Generated
      */
      private static String paymentGatewayURLBuilder(PaymentGatewayUrlDetails urlDetails){

        Payment_Gateway_Settings__c paymentGatewaySettings = Payment_Gateway_Settings__c.getorgdefaults();

        return paymentGatewaySettings.Payment_URL__c +
             'tran-type=' + paymentGatewaySettings.TransType_PayNow__c +
             '&OPETransactionID=' + urlDetails.cartExternalId +
             '&OPEDescription=' + urlDetails.productName +
             '&Email=' + urlDetails.email +
             '&FullName=' + urlDetails.name +
             '&GLCode=' + paymentGatewaySettings.GL_Code__c +
             '&UnitAmountIncTax=' + String.valueOf(urlDetails.amount);
   }


  /**
     * Creates commerce user based on contact details
     * @param <Id> userId
     * @return WebCart
     */
    private static WebCart createWebCart(User portalUser){

      Id studyWebStoreId;
      List<WebStore> studyWebStoreList = [SELECT Id FROM WebStore WHERE Name = 'Study' LIMIT 1];
      for(WebStore webStore : studyWebStoreList){ studyWebStoreId = webStore.Id; }

      // DEPP-3152 close any carts already opened from OPE portal.
      List<WebCart> existingCart = [
        SELECT Id, Status 
        FROM WebCart 
        WHERE Status='Active' 
        AND OwnerId = : portalUser.Id 
        LIMIT 1];
      if(existingCart.size()>0){
           existingCart[0].Status = 'Closed';
           update existingCart;
      }

      WebCart webCart = new WebCart();
      webCart.Name = 'Cart';
      webCart.AccountId = portalUser.AccountId;
      webCart.Status__c = 'Active';
      webCart.OwnerId = portalUser.Id;
      webCart.WebStoreId = studyWebStoreId;
      return webCart;
 }

  /**
   * @description wrapper that contains the Quesionnaire Response Summary list
   */
  public class QuestionnaireResponseSummaryWrapper {
    @AuraEnabled public String qrsType;
    @AuraEnabled public String qrsProduct;
    @AuraEnabled public String qrsProductURL;
    @AuraEnabled public String qrsContact;
    @AuraEnabled public String qrsContactURL;
    @AuraEnabled public String qrsStatus;
    @AuraEnabled public List<QuestionAnswerWrapper> qaList;
  }

  /**
   * @description wrapper that contains the Quesionnaire Response Summary Question & Answers
   */
  public class QuestionAnswerWrapper {
    @AuraEnabled public String qId;
    @AuraEnabled public String question;
    @AuraEnabled public String aId;
    @AuraEnabled public String answer;
    @AuraEnabled public Boolean isFile;
    @AuraEnabled public String qaSequence;
  }

  private class PaymentGatewayUrlDetails {
    public String cartExternalId { get; set; }
    public String email { get; set; }
    public String name { get; set; }
    public Decimal amount { get; set; }
    public String productName { get; set; }
  }
}
