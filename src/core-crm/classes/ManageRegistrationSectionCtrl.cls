/**
 * @description Controller Class for manageRegistrationSection LWC
 * @see ../lwc/manageRegistrationSection
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | eccarius.karl.munoz       | February 09, 2022     | DEPP-1482            | Created file                 |
      | eccarius.karl.munoz       | February 28, 2022     | DEPP-1819            | Removed handling for Program |
      |                           |                       |                      | Plan due to program offering |
      |                           |                       |                      | id removal.                  |
      |                           |                       |                      |                              |
      | john.bo.a.pineda          | March 10, 2022        | DEPP-1463            | Modified code to include     |
      |                           |                       |                      | additional fields for        |
      |                           |                       |                      | Export Learners List and     |
      |                           |                       |                      | Query to filter only         |
      |                           |                       |                      | Registration Questions       |
      | roy.nino.s.regala         | March 25, 2022        | DEPP-1539            | Add registration             |
      | eccarius.karl.munoz       | April 19, 2022        | DEPP-2157            | 1.) Added Selected Pricing   |
      |                           |                       |                      | and Pricing Validation in    |
      |                           |                       |                      | the table column.            |
      |                           |                       |                      | 2.) Updated handling for     |
      |                           |                       |                      | Edit row action to include   |
      |                           |                       |                      | Pricing Validation update.   |
      |                           |                       |                      |                              |
      | eccarius.karl.munoz       | May 03, 2022          | DEPP-2314            | Added handling for Program   |
      |                           |                       |                      | Presribed                    |
      |                           |                       |                      |                              |
      | eccarius.karl.munoz       | June 09, 2022         | DEPP-1919,2641,2921  | 1.) Modified addRegistration |
      |                           |                       |                      | to include cart and cart     |
      |                           |                       |                      | item creation.               |
      |                           |                       |                      | 2.) Added Pricing on AddReg  |
      |                           |                       |                      | 3.) Added Payment Gateway    |
      |                           |                       |                      | URL Builder                  |
      |                           |                       |                      |                              |
      | roy.nino.s.regala         | June 27, 2022         | DEPP-3252            |remove courseconnection insert|
      | keno.domienri.dico        | June 27, 2022         | DEPP-3287            | Added logic for new button in|
      |                           |                       |                      | Manage Registration backed   |
*/
public without sharing class ManageRegistrationSectionCtrl {

     private static string studentRT = System.Label.RT_CourseConnection_Student;
     private static Id studentRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get(studentRT).getRecordTypeId();
     private static string studentProgramRT = System.Label.RT_CourseConnection_Student_Program;
     private static Id studentProgramRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get(studentProgramRT).getRecordTypeId();

     /**
      * @description Retrieves list of related answers
      * @param prodReqId - Record ID from record page
      * @return List of Related_Answer__c
      */
     @AuraEnabled(cacheable=true)  
     public static List<Related_Answer__c> getQuestions(String productReqId){
          List<Related_Answer__c> relatedAnswersList = new List<Related_Answer__c>(
               [
                    SELECT Id, Question__r.Type__c, Question__r.Label__c, Sequence__c, 
                    Questionnaire__r.Parent_Record_ID__c, Question__r.Acceptable_Response__c, 
                    Question__r.Message__c, Questionnaire__r.Questionnaire_Type__c,
                    Question__r.Dropdown_Options__c
                    FROM Related_Answer__c
                    WHERE Questionnaire__r.Parent_Record_ID__c =: productReqId
                    AND (Questionnaire__r.Questionnaire_Type__c = 'Registration Questions' 
                    OR Questionnaire__r.Questionnaire_Type__c = 'Registration Criteria')
                    ORDER BY Questionnaire__r.Questionnaire_Type__c, Sequence__c 
               ]
          );
          return relatedAnswersList;
     }

     /**
      * @description Retrieves list of Registration details of students for Non Program Plan
      * @param childRecordId - Record ID of course offering
      * @return List of ManageRegistrationDetails
      */
     @AuraEnabled(cacheable=true)
     public static List<ManageRegistrationDetails> getRegistrations(String childRecordId, Boolean prescribedProgram){
          List<ManageRegistrationDetails> response = new List<ManageRegistrationDetails>();
          Map<Id,Questionnaire_Response_Summary__c> contactToQRSummary = new Map<Id,Questionnaire_Response_Summary__c>();
          //Id courseOfferingId = [SELECT Id FROM hed__Course_Offering__c WHERE Id =: childRecordId]?.Id;
          if(childRecordId == null){
               return new List<ManageRegistrationDetails>();
          }
          List<Questionnaire_Response_Summary__c> questionnaireResponseList = [
               SELECT Id, Name, Contact__c, Course_Offering__c, Questionnaire__c, Questionnaire__r.Questionnaire_Type__c, Registration_Status__c
                 FROM Questionnaire_Response_Summary__c
                WHERE Questionnaire__r.Questionnaire_Type__c = 'Registration Questions' AND (Course_Offering__c =: childRecordId OR Program_Offering__c  =: childRecordId)
          ];

          for(Questionnaire_Response_Summary__c qResSummary: questionnaireResponseList){
               contactToQRSummary.put(qResSummary.Contact__c, qResSummary);
          }

          List<hed__Course_Enrollment__c > courseConnections = [
               SELECT Id, Name, hed__Contact__c, hed__Contact__r.Id, hed__Contact__r.Name, Pricing_Validation__c, hed__Course_Offering__c, Cart_ID__r.External_Id__c, Cart_ID__r.Amount_Paid__c,
                    Cart_ID__r.TotalAmount, Paid_in_Full__c, hed__Status__c, LMS_Integration_Status__c, hed__Contact__r.FirstName, hed__Contact__r.LastName,
                    hed__Contact__r.Birthdate, hed__Contact__r.Email, Payment_Method__c, Cart_Item__r.Pricebook_Entry_ID__c, Is_Group_Registered__c
                 FROM hed__Course_Enrollment__c
                WHERE 
                    RecordTypeId IN (:studentRecTypeId, :studentProgramRecTypeId) 
                    AND (hed__Course_Offering__c =: childRecordId OR (Program_Offering__c  =: childRecordId AND hed__Course_Offering__c = null ))
          ];
          
          Map<String, PricebookEntry> pbeList = new Map<String, PricebookEntry>();
          
          Product2 product = getProduct(childRecordId, prescribedProgram);
          List<Map<String,String>> pBEntries = new List<Map<String,String>>();
          List<PricebookEntry> priceBookEntries = [SELECT Id, UnitPrice, Pricebook2.Name FROM PricebookEntry WHERE Product2Id =: product.Id ORDER BY CreatedDate];
          for(PricebookEntry p : priceBookEntries){   
               pbeList.put(p.Id, p);
          }

          Map<Id, PricebookEntry> studentWithPricingMap = new Map<Id, PricebookEntry>();
          for(hed__Course_Enrollment__c student : courseConnections){
               if(pbeList.containsKey(student.Cart_Item__r.Pricebook_Entry_ID__c)){
                    studentWithPricingMap.put(student.hed__Contact__r.Id, pbeList.get(student.Cart_Item__r.Pricebook_Entry_ID__c));
               }
          }    

          Decimal amount;
          for(hed__Course_Enrollment__c student : courseConnections){
               ManageRegistrationDetails regDetails = new ManageRegistrationDetails();
               regDetails.id = student.Id;
               regDetails.contactId = student.hed__Contact__c;
               regDetails.contactFullName = student.hed__Contact__r.Name;
               regDetails.paidInFull = student.Paid_in_Full__c;
               regDetails.lmsIntegrationStatus = student.LMS_Integration_Status__c;
               regDetails.contactFirstName = student.hed__Contact__r.FirstName;
               regDetails.contactLastName = student.hed__Contact__r.LastName;
               regDetails.contactBirthdate = student.hed__Contact__r.Birthdate;
               regDetails.contactEmail = student.hed__Contact__r.Email;
               regDetails.paymentMethod = student.Payment_Method__c;
               regDetails.isGroupRegistered = student.Is_Group_Registered__c;   
               regDetails.registrationStatus = student.hed__Status__c;
               if(studentWithPricingMap.containsKey(student.hed__Contact__c)){
                    regDetails.selectedPricing = studentWithPricingMap.get(student.hed__Contact__c).Pricebook2.Name;
                    amount = studentWithPricingMap.get(student.hed__Contact__c).UnitPrice;
               }                               
               regDetails.pricingValidation = student.Pricing_Validation__c;
               if(contactToQRSummary.containsKey(student.hed__Contact__c)){
                    regDetails.questionId = contactToQRSummary.get(student.hed__Contact__c).Id;
                    if(contactToQRSummary.get(student.hed__Contact__c).Questionnaire__c != NULL && contactToQRSummary.get(student.hed__Contact__c).Questionnaire__r.Questionnaire_Type__c == 'Registration Questions'){
                         regDetails.applicationURL = '/' +  contactToQRSummary.get(student.hed__Contact__c).Id;
                         regDetails.applicationName =  contactToQRSummary.get(student.hed__Contact__c).Name;
                    }
               }
               if((student.Paid_in_Full__c == 'No' && student.Payment_Method__c == 'Invoice' && student.Is_Group_Registered__c) || (student.Paid_in_Full__c == 'No' && student.Payment_Method__c == 'Invoice')){
                    regDetails.regenerateInvoiceURL = paymentGatewayURLBuilder(
                         student.Cart_ID__r.External_Id__c, 
                         student.hed__Contact__r.Email,
                         student.hed__Contact__r.Name,
                         student.Cart_ID__r.TotalAmount,
                         product.Name

                    );
               }
               response.add(regDetails);
          }

          return response;
     }

     //must used custom settings for the other hard coded query params
     /**
      * Generates Payment Gateway URL based on the provided parameters
      * @param <String> cartExternalId
      * @param <String> email
      * @param <String> name
      * @param <Decimal> amount
      * @return String - URL Generated
      */
     private static String paymentGatewayURLBuilder(String cartExternalId, String email, String name, Decimal amount, String productName){

          Payment_Gateway_Settings__c paymentGatewaySettings = Payment_Gateway_Settings__c.getorgdefaults();

          return paymentGatewaySettings.Payment_URL__c +
               'tran-type=' + paymentGatewaySettings.TransType_Invoice__c +
               '&OPETransactionID=' + cartExternalId +
               '&OPEDescription=' + productName +
               '&Email=' + email +
               '&FullName=' + name +
               '&GLCode=' + paymentGatewaySettings.GL_Code__c +
               '&UnitAmountIncTax=' + String.valueOf(amount);
     }

     /**
      * @description Updates Registration details of students
      * @param id - id of student selected
      * @param questionId - question id of student selected
      * @param registrationStatus - registration status of student selected
      * @param paidInFull - paid in full field of student selected
      * @param pricingValidation - pricing validation field of student selected
      * @return String
      */
     @AuraEnabled
     public static String updateRegistration(String id, String questionId, String registrationStatus, String paidInFull, String pricingValidation, String programOfferingId, String contactId){
          List<hed__Course_Enrollment__c> studentsToUpdate = new List<hed__Course_Enrollment__c>();
          hed__Course_Enrollment__c studentFromParentOffering = new hed__Course_Enrollment__c();
          studentFromParentOffering.Id = id;
          studentFromParentOffering.Paid_in_Full__c = paidInFull;
          studentFromParentOffering.Pricing_Validation__c = pricingValidation;
          studentFromParentOffering.hed__Status__c = registrationStatus;
          studentsToUpdate.add(studentFromParentOffering);

          if(programOfferingId != ''){
               List<hed__Course_Enrollment__c> students = [SELECT Id, Paid_in_Full__c, Pricing_Validation__c FROM hed__Course_Enrollment__c WHERE hed__Course_Offering__c != NULL AND Program_Offering__c =: programOfferingId AND hed__Contact__c =: contactId];
               for(hed__Course_Enrollment__c student : students){
                    hed__Course_Enrollment__c learner = new hed__Course_Enrollment__c();
                    learner.Id = student.id;
                    learner.Paid_in_Full__c = paidInFull;
                    learner.Pricing_Validation__c = pricingValidation;
                    learner.hed__Status__c = registrationStatus;
                    studentsToUpdate.add(learner);                 
               }
          }                 

          Questionnaire_Response_Summary__c questionnaire = new Questionnaire_Response_Summary__c();
          questionnaire.Id = questionId;
          try {
               if(studentsToUpdate.size() > 0){
                    update studentsToUpdate;
               }
               if(questionnaire.Id !=null){
                    update questionnaire;
               }
               return 'Success';
          }
          catch (Exception e) {
               return 'The following exception has occurred: ' + e.getMessage();
          }
     }

     /**
      *  @description Retrieves list of picklist values for paid in full field
      *  @return List<String>
      */
     @AuraEnabled(cacheable=true)
     public static List<String> getPaidInFullValues(){
          List<String> response = new List<String>();
          String strObjectName = 'hed__Course_Enrollment__c';
          String strPicklistField = 'Paid_in_Full__c';
          Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(strObjectName);
          Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
          Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
          List<Schema.PicklistEntry> lstPickListValues = mapFields.get(strPicklistField).getDescribe().getPickListValues();
          for (Schema.PicklistEntry objPickList : lstPickListValues) {
               String val = objPickList.getValue();
               response.add(val);
          }
          return response;
     }

     /**
      *  @description Retrieves list of picklist values for registration status field
      *  @return List<String>
      */
     @AuraEnabled(cacheable=true)
     public static List<String> getRegistrationStatusValues(){
          List<String> response = new List<String>();
          String strObjectName = 'hed__Course_Enrollment__c';
          String strPicklistField = 'hed__Status__c';
          Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(strObjectName);
          Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
          Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
          List<Schema.PicklistEntry> lstPickListValues = mapFields.get(strPicklistField).getDescribe().getPickListValues();
          for (Schema.PicklistEntry objPickList : lstPickListValues) {
               String val = objPickList.getValue();
               response.add(val);
          }
          return response;
     }

     /**
      *  @description Retrieves list of picklist values for pricing validation field
      *  @return List<String>
      */
     @AuraEnabled(cacheable=true)
     public static List<String> getPricingValidationValues(){
          List<String> response = new List<String>();
          String strObjectName = 'hed__Course_Enrollment__c';
          String strPicklistField = 'Pricing_Validation__c';
          Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(strObjectName);
          Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
          Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
          List<Schema.PicklistEntry> lstPickListValues = mapFields.get(strPicklistField).getDescribe().getPickListValues();
          for (Schema.PicklistEntry objPickList : lstPickListValues) {
               String val = objPickList.getValue();
               response.add(val);
          }
          return response;
     }

     /**
      * @Retrieves list of Price Book Entries from Product Management tab
      * @param childRecordId - offering Id
      * @return List<Map<String,String>> - id and price book name
      */
     @AuraEnabled(cacheable=true)  
     public static List<Map<String,String>> getPBEntries(String childRecordId, Boolean prescribedProgram){
          Product2 product = getProduct(childRecordId, prescribedProgram);
          List<Map<String,String>> pBEntries = new List<Map<String,String>>();
          List<PricebookEntry> priceBookEntries = [SELECT Id, Pricebook2.Name FROM PricebookEntry WHERE Product2Id =: product.Id ORDER BY CreatedDate];
          for(PricebookEntry pe : priceBookEntries){
               pBEntries.add(new Map<String,String>{
                    'id' => pe.Id,
                    'label' => pe.Pricebook2.Name
               });
          }
          return pBEntries;
     }

     /**
     * @description get list of contacts searched 
     * @param filterString - search string for filter
     * @param filterContacts - list of contact ids
     * @return list of map of formatted contacts for customSearch
     */
    @AuraEnabled(cacheable=true)
    public static List<Map<String,String>> getSearchedContacts(String filterString, List<Id> filterContacts){
        filterString = '%' + filterString + '%';
        List<Map<String,String>> contactMap = new List<Map<String,String>>();
        
        for(Contact con : [
            SELECT Id, Name, Email
            FROM Contact
            WHERE (
                Name LIKE :filterString OR
                Name = :filterString 
            ) AND Id NOT IN:filterContacts 
            LIMIT 15
        ]){
          contactMap.add(new Map<String,String>{
                'id' => con.Id,
                'label' => con.Name,
                'meta' => con.Email
            });
        }
        return contactMap;
    }  

     /**
     * @description get list of contacts searched 
     * @param contactRecord - contact to create
     * @param courseOfferingId - course offering id
     * @param relatedAnswerList - related answer records
     * @param answerList - answer records to be inserted
     * @param fileUpload - file to upload
     */
     @AuraEnabled
     public static String addRegistration(Contact contactRecord, String offeringId, List<Related_Answer__c> relatedAnswerList, List<Answer__c> answerList, String fileUpload, Boolean prescribedProgram, Id priceBookEntryId){
          List<FileUpload> parsedFileUpload = new List<FileUpload>();
          if(fileUpload != ''){
               parsedFileUpload = (List<FileUpload>) JSON.deserialize(fileUpload, List<FileUpload>.class);
          }

          List<Questionnaire_Response_Summary__c> questionnaireSummaryToInsert = new List<Questionnaire_Response_Summary__c>();
          Map<String,String> cvToRelatedAnswerMap = new Map<String,String>();
          List<ContentDocumentLink> contentDocLinkListToInsert = new List<ContentDocumentLink>();
          List<ContentVersion> cvListToInsertList = new List<ContentVersion>();
          Map<Id,Id> relatedAnswerToQuestionnaireMap = new Map<Id,Id>();
          Map<Id,Id> questionnaireToqResSummaryMap = new Map<Id,Id>();
          Map<Id,Id> relatedAnswerToAnswerMap = new Map<Id,Id>();
          Set<Id> questionnaireIds = new Set<Id>();

          List<Answer__c> answersToInsert = new List<Answer__c>();
          Map<Id,Answer__c> answersToUpdate = new Map<Id,Answer__c>();

          String contactRecName;
          String contactRecEmail;
          String contactRecFname;
          String contactRecLname;
          
          if(contactRecord.Id == NULL){
               contactRecName = contactRecord.FirstName + ' ' + contactRecord.LastName;
               contactRecEmail = contactRecord.Email;
               contactRecFname = contactRecord.FirstName;
               contactRecLname = contactRecord.LastName;
               insert contactRecord;
          }else{
               Contact con = [SELECT Id, Name, Email, FirstName, LastName FROM Contact WHERE Id =: contactRecord.Id LIMIT 1];
               contactRecName = con.Name;
               contactRecEmail = con.Email;
               contactRecFname = con.FirstName;
               contactRecLname = con.LastName;
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
          }

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
          }

          List<ContentVersion> newContentVersionList = new List<ContentVersion>(
               [
                    SELECT ContentDocumentId, Title
                    FROM ContentVersion 
                    WHERE Id IN:cvListToInsertList
               ]
          );

          if(!newContentVersionList.isEmpty()){
               ContentDocumentLink cdl;
               Answer__c updateAnswer;
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
          }

          if(!contentDocLinkListToInsert.isEmpty()){
               insert contentDocLinkListToInsert;
          }

          if(!answersToUpdate.keySet().isEmpty()){
               update answersToUpdate.values();
          }

          Id commerceUser = createUser(contactRecEmail, contactRecLname, contactRecFname, contactRecord.Id);           
          WebCart newWebCart = createWebCart(commerceUser);
          insert newWebCart;

          Product2 product = getProduct(offeringId, prescribedProgram);
          PricebookEntry pbe = new PricebookEntry();
          Decimal amount;
          List<PricebookEntry> pbList = [SELECT Id, UnitPrice, Product2Id FROM PricebookEntry WHERE Id =: priceBookEntryId LIMIT 1];
          for(PricebookEntry pb : pbList){
               pbe = pb;
               amount = pb.UnitPrice;
          }

          CartItem newCartItem = createCartItem(offeringId, newWebCart.Id, pbe, prescribedProgram, product.Id);
          newCartItem.Contact__c = contactRecord.Id;
          insert newCartItem;

          Cart_Payment__c cartPayment = new Cart_Payment__c(Status__c = 'Invoiced');
          insert cartPayment;

          String externalId;
          List<WebCart> carts = [SELECT External_Id__c FROM WebCart WHERE OwnerId =: commerceUser LIMIT 1]; 
          for(WebCart webCart : carts){ externalId = webCart.External_Id__c; }

          String paymentURL = paymentGatewayURLBuilder(externalId, contactRecEmail, contactRecName, amount, product.Name);
          
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

          /*
          List<hed__Course_Enrollment__c> courseConnectionList = new List<hed__Course_Enrollment__c>();
          hed__Course_Enrollment__c newCourseConnection = new hed__Course_Enrollment__c();          
          newCourseConnection.hed__Contact__c =  contactRecord.Id;          
          newCourseConnection.hed__Status__c = 'Active';
          newCourseConnection.Paid_in_Full__c = 'No';
          newCourseConnection.Payment_Method__c = 'Invoice';
          newCourseConnection.Amount__c = amount;
          newCourseConnection.Cart_ID__c = newWebCart.Id;
          newCourseConnection.Cart_Item__c = newCartItem.Id;
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
                    childCourseConnection.hed__Contact__c =  contactRecord.Id;          
                    childCourseConnection.hed__Status__c = 'Active';
                    childCourseConnection.Paid_in_Full__c = 'No';
                    childCourseConnection.Payment_Method__c = 'Invoice';
                    childCourseConnection.Amount__c = amount;
                    childCourseConnection.Program_Offering__c = offeringId;
                    childCourseConnection.hed__Course_Offering__c = childOffering.Id;
                    childCourseConnection.RecordTypeId = studentRecTypeId;
                    courseConnectionList.add(childCourseConnection);
               }
          }
          
          insert courseConnectionList;*/

          return paymentURL;

     }  

     /**
     * @description get list of contacts searched if button clicked is Proceed without Invoice from manageRegistrationSection lwc 
     * @param contactRecord - contact to create
     * @param courseOfferingId - course offering id
     * @param relatedAnswerList - related answer records
     * @param answerList - answer records to be inserted
     * @param fileUpload - file to upload
     */
    @AuraEnabled
    public static void addRegistration2(Contact contactRecord, String offeringId, List<Related_Answer__c> relatedAnswerList, List<Answer__c> answerList, String fileUpload, Boolean prescribedProgram, Id priceBookEntryId, Boolean isProceedNoInvoice){
         List<FileUpload> parsedFileUpload = new List<FileUpload>();
         if(fileUpload != ''){
              parsedFileUpload = (List<FileUpload>) JSON.deserialize(fileUpload, List<FileUpload>.class);
         }

         List<Questionnaire_Response_Summary__c> questionnaireSummaryToInsert = new List<Questionnaire_Response_Summary__c>();
         Map<String,String> cvToRelatedAnswerMap = new Map<String,String>();
         List<ContentDocumentLink> contentDocLinkListToInsert = new List<ContentDocumentLink>();
         List<ContentVersion> cvListToInsertList = new List<ContentVersion>();
         Map<Id,Id> relatedAnswerToQuestionnaireMap = new Map<Id,Id>();
         Map<Id,Id> questionnaireToqResSummaryMap = new Map<Id,Id>();
         Map<Id,Id> relatedAnswerToAnswerMap = new Map<Id,Id>();
         Set<Id> questionnaireIds = new Set<Id>();

         List<Answer__c> answersToInsert = new List<Answer__c>();
         Map<Id,Answer__c> answersToUpdate = new Map<Id,Answer__c>();

         String contactRecName;
         String contactRecEmail;
         String contactRecFname;
         String contactRecLname;
         
         if(contactRecord.Id == NULL){
              contactRecName = contactRecord.FirstName + ' ' + contactRecord.LastName;
              contactRecEmail = contactRecord.Email;
              contactRecFname = contactRecord.FirstName;
              contactRecLname = contactRecord.LastName;
              insert contactRecord;
         }else{
              Contact con = [SELECT Id, Name, Email, FirstName, LastName FROM Contact WHERE Id =: contactRecord.Id LIMIT 1];
              contactRecName = con.Name;
              contactRecEmail = con.Email;
              contactRecFname = con.FirstName;
              contactRecLname = con.LastName;
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
         }

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
         }

         List<ContentVersion> newContentVersionList = new List<ContentVersion>(
              [
                   SELECT ContentDocumentId, Title
                   FROM ContentVersion 
                   WHERE Id IN:cvListToInsertList
              ]
         );

         if(!newContentVersionList.isEmpty()){
              ContentDocumentLink cdl;
              Answer__c updateAnswer;
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
         }

         if(!contentDocLinkListToInsert.isEmpty()){
              insert contentDocLinkListToInsert;
         }

         if(!answersToUpdate.keySet().isEmpty()){
              update answersToUpdate.values();
         }

     //     Id commerceUser = createUser(contactRecEmail, contactRecLname, contactRecFname, contactRecord.Id);           
     //     WebCart newWebCart = createWebCart(commerceUser);
     //     insert newWebCart;

         Product2 product = getProduct(offeringId, prescribedProgram);
         PricebookEntry pbe = new PricebookEntry();
         Decimal amount;
         List<PricebookEntry> pbList = [SELECT Id, UnitPrice, Product2Id FROM PricebookEntry WHERE Id =: priceBookEntryId LIMIT 1];
         for(PricebookEntry pb : pbList){
              pbe = pb;
              amount = pb.UnitPrice;
         }

     //     CartItem newCartItem = createCartItem(offeringId, newWebCart.Id, pbe, prescribedProgram, product.Id);
     //     insert newCartItem;

     //     Cart_Payment__c cartPayment = new Cart_Payment__c(Status__c = 'Invoiced');
     //     insert cartPayment;

     //     String externalId;
     //     List<WebCart> carts = [SELECT External_Id__c FROM WebCart WHERE OwnerId =: commerceUser LIMIT 1]; 
     //     for(WebCart webCart : carts){ externalId = webCart.External_Id__c; }

     //      String paymentURL = paymentGatewayURLBuilder(externalId, contactRecEmail, contactRecName, amount, product.Name);
         
     //     WebCart webCartToClose = new WebCart(
     //          Id = newWebCart.Id, 
     //          Status__c = 'Closed', 
     //          Status = 'Closed', 
     //          Cart_Payment__c = cartPayment.Id,
     //          Payment_URL__c = paymentURL
     //     );
     //     update webCartToClose;
         
         List<hed__Course_Enrollment__c> courseConnectionList = new List<hed__Course_Enrollment__c>();
         hed__Course_Enrollment__c newCourseConnection = new hed__Course_Enrollment__c();          
         newCourseConnection.hed__Contact__c =  contactRecord.Id;          
         newCourseConnection.hed__Status__c = 'Active';

         if(amount == 0){
          newCourseConnection.Paid_in_Full__c = 'Yes';
          newCourseConnection.Payment_Method__c = 'No Charge';
         } else {
          newCourseConnection.Paid_in_Full__c = 'Yes';
          newCourseConnection.Payment_Method__c = 'Admin Added';
         }
         
         newCourseConnection.Amount__c = amount;
     //     newCourseConnection.Cart_ID__c = newWebCart.Id;
     //     newCourseConnection.Cart_Item__c = newCartItem.Id;
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
                   childCourseConnection.hed__Contact__c =  contactRecord.Id;          
                   childCourseConnection.hed__Status__c = 'Active';

                   if(amount == 0){
                    childCourseConnection.Paid_in_Full__c = 'No';
                    childCourseConnection.Payment_Method__c = 'Invoice';
                   } else {
                    childCourseConnection.Paid_in_Full__c = 'No';
                    childCourseConnection.Payment_Method__c = 'Invoice';
                   }

                   
                   childCourseConnection.Amount__c = amount;
                   childCourseConnection.Program_Offering__c = offeringId;
                   childCourseConnection.hed__Course_Offering__c = childOffering.Id;
                   childCourseConnection.RecordTypeId = studentRecTypeId;
                   courseConnectionList.add(childCourseConnection);
              }
         }
         
         insert courseConnectionList;

     //     return paymentURL;

    }  

     /**
     * Creates commerce user based on contact details
     * @param <String> contactRecEmail
     * @param <String> contactRecLname
     * @param <String> contactRecFname
     * @param <Id> contactId
     * @return User
     */
     private static Id createUser(String contactRecEmail, String contactRecLname, String contactRecFname, Id contactId){
          Id response;
          String filter = contactRecEmail + '.ope';
          List<User> users = [SELECT Id FROM User WHERE ContactId  =: contactId OR Username =: filter LIMIT 1];

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

     /**
     * Creates commerce user based on contact details
     * @param <Id> userId
     * @return WebCart
     */
     private Static WebCart createWebCart(Id userId){
          Id opeCatalougeAccountId;
          List<Account> opeCatalougeAccounts = [SELECT Id FROM Account WHERE Name = 'OPE Catalogue' LIMIT 1];
          for(Account account : opeCatalougeAccounts){ opeCatalougeAccountId = account.Id; }

          Id studyWebStoreId;
          List<WebStore> studyWebStoreList = [SELECT Id FROM WebStore WHERE Name = 'Study' LIMIT 1];
          for(WebStore webStore : studyWebStoreList){ studyWebStoreId = webStore.Id; }

          // DEPP-3152 close any carts already opened from OPE portal.
          List<WebCart> existingCart = [Select Id, Status FROM WebCart WHERE Status='Active' and OwnerId = : userId LIMIT 1];
          if(existingCart.size()>0){
               existingCart[0].Status = 'Closed';
               update existingCart;
          }

          WebCart webCart = new WebCart();
          webCart.Name = 'Cart';
          webCart.AccountId = opeCatalougeAccountId;
          webCart.Status__c = 'Active';
          webCart.OwnerId = userId;
          webCart.WebStoreId = studyWebStoreId;
          return webCart;
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
     private Static CartItem createCartItem(Id offeringId, Id newWebCartId, PricebookEntry pbe, Boolean prescribedProgram, Id prodId){
          List<CartDeliveryGroup> cartDelGrpList = [SELECT Id FROM CartDeliveryGroup WHERE Name = 'Default Delivery' LIMIT 1];
          Id cartDelGrpId;
          for(CartDeliveryGroup cdg : cartDelGrpList) { cartDelGrpId = cdg.Id; }
          
          CartItem cartItem = new CartItem();
          cartItem.CartId = newWebCartId;
          cartItem.Name = 'Cart Item';
          cartItem.CartDeliveryGroupId = cartDelGrpId;
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
     * Retrieves Product based on offering id
     * @param <Id> offeringId
     * @return Id
     */
     private static Product2 getProduct(Id offeringId, Boolean isPrescribedProgram){
          Product2 response = new Product2();

          Id filter;
          Id prodId;

          List<Product2> productList = new List<Product2>();

          if(!isPrescribedProgram){
               List<hed__Course_Offering__c> courseOfferingList = [SELECT Id, hed__Course__c FROM hed__Course_Offering__c WHERE Id =: offeringId LIMIT 1];
               for(hed__Course_Offering__c courseOffering : courseOfferingList){
                    filter = courseOffering.hed__Course__c;
               }
               productList = [SELECT Id, Name FROM Product2 WHERE Course__c =: filter];
          }else{
               List<Program_Offering__c> programOfferingList = [SELECT Id, hed_Program_Plan__c  FROM Program_Offering__c WHERE Id =: offeringId LIMIT 1];
               for(Program_Offering__c programOffering : programOfferingList){
                    filter = programOffering.hed_Program_Plan__c;
               }
               productList = [SELECT Id, Name FROM Product2 WHERE Program_Plan__c  =: filter];
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
      * @description Wrapper class that holds data to be displayed
      */
     public class ManageRegistrationDetails{
          @AuraEnabled
          public String id;
          @AuraEnabled
          public String contactId;
          @AuraEnabled
          public String questionId;
          @AuraEnabled
          public String contactFullName;
          @AuraEnabled
          public String paidInFull;
          @AuraEnabled
          public String registrationStatus;
          @AuraEnabled
          public String lmsIntegrationStatus;
          @AuraEnabled
          public String contactFirstName;
          @AuraEnabled
          public String contactLastName;
          @AuraEnabled
          public Date contactBirthdate;
          @AuraEnabled
          public String contactEmail;
          @AuraEnabled
          public String paymentMethod;
          @AuraEnabled
          public String applicationName;
          @AuraEnabled
          public String applicationURL;
          @AuraEnabled
          public Boolean isGroupRegistered;
          @AuraEnabled
          public String pricingValidation;
          @AuraEnabled
          public String selectedPricing;
          @AuraEnabled
          public String regenerateInvoiceURL;
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