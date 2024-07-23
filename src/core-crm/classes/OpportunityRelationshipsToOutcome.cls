/**
* @description The OpportunityRelationshipsToOutcome class provides methods to update Opportunity_Outcome__c records
* by copying related information from the Opportunity object.
*
* @author Accenture
*
* @history
*
*    | Developer Email                | Date                  | JIRA                   | Change Summary                                                                      |
*    |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------------------------------|
*    | kenneth.f.alsay                | July 13, 2023         | DEPP-5475              | Created File                                                                        |
*    | ryan.j.a.dela.cruz             | July 18, 2023         | DEPP-5468              | Refactor whole class, added new methods                                             |
*    | marygrace.li@qut.edu.au        | August 7, 2023        | DEPP-6275              | Updated to Pure_Project_ID1__c before deleting the field                            |
*    | marygrace.li@qut.edu.au        | August 7, 2023        | DEPP-6275              | Updated Pure_Project_ID__c field                                                    |
*    | kenneth.f.alsay                | August 14, 2023       | DEPP-6275-6208         | Removed Pure_Project_ID__c field from being copied                                  |
*    | kenneth.f.alsay                | August 25, 2023       | DEPP-6466              | Changed assignment for opptyOutcome.Start_Date__c to project creation date          |
*/

public with sharing class OpportunityRelationshipsToOutcome {
    public static Id esbIntegrationUserId;
    
    /**
* Updates Opportunity_Outcome__c records by copying related information from the Opportunity object.
*
* @param newItems A list of Opportunity_Outcome__c records to be updated.
*/
    public static void updateOpportunityOutcome(List<Opportunity_Outcome__c> newItems) {
        // Create a map to store Opportunity records based on their IDs
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        Set<Id> opportunityIds = new Set<Id>();
        
        // Collect the IDs of Opportunities associated with relevant Opportunity_Outcome__c records
        for (Opportunity_Outcome__c opptyOutcome : newItems) {
            if (isRelevantRecordType(opptyOutcome.RecordTypeId)) {
                opportunityIds.add(opptyOutcome.Opportunity__c);
            }
        }
        
        // Retrieve Opportunity records based on the collected IDs and populate the map
        oppMap.putAll(OpportunitiesDAO.newInstance().getRecordsBySetIds(opportunityIds));
        
        // Update Opportunity_Outcome__c records with related information from Opportunity records
        updateOutcomeFields(newItems, oppMap);
    }
    
    /**
* Update Opportunity_Outcome__c records with related information from Opportunity records.
*
* @param newItems A list of Opportunity_Outcome__c records to be updated.
* @param oppMap A map of Opportunity records based on their IDs.
*/
    private static void updateOutcomeFields(
        List<Opportunity_Outcome__c> newItems,
        Map<Id, Opportunity> oppMap
    ) {
        for (Opportunity_Outcome__c opptyOutcome : newItems) {
            if (oppMap.containsKey(opptyOutcome.Opportunity__c)) {
                Opportunity relatedOpportunity = oppMap.get(opptyOutcome.Opportunity__c);
                
                // Copy relevant fields from Opportunity to Opportunity_Outcome__c
                opptyOutcome.OwnerId = relatedOpportunity.OwnerId;
                opptyOutcome.Start_Date__c = System.today();
            }
        }
    }
    
    /**
* Check if the given RecordTypeId belongs to relevant types for Opportunity_Outcome__c records.
*
* @param recordTypeId The RecordTypeId to check.
* @return True if the RecordTypeId is relevant, False otherwise.
*/
    private static Boolean isRelevantRecordType(Id recordTypeId) {
        return recordTypeId == OpportunityOutcomesDAO.STARTUP_RECTYPE_ID ||
            recordTypeId == OpportunityOutcomesDAO.RESEARCHCOMMERCIALISATIONPROJECT_RECTYPE_ID;
    }
    
    /**
* @description Copies relationships from Opportunity to Opportunity_Outcome__c records, including Financial_Split__c records.
*
* @param newItems A list of Opportunity_Outcome__c records to copy relationships to.
*/
    public static void copyRelationshipsFromOppToOppOutcome(List<Opportunity_Outcome__c> newItems) {
        // Create a map to store Opportunity records based on their IDs
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        Set<Id> opportunityIds = new Set<Id>();
        
        // Create Opportunity Outcome Id to Opportunity Id Map
        Map<Id, Id> oppOutIdToOppIdMap = new Map<Id, Id>();
        
        // Collect the IDs of Opportunities associated with relevant Opportunity_Outcome__c records
        for (Opportunity_Outcome__c opptyOutcome : newItems) {
            if (
                opptyOutcome.RecordTypeId == OpportunityOutcomesDAO.STARTUP_RECTYPE_ID ||
                opptyOutcome.RecordTypeId ==
                OpportunityOutcomesDAO.RESEARCHCOMMERCIALISATIONPROJECT_RECTYPE_ID
            ) {
                opportunityIds.add(opptyOutcome.Opportunity__c);          
                oppOutIdToOppIdMap.put(opptyOutcome.Id, opptyOutcome.Opportunity__c);
            }
        }
        
        if(opportunityIds.size()>0){
            // Retrieve Opportunity records based on the collected IDs and populate the map
            oppMap.putAll(OpportunitiesDAO.newInstance().getRecordsBySetIds(opportunityIds));
                    // Retrieve the ESB Integration User
            List<User> esbIntegrationUser = [ // NO PMD
            SELECT Id
            FROM User
            WHERE FirstName = 'ESB' AND LastName = 'Integration User'
            WITH USER_MODE
            LIMIT 1
            ];
            esbIntegrationUserId = esbIntegrationUser[0].Id;
            
            // Copy Financial_Split__c records from Opportunities to Opportunity_Outcome__c records
            copyFinancialSplits(newItems, oppMap, oppOutIdToOppIdMap);
            
            // Copy Contextual_Role__c records from Opportunities to Opportunity_Outcome__c records
            copyContextualRoles(newItems, oppMap, esbIntegrationUser);
            
            // Link Pure_Project__c records to Opportunity_Outcome__c records
            linkPureProjects(newItems, oppMap, esbIntegrationUser);
            
            // Copy IP_Management_Relationship__c records from Opportunities to Opportunity_Outcome__c records
            copyIPManagementRelationships(newItems, oppMap, esbIntegrationUser);
        }
    }
    
/**
* Copies Financial_Split__c records from Opportunities to Opportunity_Outcome__c records.
*
* @param newItems             A list of Opportunity_Outcome__c records to copy relationships to.
* @param oppMap               A map of Opportunity records based on their IDs.
* @param esbIntegrationUser   The ESB Integration User.
*/
    private static void copyFinancialSplits(
        List<Opportunity_Outcome__c> newItems,
        Map<Id, Opportunity> oppMap,
        Map<Id, Id> oppOutIdToOppIdMap
    ) {
        // Retrieve Financial_Split__c records associated with the Opportunities
        List<Financial_Split__c> oppFinancialSplits = FinancialSplitsDAO.newInstance()
            .getActiveOpportunityFinancialSplitsRecords(oppMap.keySet());
        
        Map<Id, List<Financial_Split__c>> oppFinancialSplitsMap = new Map<Id, List<Financial_Split__c>>();
        List<Financial_Split__c> financialSplitList = new List<Financial_Split__c>();
        
        // Create a map of Financial_Split__c records grouped by Opportunity ID
        for (Financial_Split__c fs : oppFinancialSplits) {
            if (!oppFinancialSplitsMap.containsKey(fs.Opportunity__c)) {
                oppFinancialSplitsMap.put(fs.Opportunity__c, new List<Financial_Split__c>());
            }
            oppFinancialSplitsMap.get(fs.Opportunity__c).add(fs.clone(false, true, false, false));
        }
        
        // Copy Financial_Split__c records from Opportunities to Opportunity_Outcome__c records
        for (Opportunity_Outcome__c oppOut : newItems) {
            if (oppFinancialSplitsMap.containsKey(oppOut.Opportunity__c)) {
                financialSplitList.addAll(updateFinancialSplitRecord(oppFinancialSplitsMap.get(oppOut.Opportunity__c), oppOut.Id));
            }
        }
        
        // Insert the copied Financial_Split__c records
        if (!financialSplitList.isEmpty()) {
            FinancialSplitsDAO.newInstance()
                .insertRecords(financialSplitList, false, AccessLevel.USER_MODE);
        }
    }
    
    public static List<Financial_Split__c> updateFinancialSplitRecord(List<Financial_Split__c> fsList, Id oppOutId){
        List<Financial_Split__c> newFSList = new List<Financial_Split__c>();
        for(Financial_Split__c fs : fsList){
            fs.Opportunity__c = null;
            fs.Opportunity_Outcome__c = oppOutId;
            fs.OwnerId = esbIntegrationUserId;
            fs.RecordTypeId = FinancialSplitsDAO.OPPORTUNITY_OUTCOME_FUNDING_BODY_RECORDTYPEID;
            newFSList.add(fs);
        }
        return newFSList;
    }
    
    /**
* Copies Contextual_Role__c records from Opportunities to Opportunity_Outcome__c records.
*
* @param newItems             A list of Opportunity_Outcome__c records to copy relationships to.
* @param oppMap               A map of Opportunity records based on their IDs.
* @param esbIntegrationUser   The ESB Integration User.
*/
    private static void copyContextualRoles(
        List<Opportunity_Outcome__c> newItems,
        Map<Id, Opportunity> oppMap,
        List<User> esbIntegrationUser
    ) {
        // Add contextual role groups to List<String>
        List<String> contextualRoleGroups = new List<String>{
            'Partners',
                'School',
                'Faculty',
                'Research Centre',
                'Contributors'
                };
                    
                    // Retrieve active Contextual_Role__c records associated with the Opportunities
                    List<Contextual_Role__c> oppContextualRole = ContextualRolesDAO.newInstance()
                    .getActiveOpportunityContextualRolesRecords(oppMap.keySet(), contextualRoleGroups);
        
        Map<Id, List<Contextual_Role__c>> oppContextualRoleMap = new Map<Id, List<Contextual_Role__c>>();
        List<Contextual_Role__c> contextualRoleList = new List<Contextual_Role__c>();
        
        // Create a map of Contextual_Role__c records grouped by Opportunity ID
        for (Contextual_Role__c cr : oppContextualRole) {
            if (!oppContextualRoleMap.containsKey(cr.Opportunity__c)) {
                oppContextualRoleMap.put(cr.Opportunity__c, new List<Contextual_Role__c>());
            }
            oppContextualRoleMap.get(cr.Opportunity__c).add(cr.clone(false, true, false, false));
        }
        
        // Copy Contextual_Role__c records from Opportunities to Opportunity_Outcome__c records
        for (Opportunity_Outcome__c oppOut : newItems) {
            if (oppContextualRoleMap.containsKey(oppOut.Opportunity__c)) {
                contextualRoleList.addAll(updateContextualRoleRecords(oppContextualRoleMap.get(oppOut.Opportunity__c), oppOut.Id));
            }
        }
        
        // Insert the copied Contextual_Role__c records
        if (!contextualRoleList.isEmpty()) {
            ContextualRolesDAO.newInstance()
                .insertRecords(contextualRoleList, false, AccessLevel.USER_MODE);
        }
    }
    
    public static List<Contextual_Role__c> updateContextualRoleRecords(List<Contextual_Role__c> crList, Id oppOutId){
        List<Contextual_Role__c> newCRList = new List<Contextual_Role__c>();
        for(Contextual_Role__c cr : crList){
            cr.Opportunity__c = null;
            cr.Opportunity_Outcome__c = oppOutId;
            cr.OwnerId = esbIntegrationUserId;
            cr.RecordTypeId = ContextualRolesDAO.OPPORTUNITY_OUTCOME_ROLE_RECTYPE_ID;
            newCRList.add(cr);
        }
        return newCRList;
    }
    
    /**
* Links Pure_Project__c records to Opportunity_Outcome__c records.
*
* @param newItems             A list of Opportunity_Outcome__c records to copy relationships to.
* @param oppMap               A map of Opportunity records based on their IDs.
* @param esbIntegrationUser   The ESB Integration User.
*/
    private static void linkPureProjects(
        List<Opportunity_Outcome__c> newItems,
        Map<Id, Opportunity> oppMap,
        List<User> esbIntegrationUser
    ) {
        // Retrieve Pure_Project__c records associated with the Opportunities
        List<Pure_Project__c> oppPureProjects = PureProjectsDAO.newInstance()
            .getOpportunityPureProjectRecords(oppMap.keySet());
        
        Map<Id, List<Pure_Project__c>> oppPureProjectsMap = new Map<Id, List<Pure_Project__c>>();
        List<Pure_Project__c> pureProjectsList = new List<Pure_Project__c>();
        
        // Create a map of Pure_Project__c records grouped by Opportunity ID
        for (Pure_Project__c pp : oppPureProjects) {
            if (!oppPureProjectsMap.containsKey(pp.Opportunity__c)) {
                oppPureProjectsMap.put(pp.Opportunity__c, new List<Pure_Project__c>());
            }
            oppPureProjectsMap.get(pp.Opportunity__c).add(pp);
        }
        
        // Link Pure_Project__c records to Opportunity_Outcome__c records
        for (Opportunity_Outcome__c oppOut : newItems) {
            if (oppPureProjectsMap.containsKey(oppOut.Opportunity__c)) {
                pureProjectsList.addAll(updatePureProjectRecords(oppPureProjectsMap.get(oppOut.Opportunity__c), oppOut.Id));
            }
        }
        
        if (!pureProjectsList.isEmpty()) {
            // Update Pure_Project__c records
            PureProjectsDAO.newInstance()
                .insertRecords(pureProjectsList, false, AccessLevel.USER_MODE);
        }
    }
    
    public static List<Pure_Project__c> updatePureProjectRecords(List<Pure_Project__c> pureList, Id oppOutId){
        List<Pure_Project__c> newPureProjList = new List<Pure_Project__c>();
        for(Pure_Project__c pure : pureList){
            pure.Opportunity_Outcome__c = oppOutId;
            pure.OwnerId = esbIntegrationUserId;
            newPureProjList.add(pure);
        }
        return newPureProjList;
    }
    
    /**
	* Copies IP_Management_Relationship__c records from Opportunities to Opportunity_Outcome__c records.
	*
	* @param newItems             A list of Opportunity_Outcome__c records to copy relationships to.
	* @param oppMap               A map of Opportunity records based on their IDs.
	* @param esbIntegrationUser   The ESB Integration User.
	*/
    private static void copyIPManagementRelationships(
        List<Opportunity_Outcome__c> newItems,
        Map<Id, Opportunity> oppMap,
        List<User> esbIntegrationUser
    ) {
        List<IP_Management_Relationship__c> oppIPManagementRelationships = retrieveActiveIPManagementRelationships(
            oppMap
        );
        
        Map<Id, List<IP_Management_Relationship__c>> oppIPMgtRelationshipsMap = createIPManagementRelationshipsMap(
            oppIPManagementRelationships
        );
        
        copyIPManagementRelationshipsToOutcome(newItems, oppIPMgtRelationshipsMap);
    }
    
    /**
    * Retrieve active IP_Management_Relationship__c records associated with the Opportunities.
    *
    * @param oppMap   A map of Opportunity records based on their IDs.
    * @return A list of active IP_Management_Relationship__c records.
    */
    private static List<IP_Management_Relationship__c> retrieveActiveIPManagementRelationships(
        Map<Id, Opportunity> oppMap
    ) {
        return IPManagementRelationshipsDAO.newInstance()
            .getActiveOpportunityIPManagementRelationshipRecords(oppMap.keySet());
    }
    
    /**
    * Create a map of IP_Management_Relationship__c records grouped by Opportunity ID.
    *
    * @param oppIPManagementRelationships   A list of IP_Management_Relationship__c records.
    * @return A map of Opportunity ID to corresponding IP_Management_Relationship__c records.
    */
    private static Map<Id, List<IP_Management_Relationship__c>> createIPManagementRelationshipsMap(
        List<IP_Management_Relationship__c> oppIPManagementRelationships
    ) {
        Map<Id, List<IP_Management_Relationship__c>> oppIPMgtRelationshipsMap = new Map<Id, List<IP_Management_Relationship__c>>();
        
        for (IP_Management_Relationship__c ipMgtRel : oppIPManagementRelationships) {
            if (!oppIPMgtRelationshipsMap.containsKey(ipMgtRel.Opportunity__c)) {
                oppIPMgtRelationshipsMap.put(
                    ipMgtRel.Opportunity__c,
                    new List<IP_Management_Relationship__c>()
                );
            }
            oppIPMgtRelationshipsMap.get(ipMgtRel.Opportunity__c)
                .add(ipMgtRel.clone(false, true, false, false));
        }
        
        return oppIPMgtRelationshipsMap;
    }
    
    /**
    * Copy IP_Management_Relationship__c records from Opportunities to Opportunity_Outcome__c records.
    *
    * @param newItems                   A list of Opportunity_Outcome__c records to copy relationships to.
    * @param oppIPMgtRelationshipsMap   A map of Opportunity ID to corresponding IP_Management_Relationship__c records.
    */
    private static void copyIPManagementRelationshipsToOutcome(
        List<Opportunity_Outcome__c> newItems,
        Map<Id, List<IP_Management_Relationship__c>> oppIPMgtRelationshipsMap
    ) {
        List<IP_Management_Relationship__c> ipMgtRelationshipsList = new List<IP_Management_Relationship__c>();
        
        for (Opportunity_Outcome__c oppOut : newItems) {
            if (oppIPMgtRelationshipsMap.containsKey(oppOut.Opportunity__c)) {
                ipMgtRelationshipsList.addAll(updateIPManagementRelationshipRecords(oppIPMgtRelationshipsMap.get(oppOut.Opportunity__c), oppOut.Id));
            }
        }
        
        if (!ipMgtRelationshipsList.isEmpty()) {
            IPManagementRelationshipsDAO.newInstance()
                .insertRecords(ipMgtRelationshipsList, false, AccessLevel.USER_MODE);
            updateIPManagementsOwner(ipMgtRelationshipsList);
        }

        
    }
    
    public static List<IP_Management_Relationship__c> updateIPManagementRelationshipRecords(List<IP_Management_Relationship__c> ipMgtRelList, Id oppOutId){
        List<IP_Management_Relationship__c> newIpMgtRelList = new List<IP_Management_Relationship__c>();
        for(IP_Management_Relationship__c ipMgtRel : ipMgtRelList){
            ipMgtRel.Opportunity__c = null;
            ipMgtRel.Opportunity_Outcome__c = oppOutId;
            ipMgtRel.RecordTypeId = IPManagementRelationshipsDAO.IP_OPPORTUNITY_OUTCOME_RELATIONSHIP_RECTYPE_ID;
            ipMgtRel.Is_Active__c = true;
            newIpMgtRelList.add(ipMgtRel);
        }
        return newIpMgtRelList;
    }    
    
    
    /**
    * Update the Owner of related IP_Management__c records to the ESB Integration User.
    *
    * @param oppIPMgtRelationshipsMap   A map of Opportunity ID to corresponding IP_Management_Relationship__c records.
    * @param esbIntegrationUser         The ESB Integration User.
    */
    private static void updateIPManagementsOwner(
        List<IP_Management_Relationship__c> ipMgtRelationshipsList
    ) {
        Set<Id> ipManagementIds = new Set<Id>();
        for(IP_Management_Relationship__c ipMgtRel : ipMgtRelationshipsList){
            ipManagementIds.add(ipMgtRel.IP_Management__c);
        }

        List<IP_Management__c> ipManagementList = IPManagementsDAO.newInstance().getIPManagementRecordsBySetIds(ipManagementIds);
        
        for(IP_Management__c ipMgt : ipManagementList){
            ipMgt.OwnerId = esbIntegrationUserId;
        }
        
        if (!ipManagementList.isEmpty()) {
            IPManagementsDAO.newInstance()
                .updateRecords(ipManagementList, false, AccessLevel.USER_MODE);
        }
    }
 
    
}