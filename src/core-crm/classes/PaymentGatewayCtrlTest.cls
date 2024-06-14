@isTest
public with sharing class PaymentGatewayCtrlTest {
    @testSetup
    static void insertTestData(){
        TestDataFactoryUser.generateUserSystemAdministrator();
        Payment_Gateway_Settings__c paymentGateway = new Payment_Gateway_Settings__c();
        paymentGateway.Payment_URL__c = 'https://www.test@sample.com/tranadd?';
        paymentGateway.GL_Code__c = '1234';
        paymentGateway.TransType_PayNow__c = 'test1';
        paymentGateway.TransType_Invoice__c = 'test2';        
        insert paymentGateway;  

        CCE_Payment_Gateway_Settings__c paymentGatewayCCE = new CCE_Payment_Gateway_Settings__c();
        paymentGatewayCCE.Payment_URL__c = 'https://www.test@sample.com/tranadd?';
        paymentGatewayCCE.GL_Code__c = '1234';
        paymentGatewayCCE.TransType_PayNow__c = 'test1';
        paymentGatewayCCE.TransType_Invoice__c = 'test2';        
        insert paymentGatewayCCE;  
    }
    
    @isTest
    static void getPaymentGatewayTest() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {        
            String fullname = 'John Doe';
            String email = 'sample@email.com';
            String amount = '500.00';
            String externalId = '4567';
            
            test.startTest();
            Payment_Gateway_Settings__c getDetails = PaymentGatewayCtrl.getPaymentGatewaySettings();
            String PaymentBaseUrl = getDetails.Payment_URL__c;
            String GLCode = getDetails.GL_Code__c;
            String TransCode1 = getDetails.TransType_PayNow__c;

            CCE_Payment_Gateway_Settings__c getDetailsCCE = PaymentGatewayCtrl.getCCEPaymentGatewaySettings();
            String PaymentBaseUrlCCE = getDetailsCCE.Payment_URL__c;
            String GLCodeCCE = getDetailsCCE.GL_Code__c;
            String TransCode1CCE = getDetailsCCE.TransType_PayNow__c;
            test.stopTest();
            
            String expected = 'https://www.test@sample.com/tranadd?type=test1&OPETRANSACTIONID=4567&EMAIL=sample%40email.com&FULLNAME=John+Doe&GLCODE=1234&UNITAMOUNTINCTAX=500.00';
            String actual = PaymentBaseUrl + 'type=' + TransCode1 + '&OPETRANSACTIONID=' + externalId + '&EMAIL=' + email.replace('@','%40') + '&FULLNAME=' + fullname.replace(' ', '+') + '&GLCODE=' + GLCode + '&UNITAMOUNTINCTAX=' + amount;
            
            String expected2 = 'https://www.test@sample.com/tranadd?type=test1&OPETRANSACTIONID=4567&EMAIL=sample%40email.com&FULLNAME=John+Doe&GLCODE=1234&UNITAMOUNTINCTAX=500.00';
            String actual2 = PaymentBaseUrlCCE + 'type=' + TransCode1CCE + '&OPETRANSACTIONID=' + externalId + '&EMAIL=' + email.replace('@','%40') + '&FULLNAME=' + fullname.replace(' ', '+') + '&GLCODE=' + GLCodeCCE + '&UNITAMOUNTINCTAX=' + amount;
            
            System.assertEquals(expected, actual, 'Expected is not equal to actual');
            System.assertEquals(expected2, actual2, 'Expected is not equal to actual');
        }
    }
}