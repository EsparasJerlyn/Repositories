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
      | john.bo.a.pineda          | June 28, 2022         | DEPP-3314            | Uncommented code that sets   |
      |                           |                       |                      | the Selected Pricebook       |
      | julie.jane.alegre         | July 4, 2022          | DEPP-3389            | Remove Registration Criteria |
      |                           |                       |                      | on getQuestions method       |
      | john.m.tambasen           | July 29, 2022         | DEPP-3577            | PBE early bird               |
      | Tiffany.Zhang             | Aug 9, 2022           | DEPP-3486            | Manage Registration and      |
      |                           |                       |                      | Nomination table in          |
      |                           |                       |                      | CCE portal                   |
      | rhea.b.torres             | July 30, 2022         | DEPP-3594            | Add logic to not return email|
      |                           |                       |                      | options if Contact has       |
      |                           |                       |                      | Registered Email             |
      | john.m.tambasen           | August, 16 2022       | DEPP-1946            | Single/Group Coaching changes|
      | eccarius.karl.munoz       | August 29, 2022       | DEPP-3754            | Added dedup validation upon  |
      |                           |                       |                      | creation of contact          |
      | john.m.tambasen           | August, 22 2022       | DEPP-3325            | Added discount functionality |
      | kathy.cornejo             | September 08, 2022    | DEPP-4097            | Updated logic for searched   |
      |                           |                       |                      | contacts                     |
      | eccarius.karl.munoz       | September 13, 2022    | DEPP-3824            | Updated logic to use admin   |
      |                           |                       |                      | account for cart and user    |
      | john.m.tambasen           | Septemebr 21, 2022    | DEPP-4390            | Update QUTPay URL for CCE    |
      | roy.nino.s.regala         | November 11, 2022     | DEPP-4637            | Updated invoice url          |
*/

