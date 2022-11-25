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

public without sharing class ManageRegistrationLearnersListHelper{

     private static string studentRT = System.Label.RT_CourseConnection_Student;
     private static Id studentRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get(studentRT).getRecordTypeId();
     private static string studentProgramRT = System.Label.RT_CourseConnection_Student_Program;
     private static Id studentProgramRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get(studentProgramRT).getRecordTypeId();
     private static List<hed__Course_Enrollment__c> registeredLearners;
     private static Map<Id,List<hed__Course_Enrollment__c>> relatedEnrollments;
     private static Map<Id, PricebookEntry> studentWithPricingMap;
     private static Map<Id,Questionnaire_Response_Summary__c> contactToQRSummary;

     /**
      * @description Retrieves list of Registration details of students for Non Program Plan
      * @param childRecordId - Record ID of course offering
      * @param prescribedProgram - checks if offering is a prescribed program
      * @return List of ManageRegistrationDetails
      */
      @AuraEnabled(cacheable=true)
      public static List<ManageRegistrationDetails> getRegistrations(String childRecordId, Boolean prescribedProgram){
 
           List<ManageRegistrationDetails> response = new List<ManageRegistrationDetails>();
           contactToQRSummary = new Map<Id,Questionnaire_Response_Summary__c>();
           registeredLearners = new List<hed__Course_Enrollment__c>();
           ManageRegistrationWrapper.PaymentUrlClass urlObj = new ManageRegistrationWrapper.PaymentUrlClass();
           relatedEnrollments = new Map<Id,List<hed__Course_Enrollment__c>>();
           Map<String, PricebookEntry> pbeList = new Map<String, PricebookEntry>();
 
           List<Questionnaire_Response_Summary__c> questionnaireResponseList = [
                SELECT Id, Name, Contact__c, Course_Offering__c, Questionnaire__c, Questionnaire__r.Questionnaire_Type__c, Registration_Status__c
                FROM Questionnaire_Response_Summary__c
                WHERE Questionnaire__r.Questionnaire_Type__c = 'Registration Questions' 
                AND (Course_Offering__c =: childRecordId OR Program_Offering__c  =: childRecordId)
                WITH SECURITY_ENFORCED
           ];
 
           for(Questionnaire_Response_Summary__c qResSummary: questionnaireResponseList){
                contactToQRSummary.put(qResSummary.Contact__c, qResSummary);
           }
 
           registeredLearners = [
                    SELECT Id, Name, hed__Contact__c, hed__Contact__r.Id, hed__Contact__r.Name, hed__Contact__r.Position__c, hed__Contact__r.hed__Primary_Organization__r.Name, 
                    hed__Contact__r.Dietary_Requirement__c, hed__Contact__r.Accessibility_Requirement__c, Pricing_Validation__c, hed__Course_Offering__c, Cart_ID__r.External_Id__c,
                    Cart_ID__r.TotalAmount, Paid_in_Full__c, hed__Status__c, LMS_Integration_Status__c, hed__Contact__r.FirstName, hed__Contact__r.LastName,
                    hed__Contact__r.Birthdate, Payment_Method__c, Cart_Item__r.Pricebook_Entry_ID__c, Is_Group_Registered__c, hed__Contact__r.Registered_Email__c,
                    CreatedDate, Paid_Amount__c, hed__Contact__r.QUT_Student_Id__c
                    FROM hed__Course_Enrollment__c
                    WHERE RecordTypeId IN (:studentRecTypeId, :studentProgramRecTypeId)
                    AND (hed__Course_Offering__c =: childRecordId OR (Program_Offering__c  =: childRecordId AND hed__Course_Offering__c = null ))
                    WITH SECURITY_ENFORCED
           ];      
 
           Product2 product = ManageRegistrationSectionHelper.getProduct(childRecordId, prescribedProgram);
 
           List<PricebookEntry> priceBookEntries = [
                SELECT Id, UnitPrice, Pricebook2.Name 
                FROM PricebookEntry 
                WHERE Product2Id =: product.Id 
                WITH SECURITY_ENFORCED
                ORDER BY CreatedDate
           ];
           
           for(PricebookEntry p : priceBookEntries){
                pbeList.put(p.Id, p);
           }
 
           studentWithPricingMap = new Map<Id, PricebookEntry>();
           for(hed__Course_Enrollment__c student : registeredLearners){
                if(pbeList.containsKey(student.Cart_Item__r.Pricebook_Entry_ID__c)){
                     studentWithPricingMap.put(student.Id, pbeList.get(student.Cart_Item__r.Pricebook_Entry_ID__c));
                }
                
                //store all cart ids of the course enrollments as key of the map
                if( !relatedEnrollments.containsKey(student.Cart_ID__c) && 
                     student.Cart_ID__c != null && 
                     student.hed__Status__c != 'Cancelled'){
 
                     relatedEnrollments.put(student.Cart_ID__c,new List<hed__Course_Enrollment__c>());
                }
           }
 
           //get all active related enrollments under the same cart of thecurrent offering's enrollments
           for(hed__Course_Enrollment__c relatedStudent: [
                SELECT Id, Name, 
                hed__Contact__r.Name, 
                hed__Contact__r.Registered_Email__c,
                Cart_Item__r.Promotion_Price__c, 
                Cart_Item__r.TotalPrice,
                Cart_ID__r.External_Id__c, 
                Cart_Item__r.Product2.Name,
                Cart_Item__r.Contact__r.Name
                FROM hed__Course_Enrollment__c
                WHERE Cart_ID__c IN: relatedEnrollments.keySet()
                AND hed__Status__c != 'Cancelled'
                WITH SECURITY_ENFORCED
           ]){
                //group all active enrollments by cart
                relatedEnrollments.get(relatedStudent.Cart_ID__c).add(relatedStudent);
           }
 
           response = buildRegistrationDetails();
 
           return response;
      }
 
      private static List<ManageRegistrationDetails> buildRegistrationDetails(){
 
           List<ManageRegistrationDetails> regDetailsList = new List<ManageRegistrationDetails>();
           ManageRegistrationDetails regDetails;
                
           Decimal amount = 0;
           Boolean isCCE = false;
           String selectedPricing = '';
 
           for(hed__Course_Enrollment__c student : registeredLearners){
 
                regDetails = new ManageRegistrationDetails();
 
                amount = 0;
                selectedPricing = '';
 
                regDetails.enrolmentDetails = student;
                regDetails.regenerateInvoiceURL = '';
                regDetails.applicationDetails = null;
                
                if(studentWithPricingMap.containsKey(student.Id)){
 
                     selectedPricing = studentWithPricingMap.get(student.Id).Pricebook2.Name;
                     amount = studentWithPricingMap.get(student.Id).UnitPrice;
                }
                
                if(contactToQRSummary.containsKey(student.hed__Contact__c)){
                     regDetails.applicationDetails = contactToQRSummary.get(student.hed__Contact__c);
                }
 
                //checker if enrollment is CCE
                isCCE = selectedPricing.startsWith('SOA')?true:false;
 
                //condition to create invoice url
                if(  student.Cart_ID__c != null && 
                     student.Paid_in_Full__c == 'No' && 
                     student.Payment_Method__c == 'Invoice' && 
                     student.hed__Contact__r.Registered_Email__c != null && 
                     student.hed__Status__c != 'Cancelled'){
                          
                          regDetails.regenerateInvoiceURL = ManageRegistrationEnrolmentHelper.paymentGatewayURLBuilder(
                          relatedEnrollments.get(student.Cart_Id__c), 
                          isCCE, 
                          student.hed__Contact__r.Registered_Email__c
                     );
                }
                regDetailsList.add(regDetails);
           }
 
           return regDetailsList;
 
     }

     /**
      * @description Updates Registration details of students
      * @param id - id of student selected
      * @param questionId - question id of student selected
      * @param registrationStatus - registration status of student selected
      * @param paidInFull - paid in full field of student selected
      * @param pricingValidation - pricing validation field of student selected
      * @return String
      */
      @AuraEnabled
      public static String updateRegistration(hed__Course_Enrollment__c studentRecord){
 
           try {
 
                List<hed__Course_Enrollment__c> studentsToUpdate = new List<hed__Course_Enrollment__c>();
                studentsToUpdate.add(studentRecord);
 
                if(studentRecord.Program_Offering__c != null){
 
                     List<hed__Course_Enrollment__c> students = [
                          SELECT Id, Paid_in_Full__c, Pricing_Validation__c, hed__Status__c
                          FROM hed__Course_Enrollment__c 
                          WHERE hed__Course_Offering__c != NULL 
                          AND Program_Offering__c =: studentRecord.Program_Offering__c
                          AND hed__Contact__c =: studentRecord.hed__Contact__c
                          WITH SECURITY_ENFORCED
                     ];
 
                     for(hed__Course_Enrollment__c student : students){
                          hed__Course_Enrollment__c learner = new hed__Course_Enrollment__c();
                          learner.Id = studentRecord.Id;
                          learner.Paid_in_Full__c = studentRecord.Paid_in_Full__c;
                          learner.Pricing_Validation__c = studentRecord.Pricing_Validation__c;
                          learner.hed__Status__c = studentRecord.hed__Status__c;
                          studentsToUpdate.add(learner);
                     }
                }
           
                if( studentsToUpdate.size() > 0 && 
                    Schema.sObjectType.hed__Course_Enrollment__c.fields.Paid_in_Full__c.isUpdateable() && 
                    Schema.sObjectType.hed__Course_Enrollment__c.fields.Pricing_Validation__c.isUpdateable() &&
                    Schema.sObjectType.hed__Course_Enrollment__c.fields.hed__Status__c.isUpdateable()){
                         
                    update studentsToUpdate;
                }else{
                    return 'The following exception has occurred: You have no right to update the record';
                }

                return 'Success';
           }
           catch (Exception e) {
                return 'The following exception has occurred: ' + e.getMessage();
           }
      }

     /**
      * @description Wrapper class that holds data to be displayed
      */
     public class ManageRegistrationDetails{
          @AuraEnabled
          public hed__Course_Enrollment__c enrolmentDetails;
          @AuraEnabled
          public Questionnaire_Response_Summary__c applicationDetails;
          @AuraEnabled
          public String regenerateInvoiceURL;
     }
}