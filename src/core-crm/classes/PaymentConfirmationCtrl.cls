/**
 * @description Controller Class for cartDetails LWC
 * @see ../lwc/productDetails
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                             |
      |---------------------------|-----------------------|----------------------|--------------------------------------------|
      | john.m.tambasen           | Jun 2, 2022           | DEPP-787             | Created file                               |

*/
public without sharing class PaymentConfirmationCtrl {

    /**
     * @description get OPE Product Category Id
     * @return OPE Product Category Id
     */
    @AuraEnabled(cacheable=true)
    public static ProductCategory getOPEProductCateg(){

        ProductCategory prodCateg = new ProductCategory();

        prodCateg = [
            SELECT Id
            FROM ProductCategory
            WHERE Name = 'Products' AND Catalog.Name = 'Study Catalog'
            LIMIT 1
        ];

        return prodCateg;
    }

    /**
    * @description fetches cart data
    * @param externalId - External_Id__c of the WebCart
    * @return webCartData - WebCartData data type that contains the webcart and cartitems
    */
    @AuraEnabled(cacheable=true)
    public static CartData getCartData(String externalId, String userId){

        //get the contact ID of the current user
        String contactEmail = [SELECT Contact.Email FROM User WHERE Id = :userId LIMIT 1].Contact.Email;

        //instantiate variables
        CartData myCartData = new CartData();
        List<CartItemsWrapper> myCartItemsList = new List<CartItemsWrapper>();

        //query the cart with the passed external ID 
        WebCart webCartData = [
            SELECT 
                Id, 
                Name, 
                External_Id__c,
                Discount_Applied__c,
                Payment_Method__c
            FROM WebCart
            WHERE External_Id__c = :externalId 
            LIMIT 1];

        //query the cart items with the retrieved WebCart ID
        List<CartItem> cartItemList = [
            SELECT 
                Id, 
                Name, 
                Product2Id, 
                Pricebook_Entry_ID__c, 
                Course_Offering__c,
                Course_Offering__r.hed__Start_Date__c,
                Course_Offering__r.Delivery_Type__c,
                Program_Offering__c,
                Program_Offering__r.Start_Date__c,
                Program_Offering__r.Delivery_Type__c
            FROM CartItem
            WHERE CartId = :webCartData.Id];

        //create a set for the pricebook entries
        Set<Id> pbentryIds = new Set<Id>();
        Double mySubtotal = 0;

        //loop on the returned list to populate price book entrie IDs
        for (CartItem currentCart : cartItemList) {
            pbentryIds.add(currentCart.Pricebook_Entry_ID__c);
        }
    
        //create map of price book entry for linking with the cart items
        Map<Id, PricebookEntry> pbEntryMap = new Map<Id, PricebookEntry>([
            SELECT 
                Id, 
                Pricebook2.Name, 
                UnitPrice
            FROM PricebookEntry
            WHERE Id IN :pbentryIds]);

        //loop for popoulating the returned object
        for(CartItem currentCart : cartItemList) {
            CartItemsWrapper cartItemsWrapper = new CartItemsWrapper();
    
            //populate data
            cartItemsWrapper.cartItemId = currentCart.Id;
            cartItemsWrapper.productName = currentCart.Name;
    
            //if course offering field is not empty (Course offering product)
            if(currentCart.Course_Offering__c != null){
    
                //set data from the Course_Offering__c
                cartItemsWrapper.startDate = Datetime.newInstance(
                    currentCart.Course_Offering__r.hed__Start_Date__c,
                    Time.newInstance(0, 0, 0, 0)
                )
                .format('dd MMM yyyy');

                cartItemsWrapper.deliveryType = currentCart.Course_Offering__r.Delivery_Type__c;

            //else it is a program offering product
            } else {
    
                //set data from the Program_Offering__c
                cartItemsWrapper.startDate = Datetime.newInstance(
                    currentCart.Program_Offering__r.Start_Date__c,
                    Time.newInstance(0, 0, 0, 0)
                )
                .format('dd MMM yyyy');

                cartItemsWrapper.deliveryType = currentCart.Program_Offering__r.Delivery_Type__c;
            }
    
            cartItemsWrapper.pbName = pbEntryMap.get(currentCart.Pricebook_Entry_ID__c).Pricebook2.Name;
            cartItemsWrapper.unitPrice = pbEntryMap.get(currentCart.Pricebook_Entry_ID__c).UnitPrice;

            mySubtotal = mySubtotal + cartItemsWrapper.unitPrice;

            myCartItemsList.add(cartItemsWrapper);
        }

        //popoulate return object
        myCartData.contactEmail = contactEmail;
        myCartData.cartId = webCartData.Id;
        myCartData.cartItemsList = myCartItemsList;
        myCartData.subTotal = mySubtotal;
        myCartData.discountTotal = webCartData.Discount_Applied__c;
        myCartData.grandTotal = mySubtotal - webCartData.Discount_Applied__c;
        myCartData.paymentMethod = webCartData.Payment_Method__c;

        // return myCartData;
        return myCartData;
    }

    public class CartData{
        @AuraEnabled public String contactEmail;
        @AuraEnabled public String cartId;
        @AuraEnabled public List<CartItemsWrapper> cartItemsList;
        @AuraEnabled public Double subTotal;
        @AuraEnabled public Double discountTotal;
        @AuraEnabled public Double grandTotal;
        @AuraEnabled public String paymentMethod;
    }

    public class CartItemsWrapper{
        @AuraEnabled public String cartItemId;
        @AuraEnabled public String productName;
        @AuraEnabled public String startDate;
        @AuraEnabled public String deliveryType;
        @AuraEnabled public String pbName;
        @AuraEnabled public Double unitPrice;
    }

    /**
    * @description creates hed__Course_Enrollment__c record
    * @param cartId - ID of the WebCart
    * @return webCartData - WebCartData data type that contains the webcart and cartitems 
    */
    @AuraEnabled(cacheable=false)
    public static List<hed__Course_Enrollment__c> createCourseConnection(String cartId, String userId, Double amount, String tranId, String paymentMethod, String paidInFull){

        Id studentRecordTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Id studentProgramRecordTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Student - Program').getRecordTypeId();

        List<hed__Course_Enrollment__c> courseConnectionInsert = New List<hed__Course_Enrollment__c>();

        //get the contact ID of the current user
        String contactId = [SELECT ContactId FROM User WHERE Id = :userId LIMIT 1].ContactId;

        //retrieve cart item list
        List<CartItem> cartItemList = [
            SELECT
                Id,
                Course_Offering__c,
                Program_Offering__c,
                Program_Offering__r.hed_Program_Plan__c,
                Pricebook_Entry_ID__c
            FROM CartItem
            WHERE CartId = :cartId];

        //create a set for the pricebook entries and program plans
        Set<Id> pbentryIds = new Set<Id>();
        Set<Id> programPlanIds = new Set<Id>();

        //loop on the returned list to populate price book entrie IDs
        for (CartItem currentCart : cartItemList) {
            pbentryIds.add(currentCart.Pricebook_Entry_ID__c);
            programPlanIds.add(currentCart.Program_Offering__r.hed_Program_Plan__c);
        }
    
        //create map of price book entry for linking with the cart items
        Map<Id, PricebookEntry> pbEntryMap = new Map<Id, PricebookEntry>([
            SELECT 
                Id, 
                Pricebook2.Name, 
                UnitPrice
            FROM PricebookEntry
            WHERE Id IN :pbentryIds]);

        //create map of program plan
        Map<Id, hed__Program_Plan__c> programPlanMap = new Map<Id, hed__Program_Plan__c>([
            SELECT 
                Id, 
                Name, 
                RecordTypeId, 
                (Select Id, Name From Program_Offering__r)
            FROM hed__Program_Plan__c
            WHERE Id IN :programPlanIds]);

        //loop on the returned list to populate price book entrie IDs
        for (CartItem currentCart : cartItemList) {

            //single record to be inserted
            hed__Course_Enrollment__c tempCourseConnectionMain = new hed__Course_Enrollment__c();

            //populate data for course offering
            tempCourseConnectionMain.hed__Contact__c = contactId;
            tempCourseConnectionMain.hed__Status__c = 'Active';
            tempCourseConnectionMain.Amount__c = amount;
            tempCourseConnectionMain.Transaction_ID__c = tranId;
            tempCourseConnectionMain.Payment_Method__c = paymentMethod;
            tempCourseConnectionMain.Paid_in_Full__c = paidInFull;
            tempCourseConnectionMain.Cart_Item__c = currentCart.Id;

            //check if current pricebook is for group booking
            if(pbEntryMap.get(currentCart.Pricebook_Entry_ID__c).Pricebook2.Name == 'Group Booking'){
                tempCourseConnectionMain.Is_Group_Registered__c = true;

            } else{
                tempCourseConnectionMain.Is_Group_Registered__c = false;
            }

            //identify if the current cart item is course or program offering
            if(currentCart.Course_Offering__c != null){
                tempCourseConnectionMain.RecordTypeId = studentRecordTypeId;
                tempCourseConnectionMain.hed__Course_Offering__c = currentCart.Course_Offering__c;

            } else{
                tempCourseConnectionMain.RecordTypeId = studentProgramRecordTypeId;
                tempCourseConnectionMain.Program_Offering__c = currentCart.Program_Offering__c;

                //get the program offerings under the same program plan of the current program offering
                List<Program_Offering__c> programOfferingSiblings = programPlanMap.get(currentCart.Program_Offering__r.hed_Program_Plan__c).Program_Offering__r;

                //loop on the returned list to populate price book entrie IDs
                for (Program_Offering__c currentProgramOfferingSibling : programOfferingSiblings) {

                    //single record to be inserted
                    hed__Course_Enrollment__c tempCourseConnectionSub = new hed__Course_Enrollment__c();

                    //populate data for course offering
                    tempCourseConnectionSub.hed__Contact__c = contactId;
                    tempCourseConnectionSub.hed__Status__c = 'Active';
                    tempCourseConnectionSub.Amount__c = amount;
                    tempCourseConnectionSub.Transaction_ID__c = tranId;
                    tempCourseConnectionSub.Payment_Method__c = paymentMethod;
                    tempCourseConnectionSub.Paid_in_Full__c = paidInFull;
                    tempCourseConnectionSub.Cart_Item__c = currentCart.Id;

                    //check if current pricebook is for group booking
                    if(pbEntryMap.get(currentCart.Pricebook_Entry_ID__c).Pricebook2.Name == 'Group Booking'){
                        tempCourseConnectionSub.Is_Group_Registered__c = true;

                    } else{
                        tempCourseConnectionSub.Is_Group_Registered__c = false;
                    }

                    //program offering siblings record type should be student
                    tempCourseConnectionSub.RecordTypeId = studentRecordTypeId;
                    tempCourseConnectionSub.Program_Offering__c = currentCart.Program_Offering__c;

                    courseConnectionInsert.add(tempCourseConnectionSub);
                }
            }

            courseConnectionInsert.add(tempCourseConnectionMain);
        }

        //insert the record
        insert courseConnectionInsert;

        return courseConnectionInsert;
    }

    /**
     * @description updates the cart status
     * @param cartId - cart item ID
     * @param cartStatus - cart status
     */
    @AuraEnabled
    public static void updateWebCart(String cartId, String paymentStatus, String invoice, String receipt, Double amountPaid, String paymentUrl) {
        
        //get the cart
        WebCart webCart = [
            SELECT 
                Id, 
                Name, 
                Payment_Status__c,
                Invoice_Number__c,
                Receipt_Number__c,
                Amount_Paid__c,
                Payment_URL__c,
                Status,
                Status__c
            FROM WebCart 
            WHERE Id = :cartId
            LIMIT 1];

        //update the cart based on the status received
        webCart.Payment_Status__c = paymentStatus;
        webCart.Invoice_Number__c = invoice;
        webCart.Receipt_Number__c = receipt;
        webCart.Amount_Paid__c = amountPaid;
        webCart.Payment_URL__c = paymentUrl;
        webCart.Status__c = 'Closed';
        webCart.Status = 'Closed';

        update webCart;
    }
}
  