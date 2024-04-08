/**
 * @description Controller for salesCadenceListView.js
 * @see ../lwc/salesCadenceListView
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                            |
 *    |--------------------------------|-----------------------|------------------------|-----------------------------------------------------------|
 *    | roy.nino.s.regala              | July 19, 2023         | DEPP-5677              | Created file                                              |
 *    | mark.j.mahilum                 | Aug 23, 2023          | DEPP-6215              | Added method to add completed cadence                     |
 *    | roy.nino.s.regala              | Sep 22, 2023          | DEPP-6365              | Added new field mappings                                  |
 *    | neil.lesidan                   | Oct 23, 2023          | DEPP-6975              | Added new field mappings                                  |
 *    | johanna.a.gibas                | Oct 25, 2023          | DEPP-6889              | Updated updateCalculatedCadence to                        |
 *    |                                |                       |                        |     include updateCompletedCadences                       |
 *    | roy.nino.s.regala              | Oct 30, 2023          | DEPP-7024              | fixed pmd issue                                           |
 *    |                                |                       |                        | and added Related_QTAC_Application__r.QTAC_Offer_Round__c |
 *    | roy.nino.s.regala              | Nov 22, 2023          | DEPP-7283              | validate contact/lead before assigning to cadence and user|
 *    | roy.nino.s.regala              | Dec 11, 2023          | DEPP-7311              | Added assign to others logic and user filter              |
*     | mark.j.mahilum                 | April 08, 2024        | DEPP-8378              | Updated method paramater of sendRequest                   |
 */
