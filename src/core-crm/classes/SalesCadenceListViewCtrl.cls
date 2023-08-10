/**
 * @description Controller for salesCadenceListView.js
 * @see ../lwc/salesCadenceListView
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                 |
 *    |--------------------------------|-----------------------|------------------------|--------------------------------|
 *    | roy.nino.s.regala              | July 19, 2023         | DEPP-5677              | Created file                   |
 */
public with sharing class SalesCadenceListViewCtrl {// NOPMD - wrapper class requires a lot of public variables

    private static final String ASSIGN_TARGET_CADENCE_ENDPOINT = System.Label.SalesCadenceAssignTargetEndpoint;

    /**
     * @description gets the data for the salescadence on the list view
     *
     * @param string calculatedCadence - calculated cadence name
     * @return List<DataTableWrapper> - list of contact/lead records 
     */
    @AuraEnabled
    public static List<DataTableWrapper> getTableDataWrapper(String calculatedCadence) {

        List<DataTableWrapper> wrapper = new List<DataTableWrapper>();
        DataTableWrapper tempWrapper;
        Set<Id> targetIds = new Set<Id>();
        Map<String, String> completedCadenceStatusMap = new Map<String, String>();

        //get person contacts with Calculated Cadence
        Map<Id, Contact> contactMap = new Map<Id, Contact>(
            ContactsDAO.newInstance()
                .getPersonContactsByCalculatedCadences(new Set<String>{ calculatedCadence })
        );

        //get learner leads with calcualted cadence
        Map<Id, Lead> leadMap = new Map<Id, Lead>(
            LeadsDAO.newInstance()
                .getLearnerLeadsByCalculatedCadences(new Set<String>{ calculatedCadence })
        );


        //store targetids to one set variable
        targetIds.addAll(contactMap.keySet());
        targetIds.addAll(leadMap.keySet());

        //remove all contact/lead that has a running Cadence
        for (
            ActionCadenceTracker aCadenceTracker : ActionCadenceTrackersDAO.newInstance()
                .getRunningACTrackerByTargetIdAndCadenceName(
                    targetIds,
                    new Set<String>{ calculatedCadence },
                    'USER_MODE'
                )
        ) {
            if (contactMap.containsKey(aCadenceTracker.TargetId)) {
                contactMap.remove(aCadenceTracker.TargetId);
            } else {
                leadMap.remove(aCadenceTracker.TargetId);
            }
        }

        //get latest contact/lead record's related completed cadence status against the calculated cadence
        for (
            Completed_Cadence__c completedCadence : CompletedCadencesDAO.newInstance()
                .getCompletedCadenceByTargetIdsAndCadenceName(
                    targetIds,
                    new Set<String>{ calculatedCadence }
                )
        ) {
            completedCadenceStatusMap.put(
                completedCadence.Contact__c != null
                    ? completedCadence.Contact__c
                    : completedCadence.Lead__c,
                completedCadence.Completed_Cadence_Status__c
            );
        }
        //setup contact records as rows
        for (Contact record : contactMap.values()) {
            tempWrapper = new DataTableWrapper();
            tempWrapper.id = record.Id;
            tempWrapper.name = record.Name;
            tempWrapper.gender = record.hed__Gender__c;
            tempWrapper.email = record.Email;
            tempWrapper.countryOfCitizenship = record.Citizenship_Country__c;
            tempWrapper.countryOfResidency = record.Marketing_Segmentation__r.My_Country_Of_Residency__c;
            tempWrapper.leadScore = record.Lead_Score__c;
            tempWrapper.completedCadenceStatus = completedCadenceStatusMap.containsKey(record.Id)
                ? completedCadenceStatusMap.get(record.Id)
                : '';
            wrapper.add(tempWrapper);
        }

        //setup lead records as rows
        for (Lead record : leadMap.values()) {
            tempWrapper = new DataTableWrapper();
            tempWrapper.id = record.Id;
            tempWrapper.name = record.Name;
            tempWrapper.gender = record.hed__Gender__c;
            tempWrapper.email = record.Email;
            tempWrapper.countryOfCitizenship = record.Marketing_Segmentation__r.My_Country_Of_Citizenship__c;
            tempWrapper.countryOfResidency = record.Marketing_Segmentation__r.My_Country_Of_Residency__c;
            tempWrapper.leadScore = record.Lead_Score__c;
            tempWrapper.completedCadenceStatus = completedCadenceStatusMap.containsKey(record.Id)
                ? completedCadenceStatusMap.get(record.Id)
                : '';
            wrapper.add(tempWrapper);
        }

        return wrapper;
    }

    /**
     * @description assign contact/lead to the cadence
     *
     * @param List<Object> targetsToEnroll - the payload of the api call
     *                                       e.g. [{targetId:003A4434F,salesCadenceNameOrId:'Domestic Strong Interest Pre-Application'}]
     * @param String targetsToChange -   data needed to update calculated cadence of contact/lead
     *                                   e.g. "[{targetId:003A4434F,salesCadenceNameOrId:'Domestic Strong Interest Pre-Application Edit'}]"
     */
    @AuraEnabled
    public static void assignToMe(List<Object> targetsToEnroll, String targetsToChange) {
        Map<String, List<Object>> targetMap = new Map<String, List<Object>>();

        String endPoint = ASSIGN_TARGET_CADENCE_ENDPOINT;

        //rempves the contact/lead from the table by changing the calculated cadence value
        updateCalculatedCadence(targetsToChange);

        if (!targetsToEnroll.isEmpty()) {
            targetMap.put('inputs', targetsToEnroll);
            doNativeCallout(JSON.serialize(targetMap),endPoint);
        }
    }

    /**
     * @description call the callout and revert calculated cadence update
     *
     * @param String endpointPath - endpoint of the call out
     * @param String payLoad - payload for the api call e.g. "[{targetId:003A4434F,salesCadenceNameOrId:'Domestic Strong Interest Pre-Application Edit'}]"
     */
    @future(callout=true)
    public static void doNativeCallout(String payload, String endpointPath) {
        SalesCadenceCalloutService.sendRequest(payLoad, endpointPath);

        Map<String, Object> payLoadDataMap = (Map<String, Object>) JSON.deserializeUntyped(payload);
        //revert calculated cadence update, use the payload
        updateCalculatedCadence(JSON.serialize((List<Object>) payLoadDataMap.get('inputs')));
    }

    /**
     * @description update calcualted cadence field of contact/lead
     * 
     * @param String targetToUpdate - payload for the api call e.g. "[{targetId:003A4434F,salesCadenceNameOrId:'Domestic Strong Interest Pre-Application Edit'}]"
     */
    @AuraEnabled
    public static void updateCalculatedCadence(String targetToUpdate) {
        List<Contact> contactsToUpdate = new List<Contact>();
        List<Lead> leadsToUpdate = new List<Lead>();
        Map<String, Object> data = new Map<String, Object>();
        String recordId = '';

        for (Object objData : (List<Object>) JSON.deserializeUntyped(targetToUpdate)) {
            //transform object to map to dynamically get field values
            data = (Map<String, Object>) objData;
            recordId = (String) data.get('targetId');

            if (recordId.startswith('003')) {
                contactsToUpdate.add(
                    new Contact(
                        Id = (Id) data.get('targetId'),
                        Calculated_Cadence__c = (String) data.get('salesCadenceNameOrId')
                    )
                );
            } else {
                leadsToUpdate.add(
                    new Lead(
                        Id = (Id) data.get('targetId'),
                        Calculated_Cadence__c = (String) data.get('salesCadenceNameOrId')
                    )
                );
            }
        }

        if (!contactsToUpdate.isEmpty()) {
            ContactsDAO.newInstance().updateRecords(contactsToUpdate, true, AccessLevel.USER_MODE);
        }

        if (!leadsToUpdate.isEmpty()) {
            LeadsDAO.newInstance().updateRecords(leadsToUpdate, true, AccessLevel.USER_MODE);
        }
    }

    /**
     * @description create a completed task record
     * 
     * @param List<Task> taskRecords - task records to create
     */
    @AuraEnabled
    public static void createCompletedTask(List<Task> taskRecords) {
        TasksDAO.newInstance().insertRecords(taskRecords,true,AccessLevel.USER_MODE);
    }

    private class DataTableWrapper {
        @AuraEnabled
        public String id { get; set; }
        @AuraEnabled
        public String name { get; set; }
        @AuraEnabled
        public String gender { get; set; }
        @AuraEnabled
        public String email { get; set; }
        @AuraEnabled
        public String countryOfCitizenship { get; set; }
        @AuraEnabled
        public String countryOfResidency { get; set; }
        @AuraEnabled
        public Decimal leadScore { get; set; }
        @AuraEnabled
        public String completedCadenceStatus { get; set; }
    }
}
