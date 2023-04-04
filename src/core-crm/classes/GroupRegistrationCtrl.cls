/**
 * @description Controller Class for Manage Bulk Registration
 * @see ../lwc/manageGroupRegistration
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                     |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------------------------------|
      | eccarius.karl.munoz            | January 25, 2023      | DEPP-4684              | Created file                                                       |
      |                                |                       |                        |                                                                    |
 */
public with sharing class GroupRegistrationCtrl {

    private static string studentRT = System.Label.RT_CourseConnection_Student;
    private static Id studentRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get(studentRT).getRecordTypeId();
    private static string studentProgramRT = System.Label.RT_CourseConnection_Student_Program;
    private static Id studentProgramRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get(studentProgramRT).getRecordTypeId();

    private static final String TAILORED_EXECUTIVE_PROGRAM = 'Tailored Executive Program';      
    private static RegistrationDetailParams registrationDetailsParams;
    
    @AuraEnabled(cacheable=true)
    public static Integer getAvailableSeat(String offeringId){
        return GroupRegistrationHelper.getAvailableSeat(offeringId);
    }

    @AuraEnabled(cacheable=true)
    public static List<GroupRegistrationHelper.MobileLocaleWrapper> getMobileLocaleOptions() {
        return GroupRegistrationHelper.getMobileLocaleOptions();
    }        

    @AuraEnabled
    public static String bulkRegister(RegistrationDetails registrationDetails){
        String response = '';
        
        mapRegistrationDetails(registrationDetails);
        GroupRegistrationHelper.upsertContacts(registrationDetailsParams.contactList);
        if(!String.isBlank(registrationDetailsParams.priceBookEntryId)){  
            if(registrationDetailsParams.isCorporateBundlePricing || registrationDetailsParams.isSOAPricing){   
                List<User> corporateUser = CorporateBundleAndSOAHelper.getCorporateUser(registrationDetailsParams.priceBookEntry.PriceBook2Id);  

                WebCart newWebCart = GroupRegistrationHelper.createCCEWebCart(corporateUser); 
                List<WebCart> cceWebCarts = new List<WebCart>();
                cceWebCarts.add(newWebCart);

                Map<Id,CartDeliveryGroup> cartDeliveryGroupMap = GroupRegistrationHelper.createCartDeliveryGroups(cceWebCarts);
                CartDeliveryGroup cartDeliveryGroup = cartDeliveryGroupMap.get(newWebCart.Id);

                Map<Id,Id> contactAndCartItemMap = createCCECartItems(newWebCart.Id, cartDeliveryGroup.Id);

                GroupRegistrationHelper.closeWebCarts(cceWebCarts);

                List<hed__Course_Enrollment__c> courseConnectionList = createCBSOACourseConnections(registrationDetailsParams.contactList, newWebCart.Id, contactAndCartItemMap);

                GroupRegistrationHelper.createProductLedgers(courseConnectionList, registrationDetailsParams.priceBookEntryId, registrationDetailsParams.isCorporateBundlePricing);
            }else{
                Map<Id,User> userMap = GroupRegistrationHelper.createUsers(registrationDetailsParams.contactList);   
                Map<Id,WebCart> webCartMap = GroupRegistrationHelper.createWebCarts(registrationDetailsParams.contactList, userMap.values());      
                Map<Id,CartDeliveryGroup> cartDeliveryGroupMap = GroupRegistrationHelper.createCartDeliveryGroups(webCartMap.values());
                Map<Id,GroupRegistrationHelper.ContactAndCartId> contactAndCartMap = createCartItems(userMap, webCartMap, cartDeliveryGroupMap);
                GroupRegistrationHelper.closeWebCarts(webCartMap.values());
                createCourseConnections(contactAndCartMap);
            }
        }else{
            createCourseConnectionsTailored(registrationDetailsParams.contactList);
        }

        response = 'Success';

        return response;
    }

    /**
     * Map registration details from ui component to global variables
     */
    private static void mapRegistrationDetails(RegistrationDetails registrationDetails){
        registrationDetailsParams = new RegistrationDetailParams();
        registrationDetailsParams.prescribedProgram = registrationDetails.prescribedProgram;
        registrationDetailsParams.offeringId = registrationDetails.offeringId;
        registrationDetailsParams.discountAmount = registrationDetails.discountAmount;
        registrationDetailsParams.promotionId = registrationDetails.promotionId;
        registrationDetailsParams.contactList = registrationDetails.contacts;
        registrationDetailsParams.priceBookEntryId = registrationDetails.priceBookEntryId;

        List<PricebookEntry> pbList = [    
            SELECT Id, UnitPrice, Product2Id, PriceBook2Id, PriceBook2.Name 
            FROM PricebookEntry 
            WHERE Id =: registrationDetails.priceBookEntryId 
            WITH SECURITY_ENFORCED LIMIT 1
        ];

        Product2 product = ManageRegistrationSectionHelper.getProduct(registrationDetails.offeringId, registrationDetails.prescribedProgram);
        registrationDetailsParams.productName = product.Name;
        registrationDetailsParams.isTailored = product != null && product.Product_Category__c == TAILORED_EXECUTIVE_PROGRAM ? true : false;

        for(PricebookEntry pb : pbList){
            registrationDetailsParams.isCorporateBundlePricing = pb.PriceBook2.Name.startsWith('Corporate Bundle');
            registrationDetailsParams.isSOAPricing = pb.PriceBook2.Name.startsWith('SOA');
            registrationDetailsParams.priceBookEntry = pb;
            registrationDetailsParams.amount = pb.UnitPrice - registrationDetails.discountAmount;
        }
    }

    private static Map<Id,GroupRegistrationHelper.ContactAndCartId> createCartItems(Map<Id,User> userMap, Map<Id,WebCart> webCartMap, Map<Id,CartDeliveryGroup> cartDeliveryGroupMap){
        Map<Id,GroupRegistrationHelper.ContactAndCartId> contactCartMap = new Map<Id,GroupRegistrationHelper.ContactAndCartId>();
        List<CartItem> cartItems = new List<CartItem>();
        for(User user : userMap.values()){
            CartItem cartItem = new CartItem();
            cartItem.CartId = webCartMap.get(user.Id).Id;
            cartItem.Name = registrationDetailsParams.productName;
            cartItem.CartDeliveryGroupId = cartDeliveryGroupMap.get(webCartMap.get(user.Id).Id).Id;
            
            if(!registrationDetailsParams.prescribedProgram){
                cartItem.Course_Offering__c = registrationDetailsParams.offeringId;
            }else{
                cartItem.Program_Offering__c = registrationDetailsParams.offeringId;
            }
            cartItem.Product2Id = registrationDetailsParams.priceBookEntry.Product2Id;
            cartItem.Pricebook_Entry_ID__c = registrationDetailsParams.priceBookEntry.Id;
            cartItem.Quantity = 1;
            cartItem.TotalPrice = registrationDetailsParams.priceBookEntry.UnitPrice;
            cartItem.Type = 'Product';
            cartItem.Contact__c = userMap.get(user.Id).ContactId;
            cartItem.Promotion__c = registrationDetailsParams.promotionId;
            cartItem.Promotion_Price__c = registrationDetailsParams.discountAmount;
            cartItems.add(cartItem);
        }
        insertCartItems(cartItems);
        contactCartMap = GroupRegistrationHelper.setUpContactCartMap(cartItems);
        return contactCartMap;
    }    

    private static Map<Id,Id> createCCECartItems(Id webCartId, Id cartDeliveryGrpId){
        Map<Id,Id> contactAndCartItemMap = new Map<Id,Id>();
        List<CartItem> cartItems = new List<CartItem>();
        for(Contact con : registrationDetailsParams.contactList){
            CartItem cartItem = new CartItem();
            cartItem.CartId = webCartId;
            cartItem.Name = registrationDetailsParams.productName;
            cartItem.CartDeliveryGroupId = cartDeliveryGrpId;
            if(!registrationDetailsParams.prescribedProgram){
                cartItem.Course_Offering__c = registrationDetailsParams.offeringId;
            }else{
                cartItem.Program_Offering__c = registrationDetailsParams.offeringId;
            }
            cartItem.Product2Id = registrationDetailsParams.priceBookEntry.Product2Id;
            cartItem.Pricebook_Entry_ID__c = registrationDetailsParams.priceBookEntry.Id;
            cartItem.Quantity = 1;
            cartItem.TotalPrice = registrationDetailsParams.priceBookEntry.UnitPrice;
            cartItem.Type = 'Product';
            cartItem.Contact__c = con.Id;
            cartItem.Promotion__c = registrationDetailsParams.promotionId;
            cartItem.Promotion_Price__c = registrationDetailsParams.discountAmount;
            cartItems.add(cartItem);
        }
        insertCartItems(cartItems);
        contactAndCartItemMap = GroupRegistrationHelper.setUpContactAndCartItemMap(cartItems);
        return contactAndCartItemMap;
    }

    private static List<hed__Course_Enrollment__c> createCBSOACourseConnections(List<Contact> contacts, Id webCartId, Map<Id,Id> contactAndCartItemMap){
        List<hed__Course_Enrollment__c> courseConnectionList = new List<hed__Course_Enrollment__c>();
        List<Id> contactForChildIds = new List<Id>();

        String paidInFull = 'Yes';
        String paymentMethod = (registrationDetailsParams.amount == 0 && !registrationDetailsParams.isTailored) ? 'No Charge' : 'Admin Added';

        for(Contact contact : contacts){
            hed__Course_Enrollment__c newCourseConnection = new hed__Course_Enrollment__c();
            newCourseConnection.hed__Contact__c =  contact.Id;
            newCourseConnection.hed__Status__c = 'Active';
            newCourseConnection.Paid_in_Full__c = paidInFull;
            newCourseConnection.Payment_Method__c = paymentMethod;
            newCourseConnection.Amount__c = registrationDetailsParams.amount;
            newCourseConnection.Cart_ID__c = webCartId;
            newCourseConnection.Cart_Item__c = contactAndCartItemMap.get(contact.Id);
            if(!registrationDetailsParams.prescribedProgram){
                newCourseConnection.hed__Course_Offering__c = registrationDetailsParams.offeringId;
                newCourseConnection.RecordTypeId = studentRecTypeId;
                courseConnectionList.add(newCourseConnection);
            }else{
                newCourseConnection.Program_Offering__c = registrationDetailsParams.offeringId;
                newCourseConnection.RecordTypeId = studentProgramRecTypeId;
                courseConnectionList.add(newCourseConnection);   
                contactForChildIds.add(contact.Id);
            }
        }

        List<hed__Course_Offering__c> childOfferings = [SELECT Id, Program_Offering__c FROM hed__Course_Offering__c WHERE Program_Offering__c =: registrationDetailsParams.offeringId WITH SECURITY_ENFORCED];
        for(hed__Course_Offering__c childOffering : childOfferings){
            for(Id contactId : contactForChildIds){
                hed__Course_Enrollment__c childCourseConnection = new hed__Course_Enrollment__c();
                childCourseConnection.hed__Contact__c =  contactId;
                childCourseConnection.hed__Status__c = 'Active';
                childCourseConnection.Paid_in_Full__c = paidInFull;
                childCourseConnection.Payment_Method__c =  paymentMethod;
                childCourseConnection.Amount__c = registrationDetailsParams.amount;
                childCourseConnection.Program_Offering__c = registrationDetailsParams.offeringId;
                childCourseConnection.hed__Course_Offering__c = childOffering.Id;
                childCourseConnection.RecordTypeId = studentRecTypeId;
                courseConnectionList.add(childCourseConnection);
            }
        }
        insertCourseConnections(courseConnectionList);
        return courseConnectionList;
    }

    private static void createCourseConnections(Map<Id,GroupRegistrationHelper.ContactAndCartId> contactAndCartMap){
        List<hed__Course_Enrollment__c> courseConnectionList = new List<hed__Course_Enrollment__c>();
        List<Id> contactForChildIds = new List<Id>();

        String paidInFull = registrationDetailsParams.isTailored ? 'Contract' : 'Yes';
        String paymentMethod = (registrationDetailsParams.amount == 0 && !registrationDetailsParams.isTailored) ? 'No Charge' : 'Admin Added';

        for(Id contactId : contactAndCartMap.keySet()){
            hed__Course_Enrollment__c newCourseConnection = new hed__Course_Enrollment__c();
            newCourseConnection.hed__Contact__c =  contactId;
            newCourseConnection.hed__Status__c = 'Active';
            newCourseConnection.Paid_in_Full__c = paidInFull;
            newCourseConnection.Payment_Method__c = paymentMethod;
            newCourseConnection.Amount__c = registrationDetailsParams.amount;
            newCourseConnection.Cart_ID__c = contactAndCartMap.get(contactId).webCartId;
            newCourseConnection.Cart_Item__c = contactAndCartMap.get(contactId).cartItemId;
            if(!registrationDetailsParams.prescribedProgram){
                newCourseConnection.hed__Course_Offering__c = registrationDetailsParams.offeringId;
                newCourseConnection.RecordTypeId = studentRecTypeId;
                courseConnectionList.add(newCourseConnection);
            }else{
                newCourseConnection.Program_Offering__c = registrationDetailsParams.offeringId;
                newCourseConnection.RecordTypeId = studentProgramRecTypeId;
                courseConnectionList.add(newCourseConnection);   
                contactForChildIds.add(contactId);
            }
        }

        List<hed__Course_Offering__c> childOfferings = [SELECT Id, Program_Offering__c FROM hed__Course_Offering__c WHERE Program_Offering__c =: registrationDetailsParams.offeringId WITH SECURITY_ENFORCED];
        for(hed__Course_Offering__c childOffering : childOfferings){
            for(Id contactId : contactForChildIds){
                hed__Course_Enrollment__c childCourseConnection = new hed__Course_Enrollment__c();
                childCourseConnection.hed__Contact__c =  contactId;
                childCourseConnection.hed__Status__c = 'Active';
                childCourseConnection.Paid_in_Full__c = paidInFull;
                childCourseConnection.Payment_Method__c =  paymentMethod;
                childCourseConnection.Amount__c = registrationDetailsParams.amount;
                childCourseConnection.Program_Offering__c = registrationDetailsParams.offeringId;
                childCourseConnection.hed__Course_Offering__c = childOffering.Id;
                childCourseConnection.RecordTypeId = studentRecTypeId;
                courseConnectionList.add(childCourseConnection);
            }
        }
        insertCourseConnections(courseConnectionList);
    }

    private static void createCourseConnectionsTailored(List<Contact> contacts){
        List<hed__Course_Enrollment__c> courseConnectionList = new List<hed__Course_Enrollment__c>();
        List<Contact> contactForChild = new List<Contact>();
        for(Contact contact : contacts){
            hed__Course_Enrollment__c newCourseConnection = new hed__Course_Enrollment__c();
            newCourseConnection.hed__Contact__c =  contact.Id;
            newCourseConnection.hed__Status__c = 'Active';
            newCourseConnection.Paid_in_Full__c = 'Contract';
            newCourseConnection.Payment_Method__c = 'Admin Added';
            newCourseConnection.Amount__c = registrationDetailsParams.amount;
            if(!registrationDetailsParams.prescribedProgram){
                newCourseConnection.hed__Course_Offering__c = registrationDetailsParams.offeringId;
                newCourseConnection.RecordTypeId = studentRecTypeId;
                courseConnectionList.add(newCourseConnection);
            }else{
                newCourseConnection.Program_Offering__c = registrationDetailsParams.offeringId;
                newCourseConnection.RecordTypeId = studentProgramRecTypeId;
                courseConnectionList.add(newCourseConnection);    
                contactForChild.add(contact);   
            }
        }

        for(hed__Course_Offering__c childOffering : [SELECT Id FROM hed__Course_Offering__c WHERE Program_Offering__c =: registrationDetailsParams.offeringId WITH SECURITY_ENFORCED]){
            for(Contact c : contactForChild){
                hed__Course_Enrollment__c childCourseConnection = new hed__Course_Enrollment__c();
                childCourseConnection.hed__Contact__c = c.Id;
                childCourseConnection.hed__Status__c = 'Active';
                childCourseConnection.Paid_in_Full__c = 'Contract';
                childCourseConnection.Payment_Method__c = 'Admin Added';
                childCourseConnection.Amount__c = registrationDetailsParams.amount;
                childCourseConnection.Program_Offering__c = registrationDetailsParams.offeringId;
                childCourseConnection.hed__Course_Offering__c = childOffering.Id;
                childCourseConnection.RecordTypeId = studentRecTypeId;
                courseConnectionList.add(childCourseConnection);
            }
        }
        insertCourseConnections(courseConnectionList);
    }    

    private static void insertCartItems(List<CartItem> cartItems){
        if(Schema.sObjectType.CartItem.isCreateable()){
            insert cartItems;
        }
    }

    private static void insertCourseConnections(List<hed__Course_Enrollment__c> courseConnectionList){
        if(Schema.sObjectType.hed__Course_Enrollment__c.isCreateable()){
            insert courseConnectionList;
        }
    }

    public class RegistrationDetails{
        @AuraEnabled
        public List<Contact> contacts{ get; set; }
        @AuraEnabled
        public String offeringId{ get; set; }
        @AuraEnabled
        public Boolean prescribedProgram{ get; set; }
        @AuraEnabled
        public String priceBookEntryId{ get; set; }        
        @AuraEnabled
        public Decimal discountAmount { get; set; }
        @AuraEnabled
        public Id promotionId { get; set; }
    }

    private class RegistrationDetailParams{
        private List<Contact> contactList;
        private String productName = '';
        private String offeringId = '';
        private Boolean isCorporateBundlePricing = false;
        private Boolean isSOAPricing = false;
        private Boolean isTailored = false;
        private Boolean prescribedProgram = false;
        private PricebookEntry priceBookEntry;
        private Decimal amount = 0;
        private Decimal discountAmount = 0;
        private Id promotionId;
        private Id priceBookEntryId;
   }

}