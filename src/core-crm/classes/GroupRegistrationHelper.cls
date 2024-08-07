/**
 * @description Helper Class for Group Registration
 * @see ../lwc/GroupRegistrationCtrl
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                     |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------------------------------|
      | eccarius.karl.munoz            | January 30, 2023      | DEPP-4684              | Created file                                                       |
      |                                |                       |                        |                                                                    |
 */
public without sharing class GroupRegistrationHelper {

    private static final String RT_CONTACT_PERSON = System.Label.RT_Contact_Person;
    private static final Id RT_CONTACT_PERSON_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(RT_CONTACT_PERSON).getRecordTypeId();
   
    /**
     * creates ope users and assign ope perm set
     */
    public static Map<Id,User> createUsers(List<Contact> contacts){       
        Map<Id,User> responseMap = new Map<Id,User>();
        List<User> allUsers = new List<User>();
        List<Id> contactIds = new List<Id>();

        Profile profile = [SELECT Id FROM Profile WHERE Name = 'QUT Experience' WITH SECURITY_ENFORCED LIMIT 1];
        Map<Id,User> userMap = GroupRegistrationHelper.setUserMap(contacts);
        List<User> newUsers = new List<User>();

        for(Contact contact : contacts){
            if(userMap.containsKey(contact.Id)){
                allUsers.add(userMap.get(contact.Id));
            }else{
                User user = new User();
                user.Username = contact.Email;
                user.Email = contact.Email;
                user.LastName = contact.LastName;
                user.FirstName = contact.FirstName;
                user.ContactId = contact.Id;
                user.alias = contact.FirstName.substring(0, 1) + contact.LastName.substring(0, 2);
                user.LanguageLocaleKey = 'en_US';
                user.localesidkey = 'en_AU';
                user.emailEncodingKey = 'UTF-8';
                user.timeZoneSidKey = 'Australia/Brisbane';
                user.profileId = profile.Id;
                newUsers.add(user);
            }
            contactIds.add(contact.Id);
        }
        if(Schema.sObjectType.User.isCreateable()){
            insert newUsers;
        }
        
        allUsers.addAll(newUsers);
        assignToOPEBuyerGroup(contactIds);
        assignOPEPermSet(setUserIds(allUsers));  
        responseMap = setUserIdMap(allUsers);     

        return responseMap;
    }        

    private static void assignToOPEBuyerGroup(List<Id> contactIds){
          
        List<BuyerGroup> opeBuyerGroup = [SELECT Id FROM BuyerGroup WHERE Name = 'OPE BuyerGroup' WITH SECURITY_ENFORCED LIMIT 1];
        List<Contact> contacts = [SELECT AccountId, Account.Name FROM Contact WHERE Id IN : contactIds WITH SECURITY_ENFORCED];

        List<Id> contactAdminAccountIds = setupContactAdminAccountIds(contacts);
        Map<Id, BuyerAccount> buyerAccountMap = setupBuyerAccountMap(contactAdminAccountIds);
        Map<Id, BuyerGroupMember> buyerGroupMemberMap = setupBuyerGroupMemberMap(contactAdminAccountIds, opeBuyerGroup[0].Id);

        List<BuyerAccount> buyerAccountsToCreate = new List<BuyerAccount>();
        List<BuyerGroupMember> buyerGroupMembersToCreate = new List<BuyerGroupMember>();
        for(Contact contact : contacts){
            if(!buyerAccountMap.containsKey(contact.AccountId)){
                BuyerAccount administrativeAccountBuyer = new BuyerAccount();
                administrativeAccountBuyer.BuyerId = contact.AccountId;
                administrativeAccountBuyer.Name = contact.Account.Name;
                administrativeAccountBuyer.IsActive = true;
                administrativeAccountBuyer.BuyerStatus = 'Active';
                buyerAccountsToCreate.add(administrativeAccountBuyer);
            }

            if(!buyerGroupMemberMap.containsKey(contact.AccountId)){
                BuyerGroupMember bgMember = new BuyerGroupMember();
                bgMember.BuyerId = contact.AccountId;
                bgMember.BuyerGroupId = opeBuyerGroup[0].Id;
                buyerGroupMembersToCreate.add(bgMember);
            }
        }

        insertBuyerAccounts(buyerAccountsToCreate);
        insertBuyerGroupMembers(buyerGroupMembersToCreate);
        
    }

    private static List<Id> setupContactAdminAccountIds(List<Contact> contacts){
        List<Id> contactAdminAccountIds = new List<Id>();
        for(Contact contact : contacts){
            contactAdminAccountIds.add(contact.AccountId);
        }
        return contactAdminAccountIds;
    }

    private static Map<Id, BuyerAccount> setupBuyerAccountMap(List<Id> contactAdminAccountIds){
        Map<Id, BuyerAccount> buyerAccountMap = new Map<Id, BuyerAccount>();
        List<BuyerAccount> buyerAccounts = [SELECT Id, BuyerId FROM BuyerAccount WHERE BuyerId IN : contactAdminAccountIds WITH SECURITY_ENFORCED];
        for(BuyerAccount buyerAccount : buyerAccounts){
            buyerAccountMap.put(buyerAccount.BuyerId, buyerAccount);
        }
        return buyerAccountMap;
    }

    private static Map<Id, BuyerGroupMember> setupBuyerGroupMemberMap(List<Id> contactAdminAccountIds, Id opeBuyerGrpId){
        Map<Id, BuyerGroupMember> buyerGroupMemberMap = new Map<Id, BuyerGroupMember>();
        List<BuyerGroupMember> buyerGroupMembers = [SELECT Id, BuyerId FROM buyerGroupMember WHERE BuyerId IN : contactAdminAccountIds AND BuyerGroupId =: opeBuyerGrpId WITH SECURITY_ENFORCED];
        for(BuyerGroupMember buyerGroupMember : buyerGroupMembers){
            buyerGroupMemberMap.put(buyerGroupMember.BuyerId, buyerGroupMember);
        }
        return buyerGroupMemberMap;
    }

    private static void insertBuyerAccounts(List<BuyerAccount> buyerAccountsToCreate){
        List<Database.SaveResult> insertResults = new List<Database.SaveResult>();
        if(Schema.sObjectType.BuyerAccount.fields.BuyerId.isCreateable() &&
            Schema.sObjectType.BuyerAccount.fields.Name.isCreateable() &&
            Schema.sObjectType.BuyerAccount.fields.IsActive.isCreateable() &&
            Schema.sObjectType.BuyerAccount.fields.BuyerStatus.isCreateable()){
                insertResults = Database.insert(buyerAccountsToCreate, false);
        }
        for (Database.SaveResult result : insertResults){
            if (!result.isSuccess()){
                Logger.error('Error in Inserting Buyer Accounts').setDatabaseResult(result);
            }            
        }
        if(Logger.getBufferSize() > 0){
            Logger.saveLog();                
        }
    }

    private static void insertBuyerGroupMembers(List<BuyerGroupMember> buyerGroupMembersToCreate){
        List<Database.SaveResult> insertResults = new List<Database.SaveResult>();
        if(Schema.sObjectType.BuyerGroupMember.fields.BuyerId.isCreateable() &&
        Schema.sObjectType.BuyerGroupMember.fields.BuyerGroupId.isCreateable()){
            insertResults = Database.insert(buyerGroupMembersToCreate, false);
        }
        for (Database.SaveResult result : insertResults){
            if (!result.isSuccess()){
                Logger.error('Error in Inserting Buyer Group Members').setDatabaseResult(result);
            }            
        }
        if(Logger.getBufferSize() < 0){
            Logger.saveLog();                
        }
    }

    /**
     * assign ope perm set
     */
    @future
    private static void assignOPEPermSet(List<Id> userIds){
        List<PermissionSetAssignment> permSetAssignments = new List<PermissionSetAssignment>();
        PermissionSet permset = [SELECT Id FROM PermissionSet WHERE Label = 'OPE Catalogue' WITH SECURITY_ENFORCED LIMIT 1];
        List<PermissionSetAssignment> userPermSetAssignments = [SELECT Id, AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId =: permset.Id AND AssigneeId IN : userIds WITH SECURITY_ENFORCED];
        Map<Id,Id> permsetAssgnmntMap = new Map<Id,Id>();
        for(PermissionSetAssignment permsetAssgnmnt : userPermSetAssignments){
            permsetAssgnmntMap.put(permsetAssgnmnt.AssigneeId, permsetAssgnmnt.Id);
        }
        for(Id userId : userIds){
            if(!permsetAssgnmntMap.containsKey(userId)){
                PermissionSetAssignment permSetAssignment = new PermissionSetAssignment(
                    PermissionSetId = permset.Id, 
                    AssigneeId = userId
                );
                permSetAssignments.add(permSetAssignment);
            }
        }
        if(permSetAssignments.size() > 0 && 
            Schema.sObjectType.PermissionSetAssignment.fields.AssigneeId.isCreateable() &&
            Schema.sObjectType.PermissionSetAssignment.fields.PermissionSetId.isCreateable()){
            insert permSetAssignments;
        }
    }

    private static Map<Id,Id> setupAdminAcctContactMap(List<Contact> adminAcctIdContacts){
        Map<Id,Id> adminAcctContactMap = new Map<Id,Id>(); 
        for(Contact contact : adminAcctIdContacts){
            adminAcctContactMap.put(contact.Id, contact.AccountId);
        }
        return adminAcctContactMap;
    }

    private static Id getStudyStore(){
        Id studyWebStoreId;
        List<WebStore> studyWebStoreList = [SELECT Id FROM WebStore WHERE Name = 'Study' WITH SECURITY_ENFORCED LIMIT 1];
        for(WebStore webStore : studyWebStoreList){ 
            studyWebStoreId = webStore.Id; 
        }
        return studyWebStoreId;
    }

    /**
     * @return Map<Id,WebCart> : Id (User Id) , WebCart
     */
    public static Map<Id,WebCart> createWebCarts(List<Contact> contacts, List<User> users){
        Map<Id,WebCart> userWebCartMap = new Map<Id,WebCart>();
        List<WebCart> webCarts = new List<WebCart>();
        List<Contact> adminAcctIdContacts = [SELECT Id, AccountId FROM Contact WHERE Id IN : contacts WITH SECURITY_ENFORCED];
        Map<Id,Id> adminAcctContactMap = setupAdminAcctContactMap(adminAcctIdContacts); 
        Id studyWebStoreId = getStudyStore();

        List<WebCart> existingCart = [SELECT Id, Status FROM WebCart WHERE Status = 'Active' AND OwnerId IN : users WITH SECURITY_ENFORCED];
        GroupRegistrationHelper.closeWebCarts(existingCart);

        for(User user : users){
            WebCart webCart = new WebCart();
            webCart.Name = 'Cart';
            webCart.AccountId = adminAcctContactMap.get(user.ContactId);
            webCart.Status__c = 'Active';
            webCart.OwnerId = user.Id;
            webCart.WebStoreId = studyWebStoreId;
            webCarts.add(webCart);
        }
        if(Schema.sObjectType.WebCart.isCreateable()){
            insert webCarts;   
        }
        
        for(WebCart webcart : webCarts){
            userWebCartMap.put(webCart.OwnerId, webCart);
        }
        
        return userWebCartMap;
    }

    /**
     * @return Map<Id,CartDeliveryGroup> : Id (WebCart Id) , CartDeliveryGroup
     */
    public static Map<Id,CartDeliveryGroup> createCartDeliveryGroups(List<WebCart> webCarts){
        Map<Id,CartDeliveryGroup> cartDeliveryGroupMap = new Map<Id,CartDeliveryGroup>();
        List<CartDeliveryGroup> cartDeliveryGroups = new List<CartDeliveryGroup>();
        for(WebCart cartToUse : webCarts){
            CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup();
            cartDeliveryGroup.CartId = cartToUse.Id;
            cartDeliveryGroup.Name = 'Default Delivery';
            cartDeliveryGroups.add(cartDeliveryGroup);
        }

        if(Schema.sObjectType.CartDeliveryGroup.isCreateable()){                
            insert cartDeliveryGroups;
        }

        for(CartDeliveryGroup cartDelGrp : cartDeliveryGroups){
            cartDeliveryGroupMap.put(cartDelGrp.CartId, cartDelGrp);
        }

        return cartDeliveryGroupMap;
    }

    /**
     * Closes the active webcart
     */
    public static void closeWebCarts(List<WebCart> webCarts){
        for(WebCart webCart : webCarts){
            webCart.Status__c = 'Closed';
            webCart.Status = 'Closed';
        }
        if(Schema.sObjectType.WebCart.isUpdateable()){
            update webCarts;
        }
        
    }

    /**
     * creates web cart for corp bundle/soa
     */
    public static WebCart createCCEWebCart(List<User> corporateUser){
        WebCart newWebCart = new WebCart();
        if(!corporateUser.isEmpty()){
            newWebCart = CorporateBundleAndSOAHelper.createCCEWebCart(corporateUser[0]);
            if(Schema.sObjectType.WebCart.isCreateable()){
                insert newWebCart;
            }
        }else{
            throw new AuraHandledException('Please ensure Corporate Portal Administrator is enabled access to the portal before registering contacts.');
        }
        return newWebCart;
    }

    /**
     * Creates product ledgers
     */
    public static void createProductLedgers(List<hed__Course_Enrollment__c> courseConnectionList, Id priceBookEntryId, Boolean isCorporateBundlePricing){
        Map<String,Asset> assetRecord = new Map<String,Asset>();
        if(isCorporateBundlePricing){
            List<String> pbEntryIds = new List<String>();
            pbEntryIds.add(priceBookEntryId);
            assetRecord = CorporateBundleAndSOAHelper.getAsset(pbEntryIds);
        }
        if(assetRecord.containsKey(priceBookEntryId)){
            CorporateBundleAndSOAHelper.createProductLedgerRecords(assetRecord.get(priceBookEntryId).Id, courseConnectionList);
        }
    }

    /**
     * Upsert contacts
     */
    public static void upsertContacts(List<Contact> contacts){
        for(Contact contact : contacts){
            if(contact.Id == null){
                contact.RecordTypeId = RT_CONTACT_PERSON_ID;
            }
        }
        if(Schema.sObjectType.Contact.isUpdateable()){
            ContactsDAO.newInstance().upsertRecords(contacts, false, AccessLevel.SYSTEM_MODE);
        }
    }

    /**
     * Helper methods
     */
    public static Map<Id,User> setUserMap(List<Contact> contacts){
        Map<Id,User> userMap = new Map<Id,User>();
        List<User> existingUsers = [
            SELECT Id, ContactId 
            FROM User 
            WHERE ContactId  IN : contacts 
            AND IsActive = true WITH SECURITY_ENFORCED
        ];

        for(User user : existingUsers){
            userMap.put(user.ContactId, user);
        }
        return userMap;
    }

    public static Map<Id,User> setUserIdMap(List<User> users){
        Map<Id,User> userIdMap = new Map<Id,User>();
        for(User user : users){
            userIdMap.put(user.Id, user);
        }
        return userIdMap;
    }

    public static List<Id> setUserIds(List<User> users){
        List<Id> userIds = new List<Id>();
        for(User user : users){
            userIds.add(user.Id);
        }
        return userIds;
    }

    public static Integer getAvailableSeat(String offeringId){
        Integer response;

        List<Program_Offering__c> programOfferingList = new List<Program_Offering__c>([
            SELECT Available_Seats__c FROM Program_Offering__c WHERE Id =: offeringId WITH SECURITY_ENFORCED LIMIT 1
        ]);

        List<hed__Course_Offering__c> courseOfferingList = new List<hed__Course_Offering__c>([
            SELECT Available_Seats__c FROM hed__Course_Offering__c WHERE Id =: offeringId WITH SECURITY_ENFORCED LIMIT 1
        ]);

        if(!programOfferingList.isEmpty()){
            for(Program_Offering__c progOfferring : programOfferingList){
                response = Integer.valueOf(progOfferring.Available_Seats__c);
            }
        }else{
            for(hed__Course_Offering__c courseOffering : courseOfferingList){
                response = Integer.valueOf(courseOffering.Available_Seats__c);
            }
        }

        return response;
    }

    public static List<MobileLocaleWrapper> getMobileLocaleOptions() {
        List<MobileLocaleWrapper> mobileLocaleWrapperList = new List<MobileLocaleWrapper>();
        try {
            List<Mobile_Country_Code__mdt> mobileCountryCodeMDTList = [
                SELECT Id, Display_Name__c, Mobile_Coutnry_Code__c, Loqate_Locale__c
                FROM Mobile_Country_Code__mdt WITH SECURITY_ENFORCED
                ORDER BY Display_Name__c 
            ];
            if(mobileCountryCodeMDTList.size() > 0) {
                for (Mobile_Country_Code__mdt mobileCountryCodeMDT : mobileCountryCodeMDTList) {
                    MobileLocaleWrapper mobileLocaleWrapper = new MobileLocaleWrapper();
                    mobileLocaleWrapper.label = mobileCountryCodeMDT.Display_Name__c;
                    mobileLocaleWrapper.value = mobileCountryCodeMDT.Display_Name__c;
                    mobileLocaleWrapper.countryCode = mobileCountryCodeMDT.Mobile_Coutnry_Code__c;
                    mobileLocaleWrapper.conMobileLocale = mobileCountryCodeMDT.Loqate_Locale__c;
                    mobileLocaleWrapperList.add(mobileLocaleWrapper);
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return mobileLocaleWrapperList;
    } 

    public static Map<Id,ContactAndCartId> setUpContactCartMap(List<CartItem> cartItems){
        Map<Id,ContactAndCartId> contactCartMap = new Map<Id,ContactAndCartId>();
        for(CartItem cartItem : cartItems){
            ContactAndCartId conAndCartIds = new ContactAndCartId();
            conAndCartIds.webCartId = cartItem.CartId;
            conAndCartIds.cartItemId = cartItem.Id;
            contactCartMap.put(cartItem.Contact__c, conAndCartIds);
        }
        return contactCartMap;
    }

    public static Map<Id,Id> setUpContactAndCartItemMap(List<CartItem> cartItems){
        Map<Id,Id> contactAndCartItemMap = new Map<Id,Id>();
        for(CartItem cartItem : cartItems){
            contactAndCartItemMap.put(cartItem.Contact__c, cartItem.Id);
        }
        return contactAndCartItemMap;
    }    

    public class MobileLocaleWrapper {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
        @AuraEnabled
        public String conMobileLocale;
        @AuraEnabled
        public String countryCode;
    }

    public class ContactAndCartId {
        public Id contactId;
        public Id webCartId;
        public Id cartItemId;
    }
}