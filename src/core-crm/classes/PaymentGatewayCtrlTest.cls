@isTest(SeeAllData=false)
public with sharing class PaymentGatewayCtrlTest {
    @TestSetup
    static void insertTestData(){
        Payment_Gateway_Settings__c paymentGateway = new Payment_Gateway_Settings__c();
        paymentGateway.Payment_URL__c = 'https://www.test@sample.com/tranadd?';
        paymentGateway.GL_Code__c = '1234';
        paymentGateway.TransType_PayNow__c = 'test1';
        paymentGateway.TransType_Invoice__c = 'test2';        
        insert paymentGateway;  
    }
    
    @IsTest
    static void getPaymentGatewayTest() {            
        String fullname = 'John Doe';
        String email = 'sample@email.com';
        String amount = '500.00';
        String externalId = '4567';
        
        test.startTest();
        Payment_Gateway_Settings__c getDetails = PaymentGatewayCtrl.getPaymentGatewaySettings();
        String PaymentBaseUrl = getDetails.Payment_URL__c;
        String GLCode = getDetails.GL_Code__c;
        String TransCode1 = getDetails.TransType_PayNow__c;
        String TransCode2 = getDetails.TransType_Invoice__c;
        test.stopTest();
        
        String expected = 'https://www.test@sample.com/tranadd?type=test1&OPETRANSACTIONID=4567&EMAIL=sample%40email.com&FULLNAME=John+Doe&GLCODE=1234&UNITAMOUNTINCTAX=500.00';
		String actual = PaymentBaseUrl + 'type=' + TransCode1 + '&OPETRANSACTIONID=' + externalId + '&EMAIL=' + email.replace('@','%40') + '&FULLNAME=' + fullname.replace(' ', '+') + '&GLCODE=' + GLCode + '&UNITAMOUNTINCTAX=' + amount;
        
        System.assertEquals(expected, actual, 'Expected is not equal to actual');
		
    }
}