public with sharing class SalesCadenceListViewCtrl { // NOPMD - wrapper class requires a lot of public variables
    private static final String ASSIGN_TARGET_CADENCE_ENDPOINT = System.Label.SalesCadenceAssignTargetEndpoint;

    private static final Map<String,Set<String>> ROLE_MAPPING = new Map<String,Set<String>>{
        'Domestic' => new Set<String>{
            'Future_Student_Agent_Domestic',
            'Future_Student_Concierge_Domestic',
            'Future_Student_Team_Leader_Domestic'
        },
        'International' => new Set<String>{
            'Future_Student_Agent_International',
            'Future_Student_Concierge_International',
            'Future_Student_Team_Leader_International'
        }
    };
    private static final Set<String> TEAM_LEADER_ROLES = new Set<String>{
        'Future_Student_Team_Leader_International',
        'Future_Student_Team_Leader_Domestic'
    };

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
            tempWrapper.residenceCountry = record.Country_of_Residency__c;
            tempWrapper.partnerSourced = record.Partner_Sourced__c;

            if(!completedCadenceMap.containsKey(record.Id)){
                recordDetailsWrapper.add(tempWrapper);
                continue;
            }

            tempWrapper.completedCadenceStatus = completedCadenceMap.get(record.Id).Completed_Cadence_Status__c;
            tempWrapper.entryDate = convertDatetime(completedCadenceMap.get(record.Id).CreatedDate);
            tempWrapper.offeredPreference = completedCadenceMap.get(record.Id).Application__r.Offered_Preference__r.Name;
            tempWrapper.offeredPreferenceOwningFaculty = completedCadenceMap.get(record.Id).Application__r.Offered_Preference__r.Faculty__c;
            tempWrapper.offeredProgram = completedCadenceMap.get(record.Id).Application__r.Offered_Program_Plan__r.Name;
            tempWrapper.offeredProgramOwningFaculty = completedCadenceMap.get(record.Id).Application__r.Offered_Program_Plan__r.Owning_Faculty__r.Name;
            tempWrapper.qtacOfferRound = completedCadenceMap.get(record.Id).Application__r.Related_QTAC_Application__r.QTAC_Offer_Round__c;
            tempWrapper.currentPreference = completedCadenceMap.get(record.Id).Application__r.Current_Preference__r.Name;

            recordDetailsWrapper.add(tempWrapper);
        }
    }

    /**
     * Convert the input datetime object to a display friendly value in user's local timezone.
     * @param dt the input datetime object 
     * @return a datetime object with year, month, day, hour in user's local timezone.
     */
    @TestVisible
    private static DateTime convertDatetime(DateTime dt) {
        return DateTime.newInstance(dt.year(), dt.month(), dt.day(), dt.hour(), dt.minute(), dt.second());
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
            tempWrapper.entryDate = convertDatetime(completedCadenceMap.get(record.Id).CreatedDate);
            tempWrapper.offeredPreference = completedCadenceMap.get(record.Id).Application__r.Offered_Preference__r.Name;
            tempWrapper.offeredPreferenceOwningFaculty = completedCadenceMap.get(record.Id).Application__r.Offered_Preference__r.Faculty__c;
            tempWrapper.offeredProgram = completedCadenceMap.get(record.Id).Application__r.Offered_Program_Plan__r.Name;
            tempWrapper.offeredProgramOwningFaculty = completedCadenceMap.get(record.Id).Application__r.Offered_Program_Plan__r.Owning_Faculty__r.Name;
            tempWrapper.currentPreference = completedCadenceMap.get(record.Id).Application__r.Current_Preference__r.Name;

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
    public static void assignToCadence(List<Object> targetsToEnroll, String targetsToChange) {
        if(targetsToEnroll.isEmpty()){
            return;
        }

        Map<String, List<Object>> targetMap = new Map<String, List<Object>>();
        
        String endPoint = ASSIGN_TARGET_CADENCE_ENDPOINT;

        //rempves the contact/lead from the table by changing the calculated cadence value
        updateCalculatedCadence(targetsToChange);
        targetMap.put('inputs', targetsToEnroll);
        doNativeCallout(JSON.serialize(targetMap), endPoint);
    }

    private static void collectIdsToRemove(Set<Id> targetIdsToRemove, List<Id> targetIds, String calculatedCadence){

        Set<String> calculatedCadenceSet = new Set<String>{calculatedCadence};
        Set<Id> targetIdsSet = new Set<Id>(targetIds);

        for(Contact record: ContactsDAO.newInstance().getPersonContactsBySetIds(new Set<Id>(targetIds),AccessLevel.SYSTEM_MODE)){
            if(record.Calculated_Cadence__c == calculatedCadence + ' Edit'){
                //collect contact/leads ids where asignment is in progress
                targetIdsToRemove.add(record.Id);
            }
        }

        for(Lead record: LeadsDAO.newInstance().getLeadsByIdSet(new Set<Id>(targetIds),AccessLevel.SYSTEM_MODE)){
            if(record.Calculated_Cadence__c == calculatedCadence + ' Edit'){
                //collect contact/leads ids where asignment is in progress
                targetIdsToRemove.add(record.Id);
            }
        }

        for (
            ActionCadenceTracker aCadenceTracker : ActionCadenceTrackersDAO.newInstance()
                .getRunningACTrackerByTargetIdAndCadenceName(
                    targetIdsSet,
                    calculatedCadenceSet,
                    'USER_MODE'
                )
        ){
            //collect contact/leads ids that has a running action cadence tracker
            targetIdsToRemove.add(aCadenceTracker.TargetId);
        } 

        filterByCompletedCadence(targetIdsSet,calculatedCadenceSet,targetIdsToRemove);

    }

    private static void filterByCompletedCadence(Set<Id> targetIdsSet, Set<String> calculatedCadenceSet, Set<Id> targetIdsToRemove){
        for (
            Completed_Cadence__C completedCadence : CompletedCadencesDAO.newInstance()
                .getCompletedCadenceByTargetIds(
                    targetIdsSet,
                    calculatedCadenceSet,
                    'USER_MODE'
                )
        ){
            //collect contact/leads ids that has a Succesful cadence status
            if(completedCadence.Completed_Cadence_Status__c != CompletedCadencesDAO.SUCCESSFUL_STATUS){
                continue;
            }

            if(completedCadence.Lead__c != null){
                targetIdsToRemove.add(completedCadence.Lead__c);
            }
            
            if(completedCadence.Contact__c != null){
                targetIdsToRemove.add(completedCadence.Contact__c);
            }
        } 
    }


    /**
     * @description validate contact/lead ids to assign
     * check if contact or lead already has a running action cadence tracker
     *
     * @param List<Id> targetIds - contact or lead ids to be assigned 
     * @param String calculatedCadence -  the manual cadence name the contact/lead is to be assigned
     * @return List<Id> - final list of ids to be assigned to a cadence and user
     */
    @AuraEnabled
    public static List<Id> validateTargetsToAssign(List<Id> targetIds, String calculatedCadence){
        Set<Id> targetIdsToRemove = new Set<Id>();
        List<Id> finalTragetIds = new List<Id>();
        
        collectIdsToRemove(targetIdsToRemove,targetIds,calculatedCadence);

        //create a final list of contact or lead ids to assign to cadence and user
        for(Id targetId: targetIds){
            //add the contact/lead id to the final list
            //if it has no running action cadence and no successful completed cadence
            if(!targetIdsToRemove.contains(targetId)){
                finalTragetIds.add(targetId);
            }
        }

        return finalTragetIds;
    }

    /**
     * @description call the callout and revert calculated cadence update
     *
     * @param String endpointPath - endpoint of the call out
     * @param String payLoad - payload for the api call e.g. "[{targetId:003A4434F,salesCadenceNameOrId:'Domestic Strong Interest Pre-Application Edit'}]"
     */
    @future(callout=true)
    public static void doNativeCallout(String payload, String endpointPath) {
        SalesCadenceCalloutService.sendRequest(payLoad, endpointPath,true,null);

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

        /**
     * @description get list of user searched
     * @param filterString - search string for filter
     * @param citizenship - tells us if domestic or international
     * @return list of map of formatted user for customSearch
     */
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getSearchedUsers(
        String filterString,
        String citizenship
    ) {
        List<Map<String, String>> userMap = new List<Map<String, String>>();
        Set<String> roleSet = ROLE_MAPPING.get(citizenship);

        if(String.isBlank(filterString)){
            return userMap;
        }

        String whereClause = 'UserRole.DeveloperName IN';
        whereClause += '(\'' + String.join(roleSet, '\',\'') + '\')';
        whereClause += ' AND Id != ' + '\'' + UserInfo.getUserId() + '\'';

        List<User> users = FlowLookupController.search(
            filterString,
            'User',
            'Name',
            'Id,Name,Email',
            15,
            whereClause,
            ''
        );

        for (User user : users) {
            userMap.add(
                new Map<String, String>{
                    'id' => user.Id,
                    'label' => user.Name,
                    'meta' => user.Email
                }
            );
        }
        return userMap;
    }

    /**
     * @description get list of recently viewed user records
     * @param citizenship - tells us if domestic or international
     * @return list of map of formatted user for customSearch
     */
    @AuraEnabled
    public static List<Map<String, String>> getRecentlyViewed(String citizenship) {
        List<Map<String, String>> userMap = new List<Map<String, String>>();
        Set<String> roleSet = ROLE_MAPPING.get(citizenship);

        String whereClause = 'UserRole.DeveloperName IN';
        whereClause += '(\'' + String.join(roleSet, '\',\'') + '\')';
        whereClause += ' AND Id != ' + '\'' + UserInfo.getUserId() + '\'';

        List<User> recentlyViewedUsers = FlowLookupController.getRecentlyViewed(
            'User',
            'Id,Name,Email',
            5,
            whereClause
        );

        for (User user : recentlyViewedUsers) {
            userMap.add(
                new Map<String, String>{
                    'id' => user.Id,
                    'label' => user.Name,
                    'meta' => user.Email
                }
            );
        }
        return userMap;
    }
    /**
     * @description get list of user searched
     * @param filterString - search string for filter
     * @param filterUsers - list of user ids
     * @return list of map of formatted user for customSearch
     */
    @AuraEnabled(cacheable=true)
    public static boolean checkUserRole() {
        if (
            TEAM_LEADER_ROLES.contains(
                UsersDAO.newInstance()
                        .getUsersByNameSet(
                            new Set<String>{ UserInfo.getUserName() },
                            AccessLevel.SYSTEM_MODE
                        )[0]
                    .UserRole.DeveloperName
            )
        ) {
            return true;
        }
        return false;
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
        @AuraEnabled
        public String residenceCountry {get; set;}
        @AuraEnabled
        public boolean partnerSourced {get;set;}
        @AuraEnabled
        public String currentPreference {get;set;}
    }
}