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

        //get the email of user
        String userEmail = [SELECT Email FROM User WHERE Id = :userId LIMIT 1].Email;

        //instantiate variables
        CartData myCartData = new CartData();
        List<CartItemsWrapper> myCartItemsList = new List<CartItemsWrapper>();

        //query the cart with the passed external ID 
        WebCart webCartData = [
            SELECT 
                Id, 
                Name, 
                External_Id__c,
                Cart_Payment__r.Discount_Applied__c,
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
                Program_Offering__r.Delivery_Type__c,
                Contact__c
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
        myCartData.contactEmail = userEmail;
        myCartData.cartId = webCartData.Id;
        myCartData.cartItemsList = myCartItemsList;
        myCartData.subTotal = mySubtotal;
        myCartData.discountTotal = webCartData.Cart_Payment__r.Discount_Applied__c;
        myCartData.cartPayment = webCartData.Cart_Payment__c;
        if(webCartData.Cart_Payment__r.Discount_Applied__c!= null){
            myCartData.grandTotal = mySubtotal - webCartData.Cart_Payment__r.Discount_Applied__c;
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

    @AuraEnabled
    public static void updateCartItem(List<CartItem> cartItems){
        update cartItems;
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
    }
}
