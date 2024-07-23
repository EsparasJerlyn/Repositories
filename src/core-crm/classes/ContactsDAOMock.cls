/**
 * @description Mock DAO Class for Contact Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                | JIRA                   | Change Summary                            |
      |--------------------------------|---------------------|------------------------|-------------------------------------------|
      | roy.nino.s.regala              | April 25, 2023      | DEPP-5567              | Created file                              |
      | eugene.andrew.abuan            | June 08, 2023       | DEPP-5414              | Added checkWorkEmailFlowInputExist        |
      | mark.j.mahilum                 | June 26, 2023       | DEPP-5846              | Added new method                          |
 *    | roy.nino.s.regala              | Aug 09, 2023        | DEPP-5677              | Added method for DEPP-5677                |
 *    | julie.jane.alegre              | Sept 05, 2023       | DEPP-5965              | Added getContactsFromConvertedLead        |
 *    | roy.nino.s.regala              | Sept 20, 2023       | DEPP-6714              | method getPersonContactsBySetIds          |
 *    | alexander.cadalin              | Sep 22, 2023        | DEPP-6652              | method getContactsForQTACAddressUpdate    |
 *    | arsenio.jr.dayrit              | Sept 22,2023        | DEPP-6720              | added method for getContactByCaseMobile   |
 *    | neil.s.h.lesidan               | Sept 20, 2023       | DEPP-6478              | Added getPersonContactsByEmailOrName      |
 *    | julie.jane.alegre              | Nov 07, 2023        | DEPP-7152              | Added method getExistingMCPersonaContactsBySetIds|
 *    | nicole.genon                   | Feb 06, 2024        | DEPP-7003              | Added method getAllPersonContacts         |
 *    | sebastianne.k.trias            | Feb 19, 2024        | DEPP-7750              | added getPersonContactsByNameUsingSOSL    |
 *    | julie.jane.alegre              | May 13, 2024        | DEPP-8490              | Update method getQueryLocatorBySubQueryTest|
 */
