/**
 * @description helper class for dedup during registration
 * @see ../lwc/registrationForm
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                                       |
      |---------------------------|-----------------------|----------------------|------------------------------------------------------|
      | roy.nino.s.regala         | August 11, 2022       | DEPP-3568            | Created file                                         | 
      | roy.nino.s.regala         | January 17, 2023      | DEPP-5076            | Updated Logic to prioritize email matching result    | 
 */
public without sharing class RegistrationMatchingHelper {
    private static final String RT_CONTACT_PERSON = System.Label.RT_Contact_Person;
    private static final Id RT_CONTACT_PERSON_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
      .get(RT_CONTACT_PERSON)
      .getRecordTypeId();
    

    /**
     * @description Method validate potential contact matching
     * @param newContactList - new Contacts to process 
     * @return responseMap - reponse of the validation
     */
    @AuraEnabled(cacheable=false)
    public static List<ContactMatchingResponse> validateContactMatching(String newContactList) {
        Map<String,ContactMatchingResponse> responseMap = new Map<String,ContactMatchingResponse>();
        ContactMatchingResponse response;
        Set<String> firstNameSet = new Set<String>();
        Set<String> lastNameSet = new Set<String>();
        Set<Date> birthDateSet = new Set<Date>();  
        Map<String,Contact> criteriaMapWBirthDate = new Map<String,Contact>(); 
        Map<String,Contact> criteriaMap = new Map<String,Contact>(); 
        Map<String,Contact> contactMap = new Map<String,Contact>();
        
        List<Contact>  serializedContactList= (List<Contact>) System.JSON.deserializeStrict(
            newContactList,
            List<Contact>.class
        );
        
        //build query filters
        //build a map where key is contact details
        for(Contact con: serializedContactList){
            birthDateSet.add(con.Birthdate);
            lastNameSet.add(con.LastName);
            firstNameSet.add(con.FirstName);
            String firstNameToLowerCase = con.FirstName != null ? con.FirstName.toLowerCase() : '';
            criteriaMapWBirthDate.put(JSON.serialize(con.Birthdate) + con.LastName.toLowerCase() + firstNameToLowerCase, con);
            criteriaMap.put(con.LastName.toLowerCase() + firstNameToLowerCase, con);
            contactMap.put(con.Registered_Email__c.toLowerCase(),con);
        }

        //Get potential contacts
        List<Contact> matchingContacts = new List<Contact>([
            SELECT
                Id,
                FirstName,
                LastName,
                Birthdate,
                MobilePhone,
                Email,
                Work_Email__c,
                QUT_Learner_Email__c,
                QUT_Staff_Email__c
            FROM Contact
            WHERE
                RecordTypeId = :RT_CONTACT_PERSON_ID
                AND Parent_Person_Contact__c = NULL
                AND (((Birthdate IN: birthDateSet )
                AND LastName IN:lastNameSet
                AND FirstName IN:firstNameSet) 
                OR Email IN: contactMap.keySet()
                OR Work_Email__c IN: contactMap.keySet()
                OR QUT_Learner_Email__c IN: contactMap.keySet()
                OR QUT_Staff_Email__c IN: contactMap.keySet())
        ]);

        for(Contact con: matchingContacts){
            String firstNameToLowerCase = con.FirstName != null ? con.FirstName.toLowerCase() : '';
            //email match will always replace the values on the map using the email inputed by the user as key
            if(contactMap.containsKey(con.Email)){
                responseMap.put(con.Email,contactDetailsMatching(contactMap.get(con.Email),con));
            }else if(contactMap.containsKey(con.Work_Email__c)){
                responseMap.put(con.Work_Email__c,contactDetailsMatching(contactMap.get(con.Work_Email__c),con));
            }else if(contactMap.containsKey(con.QUT_Learner_Email__c)){
                responseMap.put(con.QUT_Learner_Email__c,contactDetailsMatching(contactMap.get(con.QUT_Learner_Email__c),con));
            }else if(contactMap.containsKey(con.QUT_Staff_Email__c)){
                responseMap.put(con.QUT_Staff_Email__c,contactDetailsMatching(contactMap.get(con.QUT_Staff_Email__c),con));
                //email mismatch and DOB,FirstName and LastName Match
                //only add firstdate,lastname, DOB matching result if current email is not on the response map
            }else if(   con.Birthdate != null && 
                        criteriaMapWBirthDate.containsKey(JSON.serialize(con.Birthdate) + con.LastName.toLowerCase() + firstNameToLowerCase) && 
                        !responseMap.containsKey(criteriaMapWBirthDate.get(JSON.serialize(con.Birthdate) + con.LastName.toLowerCase() + firstNameToLowerCase).Registered_Email__c)){   
                        //if DOB,FirstName and lastname matches
                        response = createResponseForEmailMismatch(con,criteriaMapWBirthDate.get(JSON.serialize(con.Birthdate) + con.LastName.toLowerCase() + firstNameToLowerCase).Registered_Email__c);
                        responseMap.put(response.email,response);
            }else if(   criteriaMap.containsKey(con.LastName.toLowerCase() + firstNameToLowerCase) && 
                        !responseMap.containsKey(criteriaMap.get(con.LastName.toLowerCase() + firstNameToLowerCase).Registered_Email__c)){
                        //if FirstName and lastname matches
                        response = createResponseForEmailMismatch(con,criteriaMap.get(con.LastName.toLowerCase() + firstNameToLowerCase).Registered_Email__c);
                        responseMap.put(response.email,response); 
            }
        }
       
        if(matchingContacts.isEmpty()){
            for(Contact con: serializedContactList){
                response = new ContactMatchingResponse();
                response.isPartialMatch = false;
                response.isEmailMatch = false;
                response.errorMessage = null;
                response.email = con.Registered_Email__c;
                response.mobilePhone = con.MobilePhone;
                responseMap.put(con.Registered_Email__c,response);
            }
        }

        return responseMap.values();
    }

    /**
     * @description Method check if firstname, lastname, birthdate matches
     * @param newContact - new Contacts
     * @param existinContact - matched Contacts
     * @return response - reponse of the validation
     */
    @AuraEnabled
    public static ContactMatchingResponse contactDetailsMatching(Contact newContact, Contact existingContact){
        ContactMatchingResponse response = new ContactMatchingResponse();
        List<String> fieldsMismatchTemp = new List<String>();
        if(newContact.FirstName != existingContact.FirstName){
            fieldsMismatchTemp.add('First Name');
        }
        if(newContact.LastName != existingContact.LastName){
            fieldsMismatchTemp.add('Last Name');
        }
        if(existingContact.Birthdate != null && newContact.Birthdate != existingContact.Birthdate){
            fieldsMismatchTemp.add('Date of Birth');
        }

        if(!fieldsMismatchTemp.isEmpty()){
            response.isPartialMatch = true;
            response.isEmailMatch = true;
            response.errorMessage = 'The following details do not match QUT records for the specified email address';
            response.fieldsMismatch = fieldsMismatchTemp;
            response.contactRecord = existingContact;
            response.email = newContact.Registered_Email__c;
        }else{
            response.isPartialMatch = false;
            response.isEmailMatch = true;
            response.errorMessage = null;
            response.fieldsMismatch = fieldsMismatchTemp;
            response.contactRecord = existingContact;
            response.email = newContact.Registered_Email__c;
        }

        return response;
    }

    private static ContactMatchingResponse createResponseForEmailMismatch(Contact con, String email){
        ContactMatchingResponse response = new ContactMatchingResponse();
        response.isPartialMatch = true;
        response.isEmailMatch = false;
        response.errorMessage = 'Please enter an alternate email address that you’ve used with us before to help us find you.';
        response.contactRecord = con;
        response.email = email;
        return response;
    }

    public class ContactMatchingResponse{
        @AuraEnabled
        public Boolean isPartialMatch;
        @AuraEnabled
        public Boolean isEmailMatch;
        @AuraEnabled
        public String errorMessage;
        @AuraEnabled
        public List<String> fieldsMismatch;
        @AuraEnabled
        public Contact contactRecord;
        @AuraEnabled
        public String email;
        @AuraEnabled
        public string mobilePhone;
    }
}
