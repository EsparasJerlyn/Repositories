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

public class ManageRegistrationWrapper {


     public class RegistrationData{
          @AuraEnabled
          public Contact contactRecord;
          @AuraEnabled
          public String offeringId;
          @AuraEnabled
          public List<Related_Answer__c> relatedAnswerList;
          @AuraEnabled
          public List<Answer__c> answerList;
          @AuraEnabled
          public Boolean prescribedProgram;
          @AuraEnabled
          public Id priceBookEntryId;
          @AuraEnabled
          public Boolean isProceedNoInvoice;
          @AuraEnabled
          public Decimal discountAmount;
          @AuraEnabled
          public Id promotionId;
     }

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

     public class EnrolmentResultClass{
          @AuraEnabled
          public Boolean isContactInputValid;
          @AuraEnabled
          public String contactId;
          @AuraEnabled
          public String paymentURL;
          @AuraEnabled
          public String contactName;
          @AuraEnabled
          public String contactValidationResponse;
     }

}