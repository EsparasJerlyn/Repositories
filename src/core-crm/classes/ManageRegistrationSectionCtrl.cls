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

public without sharing class ManageRegistrationSectionCtrl extends ManageRegistrationEnrolmentHelper{
     private static final String TAILORED_EXECUTIVE_PROGRAM = 'Tailored Executive Program';
     private static string studentRT = System.Label.RT_CourseConnection_Student;
     private static Id studentRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get(studentRT).getRecordTypeId();
     private static string studentProgramRT = System.Label.RT_CourseConnection_Student_Program;
     private static Id studentProgramRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get(studentProgramRT).getRecordTypeId();
     private static List<hed__Course_Enrollment__c> registeredLearners;
     private static Map<Id,List<hed__Course_Enrollment__c>> relatedEnrollments;
     private static Map<Id, PricebookEntry> studentWithPricingMap;
     private static Map<Id,Questionnaire_Response_Summary__c> contactToQRSummary;

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

          try {

               List<hed__Course_Enrollment__c> studentsToUpdate = new List<hed__Course_Enrollment__c>();
               hed__Course_Enrollment__c studentFromParentOffering = new hed__Course_Enrollment__c();
               studentFromParentOffering.Id = id;
               studentFromParentOffering.Paid_in_Full__c = paidInFull;
               studentFromParentOffering.Pricing_Validation__c = pricingValidation;
               studentFromParentOffering.hed__Status__c = registrationStatus;
               studentsToUpdate.add(studentFromParentOffering);

               if(programOfferingId != ''){

                    List<hed__Course_Enrollment__c> students = [
                         SELECT Id, Paid_in_Full__c, Pricing_Validation__c 
                         FROM hed__Course_Enrollment__c 
                         WHERE hed__Course_Offering__c != NULL 
                         AND Program_Offering__c =: programOfferingId
                         AND hed__Contact__c =: contactId
                    ];

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
          Product2 product = ManageRegistrationSectionHelper.getProduct(childRecordId, prescribedProgram);
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
     public static EnrolmentResultClass addRegistration(String registrationData, String fileUpload){
          
          EnrolmentResultClass enrolmentResult = new EnrolmentResultClass();
          EnrolmentResultClass validationReturn = new EnrolmentResultClass();
          EnrolmentResultClass enrollmentProcessingReturn = new EnrolmentResultClass();
          String contactRecName;
          Contact finalContactRecord = new Contact();
          enrolmentResult.isContactInputValid = true;
          
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

               enrolmentResult.isContactInputValid = validationReturn.isContactInputValid;
               enrolmentResult.contactValidationResponse = validationReturn.contactValidationResponse;
               
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
          if(enrolmentResult.isContactInputValid){
               //process questionnaire insertion
               ManageRegistrationSectionHelper.processQuestionnaireData(parsedRegistrationData, fileUpload);

               //get product related to the offering
               Product2 product = ManageRegistrationSectionHelper.getProduct(offeringId, prescribedProgram);

               Boolean isTailored = product != null && product.Product_Category__c == TAILORED_EXECUTIVE_PROGRAM?true:false;

               enrolmentResult.contactId = enrollmentProcessingReturn.contactId;

               if(!String.isBlank(priceBookEntryId)){

                    enrollmentProcessingReturn = ManageRegistrationSectionHelper.processEnrollmentWithPricing(parsedRegistrationData, finalContactRecord, contactRecName, product);
                    
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

                    List<hed__Course_Enrollment__c> courseConnectionList = createCourseConnectionList(enrolmentParam);                               
                    insert courseConnectionList;
                    enrolmentResult.contactName = contactRecName;
               }  
                            
          }
          return enrolmentResult;
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
          Product2 product = ManageRegistrationSectionHelper.getProduct(offeringId, prescribedProgram);

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

     private class DiscountData {
          @AuraEnabled 
          public Double discount;
          @AuraEnabled 
          public String promotionId;
     }

     /**
      * @description Wrapper class that holds data to be displayed
      */
     private class ManageRegistrationDetails{
          @AuraEnabled
          public hed__Course_Enrollment__c enrolmentDetails;
          @AuraEnabled
          public Questionnaire_Response_Summary__c applicationDetails;
          @AuraEnabled
          public String regenerateInvoiceURL;
     }
}