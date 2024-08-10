/**
 * @description helper class for manageregistrationsectionctrl
 * @see ../manageregistrationsectionctrl
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | roy.nino.s.regala         | November 15, 2022     | DEPP-4721            | Created file                 |
      | eugene.andrew.abuan       | February 15, 2023     | DEPP-5044            | Adjusted lines in createUser for assigning |
      |                           |                       |                      | permset and adding Buyer Account           |
*/

public without sharing class ManageRegistrationSectionHelper{

     private static final String TAILORED_EXECUTIVE_PROGRAM = 'Tailored Executive Program';
     private static Boolean isCorporateBundlePricing = false;
     private static Boolean isSOAPricing = false;
     private static Decimal amount;
     private static List<User> corporateUser;
     private static WebCart newWebCart;
     private static Id commerceUser;
     private static CartDeliveryGroup cartDeliveryGroup;
     private static Decimal discountAmount;
     private static PricebookEntry priceBookEntry;
     private static Contact contactRecord;
     /**
      * @description setup user, pricing, cart of enrolment
      * @param finalContactRecord - contactRecord used for registration
      * @param priceBookEntryId - pricebookentry used 
      */
     private static void setupUserAndCart(Contact finalContactRecord, Id priceBookEntryId){

          corporateUser = new List<User>();
          newWebCart = new WebCart();

          //get the pricebookentry details of the selected pricebook entry of the user
          List<PricebookEntry> pbList = [    
               SELECT Id, UnitPrice, Product2Id, PriceBook2Id, PriceBook2.Name 
               FROM PricebookEntry 
               WHERE Id =: priceBookEntryId 
               WITH SECURITY_ENFORCED
               LIMIT 1];

          //checks if pricebook selected is Corporate Bundle or Standing Offer Arrangement
          for(PricebookEntry pb : pbList){
               isCorporateBundlePricing = pb.PriceBook2.Name.startsWith('Corporate Bundle');
               isSOAPricing = pb.PriceBook2.Name.startsWith('SOA');
               priceBookEntry = pb;
               amount = pb.UnitPrice - discountAmount;
          }

          //only try to get corporate user if selected pricing is SOA or Corporate Bundle
          if(isCorporateBundlePricing == true || isSOAPricing == true){
               //get corporate user linked to the pricebookentry selected
               //cart is linked to the corporate user
               corporateUser = CorporateBundleAndSOAHelper.getCorporateUser(priceBookEntry.PriceBook2Id);
               if(!corporateUser.isEmpty()){
                    //create a new webcart for the enrolled user
                    newWebCart = CorporateBundleAndSOAHelper.createCCEWebCart(corporateUser[0]);
                    commerceUser = corporateUser[0].Id;
               }else{
                    throw new AuraHandledException('Please ensure Corporate Portal Administrator is enabled access to the portal before registering contacts.');
               }
          }else{
               //try to create new contact
               Contact newContact = new Contact(
                    Email = finalContactRecord.Email,
                    LastName = finalContactRecord.LastName,
                    FirstName = finalContactRecord.FirstName,
                    Id = finalContactRecord.Id
               );

               //create new user to be enrolled to ope portal
               commerceUser = createUser(newContact);
               newWebCart = createWebCart(commerceUser, finalContactRecord.Id);
          }

          insert newWebCart; 

          cartDeliveryGroup = new CartDeliveryGroup(
               CartId = newWebCart.Id,
               Name = 'Default Delivery'
          );

          insert cartDeliveryGroup;
     }


     /**
      * @description process enrolment with price
      * @param parsedRegistrationData - registration data wrapped
      * @param finalContactRecord - contact record used for enrolment
      * @param product - product user enroled
      * @return ManageRegistrationEnrolmentHelper.EnrolmentResultClass - result of enrolment(validation and record created)
      */
     public static ManageRegistrationEnrolmentHelper.EnrolmentResultClass processEnrollmentWithPricing(
          RegistrationData parsedRegistrationData, 
          Contact finalContactRecord, 
          Product2 product){
          
          ManageRegistrationEnrolmentHelper.EnrolmentResultClass enrollmentProcessingReturn = new ManageRegistrationEnrolmentHelper.EnrolmentResultClass();
          ManageRegistrationEnrolmentHelper.EnrolmentCreationParamClass enrolmentParam;
          Map<String,Asset> assetRecord = new Map<String,Asset>();

          Boolean isTailored = product.Product_Category__c == TAILORED_EXECUTIVE_PROGRAM?true:false;
          
                    
          Id priceBookEntryId = parsedRegistrationData.priceBookEntryId;
          discountAmount = parsedRegistrationData.discountAmount;
          
          String offeringId = parsedRegistrationData.offeringId;
          Boolean prescribedProgram = parsedRegistrationData.prescribedProgram;
          Id promotionId = parsedRegistrationData.promotionId;
          Boolean isProceedNoInvoice = parsedRegistrationData.isProceedNoInvoice;

          priceBookEntry = new PricebookEntry();
          contactRecord = parsedRegistrationData.contactRecord;
          enrolmentParam = new ManageRegistrationEnrolmentHelper.EnrolmentCreationParamClass();
                    
          setupUserAndCart(finalContactRecord,priceBookEntryId);

          enrolmentParam.offeringId = offeringId;
          enrolmentParam.prescribedProgram = prescribedProgram;
          enrolmentParam.newWebCartId = newWebCart.Id;
          enrolmentParam.priceBookEntry = priceBookEntry;
          enrolmentParam.product = product;
          enrolmentParam.cartDeliveryGroupId = cartDeliveryGroup.Id;

          CartItem newCartItem = createCartItem(enrolmentParam);
          newCartItem.Contact__c = contactRecord.Id;
          newCartItem.Promotion__c = promotionId;
          newCartItem.Promotion_Price__c = discountAmount;
   
          insert newCartItem;

          if(!isProceedNoInvoice){
               Cart_Payment__c cartPayment = new Cart_Payment__c(
                    Status__c = 'Invoiced', 
                    Discount_Applied__c = discountAmount
               );
               insert cartPayment;

               String externalId = [    
                    SELECT Id, External_Id__c 
                    FROM WebCart 
                    WHERE OwnerId =: commerceUser 
                    AND Status = 'Active' 
                    LIMIT 1].External_Id__c; 

               PaymentUrlClass urlObj = new PaymentUrlClass();

               urlObj.CartExternalId = externalId;
               urlObj.Email = finalContactRecord.Email;
               urlObj.Name = finalContactRecord.FirstName + finalContactRecord.LastName;
               urlObj.Amount = amount;
               urlObj.ProductName = product.Name;
               urlObj.IsCCE = isSOAPricing;

               String paymentURL = paymentGatewayURLBuilder(urlObj);
     
               WebCart webCartToClose = new WebCart(
                    Id = newWebCart.Id,
                    Status__c = 'Closed',
                    Status = 'Closed',
                    Cart_Payment__c = cartPayment.Id,
                    Payment_URL__c = paymentURL
               );


               update webCartToClose;
          
               //update cart payment to invoiced after linking the webcart
               //so that the cart payment trigger can check related cartitems
               cartPayment.Payment_Status__c = 'Invoiced';

               update cartPayment;                   

               enrollmentProcessingReturn.contactId = finalContactRecord.Id;
               enrollmentProcessingReturn.paymentURL = paymentURL;
               enrollmentProcessingReturn.contactName = finalContactRecord.FirstName + finalContactRecord.LastName;

          }else{
               //get cart owned by the commerce user to be enroled
               String externalId;
               
               List<WebCart> carts = [
                    SELECT External_Id__c 
                    FROM WebCart 
                    WHERE OwnerId =: commerceUser 
                    WITH SECURITY_ENFORCED
                    LIMIT 1];
                    
               externalId = carts[0].External_Id__c;
      
               WebCart webCartToClose = new WebCart( Id = newWebCart.Id, Status__c = 'Closed', Status = 'Closed');
               
               //close active webcart
               //to create new one
               update webCartToClose;
               
               enrolmentParam = new ManageRegistrationEnrolmentHelper.EnrolmentCreationParamClass();
                    
               enrolmentParam.contactId = finalContactRecord.Id;
               enrolmentParam.offeringId = offeringId;
               enrolmentParam.prescribedProgram = prescribedProgram;
               enrolmentParam.isTailored = isTailored;
               enrolmentParam.amount = amount;
               enrolmentParam.newWebCartId = newWebCart.Id;
               enrolmentParam.newCartItemId = newCartItem.Id;
               
               //directly create course connection records
               List<hed__Course_Enrollment__c> courseConnectionList = ManageRegistrationEnrolmentHelper.createCourseConnectionList(enrolmentParam);  
               
               enrollmentProcessingReturn.contactId = finalContactRecord.Id;
               enrollmentProcessingReturn.contactName = finalContactRecord.FirstName + finalContactRecord.LastName;

               //if corporate pricing is selected
               if(isCorporateBundlePricing == true){
                    //get asset record related to corporate bundle
                    List<String> pbEntryIds = new List<String>();
                    pbEntryIds.add(priceBookEntryId);
                    assetRecord = CorporateBundleAndSOAHelper.getAsset(pbEntryIds);
                    
               }

               //create product ledger records to record the asset used for enrolment
               if(assetRecord.containsKey(priceBookentryId)){
                    CorporateBundleAndSOAHelper.createProductLedgerRecords(assetRecord.get(priceBookentryId).Id, courseConnectionList);
               }
          }
          
          return enrollmentProcessingReturn;
     }

     

     /**
      * Generates Payment Gateway URL based on the provided parameters
      * @param PaymentUrlClass contains paymenturl required details
      * @return String - URL Generated
      */
      public static String paymentGatewayURLBuilder(PaymentUrlClass urlObj){

          Payment_Gateway_Settings__c paymentGatewaySettings = Payment_Gateway_Settings__c.getorgdefaults();
          CCE_Payment_Gateway_Settings__c paymentGatewaySettingsCCE = CCE_Payment_Gateway_Settings__c.getorgdefaults();

          String baseURL = '';
          String transactionId = '';
          String description = '';
          String tranType = '';
          String glCode = '';

          if(urlObj.IsCCE){
               baseURL = paymentGatewaySettingsCCE.Payment_URL__c;
               transactionId = '&CCETransactionID=';
               description = '&CCEDescription=';
               tranType = paymentGatewaySettingsCCE.TransType_Invoice__c;
               glCode = paymentGatewaySettingsCCE.GL_Code__c;
          }else{
               baseURL = paymentGatewaySettings.Payment_URL__c;
               transactionId ='&OPETransactionID=';
               description = '&OPEDescription=';
               tranType = paymentGatewaySettings.TransType_Invoice__c;
               glCode = paymentGatewaySettings.GL_Code__c;
          }

          return baseURL +
               'tran-type=' + tranType +
               transactionId + urlObj.CartExternalId +
               '&Email=' + urlObj.Email.replace('@', '%40') +
               '&GLCode=' + glCode +
               '&FullName=' + urlObj.Name +
               description + urlObj.ProductName +
               '&UnitAmountIncTax=' + String.valueOf(urlObj.Amount);
     }

     
     /**
      * @description process the questionnaire answered by user
      * @param parsedRegistrationData - stringified registrationData
      * @param fileUpload - file uploaded by user
      */
     public static void processQuestionnaireData(RegistrationData parsedRegistrationData, String fileUpload){

          //set registration data into separate readable variables
          List<Related_Answer__c> relatedAnswerList = parsedRegistrationData.relatedAnswerList;
          Boolean prescribedProgram = parsedRegistrationData.prescribedProgram;
          List<Answer__c> answerList = parsedRegistrationData.answerList;
          String offeringId = parsedRegistrationData.offeringId;
          Contact contactRecord = parsedRegistrationData.contactRecord; 
          
          
          Set<Id> questionnaireIds = new Set<Id>();
          Map<Id,Id> relatedAnswerToQuestionnaireMap = new Map<Id,Id>();
          List<Questionnaire_Response_Summary__c> questionnaireSummaryToInsert = new List<Questionnaire_Response_Summary__c>();
          Map<Id,Id> questionnaireToqResSummaryMap = new Map<Id,Id>();
          List<Answer__c> answersToInsert = new List<Answer__c>();

          List<FileUpload> parsedFileUpload = new List<FileUpload>();

          //convert fileupload string to file upload wrapper class
          if(fileUpload != ''){
               parsedFileUpload = (List<FileUpload>) JSON.deserialize(fileUpload, List<FileUpload>.class);
          }
          
          //collect all questionnaire ids and create a map the groups all questionnare against the related answer
          for(Related_Answer__c relatedA: relatedAnswerList){
               questionnaireIds.add(relatedA.Questionnaire__c);
               relatedAnswerToQuestionnaireMap.put(relatedA.Id,relatedA.Questionnaire__c);
          }

          Questionnaire_Response_Summary__c qResSummary;

          //
          for(Id qId:questionnaireIds){
               qResSummary = new Questionnaire_Response_Summary__c();
               qResSummary.Questionnaire__c = qId;
               if(!prescribedProgram){
                    qResSummary.Course_Offering__c = offeringId;
               }else{
                    qResSummary.Program_Offering__c = offeringId;
               }
               qResSummary.Registration_Status__c = 'Confirmed';
               qResSummary.Contact__c = contactRecord.Id;
               questionnaireSummaryToInsert.add(qResSummary);
          }

          if(!questionnaireSummaryToInsert.isEmpty()){
               insert questionnaireSummaryToInsert;
          }

          for(Questionnaire_Response_Summary__c questionResSummary: questionnaireSummaryToInsert){
               questionnaireToqResSummaryMap.put(questionResSummary.Questionnaire__c,questionResSummary.Id);
          }

          if(!answerList.isEmpty()){
               for(Answer__c a: answerList){
                    a.Questionnaire_Response_Summary__c = questionnaireToqResSummaryMap.get(relatedAnswerToQuestionnaireMap.get(a.Related_Answer__c));
                    answersToInsert.add(a);
               }
               insert answersToInsert;

               processFileUpload(answersToInsert,parsedFileUpload);
          }

          
     }

     /**
      * @description process the file uploaded by user
      * @param answersToInsert - answser records linked to the file upload
      * @param parsedFileUpload - file uploaded by user
      */
     private static void processFileUpload(List<Answer__c> answersToInsert, List<FileUpload> parsedFileUpload){

          Map<Id,Id> relatedAnswerToAnswerMap = new Map<Id,Id>();
          Map<String,String> cvToRelatedAnswerMap = new Map<String,String>();
          List<ContentVersion> cvListToInsertList = new List<ContentVersion>();
          List<ContentVersion> newContentVersionList = new List<ContentVersion>();
          ContentDocumentLink cdl;
          Answer__c updateAnswer;
          List<ContentDocumentLink> contentDocLinkListToInsert = new List<ContentDocumentLink>();
          Map<Id,Answer__c> answersToUpdate = new Map<Id,Answer__c>();

          for(Answer__c ans :answersToInsert){
               relatedAnswerToAnswerMap.put(ans.Related_Answer__c,ans.Id);
          }

          for(FileUpload file: parsedFileUpload){
               if(relatedAnswerToAnswerMap.containsKey(file.RelatedAnswerId)){
                    ContentVersion cv = createContentVersion(
                         file.Base64, 
                         file.FileName
                    );

                    cvToRelatedAnswerMap.put(
                         cv.Title,
                         file.RelatedAnswerId
                    );

                    cvListToInsertList.add(cv);
               }
          }

          if(!cvListToInsertList.isEmpty()){
               insert cvListToInsertList;

               newContentVersionList = new List<ContentVersion>([ 
                    SELECT ContentDocumentId, Title
                    FROM ContentVersion
                    WHERE Id IN:cvListToInsertList]);


               for(ContentVersion cv:newContentVersionList){
                    cdl = new ContentDocumentLink(
                         ContentDocumentId = cv.ContentDocumentId,
                         LinkedEntityId = relatedAnswerToAnswerMap.get(cvToRelatedAnswerMap.get(cv.Title)),
                         ShareType = 'V'
                    );

                    updateAnswer = new Answer__c(
                         Id = cdl.LinkedEntityId,
                         Response__c = cv.ContentDocumentId
                    );

                    answersToUpdate.put(
                         updateAnswer.Id,
                         updateAnswer
                    );

                    contentDocLinkListToInsert.add(cdl);
               }

               insert contentDocLinkListToInsert;

               update answersToUpdate.values();
          }
     }

     /**
     * Retrieves Product based on offering id
     * @param <Id> offeringId
     * @return Id
     */
     public static Product2 getProduct(Id offeringId, Boolean isPrescribedProgram){
          Product2 response = new Product2();

          Id filter;

          List<Product2> productList = new List<Product2>();

          if(!isPrescribedProgram){

               List<hed__Course_Offering__c> courseOfferingList = [
                    SELECT Id, hed__Course__c 
                    FROM hed__Course_Offering__c 
                    WHERE Id =: offeringId 
                    WITH SECURITY_ENFORCED
                    LIMIT 1];

               for(hed__Course_Offering__c courseOffering : courseOfferingList){
                    filter = courseOffering.hed__Course__c;
               }
               productList = [
                    SELECT Id, Name, Product_Category__c 
                    FROM Product2
                    WHERE Course__c =: filter
                    WITH SECURITY_ENFORCED];
          }else{
               List<Program_Offering__c> programOfferingList = [
                    SELECT Id, hed_Program_Plan__c 
                    FROM Program_Offering__c 
                    WHERE Id =: offeringId
                    WITH SECURITY_ENFORCED
                    LIMIT 1];
               for(Program_Offering__c programOffering : programOfferingList){
                    filter = programOffering.hed_Program_Plan__c;
               }
               productList = [
                    SELECT Id, Name, Product_Category__c 
                    FROM Product2 
                    WHERE Program_Plan__c  =: filter
                    WITH SECURITY_ENFORCED];
          }

          for(Product2 prod : productList){
               response = prod;
          }

          return response;
     }

     private static ContentVersion createContentVersion(String base64, String filename) {
          ContentVersion cv = new ContentVersion();
          cv.VersionData = EncodingUtil.base64Decode(base64);
          cv.Title = filename;
          cv.PathOnClient = filename;
          return cv;
     }

     /**
     * Creates cartitem based on parameters passed
     * @param enrolmentParam - wrapper class that contains needed data
     * @return CartItem
     */
    private static CartItem createCartItem(ManageRegistrationEnrolmentHelper.EnrolmentCreationParamClass enrolmentParam){

          CartItem cartItem = new CartItem();
          cartItem.CartId = enrolmentParam.newWebCartId;
          cartItem.Name = enrolmentParam.product.Name;
          cartItem.CartDeliveryGroupId = enrolmentParam.cartDeliveryGroupId;
          if(!enrolmentParam.prescribedProgram){
               cartItem.Course_Offering__c = enrolmentParam.offeringId;
          }else{
               cartItem.Program_Offering__c = enrolmentParam.offeringId;
          }
          cartItem.Product2Id = enrolmentParam.priceBookEntry.Product2Id;
          cartItem.Pricebook_Entry_ID__c = enrolmentParam.priceBookEntry.Id;
          cartItem.Quantity = 1;
          cartItem.TotalPrice = enrolmentParam.priceBookEntry.UnitPrice;
          cartItem.Type = 'Product';
          return cartItem;
     }

     /**
     * Creates commerce user based on contact details
     * @param <Id> userId
     * @return WebCart
     */
     private static WebCart createWebCart(Id userId, Id contactId){
          WebCart webCart = new WebCart();
          try{
               
               Id adminAcctId = [
                    SELECT AccountId 
                    FROM Contact 
                    WHERE Id =: contactId 
                    LIMIT 1].AccountId;

               Id studyWebStoreId;

               List<WebStore> studyWebStoreList = [
                    SELECT Id 
                    FROM WebStore 
                    WHERE Name = 'Study' 
                    WITH SECURITY_ENFORCED 
                    LIMIT 1];

               for(WebStore webStore : studyWebStoreList){ 
                    studyWebStoreId = webStore.Id; 
               }

               // DEPP-3152 close any carts already opened from OPE portal.
               List<WebCart> existingCart = [
                    SELECT Id, Status 
                    FROM WebCart 
                    WHERE Status='Active' 
                    AND OwnerId = : userId 
                    WITH SECURITY_ENFORCED
                    LIMIT 1];

               if(existingCart.size()>0){
                    existingCart[0].Status = 'Closed';
                    update existingCart;
               }
               
               webCart.Name = 'Cart';
               webCart.AccountId = adminAcctId;
               webCart.Status__c = 'Active';
               webCart.OwnerId = userId;
               webCart.WebStoreId = studyWebStoreId;
          }catch(Exception e){
               Logger.error('Exception caught in method createWebCart in class ManageRegistrationSectionHelper.')
                    .setExceptionDetails(e);
          } finally {
               if(Logger.getBufferSize() > 0) {
                    Logger.saveLog();
               }
          }

          return webCart;
     }

     /**
     * Creates commerce user based on contact details
     * @param <String> contactRecEmail
     * @param <String> contactRecLname
     * @param <String> contactRecFname
     * @param <Id> contactId
     * @return User
     */
     private static Id createUser(Contact newContact){
          Id response;
          Id contactId = newContact.Id;

          List<User> users = [
               SELECT Id 
               FROM User 
               WHERE ContactId  =: newContact.Id 
               AND IsActive = true 
               LIMIT 1];

          if(users.size() > 0){
               response = users[0].Id;
          }else{

               Profile profile = [
                    SELECT Id 
                    FROM Profile 
                    WHERE Name = 'QUT Experience' 
                    LIMIT 1];

               User commerceUser = new User();
               commerceUser.Username = newContact.Email;
               commerceUser.Email = newContact.Email;
               commerceUser.LastName = newContact.LastName;
               commerceUser.FirstName = newContact.FirstName;
               commerceUser.ContactId = newContact.Id;
               commerceUser.alias = newContact.FirstName.substring(0, 1) + newContact.LastName.substring(0, 2);
               commerceUser.LanguageLocaleKey = 'en_US';
               commerceUser.localesidkey = 'en_AU';
               commerceUser.emailEncodingKey = 'UTF-8';
               commerceUser.timeZoneSidKey = 'Australia/Brisbane';
               commerceUser.profileId = profile.Id;
               insert commerceUser;

               response = commerceUser.Id;
          }
          assignToOPEBuyerGroup(contactId);
          assignOPEPermSet(response);

          return response;
     }

     private static void assignToOPEBuyerGroup(Id contactId){
          
          List<BuyerGroup> opeBuyerGroup = [ SELECT Id FROM BuyerGroup WHERE Name = 'OPE BuyerGroup' WITH SECURITY_ENFORCED LIMIT 1];
          List<Contact> contact = [SELECT AccountId, Account.Name FROM Contact WHERE Id =: contactId WITH SECURITY_ENFORCED LIMIT 1];
          Id contactAdminAccountId = contact[0].AccountId;
          List<BuyerAccount> buyerAccount = [SELECT Id FROM BuyerAccount WHERE BuyerId =: contactAdminAccountId WITH SECURITY_ENFORCED LIMIT 1];

          if(buyerAccount.isEmpty()){
               BuyerAccount administrativeAccountBuyer = new BuyerAccount();
               administrativeAccountBuyer.BuyerId = contact[0].AccountId;
               administrativeAccountBuyer.Name = contact[0].Account.Name;
               administrativeAccountBuyer.IsActive = true;
               administrativeAccountBuyer.BuyerStatus = 'Active';

               insertAdministrativeAccountBuyer(administrativeAccountBuyer);               
           }

          List<BuyerGroupMember> buyerGroupMember = [SELECT Id FROM buyerGroupMember WHERE BuyerId =: contactAdminAccountId AND BuyerGroupId =: opeBuyerGroup[0].Id WITH SECURITY_ENFORCED LIMIT 1];
          if(buyerGroupMember.isEmpty()){
               BuyerGroupMember bgMember = new BuyerGroupMember();
               bgMember.BuyerId = contactAdminAccountId;
               bgMember.BuyerGroupId = opeBuyerGroup[0].Id;
               
               insertBuyerGroupMember(bgMember);
          }
     }

     private static void insertAdministrativeAccountBuyer(BuyerAccount administrativeAccountBuyer){
          if(Schema.sObjectType.BuyerAccount.fields.BuyerId.isCreateable() &&
               Schema.sObjectType.BuyerAccount.fields.Name.isCreateable() &&
               Schema.sObjectType.BuyerAccount.fields.IsActive.isCreateable() &&
               Schema.sObjectType.BuyerAccount.fields.BuyerStatus.isCreateable()){
               
                    Database.SaveResult insertResult = Database.insert(administrativeAccountBuyer, false);
                    if(!insertResult.isSuccess()){
                         Logger.error('Error in Inserting Buyer Accounts').setDatabaseResult(insertResult);
                         Logger.saveLog();                
                    }
          }
          
     }

     private static void insertBuyerGroupMember(BuyerGroupMember bgMember){
          if(Schema.sObjectType.BuyerGroupMember.fields.BuyerId.isCreateable() &&
               Schema.sObjectType.BuyerGroupMember.fields.BuyerGroupId.isCreateable()){
                    
                    Database.SaveResult insertResult = Database.insert(bgMember, false);
                    if(!insertResult.isSuccess()){
                         Logger.error('Error in Inserting Buyer Group Members').setDatabaseResult(insertResult);
                         Logger.saveLog();                
                    }
          }
     }

     @future
     private static void assignOPEPermSet(Id userId){
          List<PermissionSetAssignment> permSetAssignments = new List<PermissionSetAssignment>();
          List<PermissionSet> permsets = [SELECT Id FROM PermissionSet WHERE Label = 'OPE Catalogue' WITH SECURITY_ENFORCED LIMIT 1];
          List<PermissionSetAssignment> userPermSetAssignments = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId IN : permsets AND AssigneeId = : userId WITH SECURITY_ENFORCED];
          if(userPermSetAssignments.isEmpty()){
              for(PermissionSet perm: permsets){
                  PermissionSetAssignment permSetAssignment = new PermissionSetAssignment(
                      PermissionSetId = perm.Id, 
                      AssigneeId = userId
                  );
                  permSetAssignments.add(permSetAssignment);
              }
              if(permSetAssignments.size() > 0 && 
                    Schema.sObjectType.PermissionSetAssignment.fields.AssigneeId.isCreateable() &&
                    Schema.sObjectType.PermissionSetAssignment.fields.PermissionSetId.isCreateable()){
                  insert permSetAssignments;
              }
          }
     }

     /**
      * @description Wrapper class that holds the file uploaded by user
      */
      private class FileUpload{
          private String base64;
          private String fileName;
          private String relatedAnswerId;
      }

      public class PaymentUrlClass{
          @AuraEnabled
          public String cartExternalId;
          @AuraEnabled
          public String email;
          @AuraEnabled
          public String name;
          @AuraEnabled
          public Decimal amount;
          @AuraEnabled
          public String productName;
          @AuraEnabled
          public Boolean isCCE;
     }

     public class RegistrationData{
          @AuraEnabled
          public Contact contactRecord;
          @AuraEnabled
          public String offeringId;
          @AuraEnabled
          public List<Related_Answer__c> relatedAnswerList;
          @AuraEnabled
          public List<Answer__c> answerList;
          @AuraEnabled
          public Boolean prescribedProgram;
          @AuraEnabled
          public Id priceBookEntryId;
          @AuraEnabled
          public Boolean isProceedNoInvoice;
          @AuraEnabled
          public Decimal discountAmount;
          @AuraEnabled
          public Id promotionId;
     }

}