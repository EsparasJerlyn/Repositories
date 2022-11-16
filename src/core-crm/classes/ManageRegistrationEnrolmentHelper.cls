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

public with sharing abstract class ManageRegistrationEnrolmentHelper {

     private static string studentRT = System.Label.RT_CourseConnection_Student;
     private static Id studentRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get(studentRT).getRecordTypeId();
     private static string studentProgramRT = System.Label.RT_CourseConnection_Student_Program;
     private static Id studentProgramRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get(studentProgramRT).getRecordTypeId();


     public static EnrolmentResultClass validatedContacts(List<Contact> contactList){
          EnrolmentResultClass validationReturn = new EnrolmentResultClass();
          List<Contact> contactListToUpsert = new List<Contact>();
          List<RegistrationMatchingHelper.ContactMatchingResponse> contactsValidated = RegistrationMatchingHelper.validateContactMatching(JSON.serialize(contactList));
               for(RegistrationMatchingHelper.ContactMatchingResponse contactValidated: contactsValidated){
                    if(!contactValidated.isPartialMatch && contactValidated.isEmailMatch){
                         Contact con = contactValidated.contactRecord;
                         con.MobilePhone = contactList[0].MobilePhone;
                         con.Dietary_Requirement__c = contactList[0].Dietary_Requirement__c;
                         con.Accessibility_Requirement__c = contactList[0].Accessibility_Requirement__c;
                         contactListToUpsert.add(con);
                         validationReturn.isContactInputValid = true;
                         validationReturn.contactValidationResponse =  '';
                    }
                    else if(contactValidated.isPartialMatch && !contactValidated.isEmailMatch){
                         validationReturn.isContactInputValid = false;
                         validationReturn.contactValidationResponse =  'The email address doesn’t match the contact details provided. Please check the details.';
                    }
                    else if(contactValidated.isPartialMatch && contactValidated.isEmailMatch){
                         validationReturn.isContactInputValid = false;
                         validationReturn.contactValidationResponse =  'The personal details do not match with the email provided. Please check the details.';
                    }else{
                         validationReturn.isContactInputValid = true;
                         validationReturn.contactValidationResponse =  '';
                         contactListToUpsert.addAll(contactList);
                    }
               }  
               if(contactListToUpsert.size() > 0){
                    upsert contactListToUpsert; 
               }
          
          return validationReturn;
     }
     
     /**
     * Creates cartitem based on parameters passed
     * @param <Id> offeringId - course/program offering
     * @param <Id> newWebCartId - new cart created
     * @param <Id> pbeId - price book entry
     * @param <Boolean> prescribedProgram
     * @param <Id> prodId - product
     * @return CartItem
     */
     public static CartItem createCartItem(EnrolmentCreationParamClass enrolmentParam){

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
     public static WebCart createWebCart(Id userId, Id contactId){
          WebCart webCart = new WebCart();
          try{
               Id adminAcctId = [SELECT AccountId FROM Contact WHERE Id =: contactId LIMIT 1].AccountId;
               Id studyWebStoreId;
               List<WebStore> studyWebStoreList = [SELECT Id FROM WebStore WHERE Name = 'Study' LIMIT 1];
               for(WebStore webStore : studyWebStoreList){ studyWebStoreId = webStore.Id; }

               // DEPP-3152 close any carts already opened from OPE portal.
               List<WebCart> existingCart = [Select Id, Status FROM WebCart WHERE Status='Active' and OwnerId = : userId LIMIT 1];
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
               System.debug(e.getMessage());
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
     public static Id createUser(Contact newContact){
          Id response;

          List<User> users = [SELECT Id FROM User WHERE ContactId  =: newContact.Id AND IsActive = true LIMIT 1];

          if(users.size() > 0){
               for(User u : users){
                    response = u.Id;
               }
          }else{
               Profile profile = [SELECT Id FROM Profile WHERE Name = 'OPE Catalogue' LIMIT 1];
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

          return response;
     }


     public static List<hed__Course_Enrollment__c> createCourseConnectionList(EnrolmentCreationParamClass enrolmentParam){

          
          List<hed__Course_Enrollment__c> courseConnectionList = new List<hed__Course_Enrollment__c>();
          hed__Course_Enrollment__c newCourseConnection = new hed__Course_Enrollment__c();
          newCourseConnection.hed__Contact__c =  enrolmentParam.contactId;
          newCourseConnection.hed__Status__c = 'Active';
          newCourseConnection.Paid_in_Full__c = enrolmentParam.isTailored?'Contract':'Yes';
 
          if(enrolmentParam.amount == 0 && !enrolmentParam.isTailored){
               newCourseConnection.Payment_Method__c = 'No Charge';
          } else {
               newCourseConnection.Payment_Method__c = 'Admin Added';
          }
 
          newCourseConnection.Amount__c = enrolmentParam.amount;
          newCourseConnection.Cart_ID__c = enrolmentParam.newWebCartId;
          newCourseConnection.Cart_Item__c = enrolmentParam.newCartItemId;
          if(!enrolmentParam.prescribedProgram){
               newCourseConnection.hed__Course_Offering__c = enrolmentParam.offeringId;
               newCourseConnection.RecordTypeId = studentRecTypeId;
               courseConnectionList.add(newCourseConnection);
          }else{
               newCourseConnection.Program_Offering__c = enrolmentParam.offeringId;
               newCourseConnection.RecordTypeId = studentProgramRecTypeId;
               courseConnectionList.add(newCourseConnection);
               List<hed__Course_Offering__c> childOfferings = [SELECT Id FROM hed__Course_Offering__c WHERE Program_Offering__c =: enrolmentParam.offeringId];
               for(hed__Course_Offering__c childOffering : childOfferings){
                    hed__Course_Enrollment__c childCourseConnection = new hed__Course_Enrollment__c();
                    childCourseConnection.hed__Contact__c =  enrolmentParam.contactId;
                    childCourseConnection.hed__Status__c = 'Active';
                    childCourseConnection.Paid_in_Full__c = newCourseConnection.Paid_in_Full__c;
                    childCourseConnection.Payment_Method__c =  newCourseConnection.Payment_Method__c;
                    childCourseConnection.Amount__c = enrolmentParam.amount;
                    childCourseConnection.Program_Offering__c = enrolmentParam.offeringId;
                    childCourseConnection.hed__Course_Offering__c = childOffering.Id;
                    childCourseConnection.RecordTypeId = studentRecTypeId;
                    courseConnectionList.add(childCourseConnection);
               }
          }
          return courseConnectionList;
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
      * Generates Payment Gateway URL based on the provided parameters
      * @param list of course connections
      * @param boolean - tells the method if enrollment is CCE or OPE
      * @param string - student email where invoice is sent
      * @return String - URL Generated
      */
      public static String paymentGatewayURLBuilder(List<hed__Course_Enrollment__c> enrollmentList, Boolean isCCE, String studentEmail){

          Payment_Gateway_Settings__c paymentGatewaySettings = Payment_Gateway_Settings__c.getorgdefaults();
          CCE_Payment_Gateway_Settings__c paymentGatewaySettingsCCE = CCE_Payment_Gateway_Settings__c.getorgdefaults();

          String baseURL = '';
          String transactionId = '';
          String descriptionLabel = '';
          String tranType = '';
          String glCode = '';

          if(isCCE){
               baseURL = paymentGatewaySettingsCCE.Payment_URL__c;
               transactionId = '&CCETransactionID=';
               descriptionLabel = '&CCEDescription=';
               tranType = paymentGatewaySettingsCCE.TransType_Invoice__c;
               glCode = paymentGatewaySettingsCCE.GL_Code__c;
          }else{
               baseURL = paymentGatewaySettings.Payment_URL__c;
               transactionId ='&OPETransactionID=';
               descriptionLabel = '&OPEDescription=';
               tranType = paymentGatewaySettings.TransType_Invoice__c;
               glCode = paymentGatewaySettings.GL_Code__c;
          }

          String formURL =    'tran-type=' + tranType + 
                              transactionId + enrollmentList[0].Cart_ID__r.External_Id__c + '&' + 
                              'Email=' + studentEmail.replace('@','%40') + '&' + 
                              'GLCode=' + glCode + '&';

          String description = '';

          //construct the invoice URL
          //contact name, product name, price is looped
          for(hed__Course_Enrollment__c student: enrollmentList){
               description = description + 'FullName=' + student.Cart_Item__r.Contact__r.Name.replace(' ','%20');
               description = description + descriptionLabel + student.Cart_Item__r.Product2.Name.replace(' ','%20') + '&' + 'UnitAmountIncTax=';
               Decimal totalPrice = student.Cart_Item__r.TotalPrice != null?student.Cart_Item__r.TotalPrice:0;
               Decimal promotionPrice = student.Cart_Item__r.Promotion_Price__c != null?student.Cart_Item__r.Promotion_Price__c:0;
               Decimal tempPrice = totalPrice - promotionPrice;
               description = description + tempPrice + '&';
               
          }
          
          return baseURL + formURL + description.removeEnd('&');
     }

     /**
      * @description Wrapper class that holds the file uploaded by user
      */
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

     public class EnrolmentResultClass{
          @AuraEnabled
          public Boolean isContactInputValid;
          @AuraEnabled
          public String contactId;
          @AuraEnabled
          public String paymentURL;
          @AuraEnabled
          public String contactName;
          @AuraEnabled
          public String contactValidationResponse;
     }


     public class EnrolmentCreationParamClass{
          @AuraEnabled
          public Id contactId;
          @AuraEnabled
          public Id offeringId;
          @AuraEnabled
          public Decimal amount;
          @AuraEnabled
          public Id newWebCartId;
          @AuraEnabled
          public Id newCartItemId;
          @AuraEnabled
          public Product2 product;
          @AuraEnabled
          public Id cartDeliveryGroupId;
          @AuraEnabled
          public Boolean prescribedProgram;
          @AuraEnabled
          public Boolean isTailored;
          @AuraEnabled
          public PricebookEntry priceBookEntry;
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