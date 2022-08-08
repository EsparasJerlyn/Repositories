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
    Map<String, Answer__c> relatedAnswerToAnswerMap = new Map<String, Answer__c>();
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
    

    finalParticipants = checkDuplicateContacts(participants);
  

    if(!participants.values().isEmpty()){
        upsert finalParticipants.values();
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

    return finalParticipants.values();
    
    

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


    public static Map<String, Contact> checkDuplicateContacts(Map<String, Contact> participants){
        Map<String, Contact> criteriaMap = new Map<String, Contact>();
        Map<String,String> participantMap = new Map<String,String>();
        Set<Date> birthDateSet = new Set<Date>();
        Set<String> emailSet = new Set<String>();
        Set<String> lastNameSet = new Set<String>();

        for(String item: participants.keySet()){
            
            birthDateSet.add(participants.get(item).Birthdate);
            emailSet.add(participants.get(item).Registered_Email__c);
            lastNameSet.add(participants.get(item).LastName);

            criteriaMap.put(JSON.serialize(participants.get(item).Birthdate) + participants.get(item).Registered_Email__c + participants.get(item).LastName,participants.get(item));
            participantMap.put(JSON.serialize(participants.get(item).Birthdate) + participants.get(item).Registered_Email__c + participants.get(item).LastName,item);
        }
        

    //Detect contact duplicates
    List<Contact> duplicateContacts = new List<Contact>(
        [
        SELECT
            Id,
            MobilePhone,
            Mobile_No_Locale__c,
            ContactMobile_Locale__c,
            Dietary_Requirement__c,
            Accessibility_Requirement__c,
            AccountId,
            Birthdate,
            Email,
            Registered_Email__c,
            Work_Email__c,
            QUT_Learner_Email__c,
            QUT_Staff_Email__c,
            LastName
        FROM Contact
        WHERE
            RecordTypeId = :RT_CONTACT_PERSON_ID
            AND Parent_Person_Contact__c = NULL
            AND Birthdate IN: birthDateSet
            AND (Registered_Email__c IN: emailSet
            OR Email IN: emailSet
            OR Work_Email__c IN: emailSet
            OR QUT_Learner_Email__c IN: emailSet
            OR QUT_Staff_Email__c IN: emailSet)
            AND LastName IN:lastNameSet
            AND RecordTypeId =:RT_CONTACT_PERSON_ID
        ]);

        for(Contact item: duplicateContacts){
            Contact tempCon = new Contact();
            
            String criteria = '';

            //check if registred email matches with contact emails
            if(item.Registered_Email__c != null && participantMap.containsKey(JSON.serialize(item.Birthdate) + item.Registered_Email__c + item.LastName)){
              criteria = JSON.serialize(item.Birthdate) + item.Registered_Email__c + item.LastName;
            }else if(item.Email != null && participantMap.containsKey(JSON.serialize(item.Birthdate) + item.Email + item.LastName)){
              criteria = JSON.serialize(item.Birthdate) + item.Email + item.LastName;
            }else if(item.Work_Email__c != null && participantMap.containsKey(JSON.serialize(item.Birthdate) + item.Work_Email__c + item.LastName)){
              criteria = JSON.serialize(item.Birthdate) + item.Work_Email__c + item.LastName;
            }else if(item.QUT_Learner_Email__c != null && participantMap.containsKey(JSON.serialize(item.Birthdate) + item.QUT_Learner_Email__c + item.LastName)){
              criteria = JSON.serialize(item.Birthdate) + item.QUT_Learner_Email__c + item.LastName;
            }else if(item.QUT_Staff_Email__c != null && participantMap.containsKey(JSON.serialize(item.Birthdate) + item.QUT_Staff_Email__c + item.LastName)){
              criteria = JSON.serialize(item.Birthdate) + item.QUT_Staff_Email__c + item.LastName;
            }

            if(criteriaMap.containsKey(criteria)){      
                tempCon.Id = item.Id;
                tempCon.Registered_Email__c = participants.get(participantMap.get(criteria)).Registered_Email__c;
                tempCon.Mobile_No_Locale__c = participants.get(participantMap.get(criteria)).Mobile_No_Locale__c;
                tempCon.Dietary_Requirement__c = participants.get(participantMap.get(criteria)).Dietary_Requirement__c;
                tempCon.ContactMobile_Locale__c = participants.get(participantMap.get(criteria)).ContactMobile_Locale__c;
                tempCon.MobilePhone = participants.get(participantMap.get(criteria)).MobilePhone;
            }else{
                //user not existing
                //map registered email to email
                tempCon.Email = participants.get(participantMap.get(criteria)).Registered_Email__c;
            tempCon.RecordTypeId = RT_CONTACT_PERSON_ID;
            tempCon.Birthdate = participants.get(participantMap.get(criteria)).Birthdate;
                tempCon.Registered_Email__c = participants.get(participantMap.get(criteria)).Registered_Email__c;
                tempCon.ContactMobile_Locale__c = participants.get(participantMap.get(criteria)).ContactMobile_Locale__c;
                tempCon.Mobile_No_Locale__c = participants.get(participantMap.get(criteria)).Mobile_No_Locale__c;
            tempCon.Dietary_Requirement__c = participants.get(participantMap.get(criteria)).Dietary_Requirement__c;
                tempCon.MobilePhone = participants.get(participantMap.get(criteria)).MobilePhone;
            }
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