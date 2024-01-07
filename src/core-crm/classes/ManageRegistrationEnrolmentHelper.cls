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

public without sharing class ManageRegistrationEnrolmentHelper{
     
     private static string studentRT = System.Label.RT_CourseConnection_Student;
     private static final string  DEDUP_PERSONAL_MISMATCH = System.Label.Dedup_Mismatch_Personal_CRM_Error;
     
     private static Id studentRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get(studentRT).getRecordTypeId();
     private static string studentProgramRT = System.Label.RT_CourseConnection_Student_Program;
     private static Id studentProgramRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get(studentProgramRT).getRecordTypeId();

     
     private static final String TAILORED_EXECUTIVE_PROGRAM = 'Tailored Executive Program';

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
              finalContactRecord.Id = validationReturn.contactId;
              parsedRegistrationData.contactRecord.Id = validationReturn.contactId;

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
              finalContactRecord.Id = con.Id;

              if(Schema.sObjectType.Contact.isUpdateable()){
                    update contactRecord;
               }

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

              enrolmentResult.contactId =  finalContactRecord.Id;
               
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

                   enrolmentParam.contactId = finalContactRecord.Id;
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
                         validationReturn.contactValidationResponse =  DEDUP_PERSONAL_MISMATCH + ' ' + String.join(contactValidated.fieldsMismatch, ', ');
                    }else{
                         validationReturn.isContactInputValid = true;
                         validationReturn.contactValidationResponse =  '';
                         contactListToUpsert.addAll(contactList);
                    }
               }  
               if(contactListToUpsert.size() > 0 && Schema.sObjectType.Contact.isUpdateable()){
                    ContactsDAO.newInstance().upsertRecords(contactListToUpsert, false, AccessLevel.SYSTEM_MODE);
                    validationReturn.contactId = contactListToUpsert[0].Id;
               }
          
          return validationReturn;
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

     if(Schema.sObjectType.Contact.isCreateable()){
          CourseConnectionsDAO.newInstance().insertRecords(courseConnectionList, false, AccessLevel.SYSTEM_MODE);
      }
     
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