public without sharing class ManageRegistrationSectionCtrl {

     private static string studentRT = System.Label.RT_CourseConnection_Student;
     private static Id studentRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get(studentRT).getRecordTypeId();
     private static string studentProgramRT = System.Label.RT_CourseConnection_Student_Program;
     private static Id studentProgramRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get(studentProgramRT).getRecordTypeId();
     public static final String TAILORED_EXECUTIVE_PROGRAM = 'Tailored Executive Program';

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
                    AND Questionnaire__r.Questionnaire_Type__c = 'Registration Questions'
                    ORDER BY Questionnaire__r.Questionnaire_Type__c, Sequence__c
               ]
          );
          return relatedAnswersList;
     }

     /**
      * @description checks availability of offering for registration
      * @param offeringId - id of offering to be checked
      * @return boolean - return true if offerin is available for registration
      */
      @AuraEnabled
      public static boolean checkOfferingAvailability(String offeringId){

           List<Program_Offering__c> programOfferingList = new List<Program_Offering__c>([
               SELECT Id 
               FROM Program_Offering__c
               WHERE Available_Seats__c > 0
               AND Registration_End_Date__c > TODAY
               AND Id =: offeringId
           ]);

           List<hed__Course_Offering__c> courseOfferingList = new List<hed__Course_Offering__c>([
               SELECT Id 
               FROM hed__Course_Offering__c
               WHERE Available_Seats__c > 0
               AND Registration_End_Date__c > TODAY
               AND Id =: offeringId
           ]);

           if(programOfferingList.isEmpty() && courseOfferingList.isEmpty()){
               return false;
           }else{
               return true;
           }
      }

     /**
      * @description Retrieves list of Registration details of students for Non Program Plan
      * @param childRecordId - Record ID of course offering
      * @param prescribedProgram - checks if offering is a prescribed program
      * @return List of ManageRegistrationDetails
      */
     @AuraEnabled(cacheable=true)
     public static List<ManageRegistrationDetails> getRegistrations(String childRecordId, Boolean prescribedProgram){
          List<ManageRegistrationDetails> response = new List<ManageRegistrationDetails>();
          Map<Id,Questionnaire_Response_Summary__c> contactToQRSummary = new Map<Id,Questionnaire_Response_Summary__c>();
          PaymentUrlClass urlObj = new PaymentUrlClass();
          Map<Id,List<hed__Course_Enrollment__c>> relatedEnrollments = new Map<Id,List<hed__Course_Enrollment__c>>();

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
               SELECT Id, Name, hed__Contact__c, hed__Contact__r.Id, hed__Contact__r.Name, hed__Contact__r.Position__c, hed__Contact__r.hed__Primary_Organization__r.Name, 
                    hed__Contact__r.Dietary_Requirement__c, hed__Contact__r.Accessibility_Requirement__c, Pricing_Validation__c, hed__Course_Offering__c, Cart_ID__r.External_Id__c,
                    Cart_ID__r.TotalAmount, Paid_in_Full__c, hed__Status__c, LMS_Integration_Status__c, hed__Contact__r.FirstName, hed__Contact__r.LastName,
                    hed__Contact__r.Birthdate, Payment_Method__c, Cart_Item__r.Pricebook_Entry_ID__c, Is_Group_Registered__c, hed__Contact__r.Registered_Email__c,
                    CreatedDate, Paid_Amount__c, hed__Contact__r.QUT_Student_Id__c
                 FROM hed__Course_Enrollment__c
                WHERE
                    RecordTypeId IN (:studentRecTypeId, :studentProgramRecTypeId)
                    AND (hed__Course_Offering__c =: childRecordId OR (Program_Offering__c  =: childRecordId AND hed__Course_Offering__c = null ))
          ];

          Map<String, PricebookEntry> pbeList = new Map<String, PricebookEntry>();

          Product2 product = getProduct(childRecordId, prescribedProgram);
          List<PricebookEntry> priceBookEntries = [
               SELECT Id, UnitPrice, Pricebook2.Name 
               FROM PricebookEntry 
               WHERE Product2Id =: product.Id 
               ORDER BY CreatedDate
          ];
          
          for(PricebookEntry p : priceBookEntries){
               pbeList.put(p.Id, p);
          }

          Map<Id, PricebookEntry> studentWithPricingMap = new Map<Id, PricebookEntry>();
          for(hed__Course_Enrollment__c student : courseConnections){
               if(pbeList.containsKey(student.Cart_Item__r.Pricebook_Entry_ID__c)){
                    studentWithPricingMap.put(student.Id, pbeList.get(student.Cart_Item__r.Pricebook_Entry_ID__c));
               }
               
               //store all cart ids of the course enrollments as key of the map
               if(  !relatedEnrollments.containsKey(student.Cart_ID__c) && 
                    student.Cart_ID__c != null && 
                    student.hed__Status__c != 'Cancelled'){

                    relatedEnrollments.put(student.Cart_ID__c,new List<hed__Course_Enrollment__c>());
               }
          }

          //get all active related enrollments under the same cart of thecurrent offering's enrollments
          if(!relatedEnrollments.keySet().isEmpty()){
               for(hed__Course_Enrollment__c relatedStudent: [
                    SELECT Id, Name, 
                    hed__Contact__r.Name, 
                    hed__Contact__r.Registered_Email__c,
                    Cart_Item__r.Promotion_Price__c, 
                    Cart_Item__r.TotalPrice,
                    Cart_ID__r.External_Id__c, 
                    Cart_Item__r.Product2.Name,
                    Cart_Item__r.Contact__r.Name
                    FROM hed__Course_Enrollment__c
                    WHERE Cart_ID__c IN: relatedEnrollments.keySet()
                    AND hed__Status__c != 'Cancelled'
               ]){
                    //group all active enrollments by cart
                    relatedEnrollments.get(relatedStudent.Cart_ID__c).add(relatedStudent);
               }
          }

          Decimal amount = 0;
          Boolean isCCE = false;

          for(hed__Course_Enrollment__c student : courseConnections){
               ManageRegistrationDetails regDetails = new ManageRegistrationDetails();
               regDetails.id = student.Id;
               regDetails.contactId = student.hed__Contact__c;
               regDetails.contactFullName = student.hed__Contact__r.Name;
               regDetails.paidAmount = student.Paid_Amount__c;
               regDetails.registrationDate = student.CreatedDate;
               regDetails.studentId = student.hed__Contact__r.QUT_Student_Id__c;
               regDetails.paidInFull = student.Paid_in_Full__c;
               regDetails.lmsIntegrationStatus = student.LMS_Integration_Status__c;
               regDetails.contactFirstName = student.hed__Contact__r.FirstName;
               regDetails.contactLastName = student.hed__Contact__r.LastName;
               regDetails.contactBirthdate = student.hed__Contact__r.Birthdate;
               regDetails.contactEmail = student.hed__Contact__r.Registered_Email__c;
               regDetails.paymentMethod = student.Payment_Method__c;
               regDetails.isGroupRegistered = student.Is_Group_Registered__c;
               regDetails.registrationStatus = student.hed__Status__c;
               regDetails.position = student.hed__Contact__r.Position__c;
               regDetails.organisation = student.hed__Contact__r.hed__Primary_Organization__c != null?student.hed__Contact__r.hed__Primary_Organization__r.Name:'';
               regDetails.dietaryRequirement = student.hed__Contact__r.Dietary_Requirement__c;
               regDetails.accessibilityRequirement = student.hed__Contact__r.Accessibility_Requirement__c;
               if(studentWithPricingMap.containsKey(student.Id)){
                    regDetails.selectedPricing = studentWithPricingMap.get(student.Id).Pricebook2.Name;
                    amount = studentWithPricingMap.get(student.Id).UnitPrice;
               }
               regDetails.pricingValidation = student.Pricing_Validation__c;
               if(contactToQRSummary.containsKey(student.hed__Contact__c)){
                    regDetails.questionId = contactToQRSummary.get(student.hed__Contact__c).Id;
                    if(contactToQRSummary.get(student.hed__Contact__c).Questionnaire__c != NULL && contactToQRSummary.get(student.hed__Contact__c).Questionnaire__r.Questionnaire_Type__c == 'Registration Questions'){
                         regDetails.applicationURL = '/' +  contactToQRSummary.get(student.hed__Contact__c).Id;
                         regDetails.applicationName =  contactToQRSummary.get(student.hed__Contact__c).Name;
                    }
               }

               //checker if enrollment is CCE
               isCCE = regDetails.selectedPricing != null && regDetails.selectedPricing.startsWith('SOA')?true:false;

               //condition to 
               if(  student.Cart_ID__c != null && 
                    student.Paid_in_Full__c == 'No' && 
                    student.Payment_Method__c == 'Invoice' && 
                    student.hed__Contact__r.Registered_Email__c != null && 
                    student.hed__Status__c != 'Cancelled'){
                         
                    regDetails.regenerateInvoiceURL = paymentGatewayURLBuilder(
                         relatedEnrollments.get(student.Cart_Id__c), 
                         isCCE, 
                         student.hed__Contact__r.Registered_Email__c
                    );
               }
               response.add(regDetails);
          }

          return response;
     }

     //must used custom settings for the other hard coded query params
     /**
      * Generates Payment Gateway URL based on the provided parameters
      * @param list of course connections
      * @param boolean - tells the method if enrollment is CCE or OPE
      * @param string - student email where invoice is sent
      * @return String - URL Generated
      */
      private static String paymentGatewayURLBuilder(List<hed__Course_Enrollment__c> enrollmentList, Boolean isCCE, String studentEmail){

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

     //must used custom settings for the other hard coded query params
     /**
      * Generates Payment Gateway URL based on the provided parameters
      * @param PaymentUrlClass contains paymenturl required details
      * @return String - URL Generated
      */
     private static String paymentGatewayURLBuilder(PaymentUrlClass urlObj){

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
          List<Program_Offering__c> programOfferingList = new List<Program_Offering__c>();
          List<hed__Course_Offering__c> courseOfferingList = new List<hed__Course_Offering__c>();
          List<String> parentProductRequestIds = new List<String>();

          Date startDate;

          //get the offering start date to be checked with early bird no of days
          //if prescribed program
          if(prescribedProgram){
               //get start date value in Program_Offering__c
               // Program_Offering__c programOffering = [SELECT Id, Start_Date__c FROM Program_Offering__c WHERE Id =: childRecordId LIMIT 1];

               startDate = [SELECT Id, Start_Date__c, Registration_Start_Date__c  FROM Program_Offering__c WHERE Id =: childRecordId LIMIT 1].Start_Date__c;

          //else course only
          } else{
               //get start date value in hed__Course_Offering__c
               // hed__Course_Offering__c courseOffering = [SELECT Id, hed__Start_Date__c  FROM hed__Course_Offering__c WHERE Id =: childRecordId LIMIT 1];

               startDate = [SELECT Id, hed__Start_Date__c, Registration_Start_Date__c  FROM hed__Course_Offering__c WHERE Id =: childRecordId LIMIT 1].hed__Start_Date__c;
          }

          List<Associated_Products__c> parentProductRequests = new List<Associated_Products__c>([
               SELECT Product_Request__c 
               FROM Associated_Products__c
               WHERE Product__c =: product.Id
          ]);

          for(Associated_Products__c assocProd: parentProductRequests){
               parentProductRequestIds.add(assocProd.Product_Request__c);
          }

          //only get the corporate pricing that is published
          List<BuyerGroupPriceBook> buyerGroupPbList = new List<BuyerGroupPriceBook>([
               SELECT Id, Pricebook2Id, BuyerGroup.Product_Request__r.Product_Request_Status__c
               FROM BuyerGroupPriceBook
               WHERE BuyerGroup.Product_Request__c IN: parentProductRequestIds]);
          
          Map<String,String> pricebookStatus = new Map<String,String>();
         
          for(BuyerGroupPricebook bgPricebook: buyerGroupPbList){
               pricebookStatus.put(
                    bgPricebook.Pricebook2Id,
                    bgPricebook.BuyerGroup.Product_Request__r.Product_Request_Status__c
               );
          }
          
          List<PricebookEntry> priceBookEntries = [
               SELECT Id, Pricebook2Id, Pricebook2.Name, 
               IsActive, Early_Bird_No_of_Days__c
               FROM PricebookEntry 
               WHERE Product2Id =: product.Id 
               AND IsActive = true
               ORDER BY CreatedDate];

          for(PricebookEntry pe : priceBookEntries){

               //if current iteration is for Early Bird
               if(pe.Pricebook2.Name == 'Early Bird'){

                    //convert to int to use addDays, multiply by -1 to subract instead of adding, and -1 to include today
                    Integer daysInt = -1 * Integer.valueOf(pe.Early_Bird_No_of_Days__c);

                    //compare today if it is less than the start date allowed for early bird
                    if( Datetime.now().Date() >= startDate.addDays(daysInt) ){
                         continue;
                    }
               }
               //only store the pricebook records if its not a cce pricebook
               //only the cce pricebook that is published
               if(  !pricebookStatus.containsKey(pe.Pricebook2Id) ||
                    (pricebookStatus.containsKey(pe.Pricebook2Id) && pricebookStatus.get(pe.Pricebook2Id) == 'Published')){

                         pBEntries.add(new Map<String,String>{
                              'id' => pe.Id,
                              'label' => pe.Pricebook2.Name
                         });
                    }
               
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
        List<Map<String,String>> contactMap = new List<Map<String,String>>();
        
        List<List<Contact>> contacts = [Find :filterString 
                                        In Name Fields 
                                        Returning Contact (Id, Name, Email, FirstName, BirthDate, LastName, MiddleName, Preferred_Full_Name__c 
                                        WHERE Recordtype.DeveloperName = 'Person' AND Id NOT IN: filterContacts LIMIT 15)];
        for(Contact con :contacts[0]){
          String meta = '';

          if(con.Email != null){
               meta = con.Email;
          }

          if(con.Email != null && con.BirthDate != null){
               meta += ' • ' + con.BirthDate.format();
          }else if(con.BirthDate != null){
               meta += con.BirthDate.format();
          }

          contactMap.add(new Map<String,String>{
                'id' => con.Id,
                'label' => con.Name,
                'meta' => meta
            });
          }
        return contactMap;
    }
    
    /**
      * @Retrieves list of Price Book Entries from Product Management tab
      * @param childRecordId - offering Id
      * @return List<Map<String,String>> - id and price book name
      */
      @AuraEnabled(cacheable=true)
      public static List<Map<String,String>> getEmailOptions(String contactId){
          List<Map<String,String>> emailOptions = new List<Map<String,String>>();
           List<Contact> con = [SELECT Id, 
                                   Registered_Email__c, 
                                   Email, QUT_Staff_Email__c, 
                                   QUT_Learner_Email__c, 
                                   Work_Email__c 
                              FROM Contact 
                              WHERE Id=: contactId LIMIT 1];
           
          if(!con.isEmpty() && con[0].Registered_Email__c == null){
               if(con[0].Email != null){
                    emailOptions.add(new Map<String,String>{
                         'value' => con[0].Email,
                         'label' => con[0].Email,
                         'meta' => 'Email'
                    });
               }
               if(con[0].QUT_Learner_Email__c != null){
                    emailOptions.add(new Map<String,String>{
                         'value' => con[0].QUT_Learner_Email__c,
                         'label' => con[0].QUT_Learner_Email__c,
                         'meta' => 'Learner Email'
                    });
               }
               if(con[0].QUT_Staff_Email__c != null){
                    emailOptions.add(new Map<String,String>{
                         'value' => con[0].QUT_Staff_Email__c,
                         'label' => con[0].QUT_Staff_Email__c,
                         'meta' => 'Staff Email'
                    });
               }
               if(con[0].Work_Email__c != null){
                    emailOptions.add(new Map<String,String>{
                         'value' => con[0].Work_Email__c,
                         'label' => con[0].Work_Email__c,
                         'meta' => 'Work Email'
                    });
               }
           }

           return emailOptions;
      }

      /**
      * @Checks if Contact has Registered Email
      * @param contactId - Contact Id
      * @return String - Contact's Registered Email
      */
      @AuraEnabled(cacheable=true)
      public static String getRegisteredEmail(String contactId){
          Contact contact = [SELECT Id, Registered_Email__c FROM Contact WHERE Id=:contactId LIMIT 1];
          return contact.Registered_Email__c != null ? contact.Registered_Email__c : null;
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
     public static ManageRegistrationDetails addRegistration(String registrationData, String fileUpload){
          
          ManageRegistrationDetails finalReturn = new ManageRegistrationDetails();
          ManageRegistrationDetails validationReturn = new ManageRegistrationDetails();
          ManageRegistrationDetails enrollmentProcessingReturn = new ManageRegistrationDetails();
          String contactRecName;
          Contact finalContactRecord = new Contact();
          finalReturn.isContactInputValid = true;

          //deserialize registration data in JSON format from lwc
          RegistrationData parsedRegistrationData = new RegistrationData();
          if(registrationData != ''){
               parsedRegistrationData = (RegistrationData) JSON.deserialize(registrationData, RegistrationData.class);
          }

          //set registration data into separate readable variables
         Contact contactRecord = parsedRegistrationData.contactRecord; 
         String offeringId = parsedRegistrationData.offeringId;
         Boolean prescribedProgram = parsedRegistrationData.prescribedProgram;
         Id priceBookEntryId = parsedRegistrationData.priceBookEntryId;
         Boolean isProceedNoInvoice = parsedRegistrationData.isProceedNoInvoice;
         Id promotionId = parsedRegistrationData.promotionId;

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

               finalReturn.isContactInputValid = validationReturn.isContactInputValid;
               finalReturn.contactValidationResponse = validationReturn.contactValidationResponse;
               
          }else{
               //get the contact's full name, first name, and lastname
               //store the contact details to string variable
               Contact con = [SELECT Id, Name, Email, FirstName, LastName FROM Contact WHERE Id =: contactRecord.Id LIMIT 1];
               contactRecName = con.Name;
               finalContactRecord.Email = contactRecord.Registered_Email__c;
               finalContactRecord.FirstName = con.FirstName;
               finalContactRecord.LastName = con.LastName;
               update contactRecord;
          }
          //process contact after validation
          if(finalReturn.isContactInputValid){
               //process questionnaire insertion
               processQuestionnaireData(parsedRegistrationData, fileUpload);

               //get product related to the offering
               Product2 product = getProduct(offeringId, prescribedProgram);

               Boolean isTailored = product != null && product.Product_Category__c == TAILORED_EXECUTIVE_PROGRAM?true:false;

               if(!String.isBlank(priceBookEntryId)){

                    enrollmentProcessingReturn = processEnrollmentWithPricing(parsedRegistrationData, finalContactRecord, contactRecName, product);
                    finalReturn.contactId = enrollmentProcessingReturn.contactId;
                    finalReturn.paymentURL = enrollmentProcessingReturn.paymentURL;
                    finalReturn.contactName = enrollmentProcessingReturn.contactName;
               }else{
                    List<hed__Course_Enrollment__c> courseConnectionList = createCourseConnectionList(contactRecord.Id, offeringId, null, null, null, prescribedProgram,isTailored);                               
                    insert courseConnectionList;
               
                    finalReturn.contactId = contactRecord.Id;
                    finalReturn.contactName = contactRecName;
               }               
          }
          
          return finalReturn;
     } 

     private static ManageRegistrationDetails validatedContacts(List<Contact> contactList){
          ManageRegistrationDetails validationReturn = new ManageRegistrationDetails();
          List<Contact> contactListToUpsert = new List<Contact>();
          List<RegistrationMatchingHelper.ContactMatchingResponse> contactsValidated = RegistrationMatchingHelper.validateContactMatching(JSON.serialize(contactList));
               for(RegistrationMatchingHelper.ContactMatchingResponse contactValidated: contactsValidated){
                    if(!contactValidated.isPartialMatch && contactValidated.isEmailMatch){
                         Contact con = contactValidated.contactRecord;
                         con.MobilePhone = contactList[0].MobilePhone;
                         con.Dietary_Requirement__c = contactList[0].Dietary_Requirement__c;
                         con.Accessibility_Requirement__c = contactList[0].Accessibility_Requirement__c;
                         contactListToUpsert.add(con);
                    }
                    else if(contactValidated.isPartialMatch && !contactValidated.isEmailMatch){
                         validationReturn.isContactInputValid = false;
                         validationReturn.contactValidationResponse =  'The email address doesn’t match the contact details provided. Please check the details.';
                    }
                    else if(contactValidated.isPartialMatch && contactValidated.isEmailMatch){
                         validationReturn.isContactInputValid = false;
                         validationReturn.contactValidationResponse =  'The personal details do not match with the email provided. Please check the details.';
                    }else{
                         contactListToUpsert.addAll(contactList);
                    }
               }  
               if(contactListToUpsert.size() > 0){
                    upsert contactListToUpsert; 
               }
          
          return validationReturn;
     }

     private static ManageRegistrationDetails processEnrollmentWithPricing(RegistrationData parsedRegistrationData, Contact finalContactRecord, String contactRecName, Product2 product){
          
          ManageRegistrationDetails enrollmentProcessingReturn = new ManageRegistrationDetails();
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
               commerceUser = createUser(finalContactRecord.Email, finalContactRecord.LastName, finalContactRecord.FirstName, contactRecord.Id);
               newWebCart = createWebCart(commerceUser, contactRecord.Id);
          }
          
          insert newWebCart;                    

          CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(
               CartId = newWebCart.Id,
               Name = 'Default Delivery'
          );
          insert cartDeliveryGroup;

          CartItem newCartItem = createCartItem(offeringId, newWebCart.Id, pbe, prescribedProgram, product.Id, cartDeliveryGroup.Id);
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
               urlObj.Name = contactRecName;
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
      
               List<hed__Course_Enrollment__c> courseConnectionList = createCourseConnectionList(
                    contactRecord.Id, 
                    offeringId, 
                    amount, 
                    newWebCart.Id, 
                    newCartItem.Id, 
                    prescribedProgram,
                    isTailored
               );                               
               insert courseConnectionList;
               
               enrollmentProcessingReturn.contactId = contactRecord.Id;
               enrollmentProcessingReturn.contactName = contactRecName;

               //if corporate pricing is selected
               if(isCorporateBundlePricing == true){
                    //get asset record related to corporate bundle
                    List<String> pbEntryIds = new List<String>();
                    pbEntryIds.add(priceBookEntryId);
                    Map<String,Asset> assetRecord = CorporateBundleAndSOAHelper.getAsset(pbEntryIds);
                    if(assetRecord.containsKey(priceBookentryId)){
                         CorporateBundleAndSOAHelper.createProductLedgerRecords(assetRecord.get(priceBookentryId).Id, courseConnectionList);
                    }
               }
          }
          
          return enrollmentProcessingReturn;
     }

     private static void processQuestionnaireData(RegistrationData parsedRegistrationData, String fileUpload){

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
          Map<Id,Id> relatedAnswerToAnswerMap = new Map<Id,Id>();
          Map<String,String> cvToRelatedAnswerMap = new Map<String,String>();
          List<ContentVersion> cvListToInsertList = new List<ContentVersion>();
          List<ContentDocumentLink> contentDocLinkListToInsert = new List<ContentDocumentLink>();
          Map<Id,Answer__c> answersToUpdate = new Map<Id,Answer__c>();

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
     }

     private static List<hed__Course_Enrollment__c> createCourseConnectionList(Id contactId, Id offeringId, Decimal amount, Id newWebCartId, Id newCartItemId, Boolean prescribedProgram, Boolean isTailored){
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

     /**
     * Creates commerce user based on contact details
     * @param <Id> userId
     * @return WebCart
     */
     private Static WebCart createWebCart(Id userId, Id contactId){
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
     * Creates cartitem based on parameters passed
     * @param <Id> offeringId - course/program offering
     * @param <Id> newWebCartId - new cart created
     * @param <Id> pbeId - price book entry
     * @param <Boolean> prescribedProgram
     * @param <Id> prodId - product
     * @return CartItem
     */
     private Static CartItem createCartItem(Id offeringId, Id newWebCartId, PricebookEntry pbe, Boolean prescribedProgram, Id prodId, Id cartDeliveryGroupId){
          String prodName = [SELECT Id, Name FROM Product2 WHERE Id =: prodId LIMIT 1].Name;
          // List<CartDeliveryGroup> cartDelGrpList = [SELECT Id FROM CartDeliveryGroup WHERE Name = 'Default Delivery' LIMIT 1];
          // Id cartDelGrpId;
          // for(CartDeliveryGroup cdg : cartDelGrpList) { cartDelGrpId = cdg.Id; }

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
               productList = [SELECT Id, Name, Product_Category__c FROM Product2 WHERE Course__c =: filter];
          }else{
               List<Program_Offering__c> programOfferingList = [SELECT Id, hed_Program_Plan__c  FROM Program_Offering__c WHERE Id =: offeringId LIMIT 1];
               for(Program_Offering__c programOffering : programOfferingList){
                    filter = programOffering.hed_Program_Plan__c;
               }
               productList = [SELECT Id, Name, Product_Category__c FROM Product2 WHERE Program_Plan__c  =: filter];
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
          @AuraEnabled
          public String paymentURL;
          @AuraEnabled
          public String contactName;
          @AuraEnabled
          public String contactValidationResponse;
          @AuraEnabled
          public Boolean isContactInputValid;
          @AuraEnabled
          public Decimal paidAmount;
          @AuraEnabled
          public Datetime registrationDate;
          @AuraEnabled
          public String studentId;
          @AuraEnabled
          public String position;
          @AuraEnabled
          public String organisation;
          @AuraEnabled
          public String dietaryRequirement;
          @AuraEnabled
          public String accessibilityRequirement;
     }

     private class RegistrationData{
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


      /**
      * @description Wrapper class that holds the file uploaded by user
      */
      private class FileUpload{
          @AuraEnabled
          public String base64;
          @AuraEnabled
          public String fileName;
          @AuraEnabled
          public String relatedAnswerId;
      }

      /**
      * @description Wrapper class that holds the file uploaded by user
      */
      private class PaymentUrlClass{
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

      /**
      * @description fetches the discount data
      * @param selectedPBId - current selected pricebook
      * @param standardPBId - standard pricebook of the product
      * @param offeringId - offering ID
      * @param prescribedProgram - prescribed program or not
      * @param couponCode - coupon enetered
      * @return discount - applicable discount
      */
     @AuraEnabled(cacheable=true)
     public static DiscountData getDiscount(String selectedPBId, String standardPBId, String offeringId, Boolean prescribedProgram, String couponCode) {
          
          DiscountData discountData = new DiscountData();
          discountData.promotionId = '';
          discountData.discount = 0;
          //get the product to search
          Product2 product = getProduct(offeringId, prescribedProgram);

          //query the promotion
          List<Promotion> promotionList = [
               SELECT 
                    Id,
                    Name,
                    IsActive,
                    (SELECT Id, Name, CouponCode FROM PromotionCoupons),
                    (SELECT Id, Name, AdjustmentType, AdjustmentPercent, AdjustmentAmount, TargetType, TargetId FROM PromotionTargets),
                    (SELECT Id, Name, Promotion__c, IsActive__c, Product__c FROM Promotion_Products__r WHERE IsActive__c = true)
               FROM
                    Promotion
               WHERE
                    IsActive = TRUE
                    AND Promotion.Id IN (
                         SELECT PromotionId
                         FROM Coupon
                         WHERE
                         CouponCode = :couponCode
                         AND Status = 'Active'
                         AND StartDateTime < :system.now()
                         AND EndDateTime > :system.now()
                    )
                    AND Promotion.Id IN (
                         SELECT PromotionId
                         FROM PromotionTarget
                         WHERE (TargetType = 'Product' AND TargetId = :product.Id)
                         OR (TargetType = 'ProductCategory')
                         OR TargetType = 'Transaction'
                    )
          ];

          //retrieve the pricebook selected and standard
          Map<Id, PricebookEntry> pbEntryMap = new Map<Id, PricebookEntry>(
               [
                    SELECT Id, Pricebook2.Name, UnitPrice
                    FROM PricebookEntry
                    WHERE Id = :selectedPBId OR Id = :standardPBId
               ]
          );

          Double discount = 0;
          Double discountedPrice;
          Double standardPrice = pbEntryMap.get(standardPBId).UnitPrice;
          Double selectedPrice = pbEntryMap.get(selectedPBId).UnitPrice;

          //if no promotion retrieved with the criteria
          if(promotionList.size() == 0){
               //set to -1 to identify as invalid coupon
               discount = -1;
          }

          //loop on all the options
          for (Promotion currentPromotion : promotionList) {
               discountData.promotionId = currentPromotion.Id;

               //loop in the PromotionTarget for in case of multiple promotions
               for (PromotionTarget currentPromotionTarget : currentPromotion.PromotionTargets){

                    //check if targetype is per product or total transaction
                    if(currentPromotionTarget.TargetType == 'Transaction'){

                         if (currentPromotionTarget.AdjustmentType == 'PercentageDiscount') {
                              //set the discount amount
                              discount = ((standardPrice * currentPromotionTarget.AdjustmentPercent) / 100).setScale(2);
                         }
               
                    //else if for product specific
                    } else if(currentPromotionTarget.TargetType == 'Product'){

                         if (currentPromotionTarget.AdjustmentType == 'FixedAmountOffLineItemTotal' || currentPromotionTarget.AdjustmentType == 'FixedAmountOffUnitPrice'){
                              //set the discount amount
                              discount = (currentPromotionTarget.AdjustmentAmount).setScale(2);

                         } else if (currentPromotionTarget.AdjustmentType == 'PercentageDiscount'){
                              //set the discount amount
                              discount = ((standardPrice * currentPromotionTarget.AdjustmentPercent) / 100).setScale(2);
                         } 

                     //else if for product category
                    } else if(currentPromotionTarget.TargetType == 'ProductCategory'){

                         //create a set of product Ids that are present in the Promotion_Products__r
                         Set<String> productPromotionIds = new Set<String>();
                         for (Promotion_Product__c currentPromotionProduct : currentPromotion.Promotion_Products__r) {
                              productPromotionIds.add(currentPromotionProduct.Product__c);
                         }

                         //check if the product is found in the Promotion_Products__c
                         if(productPromotionIds.contains(product.Id)){

                              if (currentPromotionTarget.AdjustmentType == 'FixedAmountOffLineItemTotal' || currentPromotionTarget.AdjustmentType == 'FixedAmountOffUnitPrice'){
                                   //set the discount amount
                                   discount = (currentPromotionTarget.AdjustmentAmount).setScale(2);
     
                              } else if (currentPromotionTarget.AdjustmentType == 'PercentageDiscount'){
                                   //set the discount amount
                                   discount = ((standardPrice * currentPromotionTarget.AdjustmentPercent) / 100).setScale(2);
                              } 

                         //else not found
                         }else{
                              //set to -1 to identify as invalid coupon
                              discount = -1;
                         }
                    }
               }
          }

          //set the maximum discount to the standard price only
          if(discount > standardPrice){
               discount = standardPrice;
          }

          //set the discounted price
          discountedPrice =  standardPrice - discount;

          //check if selected price is still less than standard - discount
          if(discount != -1 && selectedPrice <= discountedPrice){
               //-2 to identify that the selected pricebook is still less 
               discount = -2;
          }

          discountData.discount = discount;
          return discountData;
     }

     public class DiscountData {
          @AuraEnabled public Double discount;
          @AuraEnabled public String promotionId;
     }
}