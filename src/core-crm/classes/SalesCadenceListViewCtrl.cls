/**
 * @description Controller for salesCadenceListView.js
 * @see ../lwc/salesCadenceListView
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                        |
 *    |--------------------------------|-----------------------|------------------------|---------------------------------------|
 *    | roy.nino.s.regala              | July 19, 2023         | DEPP-5677              | Created file                                              |
 *    | mark.j.mahilum                 | Aug 23, 2023          | DEPP-6215              | Added method to add completed cadence                     |
 *    | roy.nino.s.regala              | Sep 22, 2023          | DEPP-6365              | Added new field mappings                                  |
 *    | neil.lesidan                   | Oct 23, 2023          | DEPP-6975              | Added new field mappings                                  |
 *    | johanna.a.gibas                | Oct 25, 2023          | DEPP-6889              | Updated updateCalculatedCadence to                        |
 *    |                                |                       |                        |     include updateCompletedCadences                       |
 *    | roy.nino.s.regala              | Oct 30, 2023          | DEPP-7024              | fixed pmd issue                                           |
 *    |                                |                       |                        | and added Related_QTAC_Application__r.QTAC_Offer_Round__c
 */
public with sharing class SalesCadenceListViewCtrl { // NOPMD - wrapper class requires a lot of public variables
    private static final String ASSIGN_TARGET_CADENCE_ENDPOINT = System.Label.SalesCadenceAssignTargetEndpoint;

    /**
     * @description gets the data for the salescadence on the list view
     *
     * @param string calculatedCadence - calculated cadence name
     * @return List<DataTableWrapper> - list of contact/lead records
     */
    @AuraEnabled
    public static List<DataTableWrapper> getTableDataWrapper(String calculatedCadence) {
        
        Set<Id> targetIds = new Set<Id>();
        Map<String, Completed_Cadence__c> completedCadenceMap = new Map<String, Completed_Cadence__c>();

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

        Set<String> caTargetIds = new Set<String>((List<String>) new List<Id>(targetIds));

        //get latest contact/lead record's related completed cadence status against the calculated cadence
        for (
            Completed_Cadence__c completedCadence : CompletedCadencesDAO.newInstance()
                .getCompletedCadenceByTargetIdsAndCadenceName(
                    caTargetIds,
                    new Set<String>{ calculatedCadence },
                    'USER_MODE'
                )
        ) {
            completedCadenceMap.put(
                completedCadence.Contact__c != null
                    ? completedCadence.Contact__c
                    : completedCadence.Lead__c,
                completedCadence
            );
        }

        return buildRecordDetails(contactMap, leadMap, completedCadenceMap);
    }

    private static List<DataTableWrapper> buildRecordDetails(
        Map<Id, Contact> contactMap,
        Map<Id, Lead> leadMap,
        Map<String, Completed_Cadence__c> completedCadenceMap
    ) {
        List<DataTableWrapper> recordDetailsWrapper = new List<DataTableWrapper>();

        buildContactColumns(contactMap,completedCadenceMap,recordDetailsWrapper);
        buildLeadColumns(leadMap, completedCadenceMap,recordDetailsWrapper);

        return recordDetailsWrapper;
    }

    private static void buildContactColumns(
        Map<Id, Contact> contactMap,
        Map<String, Completed_Cadence__c> completedCadenceMap,
        List<DataTableWrapper> recordDetailsWrapper){

        DataTableWrapper tempWrapper;
        //setup contact records as rows
        for (Contact record : contactMap.values()) {
            tempWrapper = new DataTableWrapper();
            tempWrapper.id = record.Id;
            tempWrapper.name = record.Name;
            tempWrapper.gender = record.hed__Gender__c;
            tempWrapper.email = record.Email;
            tempWrapper.citizenshipCountry = record.Citizenship_Country__c;
            tempWrapper.primaryStudyInterest = record.Marketing_Segmentation__r.My_Primary_BSA__c;
            tempWrapper.leadScore = record.Lead_Score__c;
            tempWrapper.agentAssisted = record.Is_Agent_Assisted__c;

            if(!completedCadenceMap.containsKey(record.Id)){
                recordDetailsWrapper.add(tempWrapper);
                continue;
            }

            tempWrapper.completedCadenceStatus = completedCadenceMap.get(record.Id).Completed_Cadence_Status__c;
            tempWrapper.entryDate = completedCadenceMap.get(record.Id).CreatedDate;
            tempWrapper.offeredPreference = completedCadenceMap.get(record.Id).Application__r.Offered_Preference__r.Name;
            tempWrapper.offeredPreferenceOwningFaculty = completedCadenceMap.get(record.Id).Application__r.Offered_Preference__r.Faculty__c;
            tempWrapper.offeredProgram = completedCadenceMap.get(record.Id).Application__r.Offered_Program_Plan__r.Name;
            tempWrapper.offeredProgramOwningFaculty = completedCadenceMap.get(record.Id).Application__r.Offered_Program_Plan__r.Owning_Faculty__r.Name;
            tempWrapper.qtacOfferRound = completedCadenceMap.get(record.Id).Application__r.Related_QTAC_Application__r.QTAC_Offer_Round__c;

            recordDetailsWrapper.add(tempWrapper);
        }
    }

    private static void buildLeadColumns(
        Map<Id, Lead> leadMap,
        Map<String, Completed_Cadence__c> completedCadenceMap,
        List<DataTableWrapper> recordDetailsWrapper){
            
        DataTableWrapper tempWrapper;
        //setup lead records as rows
        for (Lead record : leadMap.values()) {
            tempWrapper = new DataTableWrapper();
            tempWrapper.id = record.Id;
            tempWrapper.name = record.Name;
            tempWrapper.gender = record.hed__Gender__c;
            tempWrapper.email = record.Email;
            tempWrapper.citizenshipCountry = record.Marketing_Segmentation__r.My_Country_Of_Citizenship__c;
            tempWrapper.primaryStudyInterest = record.Marketing_Segmentation__r.My_Primary_BSA__c;
            tempWrapper.leadScore = record.Lead_Score__c;

            if(!completedCadenceMap.containsKey(record.Id)){
                recordDetailsWrapper.add(tempWrapper);
                continue;
            }

            tempWrapper.completedCadenceStatus = completedCadenceMap.get(record.Id).Completed_Cadence_Status__c;
            tempWrapper.entryDate = completedCadenceMap.get(record.Id).CreatedDate;
            tempWrapper.offeredPreference = completedCadenceMap.get(record.Id).Application__r.Offered_Preference__r.Name;
            tempWrapper.offeredPreferenceOwningFaculty = completedCadenceMap.get(record.Id).Application__r.Offered_Preference__r.Faculty__c;
            tempWrapper.offeredProgram = completedCadenceMap.get(record.Id).Application__r.Offered_Program_Plan__r.Name;
            tempWrapper.offeredProgramOwningFaculty = completedCadenceMap.get(record.Id).Application__r.Offered_Program_Plan__r.Owning_Faculty__r.Name;

            recordDetailsWrapper.add(tempWrapper);
        }
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
            doNativeCallout(JSON.serialize(targetMap), endPoint);
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
        String calculatedCadence = '';
        Map<String, String> targetIdCadenceMap = new Map<String, String>();
        Set<String> targetIds = new Set<String>();

        for (Object objData : (List<Object>) JSON.deserializeUntyped(targetToUpdate)) {
            //transform object to map to dynamically get field values
            data = (Map<String, Object>) objData;
            recordId = (String) data.get('targetId');
            calculatedCadence = (String) data.get('salesCadenceNameOrId');

            if(!calculatedCadence.endsWith('Edit')) {
                targetIdCadenceMap.put(recordId, calculatedCadence);
            }

            if (String.isEmpty(calculatedCadence)) {
                targetIds.add(recordId);
            }

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

        if (!targetIdCadenceMap.isEmpty()) {
            SalesCadenceCalloutService.updateCompletedCadences(targetIdCadenceMap);
        }
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
        public String citizenshipCountry { get; set; }
        @AuraEnabled
        public String primaryStudyInterest { get; set; }
        @AuraEnabled
        public Decimal leadScore { get; set; }
        @AuraEnabled
        public String completedCadenceStatus { get; set; }
        @AuraEnabled
        public Datetime entryDate { get; set; }
        @AuraEnabled
        public String offeredPreference { get; set; }
        @AuraEnabled
        public String offeredPreferenceOwningFaculty { get; set; }
        @AuraEnabled
        public String offeredProgram { get; set; }
        @AuraEnabled
        public String offeredProgramOwningFaculty { get; set; }
        @AuraEnabled
        public boolean agentAssisted { get; set; }
        @AuraEnabled
        public Decimal qtacOfferRound { get; set; } 
    }
}