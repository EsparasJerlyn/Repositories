/**
 * @description Distribution Management object service class
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan	           | April 10, 2024        | DEPP-8401              | Created file                 |
 */


public with sharing class DistributionManagementService {

     /**
     * @description checks the related Distribution Management based on the parent Designation Record
     * This method is utilized on the DesignationStageUpdateBatch
     *
     * @param designationList list of Designation to be updated
     * @return designationToBeUpdated - Updated Designation
     */
    public static List<Designation__c> getRelatedDistributionManagementOfDesignation(List<Designation__c> designationList) {
        List<Designation__c> designationToBeUpdated = new List<Designation__c>();

        try{
            Map<Id, List<Distribution_Management__c>> designationToDistributionMap = buildDistributionManagementMap(designationList);
        
            for (Designation__c designation : designationList) {
                if (designation.RecordTypeId == DesignationsDAO.ENDOWNMENT_RECTYPE_ID) {
                    if (hasActiveDistributionManagement(designationToDistributionMap.get(designation.Id))) {
                        designationToBeUpdated.add(designation);
                    }
                } else if(designation.RecordtypeId == DesignationsDAO.GIVING_TO_CAUSE_RECTYPE_ID) {
                    designationToBeUpdated.add(designation);
                }
            }
        } catch (Exception e) {
            Logger.error(
                    'Exception caught in method execute in Apex class Distribution Management Service.'
                )
                .setExceptionDetails(e);
        } finally {
            if (Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }

        return designationToBeUpdated;

    }

    /**
     * @description private method to build the map that contains the designation Id and list of Distribution Management
     *
     * @param designationList list of Designation 
     * @return designationToDistributionMap - map containing designation Id and list of Distribution Management
     */
    private static Map<Id, List<Distribution_Management__c>> buildDistributionManagementMap(List<Designation__c> designationList) {
        Map<Id, List<Distribution_Management__c>> designationToDistributionMap = new Map<Id, List<Distribution_Management__c>>();
        List<Distribution_Management__c> distributionManagementList = DistributionManagementsDAO.newInstance().getDistributionManagementByDesignationId(
             new Map<Id,SObject>(designationList).keySet(), 
             AccessLevel.USER_MODE
        );
    
        for (Distribution_Management__c dm : distributionManagementList) {
            Id designationId = dm.Designation__c;
            if (!designationToDistributionMap.containsKey(designationId)) {
                designationToDistributionMap.put(designationId, new List<Distribution_Management__c>());
            }
            designationToDistributionMap.get(designationId).add(dm);
        }
        
        return designationToDistributionMap;
    }

    /**
     * @description private method Check the Distribution Management per Designation
     *
     * @param designationList list of Distribution Management 
     * @return Boolean value 
     */
    private static Boolean hasActiveDistributionManagement(List<Distribution_Management__c> distributionManagementList) {
        Boolean hasDistributionManagement = false;
        if (distributionManagementList == null || distributionManagementList.isEmpty()) {
            hasDistributionManagement = false;
        }else{
            for (Distribution_Management__c dm : distributionManagementList) {
                if (dm.Status__c == 'Active') {
                    hasDistributionManagement  = true;
                    break; // if one of the designation record has active Distribution Management, Break the loop
                }
            }
        }
        
        return hasDistributionManagement;
    }
    
}