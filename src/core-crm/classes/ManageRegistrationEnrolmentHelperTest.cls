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

public class ManageRegistrationEnrolmentHelperTest {

     private static string studentRT = System.Label.RT_CourseConnection_Student;
     private static Id studentRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get(studentRT).getRecordTypeId();
     private static string studentProgramRT = System.Label.RT_CourseConnection_Student_Program;
     private static Id studentProgramRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get(studentProgramRT).getRecordTypeId();

     
     /**
     * Creates cartitem based on parameters passed
     * @param <Id> offeringId - course/program offering
     * @param <Id> newWebCartId - new cart created
     * @param <Id> pbeId - price book entry
     * @param <Boolean> prescribedProgram
     * @param <Id> prodId - product
     * @return CartItem
     */
     public static CartItem createCartItem(Id offeringId, Id newWebCartId, PricebookEntry pbe, Boolean prescribedProgram, Id prodId, Id cartDeliveryGroupId){
          String prodName = [SELECT Id, Name FROM Product2 WHERE Id =: prodId LIMIT 1].Name;

          CartItem cartItem = new CartItem();
          cartItem.CartId = newWebCartId;
          cartItem.Name = prodName;
          cartItem.CartDeliveryGroupId = cartDeliveryGroupId;
          if(!prescribedProgram){
               cartItem.Course_Offering__c = offeringId;
          }else{
               cartItem.Program_Offering__c = offeringId;
          }
          cartItem.Product2Id = pbe.Product2Id;
          cartItem.Pricebook_Entry_ID__c = pbe.Id;
          cartItem.Quantity = 1;
          cartItem.TotalPrice = pbe.UnitPrice;
          cartItem.Type = 'Product';
          return cartItem;
     }

     /**
     * Creates commerce user based on contact details
     * @param <Id> userId
     * @return WebCart
     */
     public WebCart createWebCart(Id userId, Id contactId){
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
     public static Id createUser(String contactRecEmail, String contactRecLname, String contactRecFname, Id contactId){
          Id response;

          List<User> users = [SELECT Id FROM User WHERE ContactId  =: contactId AND IsActive = true LIMIT 1];

          if(users.size() > 0){
               for(User u : users){
                    response = u.Id;
               }
          }else{
               Profile profile = [SELECT Id FROM Profile WHERE Name = 'OPE Catalogue' LIMIT 1];
               User commerceUser = new User();
               commerceUser.Username = contactRecEmail;
               commerceUser.Email = contactRecEmail;
               commerceUser.LastName = contactRecLname;
               commerceUser.FirstName = contactRecFname;
               commerceUser.ContactId = contactId;
               commerceUser.alias = contactRecFname.substring(0, 1) + contactRecLname.substring(0, 2);
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


     public static List<hed__Course_Enrollment__c> createCourseConnectionList(Id contactId, Id offeringId, Decimal amount, Id newWebCartId, Id newCartItemId, Boolean prescribedProgram, Boolean isTailored){
          List<hed__Course_Enrollment__c> courseConnectionList = new List<hed__Course_Enrollment__c>();
          hed__Course_Enrollment__c newCourseConnection = new hed__Course_Enrollment__c();
          newCourseConnection.hed__Contact__c =  contactId;
          newCourseConnection.hed__Status__c = 'Active';
          newCourseConnection.Paid_in_Full__c = isTailored?'Contract':'Yes';
 
          if(amount == 0 && !isTailored){
               newCourseConnection.Payment_Method__c = 'No Charge';
          } else {
               newCourseConnection.Payment_Method__c = 'Admin Added';
          }
 
          newCourseConnection.Amount__c = amount;
          newCourseConnection.Cart_ID__c = newWebCartId;
          newCourseConnection.Cart_Item__c = newCartItemId;
          if(!prescribedProgram){
               newCourseConnection.hed__Course_Offering__c = offeringId;
               newCourseConnection.RecordTypeId = studentRecTypeId;
               courseConnectionList.add(newCourseConnection);
          }else{
               newCourseConnection.Program_Offering__c = offeringId;
               newCourseConnection.RecordTypeId = studentProgramRecTypeId;
               courseConnectionList.add(newCourseConnection);
               List<hed__Course_Offering__c> childOfferings = [SELECT Id FROM hed__Course_Offering__c WHERE Program_Offering__c =: offeringId];
               for(hed__Course_Offering__c childOffering : childOfferings){
                    hed__Course_Enrollment__c childCourseConnection = new hed__Course_Enrollment__c();
                    childCourseConnection.hed__Contact__c =  contactId;
                    childCourseConnection.hed__Status__c = 'Active';
                    childCourseConnection.Paid_in_Full__c = newCourseConnection.Paid_in_Full__c;
                    childCourseConnection.Payment_Method__c =  newCourseConnection.Payment_Method__c;
                    childCourseConnection.Amount__c = amount;
                    childCourseConnection.Program_Offering__c = offeringId;
                    childCourseConnection.hed__Course_Offering__c = childOffering.Id;
                    childCourseConnection.RecordTypeId = studentRecTypeId;
                    courseConnectionList.add(childCourseConnection);
               }
          }
          return courseConnectionList;
     }

}