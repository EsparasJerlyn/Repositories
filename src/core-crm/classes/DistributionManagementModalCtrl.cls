/**
  * @description Controller class for Distribution Management LWC
 *
 * @see ../lwc/distributionManagementModal
 * 
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | kathleen.mae.caceres           | April 14, 2024        | DEPP-8409 & DEPP-8456  | Created File                 |
 */
public with sharing class DistributionManagementModalCtrl {

    /**
     * @description Inserts Distribution Management and Distribution Split records
     * @param distribManagment Distribution Management object with populated fields and designation Id
     * @param distributionSplitData Distribution Split list with populated fields from datatable
     * @return true when records are successfully created
    */
    @AuraEnabled
    public static Boolean insertDistributionManagement(Distribution_Management__c distribManagment, List<Distribution_Split__c> distributionSplitData){

        List<Distribution_Management__c> newManagementList =new List<Distribution_Management__c>();
        newManagementList.add(distribManagment);

        DistributionManagementsDAO.newInstance().insertRecords(newManagementList,false,AccessLevel.USER_MODE);

        for (Distribution_Split__c distributionSplit: distributionSplitData) {
            distributionSplit.Distribution_Management__c = distribManagment.Id;
        }

        Database.SaveResult[] dbSplitList = DistributionSplitsDAO.newInstance().insertRecords(distributionSplitData, false, AccessLevel.USER_MODE);
        for(Database.SaveResult db : dbSplitList) {
            return db.isSuccess();
        }
        return false;
    }

    /**
     * @description Upserts Distribution Management and Distribution Split records
     * @param distribManagment Distribution Management object with populated fields and designation Id
     * @param distribManagmentUpsert Distribution Split list with populated fields from datatable
     * @return true when records are successfully updated
    */
    @AuraEnabled
    public static Boolean updateDistributionManagement(Distribution_Management__c distribManagment, List<Distribution_Split__c> distribManagmentUpsert){

        List<Distribution_Management__c> editedManagementList =new List<Distribution_Management__c>();
        editedManagementList.add(distribManagment);

        DistributionManagementsDAO.newInstance().updateRecords(editedManagementList, false, AccessLevel.USER_MODE);

        if (distribManagmentUpsert.size() != 0 && !distribManagmentUpsert.isEmpty()) {
            Database.UpsertResult[] dbSplitList = DistributionSplitsDAO.newInstance().upsertRecords(distribManagmentUpsert, false, AccessLevel.USER_MODE);
            for(Database.UpsertResult db: dbSplitList) {
                return db.isSuccess();
            }
        }
        return false;
    }
}