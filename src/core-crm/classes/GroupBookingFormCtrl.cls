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
      | roy.nino.s.regala         | June 20, 2022         |  DEPP-3141| Created file                    |\
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
    Map<Id, Id> relatedAnswerToAnswerMap = new Map<Id, Id>();
    Set<String> questionnaireIds = new Set<String>();
    Map<String,Set<Id>> questionnaireIdsMap = new Map<String,Set<Id>>();
    Map<String,Questionnaire_Response_Summary__c> questionnaireSummaryToInsertMap = new Map<String,Questionnaire_Response_Summary__c>();
    Map<String,Answer__c> answersToInsertMap = new Map<String,Answer__c>();
    List<Answer__c> answersToInsertList = new List<Answer__c>();
    
    Set<String> emailSet = new Set<String>();
    Set<String> birthDateSet = new Set<String>();
    Set<String> lastNameSet = new Set<String>();
    Map<String,Contact> finalParticipants = new Map<String, Contact>();
    String questionnaireId;

    List<Answer__c> answersToInsert = new List<Answer__c>();
    Map<Id, Answer__c> answersToUpdate = new Map<Id, Answer__c>();
    
    // List<FileUpload> parsedFileUpload = new List<FileUpload>();
    // Map<String,List<FileUpload>> parsedFUploadMap = new Map<String,List<FileUplaod>>();

    finalParticipants = checkDuplicateContacts(participants);
  

    
    if(!participants.values().isEmpty()){
        upsert finalParticipants.values();
    }

    for (Related_Answer__c relatedA : relatedAnswer) {
        questionnaireId = relatedA.Questionnaire__c; //always one questionnaire(registration questions)
        break;
    }

    Questionnaire_Response_Summary__c qResSummary;

    for(String key: finalParticipants.keySet()){
        qResSummary = new Questionnaire_Response_Summary__c();
        qResSummary.Questionnaire__c = questionnaireId;
        if(isPrescribed){
            qResSummary.Program_Offering__c = offeringId;
        }else{
            qResSummary.Course_Offering__c = offeringId;
        }
        qResSummary.Registration_Status__c = 'Confirmed';
        qResSummary.Contact__c = finalParticipants.get(key).Id;
        questionnaireSummaryToInsertMap.put(key,qResSummary);
    }

    if (!questionnaireSummaryToInsertMap.keySet().isEmpty()) {
      insert questionnaireSummaryToInsertMap.values();
    }

    for(String key: answerMap.keySet()){
        for(Answer__c ans: answerMap.get(key)){
            ans.Questionnaire_Response_Summary__c = questionnaireSummaryToInsertMap.get(key).Id;
            answersToInsertList.add(ans);
        }
    }
    
    if(!answersToInsertList.isEmpty()){
        insert answersToInsertList;
    }


    return finalParticipants.values();
    // for (Answer__c ans : answersToInsertMap.values()) {
    //   relatedAnswerToAnswerMap.put(ans.Related_Answer__c, ans.Id);
    // }

    // for(String key: parsedFUploadMap.keySet()){
    //     for (FileUpload file : parsedFUploadMap.get(key)) {
    //         if (relatedAnswerToAnswerMap.containsKey(file.RelatedAnswerId)) {
    //           ContentVersion cv = createContentVersion(file.Base64, file.FileName);
    //           cvToRelatedAnswerMap.put(cv.Title, file.RelatedAnswerId);
    //           cvListToInsertList.add(cv);
    //         }
    //     }
    // }
    

    // if (!cvListToInsertList.isEmpty()) {
    //   insert cvListToInsertList;
    // }

    // List<ContentVersion> newContentVersionList = new List<ContentVersion>(
    //   [
    //     SELECT ContentDocumentId, Title
    //     FROM ContentVersion
    //     WHERE Id IN :cvListToInsertList
    //   ]
    // );

    // if (!newContentVersionList.isEmpty()) {
    //   ContentDocumentLink cdl;
    //   Answer__c updateAnswer;
    //   for (ContentVersion cv : newContentVersionList) {
    //     String test = relatedAnswerToAnswerMap.get(
    //       cvToRelatedAnswerMap.get(cv.Title)
    //     );
    //     cdl = new ContentDocumentLink(
    //       ContentDocumentId = cv.ContentDocumentId,
    //       LinkedEntityId = relatedAnswerToAnswerMap.get(
    //         cvToRelatedAnswerMap.get(cv.Title)
    //       ),
    //       ShareType = 'V'
    //     );
    //     updateAnswer = new Answer__c(
    //       Id = cdl.LinkedEntityId,
    //       Response__c = cv.ContentDocumentId
    //     );
    //     answersToUpdate.put(updateAnswer.Id, updateAnswer);
    //     contentDocLinkListToInsert.add(cdl);
    //   }
    // }

    // if (!contentDocLinkListToInsert.isEmpty()) {
    //   insert contentDocLinkListToInsert;
    // }

    // if (!answersToUpdate.keySet().isEmpty()) {
    //   update answersToUpdate.values();
    // }
    
    

