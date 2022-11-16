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
*/

public with sharing class ManageRegistrationSectionHelper extends ManageRegistrationEnrolmentHelper{

     private static final String TAILORED_EXECUTIVE_PROGRAM = 'Tailored Executive Program';

     public static EnrolmentResultClass processEnrollmentWithPricing(RegistrationData parsedRegistrationData, Contact finalContactRecord, String contactRecName, Product2 product){
          
          EnrolmentResultClass enrollmentProcessingReturn = new EnrolmentResultClass();
          EnrolmentCreationParamClass enrolmentParam;
          Map<String,Asset> assetRecord = new Map<String,Asset>();

          Boolean isTailored = product != null && product.Product_Category__c == TAILORED_EXECUTIVE_PROGRAM?true:false;
          Id commerceUser;
                    
          Id priceBookEntryId = parsedRegistrationData.priceBookEntryId;
          Decimal discountAmount = parsedRegistrationData.discountAmount;
          Contact contactRecord = parsedRegistrationData.contactRecord;
          String offeringId = parsedRegistrationData.offeringId;
          Boolean prescribedProgram = parsedRegistrationData.prescribedProgram;
          Id promotionId = parsedRegistrationData.promotionId;
          Boolean isProceedNoInvoice = parsedRegistrationData.isProceedNoInvoice;
          


          PricebookEntry pbe = new PricebookEntry();
          Boolean isCorporateBundlePricing = false;
          Boolean isSOAPricing = false;
          Decimal amount;
          List<PricebookEntry> pbList = [SELECT Id, UnitPrice, Product2Id, PriceBook2Id, PriceBook2.Name FROM PricebookEntry WHERE Id =: priceBookEntryId LIMIT 1];

          for(PricebookEntry pb : pbList){
               isCorporateBundlePricing = pb.PriceBook2.Name.startsWith('Corporate Bundle');
               isSOAPricing = pb.PriceBook2.Name.startsWith('SOA');
               pbe = pb;
               amount = pb.UnitPrice - discountAmount;
          }

          List<User> corporateUser = new List<User>();
          WebCart newWebCart = new WebCart();
          //only try to get corporate user if selected pricing is SOA or Corporate Bundle
          if((isCorporateBundlePricing == true || isSOAPricing == true)){
               //get corporate user linked to the pricebookentry selected
               corporateUser = CorporateBundleAndSOAHelper.getCorporateUser(pbe.PriceBook2Id);
          }

          if(!corporateUser.isEmpty()){
               newWebCart = CorporateBundleAndSOAHelper.createCCEWebCart(corporateUser[0]);
               commerceUser = corporateUser[0].Id;
          }else if(corporateUser.isEmpty() && (isCorporateBundlePricing == true || isSOAPricing == true)){
               throw new AuraHandledException('Please make sure to enable the contact as Partner User');
          }else{
               commerceUser = ManageRegistrationEnrolmentHelper.createUser(finalContactRecord.Email, finalContactRecord.LastName, finalContactRecord.FirstName, contactRecord.Id);
               newWebCart = ManageRegistrationEnrolmentHelper.createWebCart(commerceUser, contactRecord.Id);
          }
          
          insert newWebCart;                    

          CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(
               CartId = newWebCart.Id,
               Name = 'Default Delivery'
          );
          insert cartDeliveryGroup;

          enrolmentParam = new EnrolmentCreationParamClass();
                    
          enrolmentParam.offeringId = offeringId;
          enrolmentParam.prescribedProgram = prescribedProgram;
          enrolmentParam.newWebCartId = newWebCart.Id;
          enrolmentParam.priceBookEntry = pbe;
          enrolmentParam.product = product;
          enrolmentParam.cartDeliveryGroupId = cartDeliveryGroup.Id;
          
          CartItem newCartItem = ManageRegistrationEnrolmentHelper.createCartItem(enrolmentParam);
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

               String externalId = [    SELECT Id, External_Id__c 
                                        FROM WebCart 
                                        WHERE OwnerId =: commerceUser 
                                        AND Status = 'Active' 
                                        LIMIT 1].External_Id__c; 

               PaymentUrlClass urlObj = new PaymentUrlClass();

               urlObj.CartExternalId = externalId;
               urlObj.Email = finalContactRecord.Email;
               urlObj.Name = contactRecName;
               urlObj.Amount = amount;
               urlObj.ProductName = product.Name;
               urlObj.IsCCE = isSOAPricing;

               String paymentURL = ManageRegistrationEnrolmentHelper.paymentGatewayURLBuilder(urlObj);
     
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

               enrollmentProcessingReturn.contactId = contactRecord.Id;
               enrollmentProcessingReturn.paymentURL = paymentURL;
               enrollmentProcessingReturn.contactName = contactRecName;

          }else{
               String externalId;
               List<WebCart> carts = [SELECT External_Id__c FROM WebCart WHERE OwnerId =: commerceUser LIMIT 1];
               for(WebCart webCart : carts){ externalId = webCart.External_Id__c; }
      
               WebCart webCartToClose = new WebCart(
                   Id = newWebCart.Id,
                   Status__c = 'Closed',
                   Status = 'Closed'
               );
               update webCartToClose;

               enrolmentParam = new ManageRegistrationEnrolmentHelper.EnrolmentCreationParamClass();
                    
               enrolmentParam.contactId = contactRecord.Id;
               enrolmentParam.offeringId = offeringId;
               enrolmentParam.prescribedProgram = prescribedProgram;
               enrolmentParam.isTailored = isTailored;
               enrolmentParam.amount = amount;
               enrolmentParam.newWebCartId = newWebCart.Id;
               enrolmentParam.newCartItemId = newCartItem.Id;
               
               List<hed__Course_Enrollment__c> courseConnectionList = ManageRegistrationEnrolmentHelper.createCourseConnectionList(enrolmentParam);                               
               insert courseConnectionList;
               
               enrollmentProcessingReturn.contactId = contactRecord.Id;
               enrollmentProcessingReturn.contactName = contactRecName;

               //if corporate pricing is selected
               if(isCorporateBundlePricing == true){
                    //get asset record related to corporate bundle
                    List<String> pbEntryIds = new List<String>();
                    pbEntryIds.add(priceBookEntryId);
                    assetRecord = CorporateBundleAndSOAHelper.getAsset(pbEntryIds);
                    
               }

               if(assetRecord.containsKey(priceBookentryId)){
                    CorporateBundleAndSOAHelper.createProductLedgerRecords(assetRecord.get(priceBookentryId).Id, courseConnectionList);
               }
          }
          
          return enrollmentProcessingReturn;
     }

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

          if(fileUpload != ''){
               parsedFileUpload = (List<FileUpload>) JSON.deserialize(fileUpload, List<FileUpload>.class);
          }
          
          for(Related_Answer__c relatedA: relatedAnswerList){
               questionnaireIds.add(relatedA.Questionnaire__c);
               relatedAnswerToQuestionnaireMap.put(relatedA.Id,relatedA.Questionnaire__c);
          }

          Questionnaire_Response_Summary__c qResSummary;

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
                    ContentVersion cv = createContentVersion(file.Base64, file.FileName);
                    cvToRelatedAnswerMap.put(cv.Title,file.RelatedAnswerId);
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
                    answersToUpdate.put(updateAnswer.Id,updateAnswer);
                    contentDocLinkListToInsert.add(cdl);
               }

               insert contentDocLinkListToInsert;
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
      * @description Wrapper class that holds the file uploaded by user
      */
      public class FileUpload{
          @AuraEnabled
          public String base64;
          @AuraEnabled
          public String fileName;
          @AuraEnabled
          public String relatedAnswerId;
      }
     
}