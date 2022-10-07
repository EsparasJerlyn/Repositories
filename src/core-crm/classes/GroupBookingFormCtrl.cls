/**
 * @description  GroupBookingFormCtrl Class
 *
 * @see GroupBookingFormCtrl
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA      | Change Summary                  |
      |---------------------------|-----------------------|-----------|---------------------------------|
      | roy.nino.s.regala         | June 20, 2022         |  DEPP-3141| Created file                    |
      | julie.jane.alegre         | September 29, 2022    |  DEPP-4471| Add method for available seats  |
*/
public without sharing class GroupBookingFormCtrl {

  private static final String RT_CONTACT_PERSON = System.Label.RT_Contact_Person;
  private static final Id RT_CONTACT_PERSON_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(RT_CONTACT_PERSON).getRecordTypeId();

/**
 * @description get list of contacts searched
 * @param contactRecord - contact to create
 * @param courseOfferingId - course offering id
 * @param relatedAnswerList - related answer records
 * @param answerList - answer records to be inserted
 * @param fileUpload - file to upload
 * @param forApplication - flag for checking if only for application
 */
@AuraEnabled
public static List<Contact> saveBooking(
  Map<String,Contact> participants,
  String offeringId,
  List<Related_Answer__c> relatedAnswer,
  Map<String,List<Answer__c>> answerMap,
  Map<String,String> fileUpload,
  Boolean isPrescribed
) {

  List<Questionnaire_Response_Summary__c> questionnaireSummaryToInsert = new List<Questionnaire_Response_Summary__c>();
  Map<String, String> cvToRelatedAnswerMap = new Map<String, String>();
  List<ContentDocumentLink> contentDocLinkListToInsert = new List<ContentDocumentLink>();
  List<ContentVersion> cvListToInsertList = new List<ContentVersion>();
  Map<Id, Id> relatedAnswerToQuestionnaireMap = new Map<Id, Id>();
  Map<String,Map<Id,Id>> conToRelatedAnswerToQMap = new Map<String,Map<Id,Id>>();
  Map<Id, Id> questionnaireToqResSummaryMap = new Map<Id, Id>();
  Map<String, Answer__c> relatedAnswerToAnswerMap = new Map<String, Answer__c>();
  Map<String,Questionnaire_Response_Summary__c> questionnaireSummaryToInsertMap = new Map<String,Questionnaire_Response_Summary__c>();
  Map<String,Answer__c> answersToInsertMap = new Map<String,Answer__c>();
  List<Answer__c> answersToInsertList = new List<Answer__c>();
  
  Set<String> emailSet = new Set<String>();
  Set<String> birthDateSet = new Set<String>();
  Set<String> lastNameSet = new Set<String>();
  String questionnaireId;

  List<Answer__c> answersToInsert = new List<Answer__c>();
  Map<Id, Answer__c> answersToUpdate = new Map<Id, Answer__c>();


  for(Contact con: participants.values()){
    if(con.Id == null){
      con.RecordTypeId = RT_CONTACT_PERSON_ID; //recordtype id
      con.Email = con.Registered_Email__c;//if contact is new copy over registered email to email field
    }
  }

  if(!participants.keySet().isEmpty()){
      upsert participants.values();
  }

  for (Related_Answer__c relatedA : relatedAnswer) {
      questionnaireId = relatedA.Questionnaire__c; //always one questionnaire(registration questions)
      break;
  }

  List<FileUpload> parsedFileUpload;

  for(String stringKey : fileUpload.keySet()){
      parsedFileUpload = new List<FileUpload>();
      parsedFileUpload.addALL((List<FileUpload>) JSON.deserialize(fileUpload.get(stringKey), List<FileUpload>.class));

      for (FileUpload file : parsedFileUpload) {
          ContentVersion cv = createContentVersion(file.Base64, file.FileName);
          cvToRelatedAnswerMap.put(cv.Title, file.RelatedAnswerId + stringKey);
          cvListToInsertList.add(cv);
      }
  }

  Questionnaire_Response_Summary__c qResSummary;
  
for(String key: participants.keySet()){
      qResSummary = new Questionnaire_Response_Summary__c();
      qResSummary.Questionnaire__c = questionnaireId;
      if(isPrescribed){
          qResSummary.Program_Offering__c = offeringId;
      }else{
          qResSummary.Course_Offering__c = offeringId;
      }
      qResSummary.Registration_Status__c = 'Confirmed';
      qResSummary.Contact__c = participants.get(key).Id;
      questionnaireSummaryToInsertMap.put(key,qResSummary);
  }

  if (!questionnaireSummaryToInsertMap.keySet().isEmpty()) {
    insert questionnaireSummaryToInsertMap.values();
  }

  for(String key: answerMap.keySet()){
      for(Answer__c ans: answerMap.get(key)){
          ans.Questionnaire_Response_Summary__c = questionnaireSummaryToInsertMap.get(key).Id;
          relatedAnswerToAnswerMap.put(ans.Related_Answer__c + key, ans);
      }
  }
  
  if(!relatedAnswerToAnswerMap.keySet().isEmpty()){
      insert relatedAnswerToAnswerMap.values();
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

  ContentDocumentLink cdl;
  Answer__c updateAnswer;

  if (!newContentVersionList.isEmpty()) {

    for (ContentVersion cv : newContentVersionList) {

      cdl = new ContentDocumentLink(
        ContentDocumentId = cv.ContentDocumentId,
        LinkedEntityId = relatedAnswerToAnswerMap.get(cvToRelatedAnswerMap.get(cv.Title)).Id,
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

  return participants.values();
}

private static ContentVersion createContentVersion(String base64, String filename) {
  ContentVersion cv = new ContentVersion();
  cv.VersionData = EncodingUtil.base64Decode(base64);
  cv.Title = filename;
  cv.PathOnClient = filename;
  return cv;
}

/**
 * @description Custom Add to Cart process
 * @param communityId The Id of the community from which the call originated
 * @param productId The Id of the product
 * @param effectiveAccountId ID of the account for which the request is made. If null, defaults to the account ID for the context user.
 * @param productName The Product Name.
 * @param courseOfferingId The Course Offering Id of the selected Available Start Date on UI.
 * @param pricebookEntryId The Pricebook Entry Id of the selected Price on UI.
 */
@AuraEnabled
public static void addCartItems(
  String productId,
  String productName,
  boolean isPrescribed,
  String offeringId,
  String pricebookEntryId,
  Decimal pricebookUnitPrice,
  String userId,
  List<Contact> contacts,
  String cartId
) {
    List<CartItem> cartItemsToInsert = new List<CartItem>();

    // Get Current User Active Cart Delivery Group
    Id cartDeliveryGroupId = [
      SELECT Id, Name, CreatedDate, LastModifiedDate, CartId
      FROM CartDeliveryGroup
      WHERE CartId = :cartId
    ]
    .Id;

    // Set Cart Item to be inserted
    for(Contact con: contacts){
          CartItem cItem = new CartItem();
          cItem.CartId = cartId;
          cItem.CartDeliveryGroupId = cartDeliveryGroupId;
          cItem.Name = productName;
          cItem.Contact__c = con.Id;
          cItem.Product2Id = productId;
          if (!isPrescribed) {
              cItem.Course_Offering__c = offeringId;
          } else{
              cItem.Program_Offering__c = offeringId;
          }
          cItem.Pricebook_Entry_ID__c = pricebookEntryId;
          cItem.Quantity = 1;
          cItem.Type = 'Product';
          cItem.TotalPrice = priceBookUnitPrice;
          cartItemsToInsert.add(cItem);
    }

    if(!cartItemsToInsert.isEmpty()){
      insert cartItemsToInsert;
    }
}

  @AuraEnabled
  public static void removeCartItems(String userId){
      List<WebCart> activeCarts = [SELECT Id, (SELECT Id FROM CartItems) FROM WebCart WHERE Status ='Active' AND OwnerId =: userId];
      List<CartItem> cartItemsToRemove = new List<CartItem>();
      for(WebCart currentActiveCart : activeCarts) {
        if(!currentActiveCart.CartItems.isEmpty()){
            cartItemsToRemove.addAll(currentActiveCart.CartItems);
        }
      }

      if(!cartITemsToRemove.isEmpty()){
          delete cartItemsToRemove;
      }
  }

  @AuraEnabled
  public static Decimal getAvailableSeats(String offeringId, Boolean isPrescribed){
      Decimal availableSeats = 0;
      if(offeringId != null){
          if(isPrescribed){
              availableSeats = [ 
                  SELECT Id, Available_Seats__c FROM Program_Offering__c
                  WHERE Id =: offeringId]
                  .Available_Seats__c;
          }
          else {
              availableSeats = [
                  SELECT Id,Available_Seats__c FROM hed__Course_Offering__c 
                  WHERE Id =: offeringId]
                  .Available_Seats__c;
          }
      }
      return availableSeats;

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
}