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

public with sharing class ManageRegistrationEnrolmentHelper{

     
     private static final String TAILORED_EXECUTIVE_PROGRAM = 'Tailored Executive Program';

     private static string studentRT = System.Label.RT_CourseConnection_Student;
     private static Id studentRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get(studentRT).getRecordTypeId();
     private static string studentProgramRT = System.Label.RT_CourseConnection_Student_Program;
     private static Id studentProgramRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get(studentProgramRT).getRecordTypeId();

     /**
     * @description enroll the contact
     * @param contactRecord - registrationData
     * @param fileUpload - file to upload
     */
    @AuraEnabled
    public static EnrolmentResultClass addRegistration(String registrationData, String fileUpload){
         
         EnrolmentResultClass enrolmentResult = new EnrolmentResultClass();
         EnrolmentResultClass validationReturn = new EnrolmentResultClass();
         EnrolmentResultClass enrollmentProcessingReturn = new EnrolmentResultClass();

         String contactRecName;
         Contact finalContactRecord = new Contact();
         enrolmentResult.isContactInputValid = true;
         
         //deserialize registration data in JSON format from lwc
         ManageRegistrationSectionHelper.RegistrationData parsedRegistrationData = new ManageRegistrationSectionHelper.RegistrationData();
         if(registrationData != ''){
              parsedRegistrationData = (ManageRegistrationSectionHelper.RegistrationData) JSON.deserialize(
                    registrationData, 
                    ManageRegistrationSectionHelper.RegistrationData.class
               );
         }

         //set registration data into separate readable variables
         Contact contactRecord = parsedRegistrationData.contactRecord; 
         String offeringId = parsedRegistrationData.offeringId;
         Boolean prescribedProgram = parsedRegistrationData.prescribedProgram;
         Id priceBookEntryId = parsedRegistrationData.priceBookEntryId;

         //if user is trying to create a new contact
         //validate new contact
         if(contactRecord.Id == NULL){
              contactRecName = contactRecord.FirstName + ' ' + contactRecord.LastName;
              finalContactRecord.Email = contactRecord.Email;
              finalContactRecord.FirstName = contactRecord.FirstName;
              finalContactRecord.LastName = contactRecord.LastName;
              contactRecord.Registered_Email__c = contactRecord.Email;

              List<Contact> contactList = new List<Contact>();
              contactList.add(contactRecord);
              //validate the contact records
              //contact is converted into a list because the reusable validation class is in bulk
              validationReturn = validatedContacts(contactList);

              enrolmentResult.isContactInputValid = validationReturn.isContactInputValid;
              enrolmentResult.contactValidationResponse = validationReturn.contactValidationResponse;
              
         }else{
              //get the contact's full name, first name, and lastname
              //store the contact details to string variable
              Contact con = [ SELECT Id, 
                              Name, 
                              Email, 
                              FirstName, 
                              LastName 
                              FROM Contact 
                              WHERE Id =: contactRecord.Id 
                              WITH SECURITY_ENFORCED 
                              LIMIT 1];

              contactRecName = con.Name;
              finalContactRecord.Email = contactRecord.Registered_Email__c;
              finalContactRecord.FirstName = con.FirstName;
              finalContactRecord.LastName = con.LastName;

              update contactRecord;
         }
         //process contact after validation
         if(enrolmentResult.isContactInputValid){
              //process questionnaire insertion
              ManageRegistrationSectionHelper.processQuestionnaireData(
                    parsedRegistrationData, 
                    fileUpload
               );

              //get product related to the offering
              Product2 product = ManageRegistrationSectionHelper.getProduct(
                    offeringId, 
                    prescribedProgram
               );

              //check product category
              Boolean isTailored = product != null && product.Product_Category__c == TAILORED_EXECUTIVE_PROGRAM?true:false;

              enrolmentResult.contactId = enrollmentProcessingReturn.contactId;
               
              if(!String.isBlank(priceBookEntryId)){

                   enrollmentProcessingReturn = ManageRegistrationSectionHelper.processEnrollmentWithPricing(
                         parsedRegistrationData, 
                         finalContactRecord, 
                         product
                    );
                   
                   enrolmentResult.paymentURL = enrollmentProcessingReturn.paymentURL;
                   enrolmentResult.contactName = enrollmentProcessingReturn.contactName;

              }else{
                   EnrolmentCreationParamClass enrolmentParam = new EnrolmentCreationParamClass();

                   enrolmentParam.contactId = contactRecord.Id;
                   enrolmentParam.offeringId = offeringId;
                   enrolmentParam.prescribedProgram = prescribedProgram;
                   enrolmentParam.isTailored = isTailored;
                   enrolmentParam.amount = null;
                   enrolmentParam.newWebCartId = null;
                   enrolmentParam.newCartItemId = null;

                   createCourseConnectionList(enrolmentParam);  
                   enrolmentResult.contactName = contactRecName;
              }  
                           
         }
         return enrolmentResult;
    }


    /**
     * @description validate the contact records
     * @param contactList - list of contacts need to be validated
     * @return EnrolmentResultClass - contains validation result and linked contact if match is found
     */
     private static EnrolmentResultClass validatedContacts(List<Contact> contactList){
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
     * @param enrolmentParam - wrapper class that contains needed data
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
               System.debug(LoggingLevel.WARN, 'ManageRegistrationEnrolmentHelper.createWebCart Error: ' + e.getMessage());//NOPMD
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

          List<User> users = [
               SELECT Id 
               FROM User 
               WHERE ContactId  =: newContact.Id 
               AND IsActive = true 
               LIMIT 1];

          if(users.size() > 0){
               for(User u : users){
                    response = u.Id;
               }
          }else{

               Profile profile = [
                    SELECT Id 
                    FROM Profile 
                    WHERE Name = 'OPE Catalogue' 
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

          return response;
     }


     /**
     * Creates commerce user based on contact details
     * @param enrolmentParam - wrapper class that contains the needed data for enrolment
     * @return hed__Course_Enrollment__c - newly created course connections
     */
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

               for(hed__Course_Offering__c childOffering : [SELECT Id FROM hed__Course_Offering__c WHERE Program_Offering__c =: enrolmentParam.offeringId WITH SECURITY_ENFORCED]){
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

          insert courseConnectionList;
          
          return courseConnectionList;
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

}