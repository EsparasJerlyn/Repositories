public with sharing class PaymentGatewayCtrl {

    @AuraEnabled(cacheable=true)
    public static Payment_Gateway_Settings__c getPaymentGatewaySettings(){
        return Payment_Gateway_Settings__c.getorgdefaults();
    }

    @AuraEnabled(cacheable=true)
    public static CCE_Payment_Gateway_Settings__c getCCEPaymentGatewaySettings(){
        return CCE_Payment_Gateway_Settings__c.getorgdefaults();
    }
}
