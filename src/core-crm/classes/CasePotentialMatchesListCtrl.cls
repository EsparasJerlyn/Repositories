/**
 * @description Controller Class for Case Potential Matches
 * @see ../lwc/casePotentialmatchesList
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                               |
      |--------------------------------|-----------------------|------------------------|----------------------------------------------|
      | neil.s.h.lesidan               | September 14, 2023    | DEPP-6478              | Created file                                 |
 */
public with sharing class CasePotentialMatchesListCtrl {

    @AuraEnabled
    public static Map<String, List<SObject>> getPossibleMatchEnquery(String caseId) {
        Map<String, List<SObject>> potentialMatches = new Map<String, List<SObject>>();
        List<String> fields = new List<String>{'SuppliedPhone', 'Web_First_Name__c', 'Web_Last_Name__c', 'SuppliedEmail', 'ContactId', 'Lead__c'};
        List<Case> caseList =
            (List<Case>) DynamicQueryService.getRecordsWithFieldsByIdSet(
                new DynamicQueryService.FilterWrapper(new Set<Id>{ caseId }, Case.getSObjectType(), fields),
                AccessLevel.SYSTEM_MODE
            );

        if (caseList.size() > 0) {
            Case caseRecord = caseList[0];

            if (caseRecord.ContactId == null && caseRecord.Lead__c == null) {
                possibleMatchEnquery(caseRecord, potentialMatches);
            }
        }

        return potentialMatches;
    }

    @AuraEnabled
    public static Boolean linkToCase(String caseId, String contactLeadId, String type) {
        List<Case> caseToUpdate = new List<Case>();
        List<String> fields = new List<String>{'Email', 'Name'};

        if (type == 'Contact') {
            List<Contact> contactRecord =
            (List<Contact>) DynamicQueryService.getRecordsWithFieldsByIdSet(
                new DynamicQueryService.FilterWrapper(new Set<Id>{ contactLeadId }, Contact.getSObjectType(), fields),
                AccessLevel.USER_MODE
            );

            if(!contactRecord.isEmpty()) {
                caseToUpdate.add(
                    new Case(
                        Id = caseId,
                        ContactId = contactLeadId
                    )
                );
            }
        } else if (type == 'Lead') {
            List<Lead> leadRecord =
                (List<Lead>) DynamicQueryService.getRecordsWithFieldsByIdSet(
                    new DynamicQueryService.FilterWrapper(new Set<Id>{ contactLeadId }, Lead.getSObjectType(), fields),
                    AccessLevel.USER_MODE
                );

            if(!leadRecord.isEmpty()) {
                caseToUpdate.add(
                    new Case(
                        Id = caseId,
                        Lead__c = contactLeadId
                    )
                );
            }
        }

        if(!caseToUpdate.isEmpty()) {
            CasesDAO.newInstance().updateRecords(caseToUpdate, true, AccessLevel.USER_MODE);
            return true;
        }

        return false;
    }

    private static void possibleMatchEnquery(Case caseRecord, Map<String, List<SObject>> potentialMatches) {
        if (caseRecord.ContactId == null) {
            ContactsDAO.QueryParamWrapperEmailOrName contactQueryParam = new ContactsDAO.QueryParamWrapperEmailOrName(
                caseRecord.SuppliedEmail,
                caseRecord.Web_First_Name__c,
                caseRecord.Web_Last_Name__c,
                caseRecord.SuppliedPhone
            );

            List<SObject> contactList =  ContactsDAO.newInstance().getContactByEmailOrName(contactQueryParam, AccessLevel.USER_MODE);
            potentialMatches.put('Contact', contactList);
        }

        if (caseRecord.Lead__c == null) {
            LeadsDAO.QueryParamWrapperEmailOrName leadQueryParam = new LeadsDAO.QueryParamWrapperEmailOrName(
                caseRecord.SuppliedEmail,
                caseRecord.Web_First_Name__c,
                caseRecord.Web_Last_Name__c,
                caseRecord.SuppliedPhone
            );

            List<SObject> leadList =  LeadsDAO.newInstance().getLeadByEmailOrName(leadQueryParam, AccessLevel.USER_MODE);

            potentialMatches.put('Lead', leadList);
        }
    }
}