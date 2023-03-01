/**
 * @description Controller Class for Manage Registration and Nomination (manageRegistrationAndNomination) LWC
 * @see ../lwc/manageRegistrationAndNomination
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | Tiffany.Zhang             | Aug 9, 2022           | DEPP-3486            | Manage Registration and      |
      |                           |                       |                      | Nomination table in          |
      |                           |                       |                      | CCE portal                   |
      | eccarius.karl.munoz       | September 04, 2022    | DEPP-3747            | Created file to transfer     |
      |                           |                       |                      | methods used for manage reg  |
      |                           |                       |                      | and nomination table in cce. |
      | julie.jane.alegre         | September 16, 2022    | DEPP-4311            | Add a method to change       |
      |                           |                       |                      | date format                  |
      | eccarius.karl.munoz       | September 18, 2022    | DEPP-4302, DEPP-4303 | Added handling for corporate |
      |                           |                       |                      | bundle and changed logic of  |
      |                           |                       |                      | creating learner when nomi-  |      
      |                           |                       |                      | tion record was approved.    |
      |                           |                       |                      |                              |
      | roy.nino.s.regala         | September 28. 2022    | DEPP-4449            | soa/corporate learners only  |
      |                           |                       |                      |                              |
      | eccarius.karl.munoz       | November 07. 2022     | DEPP-4486            | Added validation for the     |
      |                           |                       |                      | offering's capacity and      |
      |                           |                       |                      | registration end date.       |
      |                           |                       |                      |                              |
*/
public without sharing class ManageRegAndNomCtrl {
    private static string studentRT = System.Label.RT_CourseConnection_Student;
    private static Id studentRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get(studentRT).getRecordTypeId();
    private static string studentProgramRT = System.Label.RT_CourseConnection_Student_Program;
    private static Id studentProgramRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get(studentProgramRT).getRecordTypeId();
    private static final String RT_CONTACT_PERSON = System.Label.RT_Contact_Person;
    private static final Id RT_CONTACT_PERSON_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(RT_CONTACT_PERSON).getRecordTypeId();
    private static final string  DEDUP_PERSONAL_MISMATCH = System.Label.Dedup_Mismatch_Personal_Portal_Error;

    /**
     * @description Retrieves list of Registration details of students for CCE Portal
     * @param isRegistrations - is registration or nomination
     * @param courseName - filter by courseName
     * @param firstName - filter by firstName
     * @param lastName - filter by lastName
     * @param email - filter by email
     * @param mobile - filter by mobile
     * @param status - filter by status
     * @param birthday - filter by birthday
     * @return List of ManageRegistrationorNominationDetails
     */
    @AuraEnabled(cacheable=true)
    public static List<ManageRegistrationorNominationDetails> getRegistrationsAndNominations(RecordSearchParams recordSearchParams, String accountSelected){
        
        String nominationType = 'Nomination';

        List<ManageRegistrationorNominationDetails> response = new List<ManageRegistrationorNominationDetails>();
        List<Product2> productList = new List<Product2>();
        Set<Id> courseOfferingIds = new Set<Id>();
        Set<Id> programOfferingIds = new Set<Id>();
        Map<Id, String> productNameMap = new Map<Id, String>();
        
        Set<String> pricebookEntryIds= new Set<String>();
        Set<String> pricebook2Ids = new Set<String>();
        
        if(accountSelected != null){
            Set<Id> buyerGrpIdSet = new Set<Id>();
            List<BuyerGroupMember> buyerGrpMembers = [SELECT BuyerGroupId FROM BuyerGroupMember WHERE BuyerId = :accountSelected];
            for(BuyerGroupMember bgm : buyerGrpMembers){
                buyerGrpIdSet.add(bgm.BuyerGroupId);
            }
            
            if(!buyerGrpIdSet.isEmpty()){
                //CommerceEntitlementBuyerGroup cebg = [SELECT PolicyId FROM CommerceEntitlementBuyerGroup WHERE BuyerGroupId = :bgm.BuyerGroupId LIMIT 1]; //0ZI9t00000006NBGAY
                Set<Id> cebgSet = new Set<Id>();
                List<CommerceEntitlementBuyerGroup> cebgList = [SELECT PolicyId FROM CommerceEntitlementBuyerGroup WHERE BuyerGroupId IN : buyerGrpIdSet];
                for(CommerceEntitlementBuyerGroup cebg : cebgList){
                    cebgSet.add(cebg.PolicyId);
                }
                if(!cebgSet.isEmpty()){
                    Set<Id> productIds = new Set<Id>();
                    for(CommerceEntitlementProduct ep : [SELECT ProductId FROM CommerceEntitlementProduct WHERE PolicyId IN : cebgSet]){
                        productIds.add(ep.ProductId);
                    }
                    if(String.isNotBlank(recordSearchParams.courseName)){
                        String query = 'SELECT Id, Name, Program_Plan__c, Course__c From Product2 WHERE Id IN :productIds AND' + '(Name LIKE\'' + '%' + String.escapeSingleQuotes(recordSearchParams.courseName) + '%\')';
                        productList = Database.query(query);
                    } else {
                        productList = [SELECT Id, Name, Program_Plan__c, Course__c From Product2 WHERE Id IN :productIds];
                    }  
                }

                for(BuyerGroupPriceBook buyerGroupPb: [
                    SELECT Id, Pricebook2Id
                    FROM BuyerGroupPriceBook
                    WHERE BuyerGroupId IN: buyerGrpIdSet
                ]){
                    if(buyerGroupPb.Pricebook2Id != null){
                        pricebook2Ids.add(buyerGroupPb.Pricebook2Id);
                    }
                }

                if(!pricebook2Ids.isEmpty()){
                    for(PriceBookEntry pbEntry: [
                        SELECT ID
                        FROM PricebookEntry
                        WHERE Pricebook2Id IN: pricebook2Ids
                    ]){
                        pricebookEntryIds.add(pbEntry.Id);
                    }
                }

            }
        }

        for(Product2 p :productList){
            if(p.Course__c != null){
                courseOfferingIds.add(p.Course__c);
                productNameMap.put(p.Course__c, p.Name);
            }

            if(p.Program_Plan__c != null){
                programOfferingIds.add(p.Program_Plan__c);
                productNameMap.put(p.Program_Plan__c, p.Name);
            }           
        }

        if(recordSearchParams.isRegistrations){
            String query;
            String condition =(String.isNotBlank(recordSearchParams.firstName)
                ? ' hed__Contact__r.FirstName LIKE \'' + '%' + String.escapeSingleQuotes(recordSearchParams.firstName) + '%\'' : '');

            condition += (String.isNotBlank(recordSearchParams.lastName)
                ? (String.isNotBlank(condition) ? +' AND ' : '') + ' hed__Contact__r.LastName LIKE \'' + '%' + String.escapeSingleQuotes(recordSearchParams.lastName) + '%\'' : '');
                
            condition += (String.isNotBlank(recordSearchParams.email)
                ? (String.isNotBlank(condition) ? +' AND ' : '') + ' hed__Contact__r.Registered_Email__c LIKE \'' + '%' + String.escapeSingleQuotes(recordSearchParams.email) + '%\'' : '');
            
            condition += (String.isNotBlank(recordSearchParams.mobile)
                ? (String.isNotBlank(condition) ? +' AND ' : '') + ' hed__Contact__r.MobilePhone LIKE \'' + '%' + String.escapeSingleQuotes(recordSearchParams.mobile) + '%\'' : '');
            
            String status = recordSearchParams.status;
            condition += (String.isNotBlank(status)
                ? (String.isNotBlank(condition) ? +' AND ' : '') + String.escapeSingleQuotes(' hed__Status__c = :status') : '');

            condition += (String.isNotBlank(recordSearchParams.birthday)
                ? (String.isNotBlank(condition) ? +' AND ' : '') + ' hed__Contact__r.Birthdate =' + String.escapeSingleQuotes(recordSearchParams.birthday) : '');

            if (String.isNotBlank(condition)) {
                query = 'SELECT Id, Name, hed__Contact__c, hed__Contact__r.Id, hed__Contact__r.Name, ' +
                'hed__Course_Offering__c, Program_Offering__r.hed_Program_Plan__c, Program_Offering__c, ' +
                'Program_Offering__r.Start_Date__c, Program_Offering__r.End_Date__c, hed__Course_Offering__r.Name, ' +
                'hed__Course_Offering__r.hed__Course__c, hed__Contact__r.Birthdate, hed__Course_Offering__r.hed__End_Date__c, ' +
                'hed__Course_Offering__r.hed__Start_Date__c, hed__Status__c, hed__Contact__r.FirstName, hed__Contact__r.LastName, ' +
                'hed__Contact__r.Registered_Email__c, hed__Contact__r.MobilePhone FROM hed__Course_Enrollment__c ' + 
                'WHERE ((Cart_Item__c != null AND Cart_Item__r.Pricebook_Entry_ID__c IN: pricebookEntryIds) ' + 
                'OR (hed__Course_Offering__r.hed__Course__r.ProductRequestID__r.Product_Specification__r.Opportunity_Name__r.AccountId =: accountSelected ' +
                'OR Program_Offering__r.hed_Program_Plan__r.Product_Request__r.Product_Specification__r.Opportunity_Name__r.AccountId =: accountSelected)) ' +
                'AND RecordTypeId IN (:studentRecTypeId, :studentProgramRecTypeId) ' +
                'AND (hed__Course_Offering__r.hed__Course__c IN :courseOfferingIds OR (Program_Offering__r.hed_Program_Plan__c IN :programOfferingIds AND hed__Course_Offering__c = null )) AND' + 
                condition; 
            } else {
                query = 'SELECT Id, Name, hed__Contact__c, hed__Contact__r.Id, hed__Contact__r.Name, ' +
                'hed__Course_Offering__c, Program_Offering__r.hed_Program_Plan__c, Program_Offering__c, ' +
                'Program_Offering__r.Start_Date__c, Program_Offering__r.End_Date__c, hed__Course_Offering__r.Name, ' +
                'hed__Course_Offering__r.hed__Course__c, hed__Contact__r.Birthdate, hed__Course_Offering__r.hed__End_Date__c, ' +
                'hed__Course_Offering__r.hed__Start_Date__c, hed__Status__c, hed__Contact__r.FirstName, hed__Contact__r.LastName, ' +
                'hed__Contact__r.Registered_Email__c, hed__Contact__r.MobilePhone FROM hed__Course_Enrollment__c ' + 
                'WHERE ((Cart_Item__c != null AND Cart_Item__r.Pricebook_Entry_ID__c IN: pricebookEntryIds) ' + 
                'OR (hed__Course_Offering__r.hed__Course__r.ProductRequestID__r.Product_Specification__r.Opportunity_Name__r.AccountId =: accountSelected ' +
                'OR Program_Offering__r.hed_Program_Plan__r.Product_Request__r.Product_Specification__r.Opportunity_Name__r.AccountId =: accountSelected)) ' +
                'AND RecordTypeId IN (:studentRecTypeId, :studentProgramRecTypeId) ' +
                'AND (hed__Course_Offering__r.hed__Course__c IN :courseOfferingIds OR (Program_Offering__r.hed_Program_Plan__c IN :programOfferingIds AND hed__Course_Offering__c = null ))';
            }

            List<hed__Course_Enrollment__c > courseConnections = Database.query(query);

            for(hed__Course_Enrollment__c student : courseConnections){
                ManageRegistrationorNominationDetails regDetails = new ManageRegistrationorNominationDetails();
                regDetails.id = student.Id;
                regDetails.courseName = student.hed__Course_Offering__c != null ? productNameMap.get(student.hed__Course_Offering__r.hed__Course__c) : productNameMap.get(student.Program_Offering__r.hed_Program_Plan__c);
                regDetails.contactId = student.hed__Contact__c;
                regDetails.contactFullName = student.hed__Contact__r.Name;
                regDetails.contactFirstName = student.hed__Contact__r.FirstName;
                regDetails.contactLastName = student.hed__Contact__r.LastName;
                regDetails.contactEmail = student.hed__Contact__r.Registered_Email__c;
                regDetails.contactMobile = student.hed__Contact__r.MobilePhone;
                regDetails.status = student.hed__Status__c;
                Date offeringStartDate = student.hed__Course_Offering__r.hed__Start_Date__c != null ? student.hed__Course_Offering__r.hed__Start_Date__c : student.Program_Offering__r.Start_Date__c;
                regDetails.offeringStartDate = offeringStartDate;
                Date offeringEndDate = student.hed__Course_Offering__r.hed__End_Date__c != null ? student.hed__Course_Offering__r.hed__End_Date__c : student.Program_Offering__r.End_Date__c;
                regDetails.offeringEndDate = offeringEndDate; 
                regDetails.courseOfferingId = student.hed__Course_Offering__c;
                regDetails.programOfferingId = student.Program_Offering__c;
                regDetails.contactBirthdate = student.hed__Contact__r.Birthdate;
                regDetails.businessAccount = accountSelected;
                response.add(regDetails);
            }
            
        } else {
            String query;
            String condition = (String.isNotBlank(recordSearchParams.firstName)
                ? ' First_Name__c LIKE \'' + '%' + String.escapeSingleQuotes(recordSearchParams.firstName) + '%\'' : '');

            condition += (String.isNotBlank(recordSearchParams.lastName)
                ? (String.isNotBlank(condition) ? +' AND ' : '') + ' Last_Name__c LIKE \'' + '%' + String.escapeSingleQuotes(recordSearchParams.lastName) + '%\'' : '');
                
            condition += (String.isNotBlank(recordSearchParams.email)
                ? (String.isNotBlank(condition) ? +' AND ' : '') + ' Email__c LIKE \'' + '%' + String.escapeSingleQuotes(recordSearchParams.email) + '%\'' : '');
            
            condition += (String.isNotBlank(recordSearchParams.mobile)
                ? (String.isNotBlank(condition) ? +' AND ' : '') + ' Mobile__c LIKE \'' + '%' + String.escapeSingleQuotes(recordSearchParams.mobile) + '%\'' : '');
             
            String status = recordSearchParams.status;
            condition += (String.isNotBlank(status)
                ? (String.isNotBlank(condition) ? +' AND ' : '') + String.escapeSingleQuotes(' Status__c = :status') : '');

            condition += (String.isNotBlank(recordSearchParams.birthday)
                ? (String.isNotBlank(condition) ? +' AND ' : '') + ' Birthdate__c =' + String.escapeSingleQuotes(recordSearchParams.birthday) : '');            

            condition += (String.isNotBlank(accountSelected)
                ? (String.isNotBlank(condition) ? +' AND ' : '') + String.escapeSingleQuotes(' Account__c = :accountSelected') : '');

            if (String.isNotBlank(condition)) {
                query = 'SELECT Id, Name, Contact__c, Accessibility_Requirement__c, Dietary_Requirement__c, Contact__r.Id, Contact__r.Name, Course_Offering__c, Course_Offering__r.Name, Birthdate__c, Course_Offering__r.hed__End_Date__c, Course_Offering__r.hed__Course__c, Course_Offering__r.hed__Start_Date__c, Status__c, First_Name__c, Last_Name__c, Email__c, Mobile__c, Mobile_Locale__c, Program_Offering__c, Program_Offering__r.Start_Date__c, Program_Offering__r.End_Date__c, Program_Offering__r.hed_Program_Plan__c, Pricebook_Entry_ID__c FROM Expression_of_Interest__c WHERE (Type__c = :nominationType) AND ((Course_Offering__r.hed__Course__c IN :courseOfferingIds OR (Program_Offering__r.hed_Program_Plan__c IN :programOfferingIds AND Course_Offering__c = null ))) AND' + condition; 
            } else { 
                query = 'SELECT Id, Name, Contact__c, Accessibility_Requirement__c, Dietary_Requirement__c, Contact__r.Id, Contact__r.Name, Course_Offering__c, Course_Offering__r.Name, Birthdate__c, Course_Offering__r.hed__End_Date__c, Course_Offering__r.hed__Course__c, Course_Offering__r.hed__Start_Date__c, Status__c, First_Name__c, Last_Name__c, Email__c, Mobile__c, Mobile_Locale__c, Program_Offering__c, Program_Offering__r.Start_Date__c, Program_Offering__r.End_Date__c, Program_Offering__r.hed_Program_Plan__c, Pricebook_Entry_ID__c FROM Expression_of_Interest__c WHERE (Type__c = :nominationType) AND ((Course_Offering__r.hed__Course__c IN :courseOfferingIds) OR (Program_Offering__r.hed_Program_Plan__c IN :programOfferingIds AND Course_Offering__c = null ))';
            }
            List<Expression_of_Interest__c > eois = Database.query(query);

            for(Expression_of_Interest__c student : eois){
                ManageRegistrationorNominationDetails regDetails = new ManageRegistrationorNominationDetails();
                regDetails.id = student.Id;
                regDetails.courseName = student.Course_Offering__c != null ? productNameMap.get(student.Course_Offering__r.hed__Course__c) : productNameMap.get(student.Program_Offering__r.hed_Program_Plan__c);
                regDetails.contactId = student.Contact__c;
                regDetails.contactFullName = student.First_Name__c + ' ' + student.Last_Name__c;
                regDetails.contactFirstName = student.First_Name__c;
                regDetails.contactLastName = student.Last_Name__c;
                regDetails.contactEmail = student.Email__c;
                regDetails.contactMobile = student.Mobile__c;
                regDetails.contactMobileLocale = student.Mobile_Locale__c;
                regDetails.status = student.Status__c;
                Date offeringStartDate = student.Course_Offering__r.hed__Start_Date__c != null ? student.Course_Offering__r.hed__Start_Date__c : student.Program_Offering__r.Start_Date__c;
                regDetails.offeringStartDate = offeringStartDate;
                Date offeringEndDate = student.Course_Offering__r.hed__End_Date__c != null ? student.Course_Offering__r.hed__End_Date__c : student.Program_Offering__r.End_Date__c;
                regDetails.offeringEndDate = offeringEndDate; 
                regDetails.courseOfferingId = student.Course_Offering__c;
                regDetails.programOfferingId = student.Program_Offering__c;
                regDetails.contactBirthdate = student.Birthdate__c;
                regDetails.contactAccessibilityReq = student.Accessibility_Requirement__c;
                regDetails.contactDietaryReq = student.Dietary_Requirement__c;
                regDetails.priceBookEntryId = student.Pricebook_Entry_ID__c;
                regDetails.businessAccount = accountSelected;
                response.add(regDetails);
            }
        }
        
        return response;
    }

    /**
     *  @description Retrieves list of picklist values for registration status field
     *  @return List<String>
     */
    @AuraEnabled(cacheable=true)
    public static List<String> getNominationStatusValues(){
        List<String> choosedValues = new List<String>{'Approved', 'Pending', 'Declined'};
        List<String> response = new List<String>();
        String strObjectName = 'Expression_of_Interest__c';
        String strPicklistField = 'Status__c';
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(strObjectName);
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
        List<Schema.PicklistEntry> lstPickListValues = mapFields.get(strPicklistField).getDescribe().getPickListValues();
        for (Schema.PicklistEntry objPickList : lstPickListValues) {
            String val = objPickList.getValue();
            if(choosedValues.contains(val)){
                response.add(val);
            }
        }
        return response;
    }

    /**
     * @description Updates Registration Or NominationStatus of students
     * @param id - id of student selected 
     * @param registrationStatus - registration status of student selected
     * @param isRegistrations - is registration or nomination
     * @return String
     */
    @AuraEnabled
    public static RegistrationNominationUpdateResponse updateRegistrationOrNominationStatus(String id, String registrationStatus, Boolean isRegistrations, Expression_of_Interest__c contactInfo, String mobileNumber, String businessOrgAccount){
        
        Savepoint savePoint = Database.setSavepoint();
        RegistrationNominationUpdateResponse response = new RegistrationNominationUpdateResponse();

        //Handling for Manage Registration Update
        if(isRegistrations){
            hed__Course_Enrollment__c studentToUpdate = new hed__Course_Enrollment__c();
            studentToUpdate.Id = id;
            studentToUpdate.hed__Status__c = registrationStatus;

            try {
                update studentToUpdate;
                response.isSuccess = true;
            }
            catch (Exception e) {
                response.isSuccess = false;
                response.errorMessage = 'The following exception has occurred: ' + e.getMessage();
            }

        } else {  
            //Handling for Manage Nomination Update
            PriceBookEntry priceBookEntry = getPriceBookEntry(contactInfo.Pricebook_Entry_ID__c);
            BuyerGroupPricebook buyerGrpPriceBook = getBuyerGrpPriceBook(priceBookEntry.Pricebook2Id);
            Asset asset = getAsset(buyerGrpPriceBook.BuyerGroup.Product_Request__c);
            if(priceBookEntry.Id != null && asset != null){
                //Validates Credit Availability
                Boolean isApproveCreditDeduct = checkCreditAvailability(priceBookEntry.Id, asset.Id);
                if(!isApproveCreditDeduct){
                    response.isSuccess = false;
                    response.errorMessage = 'Credit is not enough to cover this enrolment.';
                    return response;
                }
            }
            Id contactId;
            List<Expression_of_Interest__c> studentToUpdateList = new List<Expression_of_Interest__c>();
            studentToUpdateList.add(new Expression_of_Interest__c(
                Id = id, 
                Status__c = registrationStatus)
            );

            List<Contact> contactListToAdd = new List<Contact>();
            List<Contact> contactListToUpdate = new List<Contact>();
            List<Contact> contactListParam = new List<Contact>();            
            if(registrationStatus == 'Approved'){      

                if(!validateOfferingCapacity(contactInfo.Course_Offering__c, contactInfo.Program_Offering__c)){
                    response.isSuccess = false;
                    response.errorMessage = 'Registration is full. Please contact QUTeX for any further assistance.';
                    return response;
                }

                if(!validateOfferingRegistration(contactInfo.Course_Offering__c, contactInfo.Program_Offering__c)){
                    response.isSuccess = false;
                    response.errorMessage = 'Registration is closed. Please contact QUTeX for any further assistance.';
                    return response;
                }

                Contact contact = new Contact();
                contact.FirstName = contactInfo.First_Name__c;
                contact.LastName = contactInfo.Last_Name__c;
                contact.Email = contactInfo.Email__c;
                contact.Registered_Email__c = contactInfo.Email__c;
                contact.Birthdate = contactInfo.Birthdate__c;
                contact.Accessibility_Requirement__c = String.isNotBlank(contactInfo.Accessibility_Requirement__c) ? contactInfo.Accessibility_Requirement__c : '';
                contact.Dietary_Requirement__c = String.isNotBlank(contactInfo.Dietary_Requirement__c) ? contactInfo.Dietary_Requirement__c : '';
                contact.MobilePhone = mobileNumber;
                contact.Mobile_No_Locale__c = contactInfo.Mobile__c != null ? contactInfo.Mobile__c : '';
                contact.ContactMobile_Locale__c = contactInfo.Mobile_Locale__c;
                contact.RecordTypeId = RT_CONTACT_PERSON_ID;
                contactListParam.add(contact);

                //Validates Contact Information
                List<RegistrationMatchingHelper.ContactMatchingResponse> contactsValidated = RegistrationMatchingHelper.validateContactMatching(JSON.serialize(contactListParam));
                for(RegistrationMatchingHelper.ContactMatchingResponse contactValidated: contactsValidated){
                    if(!contactValidated.isPartialMatch && contactValidated.isEmailMatch){
                        Contact con = contactValidated.contactRecord;
                        con.MobilePhone = mobileNumber;
                        con.Mobile_No_Locale__c = contactInfo.Mobile__c;
                        con.ContactMobile_Locale__c = contactInfo.Mobile_Locale__c;
                        con.Dietary_Requirement__c = contactInfo.Dietary_Requirement__c;
                        con.Accessibility_Requirement__c = contactInfo.Accessibility_Requirement__c;
                        con.Registered_Email__c = contactInfo.Email__c;
                        contactListToUpdate.add(con);
                    }
                    else if(contactValidated.isPartialMatch && !contactValidated.isEmailMatch){
                        response.isSuccess = false;
                        response.errorMessage = 'The email address doesn’t match the contact details provided. Please contact QUTeX.';
                        return response;
                    }
                    else if(contactValidated.isPartialMatch && contactValidated.isEmailMatch){
                        response.isSuccess = false;
                        response.errorMessage = DEDUP_PERSONAL_MISMATCH + ' ' + String.join(contactValidated.fieldsMismatch, ', ');
                        return response;
                    }else{
                        contactListToAdd.add(contact);
                    }
                }  
                try {
                    
                    if(contactListToAdd.size() > 0){
                        insert contactListToAdd; 
                        contactId = contactListToAdd[0].Id;
                    }
                    if(contactListToUpdate.size() > 0){
                        update contactListToUpdate;
                        contactId = contactListToUpdate[0].Id;
                    }

                    //Check Existing Learner
                    List<hed__Course_Enrollment__c> existingCourseConnectionList = [
                        SELECT Id FROM hed__Course_Enrollment__c WHERE hed__Status__c = 'Active' AND hed__Contact__c =: contactId 
                           AND (hed__Course_Offering__c =: contactInfo.Course_Offering__c OR Program_Offering__c =: contactInfo.Program_Offering__c) LIMIT 1];

                    if(!existingCourseConnectionList.isEmpty()){
                        response.isSuccess = false;
                        response.errorMessage = 'This learner is already registered.';
                        return response;
                    }

                    Id webCartId = getWebCartId(businessOrgAccount);
                    Id cartDeliveryGrpId = getCartDeliveryGrpId(webCartId);
                    Product2 product = getProductDetails(
                        contactInfo.Course_Offering__c, 
                        contactInfo.Program_Offering__c
                    );
                    Decimal cartItemTotalPrice = getCartItemTotalPrice(
                        webCartId, 
                        cartDeliveryGrpId,
                        product,
                        contactId,
                        contactInfo.Course_Offering__c,
                        contactInfo.Program_Offering__c,
                        priceBookEntry
                    );


                    //Updates Cart Payment to create Learner via trigger on Approved Cart Payment
                    Id cartPaymentId = [SELECT Id, Cart_Payment__c FROM WebCart WHERE Id =: webCartId LIMIT 1].Cart_Payment__c;
                    List<Cart_Payment__c> cartPaymentToUpdate = new List<Cart_Payment__c>();
                    Cart_Payment__c cartPayment = new Cart_Payment__c(Id = cartPaymentId, Payment_Status__c = 'Approved', Amount_Paid__c = cartItemTotalPrice);
                    cartPaymentToUpdate.add(cartPayment);
                    if(!cartPaymentToUpdate.isEmpty()){
                        update cartPaymentToUpdate;
                    }
                    //Retrieves Learner created from approved cart payment
                    Id learnerId;
                    //should be able to get program and course enrolments.
                    List<hed__Course_Enrollment__c> courseConnectionList = [SELECT Id, Payment_Method__c, Paid_in_Full__c FROM hed__Course_Enrollment__c WHERE Cart_ID__c =: webCartId];
                    List<hed__Course_Enrollment__c> learnerToUpdate = new List<hed__Course_Enrollment__c>();
                    for(hed__Course_Enrollment__c courseConnection : courseConnectionList){
                        hed__Course_Enrollment__c learner = new hed__Course_Enrollment__c();
                        learnerId = courseConnection.Id;
                        learner.Id = courseConnection.Id;
                        learner.Payment_Method__c = 'Contract';
                        learner.Paid_in_Full__c = 'Contract';
                        learnerToUpdate.add(learner);
                    }

                    if(priceBookEntry.Id != null && asset.Id != null){
                        //Creates Prodcut Ledger
                        List<Product_Ledger__c> productLedgerList = new List<Product_Ledger__c>();
                        Product_Ledger__c productLedger = new Product_Ledger__c ();
                        productLedger.Asset__c = asset.Id;
                        productLedger.Course_Connection__c = learnerId;
                        productLedger.Purchased_Price_v2__c = cartItemTotalPrice;
                        productLedgerList.add(productLedger);
                        if(!productLedgerList.isEmpty()){
                            insert productLedgerList;
                        }
                    }

                    if(!learnerToUpdate.isEmpty()){
                        update learnerToUpdate;
                    }

                    if(!studentToUpdateList.isEmpty()){
                        update studentToUpdateList;
                        response.isSuccess = true;
                    }
                }catch (Exception e) {
                    response.isSuccess = false;
                    response.errorMessage = 'The following exception has occurred: ' + e.getMessage();
                    Database.rollback(savePoint);
                }
            }else{
                try {
                    update studentToUpdateList;
                    response.isSuccess = true;
                }
                catch (Exception e) {
                    response.isSuccess = false;
                    response.errorMessage = 'The following exception has occurred: ' + e.getMessage();
                }
            }
        }
            
        return response;
    }

    /**
     * Retrieves pricebook entry based on the price book entry id from the nomination record
     */
    private static PriceBookEntry getPriceBookEntry(String pricebookEntryId){
        PriceBookEntry priceBookEntry = new PriceBookEntry();
        List<PriceBookEntry> priceBookEntryList = [SELECT Id, Pricebook2Id, Product2Id, Product2.Name, UnitPrice FROM PriceBookEntry WHERE Id =: pricebookEntryId LIMIT 1]; 
        if(!priceBookEntryList.isEmpty()){
            priceBookEntry = priceBookEntryList[0];
        }
        return pricebookEntry;
    }

    /**
     * Retrieves Buyer Group Proce book
     */
    private static BuyerGroupPricebook getBuyerGrpPriceBook(Id pricebook2Id){
        BuyerGroupPricebook buyerGrpPriceBook = new BuyerGroupPricebook();
        List<BuyerGroupPricebook> buyerGrpPriceBookList = [SELECT BuyerGroup.Product_Request__c FROM BuyerGroupPricebook Where Pricebook2Id =: pricebook2Id LIMIT 1];
        if(!buyerGrpPriceBookList.isEmpty()){
            buyerGrpPriceBook = buyerGrpPriceBookList[0];
        }
        return buyerGrpPriceBook;
    }

    /**
     * Retrieves Asset
     */
    private static Asset getAsset(Id productRequest){
        Asset asset = new Asset();
        List<Asset> assetList = [SELECT Id FROM Asset WHERE Product_Request__c =: productRequest LIMIT 1];
        if(!assetList.isEmpty()){
            asset = assetList[0];
        }
        return asset;
    }

    /**
     * Creates WebCart
     */
    private static Id getWebCartId(Id businessOrgAccount){
        Id webCartId;
        Id userId = UserInfo.getUserId();
        List<WebCart> existingWebCartList = [SELECT Id FROM WebCart WHERE OwnerId =: userId AND Status = 'Active' LIMIT 1];
        List<WebCart> webCartToUpdate = new List<WebCart>();
        for(WebCart cart : existingWebCartList){
            WebCart cartToUpdate = new WebCart(Id = cart.Id, Status = 'Closed');
            webCartToUpdate.add(cartToUpdate);
        }
        if(!webCartToUpdate.isEmpty()){
            update webCartToUpdate;
        }
        Id webStoreId = [SELECT Id FROM WebStore WHERE Name = 'CCE' LIMIT 1].Id;
        List<WebCart> webCartList = new List<WebCart>();
        WebCart webCart = new WebCart(
            Name = 'Cart',
            AccountId = businessOrgAccount,
            Status = 'Active', 
            WebStoreId = webStoreId
        );
        webCartList.add(webCart);
        
        if(!webCartList.isEmpty()){
            insert webCartList;
            webCartId = webCartList[0].Id;
        }
        return webCartId;
    }

    /**
     * Creates Cart Delivery Group
     */
    private static Id getCartDeliveryGrpId(Id webCartId){
        Id cartDeliveryGrpId;
        List<CartDeliveryGroup> cartDeliveryGroupList = new List<CartDeliveryGroup>();
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(
            CartId = webCartId,
            Name = 'Default Delivery'
        );
        cartDeliveryGroupList.add(cartDeliveryGroup);
        
        if(!cartDeliveryGroupList.isEmpty()){
            insert cartDeliveryGroupList;
            cartDeliveryGrpId = cartDeliveryGroupList[0].Id;
        }
        return cartDeliveryGrpId;
    }

    /**
     * Retrieve product details
     */
    private static Product2 getProductDetails(Id courseOfferingId, Id programOfferingId){
        Product2 product;
        if(courseOfferingId != null){    
            Id courseId =[SELECT Id, hed__Course__c FROM hed__Course_Offering__c WHERE Id =: courseOfferingId LIMIT 1].hed__Course__c;
            product = [SELECT Id, Name FROM Product2 WHERE Course__c =: courseId];
        }else{
            Id programId = [SELECT Id, hed_Program_Plan__c FROM Program_Offering__c WHERE Id =: programOfferingId].hed_Program_Plan__c;
            product = [SELECT Id, Name FROM Product2 WHERE Program_Plan__c =: programId];
        }
        return product;
    }

    /**
     * Creates Cart Item
     */
    private static Decimal getCartItemTotalPrice(
        Id webCartId, 
        Id cartDeliveryGrpId,
        Product2 product,
        Id contactId,
        Id courseOfferingId,
        Id programOfferingId,
        PriceBookEntry priceBookEntry
    ){
        Decimal cartItemTotalPrice = 0;
        List<CartItem> cartItemList = new List<CartItem>();
        CartItem cartItem = new CartItem();
        cartItem.CartId = webCartId;
        cartItem.CartDeliveryGroupId = cartDeliveryGrpId;
        cartItem.Name = product.Name;
        cartItem.Contact__c = contactId;
        cartItem.Product2Id = product.Id;
        cartItem.Course_Offering__c = courseOfferingId;
        cartItem.Program_Offering__c = programOfferingId;
        cartItem.Pricebook_Entry_ID__c = priceBookEntry?.Id;
        cartItem.TotalPrice = priceBookEntry?.UnitPrice;
        cartItem.Quantity = 1;
        cartItem.Type = 'Product';
        cartItemList.add(cartItem);
        
        if(!cartItemList.isEmpty()){
            insert cartItemList;
            cartItemTotalPrice = cartItemList[0].TotalPrice;
        }
        return cartItemTotalPrice;
    }
    /*
     * @description - checks the latest credit availablity of asset
     * @param pbEntryId - selected pricebookentry
     * @param assetId - related asset
     * @return boolean - checker if asset credit is still available for enrollment
     */
    @AuraEnabled
    public static boolean checkCreditAvailability(String pbEntryId, String assetId){
        List<PricebookEntry> selectedPriceBookEntry = new List<PricebookEntry>([
            SELECT Id, UnitPrice
            FROM PricebookEntry
            WHERE Id =: pbEntryId
        ]);

        List<Asset> relatedAsset = new List<Asset>([
            SELECT Id, 
            Remaining_Value__c
            FROM Asset
            WHERE Id =: assetId
        ]);

        if(  !selectedPriceBookEntry.isEmpty() && 
            !relatedAsset.isEmpty() &&
            relatedAsset[0].Remaining_Value__c >= selectedPriceBookEntry[0].UnitPrice){
            return true;
        }else{
            return false;
        }
    }

    /*
     * @description - validates the registration end date of the offering
     * @param courseOfferingId - course offering Id
     * @param programOfferingId - program offering Id
     * @return Boolean
     */
    @AuraEnabled
    public static Boolean validateOfferingRegistration(Id courseOfferingId, Id programOfferingId){
        List<Program_Offering__c> programOfferingList = new List<Program_Offering__c>([
            SELECT Id 
            FROM Program_Offering__c
            WHERE Registration_End_Date__c > TODAY
            AND Id =: programOfferingId
        ]);

        List<hed__Course_Offering__c> courseOfferingList = new List<hed__Course_Offering__c>([
            SELECT Id 
            FROM hed__Course_Offering__c
            WHERE Registration_End_Date__c > TODAY
            AND Id =: courseOfferingId
        ]);
        if(programOfferingList.isEmpty() && courseOfferingList.isEmpty()){
            return false;
        }
        return true;
    }

    /*
     * @description - validates the capacity of the offering
     * @param courseOfferingId - course offering Id
     * @param programOfferingId - program offering Id
     * @return Boolean
     */
    @AuraEnabled
    public static Boolean validateOfferingCapacity(Id courseOfferingId, Id programOfferingId){
        List<Program_Offering__c> programOfferingList = new List<Program_Offering__c>([
            SELECT Id 
            FROM Program_Offering__c
            WHERE Available_Seats__c > 0
            AND Id =: programOfferingId
        ]);

        List<hed__Course_Offering__c> courseOfferingList = new List<hed__Course_Offering__c>([
            SELECT Id 
            FROM hed__Course_Offering__c
            WHERE Available_Seats__c > 0
            AND Id =: courseOfferingId
        ]);

        if(programOfferingList.isEmpty() && courseOfferingList.isEmpty()){
            return false;
        }
        return true;
    }

     /**
     * @description Format Dates to dd/mm/yyyy
     * @param mydate - Date
     * @return String
     */
    @AuraEnabled
    public static String formatDate(Date mydate){
        String strDate;
        if(mydate != null){
            strDate = Datetime.newInstance(
                mydate,
              Time.newInstance(0, 0, 0, 0)
            )
            .format('dd MMM yyyy');
        }
        else{
            strDate = ' ';
        }
        return strDate;
    }

    /**
     * @description Wrapper class that holds data to be displayed
     */
    public class ManageRegistrationorNominationDetails{
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String contactId;
        @AuraEnabled
        public String courseName;
        @AuraEnabled
        public String contactFullName;
        @AuraEnabled
        public String contactFirstName;
        @AuraEnabled
        public String contactLastName;
        @AuraEnabled
        public String contactEmail;
        @AuraEnabled
        public String contactMobile;
        @AuraEnabled
        public String contactMobileLocale;
        @AuraEnabled
        public Date offeringStartDate;
        @AuraEnabled
        public Date offeringEndDate;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String courseOfferingId;
        @AuraEnabled
        public String programOfferingId;
        @AuraEnabled
        public Date contactBirthdate;
        @AuraEnabled
        public String contactDietaryReq;
        @AuraEnabled
        public String contactAccessibilityReq;
        @AuraEnabled
        public String priceBookEntryId;
        @AuraEnabled
        public String businessAccount;  
        @AuraEnabled
        public String adminAccount;      
    }

    /**
     * @description Wrapper class for Update Response
     */
    public class RegistrationNominationUpdateResponse{
        @AuraEnabled
        public Boolean isSuccess;
        @AuraEnabled
        public String errorMessage;
    }

    /**
     * @description Wrapper class for Product Offering Validation
     */
    public class ProductOfferingValidationResponse{
        @AuraEnabled
        public Boolean isFullCapacity;
        @AuraEnabled
        public Boolean isExpired;
    }

    /**
     * @description Wrapper class for Record Search
     */
    public class RecordSearchParams{
        @AuraEnabled
        public Boolean isRegistrations{ get; set; }
        @AuraEnabled
        public String courseName{ get; set; }
        @AuraEnabled
        public String firstName{ get; set; }
        @AuraEnabled
        public String lastName{ get; set; }
        @AuraEnabled
        public String email{ get; set; }
        @AuraEnabled
        public String mobile{ get; set; }
        @AuraEnabled
        public String status{ get; set; }
        @AuraEnabled
        public String birthday{ get; set; }
    }
    
}