@isTest
public inherited sharing class ContactsDAOMock extends DmlBaseMock implements IContactsDAO {//NOPMD could contain a lot of methods
    public Map<Id, Contact> contactsMap;

    public Schema.SObjectType getSObjectType() {
        return Contact.SObjectType;
    }

    public ContactsDAOMock() {
        super(new Map<Id, Contact>(), Schema.Contact.SObjectType);
        this.contactsMap = (Map<Id, Contact>) super.records;
    }

    public List<Contact> getExistingPersonContactsWithMatchingEmails(
        Set<String> allEmailsToMatch,
        Set<Id> newContactIds,
        String accessLevel
    ) {
        List<Contact> contactList = new List<Contact>();
        for (Contact record : contactsMap.values()) {
            if (
                (!newContactIds.contains(record.Id) &&
                record.RecordTypeId == ContactsDAO.PERSON_RECORDTYPE_ID &&
                (allEmailsToMatch.contains(record.Email) ||
                allEmailsToMatch.contains(record.Work_Email__c) ||
                allEmailsToMatch.contains(record.QUT_Learner_Email__c) ||
                allEmailsToMatch.contains(record.QUT_Staff_Email__c)))
            ) {
                contactList.add(record);
            }
        }
        return contactList;
    }

    public List<Contact> getPersonContactsWithLimit(Integer recordsCount) {
        List<Contact> contactList = new List<Contact>();
        for (Contact record : contactsMap.values()) {
            if (record.RecordTypeId == ContactsDAO.PERSON_RECORDTYPE_ID) {
                contactList.add(record);
            }

            if (contactList.size() == recordsCount) {
                break;
            }
        }
        return contactList;
    }

    public List<Contact> checkWorkEmailFlowInputExist(String emailInput){
        List<Contact> contactList = new List<Contact>();
        for(Contact record : contactsMap.values()){
            if(
                record.RecordTypeId == ContactsDAO.PERSON_RECORDTYPE_ID &&
                (emailInput.contains(record.Email) ||
                emailInput.contains(record.Work_Email__c) ||
                emailInput.contains(record.QUT_Learner_Email__c) ||
                emailInput.contains(record.QUT_Staff_Email__c))){
                contactList.add(record);
            }
        }
        return contactList;
    }
    
    public List<Contact> getContactsWithMatchingApplicationDetails(
        ContactsDAO.QueryParamWrapper queryParam,
        String accessLevel
    ) {
        List<Contact> contactList = new List<Contact>();
        for (Contact record : contactsMap.values()) {
            
            boolean isPersonRecordType = record.RecordTypeId == ContactsDAO.PERSON_RECORDTYPE_ID;
            boolean hasMatchingNames = (queryParam.firstNames.contains(record.FirstName) && queryParam.lastNames.contains(record.LastName));
            boolean hasMatchingBirthdate = queryParam.birthdates.contains(record.BirthDate);
            boolean hasMatchingEmails = (queryParam.emailsToMatch.contains(record.Email) || queryParam.emailsToMatch.contains(record.Work_Email__c) ||
                                         queryParam.emailsToMatch.contains(record.QUT_Learner_Email__c) || queryParam.emailsToMatch.contains(record.QUT_Staff_Email__c));
    
            if(isPersonRecordType && ((hasMatchingNames && hasMatchingBirthdate) || (hasMatchingNames && hasMatchingEmails))){
                contactList.add(record);
            }

        }
        return contactList;
    }
    
    public List<Contact> getContactsWithMatchingEmails(
        Set<String> allEmailsToMatch,
        String accessLevel
    ) {
        List<Contact> contactList = new List<Contact>();
        for (Contact record : contactsMap.values()) {
            if (
                (record.RecordTypeId == ContactsDAO.PERSON_RECORDTYPE_ID &&
                 (allEmailsToMatch.contains(record.Email) ||
                  allEmailsToMatch.contains(record.Work_Email__c) ||
                  allEmailsToMatch.contains(record.QUT_Learner_Email__c) ||
                  allEmailsToMatch.contains(record.QUT_Staff_Email__c)))
            ) {
                contactList.add(record);
            }
        }
        return contactList;
    }

    public List<Contact> getContactsWithMatchingSamsApplications(
        ContactsDAO.QueryParamWrapper queryParam,
        String accessLevel
    ) {
        List<Contact> contactList = new List<Contact>();
        for (Contact record : contactsMap.values()) {
            
            boolean isPersonRecordType = record.RecordTypeId == ContactsDAO.PERSON_RECORDTYPE_ID;
            boolean hasMatchingNames = (queryParam.firstNames.contains(record.FirstName) && queryParam.lastNames.contains(record.LastName));
            boolean hasMatchingBirthdate = queryParam.birthdates.contains(record.BirthDate);
            boolean hasMatchingEmails = (queryParam.emailsToMatch.contains(record.Email) || queryParam.emailsToMatch.contains(record.Work_Email__c) ||
                                         queryParam.emailsToMatch.contains(record.QUT_Learner_Email__c) || queryParam.emailsToMatch.contains(record.QUT_Staff_Email__c));
            boolean hasNomitedIds =  (queryParam.nominatedStudentId.contains(record.QUT_student_ID__c));
    
            if(isPersonRecordType && ((hasMatchingNames && hasMatchingBirthdate) || (hasMatchingNames && hasMatchingEmails) || hasNomitedIds)){
                contactList.add(record);
            }

        }
        return contactList;
    }

    public List<Contact> getContactsByMatchingAttributes(
        Map<String,Set<String>> fieldSetMap,
        Set<Date> birthDateSet,
        AccessLevel accessLevel
    ) {

        String regexPattern = '[^a-zA-Z]';

        List<Contact> contactList = new List<Contact>();
        for (Contact record : contactsMap.values()) {
            Contact newContact = new Contact();

            String firstNameFormula = record.FirstName != null?record.FirstName.replaceAll(regexPattern, ''):record.FirstName;
            String lastNameFormula = record.LastName != null?record.LastName.replaceAll(regexPattern, ''):record.LastName;

            boolean isPersonRecordType = record.RecordTypeId == ContactsDAO.PERSON_RECORDTYPE_ID;
            boolean hasMatchingFirstName = fieldSetMap.get('firstName').contains(firstNameFormula);
            boolean hasMatchingLastName = fieldSetMap.get('lastName').contains(lastNameFormula);
            boolean hasMatchingBirthdate = birthDateSet.contains(record.BirthDate);
            boolean hasMatchingEmails = fieldSetMap.get('email').contains(record.Email) || fieldSetMap.get('email').contains(record.Work_Email__c) ||
                                        fieldSetMap.get('email').contains(record.QUT_Learner_Email__c) || fieldSetMap.get('email').contains(record.QUT_Staff_Email__c);
            boolean hasMatchingMobilePhones =  fieldSetMap.get('mobilePhone').contains(record.MobilePhone);
            boolean hasMatchingEmailOrMobile = hasMatchingEmails || hasMatchingMobilePhones;
            boolean isNaturalKeyMatch = hasMatchingFirstName && hasMatchingLastName && hasMatchingBirthdate;
            boolean isPartialOrFirstNameStemMatch = hasMatchingLastName && hasMatchingBirthdate && hasMatchingEmailOrMobile;
            boolean isMaidenNameMatch = hasMatchingFirstName && hasMatchingBirthdate && hasMatchingEmailOrMobile;
            boolean noDOBMatch = hasMatchingFirstName && hasMatchingLastName && hasMatchingEmailOrMobile;
            boolean hasMatch = isNaturalKeyMatch || isPartialOrFirstNameStemMatch || isMaidenNameMatch || noDOBMatch;
            boolean isIdExcluded = fieldSetMap.get('excludedIds').contains(record.Id);
    
            
            newContact = (Contact) JSON.deserialize(
                            '{"attributes":{"type":"Contact"},"Id":"' +
                            record.Id +
                            '","FirstName":"' +
                            record.FirstName +
                            '","Matching_Firstname__c":"' +
                            firstNameFormula +
                            '","LastName":"' +
                            record.LastName +
                            '","Matching_Lastname__c":"' +
                            lastNameFormula +
                            '"}',
                            Contact.class
                        );
            newContact.BirthDate = record.BirthDate;
            newContact.Email = record.Email;
            newContact.QUT_Staff_Email__c = record.QUT_Staff_Email__c;
            newContact.QUT_Learner_Email__c = record.QUT_Learner_Email__c;
            newContact.Work_Email__c = record.Work_Email__c;
            newContact.RecordTypeId = record.RecordTypeId;
            newContact.MobilePhone = record.MobilePhone;
            newContact.QUT_Student_ID__c = record.QUT_Student_ID__c;
            newContact.QUT_Employee_ID__c = record.QUT_Employee_ID__c;

            //is person contact
            if(isPersonRecordType && hasMatch && !isIdExcluded){
                contactList.add(newContact);
            }

        }
        return contactList;
    }

    public List<Contact> getPersonContactsByCalculatedCadences(
        Set<String> calculatedCadences
    ) {
        List<Contact> contactList = new List<Contact>();
        for (Contact record : contactsMap.values()) {
            if(calculatedCadences.contains(record.Calculated_Cadence__c)){
                contactList.add(record);
            }
        }
        return contactList;
    }

    public List<Contact> getContactCalculatedCadenceByIds(
        Set<String> recordIds,
        String accessLevel
    ) {
        List<Contact> contactList = new List<Contact>();
        
        for (Contact record : contactsMap.values()) {
            if (
                recordIds.contains(record.Id)
            ) {
                contactList.add(record);
            }
        }
        
        return contactList;
    }
    public List<Contact> getContactsFromConvertedLead(
        Set<Id> recordIds,
        String accessLevel
    ) {
        List<Contact> contactList = new List<Contact>();
        for (Contact record : contactsMap.values()) {
            if (recordIds.contains(record.Id)){
                contactList.add(record);
            }
        }
        return contactList;
    }

    public List<Contact> getPersonContactsBySetIds(
        Set<Id> recordIds,
        AccessLevel accessLevel
    ){
        List<Contact> contactList = new List<Contact>();
        for (Contact record : contactsMap.values()) {
            if (recordIds.contains(record.Id)){
                contactList.add(record);
            }
        }
        return contactList;
    }

    public List<Contact> getAlumniPersonContactsBySetIds(
        Set<Id> recordIds,
        AccessLevel accessLevel
    ){
        List<Contact> contactList = new List<Contact>();
        for (Contact record : contactsMap.values()) {
            if (recordIds.contains(record.Id)){
                contactList.add(record);
            }
        }
        return contactList;
    }

    public List<Contact> getContactByCaseMobile(
        Set<String> caseMobile,
        AccessLevel accessLevel
    ){
        List<Contact> contactList = new List<Contact>();
        for (Contact record : contactsMap.values()) {
            if (caseMobile.contains(record.MobilePhone)){
                contactList.add(record);
            }
        }
        return contactList;
    }

    public List<Contact> getPersonContactsByEmailOrName(
        ContactsDAO.QueryParamWrapperEmailOrName queryParam,
        AccessLevel accessLevel
    ){

        String email = queryParam.email;
        List<Contact> contactList = new List<Contact>();

        for (Contact record : contactsMap.values()) {
            if (email != null && email != '' && email == record.Email) {
                contactList.add(record);
            }
        }

        return contactList;
    }

    public List<Contact> getContactsForQTACAddressUpdate(
        Set<Id> qtacApplicantIdSet,
        AccessLevel accessLevel
    ) {
        List<Contact> contactList = new List<Contact>();
        for(Contact contact : contactsMap.values()) {
            if(qtacApplicantIdSet.contains(contact.Id)) {
                contactList.add(contact);
            }
        }
        return contactList;
    }

    public List<Contact> getContactMobilePhoneByRecordIds(
        Set<Id> recordIds,
        AccessLevel accessLevel
    ){
        List<Contact> contactList = new List<Contact>();
        for (Contact record : contactsMap.values()) {
            if (recordIds.contains(record.Id)){
                contactList.add(record);
            }
        }
        return contactList;
    }

    public Database.QueryLocator queryLocatorGetContactsByIds(
        Set<Id> recordIds
    ){
        return null;
    }
    
    public List<Contact> getExistingMCPersonaContactsBySetIds(
        Set<Id> recordIds,
        AccessLevel accessLevel
    ){
        List<Contact> contactList = new List<Contact>();
        for (Contact record : contactsMap.values()) {
            if (recordIds.contains(record.Id)){
                contactList.add(record);
            }
        }
        return contactList;
    }

    public List<Contact> getContactsByParentPersonLeadIds(
        Set<Id> leadIds,
        AccessLevel accessLevel
    ) {
        List<Contact> contactList = new List<Contact>();
        for(Contact con : contactsMap.values()) {
            if(leadIds.contains(con.Parent_Person_Lead__c)) {
                contactList.add(con);
            }
        }
        return contactList;
    }

    public List<Contact> getContactsNoParentPersonContactByIds(
        Set<Id> recordIds,
        AccessLevel accessLevel
    ) {
        List<Contact> contactList = new List<Contact>();
        for(Contact con : contactsMap.values()) {
            if(recordIds.contains(con.Id) && con.Parent_Person_Contact__c == null) {
                contactList.add(con);
            }
        }
        return contactList;
    }

    public List<Contact> getMCPersonaContactsByParentPersonContactIds(
        Set<Id> recordIds,
        AccessLevel accessLevel
    ){
        List<Contact> contactList = new List<Contact>();
        for (Contact record : contactsMap.values()) {
            if (recordIds.contains(record.Parent_Person_Contact__c)){
                contactList.add(record);
            }
        }
        return contactList;
    }

    public List<Contact> getContactsWithParentPersonContactByIds(
        Set<Id> recordIds,
        AccessLevel accessLevel
    ) {
        List<Contact> contactList = new List<Contact>();
        for(Contact con : contactsMap.values()) {
            if(recordIds.contains(con.Id)) {
                contactList.add(con);
            }
        }
        return contactList;
    }

    public List<Contact> getMCPersonaContactsByParentPersonLeadIds(
        Set<Id> recordIds,
        AccessLevel accessLevel
    ){
        List<Contact> contactList = new List<Contact>();
        for (Contact record : contactsMap.values()) {
            if (recordIds.contains(record.Parent_Person_Lead__c)){
                contactList.add(record);
            }
        }
        return contactList;
    }

    public List<Contact> getPersonContactsWithMatchingEmailsPosition(
        String filterString,
        Integer queryLimit,
        AccessLevel accessLevel
    ){
        List<Contact> contactList = new List<Contact>();
        if(!String.isEmpty(filterString)){
            for (Contact record : contactsMap.values()) {
                Boolean hasMatchingEmail = (record.Email != null && 
                            record.Email.contains(filterString)) || 
                            (record.QUT_Learner_Email__c != null && 
                            record.QUT_Learner_Email__c.contains(filterString)) || 
                            (record.QUT_Staff_Email__c != null && 
                            record.QUT_Staff_Email__c.contains(filterString)) || 
                            (record.Work_Email__c != null && 
                            record.Work_Email__c.contains(filterString)) || 
                            (record.hed__UniversityEmail__c != null && 
                            record.hed__UniversityEmail__c.contains(filterString));
                Boolean hasMatchingName = (record.Name != null && record.Name.contains(filterString)) || 
                            (record.Salutation != null && record.Salutation.contains(filterString)) || 
                            (record.FirstName != null && record.FirstName.contains(filterString)) || 
                            (record.MiddleName != null && record.MiddleName.contains(filterString)) || 
                            (record.LastName != null && record.LastName.contains(filterString)) ||
                            (record.Suffix != null && record.Suffix.contains(filterString));
                Boolean hasMatchingPosition = (record.Position__c != null && 
                            record.Position__c.contains(filterString));

                if (hasMatchingEmail || hasMatchingName || hasMatchingPosition){
                    contactList.add(record);
                }
            }
        }
        return contactList;
    }

    public List<Contact> getPersonContactsByNameUsingSOSL(
        String filterName
    ){
        List<Contact> contactList = new List<Contact>();
        for (Contact record : contactsMap.values()) {
            if ( record.RecordTypeId == ContactsDAO.PERSON_RECORDTYPE_ID && filterName.contains(record.Name) ) 
            {
                contactList.add(record);
            }
        }
        return contactList;
    }

    public String getWhereClauseByCriteria(
        ContactsDAO.Criteria contactCriteria
    ){
        return 
            'WHERE hed__Citizenship_Status__c = \'' + contactCriteria.getCitizenshipStatus() + '\' ' +
              'AND QUT_Student__c = ' + contactCriteria.getIsQUTStudent() + ' ' +
              'AND RecordType.DeveloperName = \'' + contactCriteria.getRecordType() + '\' ' +
              'AND Id IN (' + contactCriteria.getContactIdSet() + ') ';
    }

    public Database.QueryLocator getQueryLocatorByCriteria(ContactsDAO.Criteria criteria) {        
        String query =
        'SELECT Id, hed__Citizenship_Status__c, QUT_Student_ID__c, Email, Name, MobilePhone ' + 
              'FROM Contact ' + getWhereClauseByCriteria(criteria);
        return Database.getQueryLocator(query);
    }

    public Database.QueryLocator getQueryLocatorBySubQuery(String subQueryString) {   //update to string
        String query =
        'SELECT Id, hed__Citizenship_Status__c, QUT_Student_ID__c, Email, Name, MobilePhone ' + 
             'FROM Contact WHERE Id IN (' + subQueryString + ')';
        return Database.getQueryLocator(query);
    }

    public List<Contact> findByCriteria(
        ContactsDAO.Criteria contactCriteria,
        AccessLevel accessLevel
    ) {
        List<Contact> contactList = new List<Contact>();

        for (Contact record : contactsMap.values()) {
            if(
                record.hed__Citizenship_Status__c == contactCriteria.getCitizenshipStatus() &&
                record.QUT_Student__c == contactCriteria.getIsQUTStudent() &&
                record.RecordType.DeveloperName == contactCriteria.getRecordType() 
            )
            {
                contactList.add(record);
            }
        }
        return contactList;
    }

    public List<Contact> getContactByStudentId(
        List<String> studentIdList,
        AccessLevel accessLevel){
        List<Contact> contactList = new List<Contact>();

        for(Contact con : contactsMap.values()) {
            if(studentIdList.contains(String.valueOf(con.Id))) {
                contactList.add(con);
            }
        }
        return contactList;  
    }

    public Database.QueryLocator getQueryLocatorContactByStudentId(
        List<String> studentIdList,
        AccessLevel accessLevel
    ){
        return null;
    }
}