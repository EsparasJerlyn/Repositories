public inherited sharing class CartItemHelper {
    public static CartItem createCartItem(CartItemDetails details){
        CartItem cartItem = new CartItem();
        cartItem.CartId = details.newWebCartId;
        try {
            cartItem.Name = String.isBlank(details.pbEntry.Product2.Name)? 'Cart Item' : details.pbEntry.Product2.Name;
        } catch(SObjectException sObjE) {
            cartItem.Name = 'Cart Item';
        }
        cartItem.CartDeliveryGroupId = details.cartDeliveryGroupId;
        if(!details.prescribedProgram){
            cartItem.Course_Offering__c = details.offeringId;
        }else{
            cartItem.Program_Offering__c = details.offeringId;
        }
        cartItem.Product2Id = details.pbEntry.Product2Id;
        cartItem.Pricebook_Entry_ID__c = details.pbEntry.Id;
        cartItem.Quantity = 1;
        cartItem.TotalPrice = details.pbEntry.UnitPrice;
        cartItem.Type = 'Product';
        return cartItem;
    }
    
    public class CartItemDetails {
        public Id offeringId { get; set; }
        public Id newWebCartId { get; set; }
        public PricebookEntry pbEntry { get; set; }
        public Boolean prescribedProgram { get; set; }
        public Id cartDeliveryGroupId { get; set; }
    }
}