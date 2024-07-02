/**
 * @description Class to validate Student Id based on the Manual Import of CSV
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | May 13, 2024          | DEPP-8485              | Created file                 |
      | kim.howard.capanas             | May 15, 2024          | DEPP-7526              | Update ValidationResult      |
      |                                |                       |                        | wrapper to include student   |  
      |                                |                       |                        | details                      |
 */


public with sharing class StudentIdValidator {

    /**
    * @description Method to validate the Contact through the Student Id
    * @param studentIds - List of Student Id based on the given csv
    * @return List<ValidationResult> - List of Student Id with the corresponding Validation Result
    */
    public static List<ValidationResult> validate(List<String> studentIds) {
        Set<String> uniqueStudentIds = new Set<String>(studentIds);

        // Map to store validation results for each student ID
        Map<String, ValidationResult> validationResults = new Map<String, ValidationResult>();

        List<Contact> contacts = ContactsDAO.newInstance().getContactByStudentId(studentIds, AccessLevel.SYSTEM_MODE);
        for (Contact contact : contacts) {
            if (!validationResults.containsKey(contact.QUT_Student_ID__c)) {
                // Add the student ID to the map with VALID result
                validationResults.put(contact.QUT_Student_ID__c, new ValidationResult(ValidationResultCode.VALID, contact));
            } else {
                // Add the student ID to the map with MULTIPLE_MATCH result
               	validationResults.put(contact.QUT_Student_ID__c, new ValidationResult(ValidationResultCode.MULTIPLE_MATCH, contact));
            }
        }
        		
        for (String studentId : uniqueStudentIds) {
            // Add the student ID to the map with INVALID result
            if (!validationResults.containsKey(studentId)) {
                validationResults.put(studentId, new ValidationResult(ValidationResultCode.INVALID, studentId));
            }
        }

        // Return the list of validation results
        return validationResults.values();
    }

    /**
    * @description Class that stores the Validation Result
    */
    public class ValidationResult {
        private ValidationResultCode resultCode;
        private String id;
        private String studentId;
        private String fullName;
        private String email;
        private String mobilePhone;

        public ValidationResult(ValidationResultCode resultCode, Contact contact) {
            this.resultCode = resultCode;
            this.studentId = contact.QUT_Student_ID__c;
            this.fullName = contact.Name;
            this.email = contact.QUT_Learner_Email__c;
            this.mobilePhone = contact.MobilePhone;
            this.id = contact.Id;
        }

        public ValidationResult(ValidationResultCode resultCode, String studentId) {
            this.resultCode = resultCode;
            this.studentId = studentId;
        }

        @AuraEnabled
        public String getResultCode() {
            return resultCode.name();
        }
        
        @AuraEnabled
        public String getStudentId() {
            return studentId;
        }

        @AuraEnabled
        public String getFullName() {
            return fullName;
        }

        @AuraEnabled
        public String getEmail() {
            return email;
        }

        @AuraEnabled
        public String getMobilePhone() {
            return mobilePhone;
        }
        
        @AuraEnabled
        public String getId() {
            return id;
        }
    }

    /**
    * @description enum method that stores the Validation Result Criteria
    */
    public enum ValidationResultCode {
      VALID,
      INVALID,
      MULTIPLE_MATCH
    }

}