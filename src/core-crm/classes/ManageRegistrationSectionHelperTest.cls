/**
 * @description helper class for manageregistrationsectionctrl
 * @see ../manageregistrationsectionctrl
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | roy.nino.s.regala         | November 15, 2022     | DEPP-4721            | Created file                 |
*/

public class ManageRegistrationSectionHelperTest {

     /**
      * Generates Payment Gateway URL based on the provided parameters
      * @param PaymentUrlClass contains paymenturl required details
      * @return String - URL Generated
      */
      public static String paymentGatewayURLBuilder(PaymentUrlClass urlObj){

          Payment_Gateway_Settings__c paymentGatewaySettings = Payment_Gateway_Settings__c.getorgdefaults();
          CCE_Payment_Gateway_Settings__c paymentGatewaySettingsCCE = CCE_Payment_Gateway_Settings__c.getorgdefaults();

          String baseURL = '';
          String transactionId = '';
          String description = '';
          String tranType = '';
          String glCode = '';

          if(urlObj.IsCCE){
               baseURL = paymentGatewaySettingsCCE.Payment_URL__c;
               transactionId = '&CCETransactionID=';
               description = '&CCEDescription=';
               tranType = paymentGatewaySettingsCCE.TransType_Invoice__c;
               glCode = paymentGatewaySettingsCCE.GL_Code__c;
          }else{
               baseURL = paymentGatewaySettings.Payment_URL__c;
               transactionId ='&OPETransactionID=';
               description = '&OPEDescription=';
               tranType = paymentGatewaySettings.TransType_Invoice__c;
               glCode = paymentGatewaySettings.GL_Code__c;
          }

          return baseURL +
               'tran-type=' + tranType +
               transactionId + urlObj.CartExternalId +
               '&Email=' + urlObj.Email.replace('@', '%40') +
               '&GLCode=' + glCode +
               '&FullName=' + urlObj.Name +
               description + urlObj.ProductName +
               '&UnitAmountIncTax=' + String.valueOf(urlObj.Amount);
     }


     /**
      * Generates Payment Gateway URL based on the provided parameters
      * @param list of course connections
      * @param boolean - tells the method if enrollment is CCE or OPE
      * @param string - student email where invoice is sent
      * @return String - URL Generated
      */
      public static String paymentGatewayURLBuilder(List<hed__Course_Enrollment__c> enrollmentList, Boolean isCCE, String studentEmail){

          Payment_Gateway_Settings__c paymentGatewaySettings = Payment_Gateway_Settings__c.getorgdefaults();
          CCE_Payment_Gateway_Settings__c paymentGatewaySettingsCCE = CCE_Payment_Gateway_Settings__c.getorgdefaults();

          String baseURL = '';
          String transactionId = '';
          String descriptionLabel = '';
          String tranType = '';
          String glCode = '';

          if(isCCE){
               baseURL = paymentGatewaySettingsCCE.Payment_URL__c;
               transactionId = '&CCETransactionID=';
               descriptionLabel = '&CCEDescription=';
               tranType = paymentGatewaySettingsCCE.TransType_Invoice__c;
               glCode = paymentGatewaySettingsCCE.GL_Code__c;
          }else{
               baseURL = paymentGatewaySettings.Payment_URL__c;
               transactionId ='&OPETransactionID=';
               descriptionLabel = '&OPEDescription=';
               tranType = paymentGatewaySettings.TransType_Invoice__c;
               glCode = paymentGatewaySettings.GL_Code__c;
          }

          String formURL =    'tran-type=' + tranType + 
                              transactionId + enrollmentList[0].Cart_ID__r.External_Id__c + '&' + 
                              'Email=' + studentEmail.replace('@','%40') + '&' + 
                              'GLCode=' + glCode + '&';

          String description = '';

          //construct the invoice URL
          //contact name, product name, price is looped
          for(hed__Course_Enrollment__c student: enrollmentList){
               description = description + 'FullName=' + student.Cart_Item__r.Contact__r.Name.replace(' ','%20');
               description = description + descriptionLabel + student.Cart_Item__r.Product2.Name.replace(' ','%20') + '&' + 'UnitAmountIncTax=';
               Decimal totalPrice = student.Cart_Item__r.TotalPrice != null?student.Cart_Item__r.TotalPrice:0;
               Decimal promotionPrice = student.Cart_Item__r.Promotion_Price__c != null?student.Cart_Item__r.Promotion_Price__c:0;
               Decimal tempPrice = totalPrice - promotionPrice;
               description = description + tempPrice + '&';
               
          }
          
          return baseURL + formURL + description.removeEnd('&');
     }


     /**
      * @description Wrapper class that holds the file uploaded by user
      */
      public class PaymentUrlClass{
          @AuraEnabled
          public String cartExternalId;
          @AuraEnabled
          public String email;
          @AuraEnabled
          public String name;
          @AuraEnabled
          public Decimal amount;
          @AuraEnabled
          public String productName;
          @AuraEnabled
          public Boolean isCCE;
      }


     
}