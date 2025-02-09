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
      | roy.nino.s.regala         | November 15, 2022     | DEPP-4721            | Fixed cyclomatic issues      |
*/

public with sharing class ManageRegistrationSectionCtrl{
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
               AND Id =: offeringId
           ]);

           List<hed__Course_Offering__c> courseOfferingList = new List<hed__Course_Offering__c>([
               SELECT Id 
               FROM hed__Course_Offering__c
               WHERE Available_Seats__c > 0
               AND Id =: offeringId
           ]);

           if(programOfferingList.isEmpty() && courseOfferingList.isEmpty()){
               return false;
           }else{
               return true;
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
               WITH SECURITY_ENFORCED
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
                              WHERE Id=: contactId 
                              WITH SECURITY_ENFORCED
                              LIMIT 1];
           
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
          Contact contact = [
               SELECT Id, Registered_Email__c 
               FROM Contact 
               WHERE Id=:contactId 
               WITH SECURITY_ENFORCED
               LIMIT 1];
          return contact.Registered_Email__c != null ? contact.Registered_Email__c : null;
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