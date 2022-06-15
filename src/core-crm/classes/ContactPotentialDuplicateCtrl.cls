/**
 * @description Controller Class for Contact Potential Duplicate
 * @see ../lwc/contactPotentialDuplicate
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                 | Change Summary               |
      |--------------------------------|-----------------------|----------------------|------------------------------|
      | eccarius.munoz                 | May 25, 2022          | DEPP-1902            | Created file                 | 
      |                                |                       |                      |                              |
	   
 */
public without sharing class ContactPotentialDuplicateCtrl {

    @AuraEnabled(cacheable=true)
    public static List<ContactWrapper> getSelectedContact(Id recordId){
        List<Contact> contactList = [SELECT Id, FirstName, LastName, Birthdate, Email, Work_Email__c, QUT_Learner_Email__c, QUT_Staff_Email__c, 
                                            QUT_Student_ID__c, QUT_Employee_ID__c FROM Contact WHERE Id = : recordId];
        List<ContactWrapper> responseList = new List<ContactWrapper>();
        for(Contact contact : contactList){
            ContactWrapper contactWrapper = new ContactWrapper();
            contactWrapper.id = contact.Id;
            contactWrapper.firstName = contact.FirstName;
            contactWrapper.lastName = contact.LastName;
            contactWrapper.birthDate = contact.Birthdate;
            contactWrapper.email = contact.Email;
            contactWrapper.workEmal = contact.Work_Email__c;
            contactWrapper.qutLearnerEmail = contact.QUT_Learner_Email__c;
            contactWrapper.qutStaffEmail = contact.QUT_Staff_Email__c;
            contactWrapper.qutStudentEmail = contact.QUT_Student_ID__c;
            contactWrapper.qutEmployeeId = contact.QUT_Employee_ID__c;
            responseList.add(contactWrapper);
        }
        return responseList;
    }

    @AuraEnabled(cacheable=true)
    public static List<ContactWrapper> getPotentialDuplicate(Id recordId){
        
        List<Potential_Duplicate__c> contactList = [SELECT Duplicate_Contact__r.Id, Duplicate_Contact__r.FirstName, Duplicate_Contact__r.LastName, Duplicate_Contact__r.Birthdate, 
                                                            Duplicate_Contact__r.Email, Duplicate_Contact__r.Work_Email__c, Duplicate_Contact__r.QUT_Learner_Email__c, 
                                                            Duplicate_Contact__r.QUT_Staff_Email__c, Duplicate_Contact__r.QUT_Student_ID__c, Duplicate_Contact__r.QUT_Employee_ID__c 
                                                        FROM Potential_Duplicate__c WHERE Contact__c =: recordId AND Duplicate_Contact__c != null ORDER BY Duplicate_Contact__r.FirstName ASC];
        List<ContactWrapper> responseList = new List<ContactWrapper>();
        for(Potential_Duplicate__c contact : contactList){
            ContactWrapper contactWrapper = new ContactWrapper();
            contactWrapper.id = contact.Duplicate_Contact__r.Id;
            contactWrapper.firstName = contact.Duplicate_Contact__r.FirstName;
            contactWrapper.lastName = contact.Duplicate_Contact__r.LastName;
            contactWrapper.birthDate = contact.Duplicate_Contact__r.Birthdate;
            contactWrapper.email = contact.Duplicate_Contact__r.Email;
            contactWrapper.workEmal = contact.Duplicate_Contact__r.Work_Email__c;
            contactWrapper.qutLearnerEmail = contact.Duplicate_Contact__r.QUT_Learner_Email__c;
            contactWrapper.qutStaffEmail = contact.Duplicate_Contact__r.QUT_Staff_Email__c;
            contactWrapper.qutStudentEmail = contact.Duplicate_Contact__r.QUT_Student_ID__c;
            contactWrapper.qutEmployeeId = contact.Duplicate_Contact__r.QUT_Employee_ID__c;
            responseList.add(contactWrapper);
        }
        return responseList;
    }  

    @AuraEnabled
    public static String mergeContacts(Object data, Object contact){
        String response = '';
        try {
            List<ContactWrapper> contactList = (List<ContactWrapper>) JSON.deserialize(JSON.serialize(data), List<ContactWrapper>.class);   
            List<ContactWrapper> mainContactList = (List<ContactWrapper>) JSON.deserialize(JSON.serialize(contact), List<ContactWrapper>.class);     
                
            List<ID> contactIDs = new List<ID>();
            for(ContactWrapper cw : contactList){
                contactIDs.add(cw.id);
            }
            List<ID> mainContactIds = new List<ID>();
            for(ContactWrapper cw : mainContactList){
                mainContactIds.add(cw.id);
            }
              
            List<Potential_Duplicate__c> unselectedDuplicateContactList = [SELECT Id FROM Potential_Duplicate__c WHERE Duplicate_Contact__c IN : contactIDs];
            List<Potential_Duplicate__c> selectedDuplicateList = [SELECT Id FROM Potential_Duplicate__c WHERE Contact__c IN : mainContactIds];
            List<Contact> contacsToDelete = [SELECT Id FROM Contact WHERE Id IN : contactIDs];
             
            List<Potential_Duplicate__c> potentialDuplicatesToDelete = new List<Potential_Duplicate__c>();
            potentialDuplicatesToDelete.addAll(unselectedDuplicateContactList);
            potentialDuplicatesToDelete.addAll(selectedDuplicateList);
            
            delete potentialDuplicatesToDelete;
            delete contacsToDelete;

            response = 'Success';

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return response;
    }
    
    public class ContactWrapper{
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String firstName;
        @AuraEnabled
        public String lastName;
        @AuraEnabled
        public Date birthDate;
        @AuraEnabled
        public String email;
        @AuraEnabled
        public String workEmal;
        @AuraEnabled
        public String qutLearnerEmail;
        @AuraEnabled
        public String qutStaffEmail;
        @AuraEnabled
        public String qutStudentEmail;
        @AuraEnabled
        public String qutEmployeeId;
    }
        
}
