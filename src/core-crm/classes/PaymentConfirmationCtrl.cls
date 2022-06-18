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
   * @description checks if user owns the cart
   * @param  externalId - externalId
   * @param userId - userId
   */
  @AuraEnabled
  public static boolean checkCartOwnerShip(String externalId, String userId) {
    //get the cart
    List<WebCart> ownedCart = [SELECT Id FROM WebCart WHERE External_Id__c = :externalId AND OwnerId =: userId LIMIT 1];
    return !ownedCart.isEmpty();
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
                Payment_Method__c,
                Cart_Payment__c
            FROM WebCart
            WHERE External_Id__c = :externalId 
            AND OwnerId =:userId
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
        myCartData.cartPayment = webCartData.Cart_Payment__c;
        if(webCartData.Discount_Applied__c!= null){
            myCartData.grandTotal = mySubtotal - webCartData.Discount_Applied__c;
        }else{
            myCartData.grandTotal = mySubtotal;
        }
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
        @AuraEnabled public String cartPayment;
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
    public static void createCourseConnection(String cartId, String userId, Double amount, String tranId, String paymentMethod, String paidInFull){

        Id studentRecordTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Id studentProgramRecordTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Student - Program').getRecordTypeId();
        Set<String> programOfferingIds = new Set<String>();
        Map<String,Set<String>> programToChild = new Map<String,Set<String>>();
        List<hed__Course_Enrollment__c> existingCourseCon = new List<hed__Course_Enrollment__c>();
        existingCourseCon = [SELECT Id, Cart_Item__c FROM hed__Course_Enrollment__c WHERE Cart_ID__c =: cartId];
        List<hed__Course_Enrollment__c> updateCourseCon = new List<hed__Course_Enrollment__c>();
        List<hed__Course_Enrollment__c> courseConnectionInsert = new List<hed__Course_Enrollment__c>();

        //get the contact ID of the current user
        String contactId = [SELECT ContactId FROM User WHERE Id = :userId LIMIT 1].ContactId;
        if(!existingCourseCon.isEmpty()){
            for(hed__Course_Enrollment__c courseCon: existingCourseCon){
                courseCon.Amount__c = amount;
                courseCon.Transaction_ID__c = tranId;
                courseCon.Payment_Method__c = paymentMethod;
                courseCon.Paid_in_Full__c = paidInFull;
                updateCourseCon.add(courseCon);
            }
            update updateCourseCon;
        }else{
            //retrieve cart item list
            List<CartItem> cartItemList = [
                SELECT
                    Id,
                    Course_Offering__c,
                    Program_Offering__c,
                    Pricebook_Entry_ID__c
                FROM CartItem
                WHERE CartId = :cartId];

            //create a set for the pricebook entries and program plans
            Set<Id> pbentryIds = new Set<Id>();

            //loop on the returned list to populate price book entrie IDs
            for (CartItem currentCart : cartItemList) {
                pbentryIds.add(currentCart.Pricebook_Entry_ID__c);
                programOfferingIds.add(currentCart.Program_Offering__c);
                
            }

            List<hed__Course_Offering__c> getChildCourseOffering = new List<hed__Course_Offering__c>();
            getChildCourseOffering = [SELECT Id, Program_Offering__c FROM hed__Course_Offering__c WHERE Program_Offering__c IN: programOfferingIds];

            for(hed__Course_Offering__c co: getChildCourseOffering){
                if(!programToChild.containsKey(co.Program_Offering__c)){
                    programToChild.put(co.Program_Offering__c, new Set<String>());
                  }
                  programToChild.get(co.Program_Offering__c).add(co.Id);
            }
            //create map of price book entry for linking with the cart items
            Map<Id, PricebookEntry> pbEntryMap = new Map<Id, PricebookEntry>([
                SELECT 
                    Id, 
                    Pricebook2.Name, 
                    UnitPrice
                FROM PricebookEntry
                WHERE Id IN :pbentryIds]);

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
                tempCourseConnectionMain.Cart_ID__c = cartId;

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
                    if(programToChild.containsKey(currentCart.Program_Offering__c)){
                        for(String offering: programToChild.get(currentCart.Program_Offering__c)){
                            hed__Course_Enrollment__c tempCourseConnectionSub = new hed__Course_Enrollment__c();
                            tempCourseConnectionSub.hed__Contact__c = contactId;
                            tempCourseConnectionSub.hed__Status__c = 'Active';
                            tempCourseConnectionSub.Amount__c = amount;
                            tempCourseConnectionSub.Transaction_ID__c = tranId;
                            tempCourseConnectionSub.Payment_Method__c = paymentMethod;
                            tempCourseConnectionSub.Paid_in_Full__c = paidInFull;
                            tempCourseConnectionSub.Cart_Item__c = currentCart.Id;
                            tempCourseConnectionSub.Cart_ID__c = cartId;
                            //check if current pricebook is for group booking
                            if(pbEntryMap.get(currentCart.Pricebook_Entry_ID__c).Pricebook2.Name == 'Group Booking'){
                                tempCourseConnectionSub.Is_Group_Registered__c = true;
                            } else{
                                tempCourseConnectionSub.Is_Group_Registered__c = false;
                            }
                            tempCourseConnectionSub.RecordTypeId = studentRecordTypeId;
                            tempCourseConnectionSub.hed__Course_Offering__c = offering;
                            courseConnectionInsert.add(tempCourseConnectionSub);
                        }
                    }

                }

                courseConnectionInsert.add(tempCourseConnectionMain);
            }

            //insert the record
            insert courseConnectionInsert;
        }
        
    }

    /**
     * @description updates the cart status
     * @param cartId - cart item ID
     * @param cartStatus - cart status
     */
    @AuraEnabled
    public static void updateWebCart(String cartId, String paymentStatus, String invoice, String receipt, Double amountPaid, String paymentUrl,String email) {
        
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
                Status__c,
                Cart_Payment__c
            FROM WebCart 
            WHERE Id = :cartId
            LIMIT 1];

        //we can only update the cart if it is not Closed
        if(webCart.Status != 'Closed'){

            //update the cart based on the status received
            webCart.Payment_Status__c = paymentStatus;
            webCart.Invoice_Number__c = invoice;
            webCart.Receipt_Number__c = receipt;
            webCart.Amount_Paid__c = amountPaid;
            webCart.Payment_URL__c = paymentUrl;

            //close the cart only if the payment is approved
            if(paymentStatus == 'Approved'){
                webCart.Status__c = 'Closed';
                webCart.Status = 'Closed';
            }

            update webCart;
        }
        //update cartpayment 
        if(webCart.Cart_Payment__c != null){
            Cart_Payment__c  cpToUpdate = new Cart_Payment__c(  
                Id = webCart.Cart_Payment__c,
                Email__c = email,
                Invoice_Number__c = invoice,
                Receipt_Number__c = receipt,
                Amount_Paid__c = amountPaid,
                Payment_Status__c = paymentStatus
            );
            update cpToUpdate;
        }
        


    }
}
  