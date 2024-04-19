/**
 * @description Controller Class for LWC DesignationFinalcials
 * @see ../lwc/designationFinalcials
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                    |
      |--------------------------------|-----------------------|------------------------|---------------------------------------------------|
      | neil.s.h.lesidan               | April 11, 2024        | DEPP-8392              | Created file                                      |
 */
public with sharing class DesignationFinancialsCtrl {

    /**
     * @description Fetches the Distribution Management Object that are connected to Designation
     * @param designationId Record Id of Designation Object
     * @return Records of List<Distribution_Management__c>
    */
    @AuraEnabled
    public static List<Distribution_Management__c> getDistributionManagementList(Id designationId) {
        List<Distribution_Management__c> distributionManagementList = DistributionManagementsDAO.newInstance().getDistributionManagementByDesignationId(new Set<Id>{designationId}, AccessLevel.USER_MODE);
        return distributionManagementList;
    }

    /**
     * @description Fetches the Distribution Split Object that are connected to Distribution Management
     * @param distributionManagement Record List of Distribution Management Object
     * @return Records of List<Distribution_Split__c>
    */
    @AuraEnabled
    public static List<Distribution_Split__c> getDistributionSplitList(List<Distribution_Management__c> distributionManagement) {
        Set<Id> ids = new Set<Id>(new Map<Id, Distribution_Management__c>(distributionManagement).keySet());
        List<Distribution_Split__c> distributionManagementList = DistributionSplitsDAO.newInstance().getDistributionSplitByDistributionManagement(ids, AccessLevel.USER_MODE);
        return distributionManagementList;
    }
}