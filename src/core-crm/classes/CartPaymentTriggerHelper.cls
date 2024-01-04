/**
 * @description helper Class for CartPaymentTriggerHandler
 * @see ..CartPaymentTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      || roy.nino.s.regala             | June 24, 2022         | DEPP-3252              | Created file                 |
      | julie.jane.alegre              | July 12, 2022         | DEPP-3458              | Add logic on discounted item |
      | john.m.tambasenb               | August 11, 2022       | DEPP-3738              | negative amount showing      |
      | arsenio.jr.dayrit              | January 03, 2023      | ApexCRUDViolationFix   | Removed PMD CrudViolation    |
 */

public without sharing class CartPaymentTriggerHelper{
    private static final Id STUDENT_RECTYPEID = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
    private static final Id STUDENT_PROGRAM_RECTYPEID = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Student - Program').getRecordTypeId();

    /**
     * @description create/update existing course connection
     * @param cartpaymentIds - cartpayment ids with updated payment statuses(invoiced or approved)
     * @param cartPaymentMap - new cartpayment map 
     */
    public static void upsertCourseConnection(Set<Id> cartPaymentIds, Map<Id,Cart_Payment__c> cartPaymentMap){

        List<CartItem> cartItemList =  new List<CartItem>();
        Map<Id,PricebookEntry> pricebookEntryMap;
        Set<Id> pricebookEntryIds = new Set<Id>();
        Set<Id> programOfferingIds = new Set<Id>();
        Map<Id,List<hed__Course_Enrollment__c>> cartItemToCourseconMap = new Map<Id,List<hed__Course_Enrollment__c>>();
        List<hed__Course_Enrollment__c> courseConList = new List<hed__Course_Enrollment__c>();
        Map<String,hed__Course_Enrollment__c> courseConnectionToUpsert = new Map<String,hed__Course_Enrollment__c>();
        Map<String,Decimal> notCancelledEnrollmentAmount = new Map<String,Decimal>();
        List<hed__Course_Offering__c> getChildCourseOffering = new List<hed__Course_Offering__c>();
        Map<Id,WebCart> webCartMap;
        Map<String,Set<String>> programToChild = new Map<String,Set<String>>();
        Set<Id> cartItemIdSet = new Set<Id>();

        //get all related webcarts linked to the cartpayments updated to Approved or Invoiced
        webCartMap = new Map<Id,WebCart>([
            SELECT Id, Cart_Payment__c, 
            External_Id__c
            FROM WebCart 
            WHERE Cart_Payment__c 
            IN: cartPaymentIds
        ]);

            //get all cart items related to the webcarts
            cartItemList = CartItemsDAO.newInstance().getCartItemsByWebCartId(webCartMap.keySet(), AccessLevel.SYSTEM_MODE);

        //get all existing courseconnections related to the cartitems
        
        for(CartItem cartItem : cartItemList){
            cartItemIdSet.add(cartItem.Id);
        }
        courseConList = CourseConnectionsDAO.newInstance().getCourseConnectionByCartItem(cartItemIdSet, AccessLevel.SYSTEM_MODE);
        
        Decimal promotionPrice = 0;
        Decimal totalPrice = 0;
        
        for(hed__Course_Enrollment__c courseCon: courseConList){
            //only process enrollment that are active
            if(courseCon.hed__Status__c != 'Cancelled'){
                promotionPrice = courseCon.Cart_Item__r.Promotion_Price__c != null?courseCon.Cart_Item__r.Promotion_Price__c:0;
                totalPrice = courseCon.Cart_Item__r.TotalPrice != null?courseCon.Cart_Item__r.TotalPrice:0;
    
                //group all enrollments by cart id
                //values should be the total discounted price of the active enrollments
                if(!notCancelledEnrollmentAmount.containsKey(courseCon.Cart_ID__c)){
                    notCancelledEnrollmentAmount.put(courseCon.Cart_ID__c,totalPrice - promotionPrice);
                }else{
                    notCancelledEnrollmentAmount.put(courseCon.Cart_ID__c,notCancelledEnrollmentAmount.get(courseCon.Cart_ID__c) + (totalPrice - promotionPrice));
                }
            } 
        }

        for(CartItem cItem: cartItemList){
            if(cItem.Pricebook_Entry_ID__c != null){
                pricebookEntryIds.add(cItem.Pricebook_Entry_ID__c);
            }
            if(cItem.Program_Offering__c != null){
                programOfferingIds.add(cItem.Program_Offering__c);
            }
        }

        //get pricebook entry details
        if(!pricebookEntryIds.isEmpty()){
            pricebookEntryMap = new Map<Id,PricebookEntry>([
                SELECT 
                Id, 
                Pricebook2.Name, 
                UnitPrice
                FROM PricebookEntry
                WHERE Id IN :pricebookEntryIds
            ]);
        }
        
        //get child course offering related to the program offerings
            getChildCourseOffering = CourseOfferingsDAO.newInstance().getCourseOfferingByProgramOfferingId(programOfferingIds, AccessLevel.SYSTEM_MODE);
        
        for(hed__Course_Offering__c co: getChildCourseOffering){
            if(!programToChild.containsKey(co.Program_Offering__c)){
                programToChild.put(
                    co.Program_Offering__c, 
                    new Set<String>()
                );
              }
              programToChild.get(co.Program_Offering__c).add(co.Id);
        }

        //create a cart item to course connection map
        //consider 1 cart item -> multiple course connections (prescribed program)
        //update existing course connection
        for(hed__Course_Enrollment__c courseCon : courseConList){
            String offeringId;
            if(courseCon.hed__Status__c != 'Cancelled'){
                //update paid in full of course connection
                //amount paid thru qut pay is compared to the total discounted price of all active enrollment under the cart
                if(courseCon.Cart_ID__c != null && cartPaymentMap.containsKey(courseCon.Cart_Id__r.Cart_Payment__c)){
                    courseCon.Paid_in_Full__c = notCancelledEnrollmentAmount.get(courseCon.Cart_ID__c) <= cartPaymentMap.get(courseCon.Cart_Id__r.Cart_Payment__c).Amount_Paid__c?'Yes':'No';
                }

                offeringId = courseCon.Program_Offering__c != null?courseCon.Program_Offering__c:courseCon.hed__Course_Offering__c;
                courseConnectionToUpsert.put(string.valueOf(courseCon.Cart_Item__c) + offeringId, courseCon);
            }
            
            if(!cartItemToCourseconMap.containsKey(courseCon.Id)){

                cartItemToCourseconMap.put(
                    courseCon.Cart_Item__c,
                    new List<hed__Course_Enrollment__c>()
                    );

            }
            cartItemToCourseconMap.get(courseCon.Cart_Item__c).add(courseCon);
        }

        //loop through the cart items 
        //and build the course connection to upsert
        for(CartItem cItem: cartItemList){
            //only process cart items without existing course connections
            if(!cartItemToCourseconMap.containsKey(cItem.Id)){
                CourseConnDetails connectionDetails = new CourseConnDetails();
                connectionDetails.cItem = cItem;
                connectionDetails.payment = cartPaymentMap.get(cItem.Cart.Cart_Payment__c);
                connectionDetails.pbEntryMap = pricebookEntryMap;
                connectionDetails.programToChild = programToChild;
                courseConnectionToUpsert.putAll(buildCourseConnection(connectionDetails));
            }
        }

        if(!courseConnectionToUpsert.isEmpty()){
            upsert courseConnectionToUpsert.values();
        }
      
    }  

    /**
     * @description create/update existing course connection
     * @param cItem - cartItem
     * @param payment - cuurent payment record related to the cartitem's webcart
     * @param pbEntryMap - pricebook entry linked to the cartitem
     * @param programToChild - program offerings related to the cart item to child course offering map
     * @return finalCourseConMap - final course connection to upsert
     */
    private static Map<String,hed__Course_Enrollment__c> buildCourseConnection(CourseConnDetails connectionDetails){
        CartItem cItem = connectionDetails.cItem;
        Cart_Payment__c payment = connectionDetails.payment;
        Map<Id, PriceBookEntry> pbEntryMap = connectionDetails.pbEntryMap;
        Map<String, Set<String>> programToChild = connectionDetails.programToChild;

        Map<String,hed__Course_Enrollment__c> finalCourseConMap = new Map<String,hed__Course_Enrollment__c>();
        hed__Course_Enrollment__c tempCourseEnrollment;
        hed__Course_Enrollment__c tempCourseEnrollmentChild;
        String offeringId;
        Decimal discount = payment.Discount_Applied__c != null?payment.Discount_Applied__c:0;

        //update existing course connections
        //create new course connection records
        tempCourseEnrollment = new hed__Course_Enrollment__c();
        tempCourseEnrollment.hed__Contact__c = cItem.Contact__c;
        tempCourseEnrollment.hed__Status__c = 'Active';
        tempCourseEnrollment.Amount__c = cItem.Cart.TotalAmount - discount;
        tempCourseEnrollment.Transaction_ID__c =  cItem.CartId != null?cItem.Cart.External_Id__c:'';
        tempCourseEnrollment.Payment_Method__c = payment.Payment_Status__c == 'Approved'?'Pay Now':'Invoice';
        tempCourseEnrollment.Paid_in_Full__c = cItem.CartId != null && (cItem.Cart.TotalAmount - discount) <= payment.Amount_Paid__c?'Yes':'No';
        tempCourseEnrollment.Cart_Item__c = cItem.Id;
        tempCourseEnrollment.Cart_ID__c = cItem.CartId;

        if( cItem.Pricebook_Entry_ID__c != null && 
            pbEntryMap.containsKey(cItem.Pricebook_Entry_ID__c) && 
            pbEntryMap.get(cItem.Pricebook_Entry_ID__c).Pricebook2.Name == 'Group Booking'){
            tempCourseEnrollment.Is_Group_Registered__c = true;
        } else{
            tempCourseEnrollment.Is_Group_Registered__c = false;
        }

        if(cItem.Program_Offering__c != null){
            tempCourseEnrollment.Program_Offering__c = cItem.Program_Offering__c; 
            tempCourseEnrollment.RecordTypeId = STUDENT_PROGRAM_RECTYPEID;  
            offeringId = cItem.Program_Offering__c; 
            //create new course connection for child course offering of program offering
            if(programToChild.containsKey(cItem.Program_Offering__c)){
                for(String offering: programToChild.get(cItem.Program_Offering__c)){
                    tempCourseEnrollmentChild = new hed__Course_Enrollment__c();
                    tempCourseEnrollmentChild.hed__Contact__c = cItem.Contact__c;
                    tempCourseEnrollmentChild.hed__Status__c = 'Active';
                    tempCourseEnrollmentChild.Amount__c = cItem.Cart.TotalAmount - discount;
                    tempCourseEnrollmentChild.Transaction_ID__c = cItem.CartId != null?cItem.Cart.External_Id__c:'';
                    tempCourseEnrollmentChild.Payment_Method__c = payment.Payment_Status__c == 'Approved'?'Pay Now':'Invoice';
                    tempCourseEnrollmentChild.Paid_in_Full__c = cItem.CartId != null && (cItem.Cart.TotalAmount - discount) <= payment.Amount_Paid__c?'Yes':'No';
                    tempCourseEnrollmentChild.Cart_Item__c = cItem.Id;
                    tempCourseEnrollmentChild.Cart_ID__c = cItem.CartId;
                    
                    //check if current pricebook is for group booking
                    if( cItem.Pricebook_Entry_ID__c != null && 
                        pbEntryMap.get(cItem.Pricebook_Entry_ID__c).Pricebook2.Name == 'Group Booking'){
                        tempCourseEnrollmentChild.Is_Group_Registered__c = true;
                    } else{
                        tempCourseEnrollmentChild.Is_Group_Registered__c = false;
                    }
                    
                    tempCourseEnrollmentChild.RecordTypeId = STUDENT_RECTYPEID;
                    tempCourseEnrollmentChild.hed__Course_Offering__c = offering;
                    finalCourseConMap.put(string.valueOf(cItem.Id) + offering, tempCourseEnrollmentChild);
                }
            }
        }else if(cItem.Course_Offering__c != null){
            tempCourseEnrollment.hed__Course_Offering__c = cItem.Course_Offering__c;  
            tempCourseEnrollment.RecordTypeId = STUDENT_RECTYPEID;
            offeringId = cItem.Course_Offering__c;
        }
        finalCourseConMap.put(string.valueOf(cItem.Id) + offeringId, tempCourseEnrollment);

        return finalCourseConMap;
    }

    public class CourseConnDetails {
        public CartItem cItem { get; set; }
        public Cart_Payment__c payment { get; set; }
        public Map<Id, PriceBookEntry> pbEntryMap { get; set; }
        public Map<String, Set<String>> programToChild { get; set; }
    }
}
