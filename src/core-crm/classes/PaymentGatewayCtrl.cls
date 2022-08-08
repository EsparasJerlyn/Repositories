public with sharing class PaymentGatewayCtrl {

    @AuraEnabled(cacheable=true)
    public static Payment_Gateway_Settings__c getPaymentGatewaySettings(){
        return Payment_Gateway_Settings__c.getorgdefaults();
    }

}
