/**
 * @description Controller Class for Potential Matches
 * @see ../lwc/potentialmatchesList
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                    |
      |--------------------------------|-----------------------|------------------------|---------------------------------------------------|
      | neil.s.h.lesidan               | September 14, 2023    | DEPP-6478              | Created file                                      |
      | neil.s.h.lesidan               | November 23, 2023     | DEPP-7280              | Include Service Appointment in Potential Matches  |
 */
public with sharing class PotentialMatchesListCtrl {

    @AuraEnabled
    public static Map<String, List<SObject>> getPossibleMatchEnquery(String objectId, String objectName) {
        Map<String, List<SObject>> potentialMatches = new Map<String, List<SObject>>();
        List<SObject> objList = new List<SObject> ();

        if (objectName == 'Case') {
            List<String> fields = new List<String>{'SuppliedPhone', 'Web_First_Name__c', 'Web_Last_Name__c', 'SuppliedEmail', 'ContactId', 'Lead__c'};
            objList = (List<SObject>) DynamicQueryService.getRecordsWithFieldsByIdSet(
                new DynamicQueryService.FilterWrapper(new Set<Id>{ objectId }, Case.getSObjectType(), fields),
                AccessLevel.SYSTEM_MODE
            );
        }

        if (objectName == 'ServiceAppointment') {
            List<String> fields = new List<String>{'Mobile_No_Locale__c', 'First_Name__c', 'Last_Name__c', 'Email', 'Contact__c', 'LeadId__c'};
            objList = (List<SObject>) DynamicQueryService.getRecordsWithFieldsByIdSet(
                new DynamicQueryService.FilterWrapper(new Set<Id>{ objectId }, ServiceAppointment.getSObjectType(), fields),
                AccessLevel.SYSTEM_MODE
            );
        }

        if (objList.size() > 0) {
            SObject objRecord = objList[0];
            possibleMatchEnquery(objRecord, potentialMatches, objectName);
        }

        return potentialMatches;
    }

    @AuraEnabled
    public static Boolean linkToObject(String objectId, String contactLeadId, String type, String objectName) { //NOPMD
        List<SObject> objectToUpdate = new List<SObject>();
        List<String> fields = new List<String>{'Email', 'Name'};

        if (type == 'Contact') {
            List<Contact> contactRecord =
            (List<Contact>) DynamicQueryService.getRecordsWithFieldsByIdSet(
                new DynamicQueryService.FilterWrapper(new Set<Id>{ contactLeadId }, Contact.getSObjectType(), fields),
                AccessLevel.USER_MODE
            );

            if(!contactRecord.isEmpty()) {
                objectToUpdate = objectToUpdateContact(objectId, contactLeadId, objectName);
            }
        } else if (type == 'Lead') {
            List<Lead> leadRecord =
                (List<Lead>) DynamicQueryService.getRecordsWithFieldsByIdSet(
                    new DynamicQueryService.FilterWrapper(new Set<Id>{ contactLeadId }, Lead.getSObjectType(), fields),
                    AccessLevel.USER_MODE
                );

            if(!leadRecord.isEmpty()) {
                objectToUpdate = objectToUpdateLead(objectId, contactLeadId, objectName);
            }
        }

        if(!objectToUpdate.isEmpty()) {
            if (objectName == 'Case') {
                CasesDAO.newInstance().updateRecords(objectToUpdate, true, AccessLevel.USER_MODE);
            }

            if (objectName == 'ServiceAppointment') {
                ServiceAppointmentsDAO.newInstance().updateRecords(objectToUpdate, true, AccessLevel.SYSTEM_MODE);
            }

            return true;
        }

        return false;
    }

    private static List<SObject> objectToUpdateContact(String objectId, String contactLeadId, String objectName) {
        List<SObject> objectToUpdate = new List<SObject>();
        if (objectName == 'Case') {
            objectToUpdate.add(
                new Case(
                    Id = objectId,
                    ContactId = contactLeadId
                )
            );
        }

        if (objectName == 'ServiceAppointment') {
            objectToUpdate.add(
                new ServiceAppointment(
                    Id = objectId,
                    Contact__c = contactLeadId
                )
            );
        }

        return objectToUpdate;
    }

    private static List<SObject> objectToUpdateLead(String objectId, String contactLeadId, String objectName) {
        List<SObject> objectToUpdate = new List<SObject>();
        if (objectName == 'Case') {
            objectToUpdate.add(
                new Case(
                    Id = objectId,
                    Lead__c = contactLeadId
                )
            );
        }

        if (objectName == 'ServiceAppointment') {
            objectToUpdate.add(
                new ServiceAppointment(
                    Id = objectId,
                    LeadId__c = contactLeadId
                )
            );
        }

        return objectToUpdate;
    }

    private static void possibleMatchEnquery(SObject objRecord, Map<String, List<SObject>> potentialMatches, String objectName) {
        Map<String, String> queryPrams = new Map<String, String>();
        filteredByObjectFields(objRecord, queryPrams, objectName);

        String contactId = '';
        String leadId = '';
        if (objectName == 'Case') {
            contactId = (String) objRecord.get('ContactId');
            leadId = (String) objRecord.get('Lead__c');
        }

        if (objectName == 'ServiceAppointment') {
            contactId = (String) objRecord.get('Contact__c');
            leadId = (String) objRecord.get('LeadId__c');
        }

        if (String.isEmpty(contactId) && String.isEmpty(leadId)) {
            ContactsDAO.QueryParamWrapperEmailOrName contactQueryParam = new ContactsDAO.QueryParamWrapperEmailOrName(
                queryPrams.get('email'),
                queryPrams.get('firstname'),
                queryPrams.get('lastname'),
                queryPrams.get('phone')
            );

            List<SObject> contactList =  ContactsDAO.newInstance().getPersonContactsByEmailOrName(contactQueryParam, AccessLevel.USER_MODE);
            potentialMatches.put('Contact', contactList);

            LeadsDAO.QueryParamWrapperEmailOrName leadQueryParam = new LeadsDAO.QueryParamWrapperEmailOrName(
                queryPrams.get('email'),
                queryPrams.get('firstname'),
                queryPrams.get('lastname'),
                queryPrams.get('phone')
            );

            List<SObject> leadList = LeadsDAO.newInstance().getLeadByEmailOrName(leadQueryParam, true, AccessLevel.USER_MODE);

            potentialMatches.put('Lead', leadList);
        }
    }

    private static void filteredByObjectFields(SObject objRecord, Map<String, String> queryPrams, String objectName) {
        if (objectName == 'Case') {
            queryPrams.put('email', (String) objRecord.get('SuppliedEmail'));
            queryPrams.put('firstname', (String) objRecord.get('Web_First_Name__c'));
            queryPrams.put('lastname', (String) objRecord.get('Web_Last_Name__c'));
            queryPrams.put('phone', (String) objRecord.get('SuppliedPhone'));
        }

        if (objectName == 'ServiceAppointment') {
            queryPrams.put('email', (String) objRecord.get('Email'));
            queryPrams.put('firstname', (String) objRecord.get('First_Name__c'));
            queryPrams.put('lastname', (String) objRecord.get('Last_Name__c'));
            queryPrams.put('phone', (String) objRecord.get('Mobile_No_Locale__c'));
        }
    }
}