//     if (!forApplication) {
//       hed__Course_Enrollment__c newCourseConnection = new hed__Course_Enrollment__c(
//         hed__Course_Offering__c = courseOfferingId,
//         hed__Contact__c = contactRecord.Id,
//         RecordTypeId = STUDENT_RECTYPEID,
//         hed__Status__c = 'Active'
//       );
//       insert newCourseConnection;
//     }
//   }


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


    public static Map<String, Contact> checkDuplicateContacts(Map<String, Contact> participants){
        Map<String, Contact> criteriaMap = new Map<String, Contact>();
        Map<String,String> participantMap = new Map<String,String>();
        Set<Date> birthDateSet = new Set<Date>();
        Set<String> emailSet = new Set<String>();
        Set<String> lastNameSet = new Set<String>();

        for(String item: participants.keySet()){
            
            birthDateSet.add(participants.get(item).Birthdate);
            emailSet.add(participants.get(item).Email);
            lastNameSet.add(participants.get(item).LastName);

            criteriaMap.put(JSON.serialize(participants.get(item).Birthdate) + participants.get(item).Email + participants.get(item).LastName,participants.get(item));
            participantMap.put(JSON.serialize(participants.get(item).Birthdate) + participants.get(item).Email + participants.get(item).LastName,item);
        }
        

    //Detect contact duplicates
    List<Contact> duplicateContacts = new List<Contact>(
        [
        SELECT
            Id,
            MobilePhone,
            Dietary_Requirement__c,
            Accessibility_Requirement__c,
            AccountId,
            Birthdate,
            Email,
            Work_Email__c,
            QUT_Learner_Email__c,
            QUT_Staff_Email__c,
            LastName
        FROM Contact
        WHERE
            RecordTypeId = :RT_CONTACT_PERSON_ID
            AND Parent_Person_Contact__c = NULL
            AND Birthdate IN: birthDateSet
            AND Email IN: emailSet
            AND LastName IN:lastNameSet
        ]);

        for(Contact item: duplicateContacts){
            Contact tempCon = new Contact();
            String criteria = JSON.serialize(item.Birthdate) + item.Email + item.LastName;
            if(criteriaMap.containsKey(criteria)){      
                tempCon.Id = item.Id;
            }
            tempCon.RecordTypeId = RT_CONTACT_PERSON_ID;
            tempCon.Birthdate = participants.get(participantMap.get(criteria)).Birthdate;
            tempCon.Email = participants.get(participantMap.get(criteria)).Email;
            tempCon.MobilePhone = participants.get(participantMap.get(criteria)).MobilePhone;
            tempCon.Dietary_Requirement__c = participants.get(participantMap.get(criteria)).Dietary_Requirement__c;
            participants.put(participantMap.get(criteria),tempCon);
        }  

        return participants;
    }

    @AuraEnabled
    public static void removeCartItems(String userId){
        WebCart activeCart = [SELECT Id, (SELECT Id FROM CartItems) FROM WebCart WHERE Status ='Active' AND OwnerId =: userId];
        List<CartItem> cartItemsToRemove = new List<CartItem>();
        if(!activeCart.CartItems.isEmpty()){
            cartItemsToRemove.addAll(activeCart.CartItems);
        }

        if(!cartITemsToRemove.isEmpty()){
            delete cartItemsToRemove;
        }
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