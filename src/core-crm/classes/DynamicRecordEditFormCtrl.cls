/**
 * @description Controller Class for dynamicRecordEditForm
 * @see ../lwc/dynamicRecordEditForm
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                               |
 *    |--------------------------------|-----------------------|------------------------|--------------------------------------------------------------|
 *    | kim.howard.capanas             | March 18, 2024        | DEP1-8203              | Created file                                                 |
 *    | kim.howard.capanas             | April 18, 2024        | DEPP-8499              | Modified getRecordIds to fetch recordId from Donation Asset  |
 *    |                                |                       |                        |                                                              |
 */
public with sharing class DynamicRecordEditFormCtrl {

    /**
     * @description Logic for getting dynamic recordID
     * @param recordId - Parent recordId
     * @param objectApiName - objectApiName you want to get
     * @return recordId
     */
    @AuraEnabled(cacheable=true)
    public static String getRecordIds(String recordId, String objectApiName) {
        String recId = recordId;
        
        // For future development use the same logic to get values from other Object
        // @TODO - make this method dynamic
        if (objectApiName == 'Product2') {
            List<Product2> product2RecList = ProductsDAO.newInstance().getProductByDesignationId(new Set<Id>{Id.valueOf(recordId)}, AccessLevel.USER_MODE);

            recId = product2RecList.get(0).Id;
        }

        if (objectApiName == 'Donation_Asset__c') {
            List<Donation__c> donationAssetList = DonationsDAO.newInstance().getDonationAssetsByDonationId(new Set<Id>{Id.valueOf(recordId)}, AccessLevel.USER_MODE);

            recId = donationAssetList.get(0).Donation_Asset__c;
        }

        return recId;
    }

    /**
     * @description Method to Identify UI Behavior if Edit or Read-Only
     * @param paramsMap - contains filter criteria
     * @return uiBehavior
     */
    @AuraEnabled(cacheable=false)
    public static Boolean getUiBehavior(Map<String, String> paramsMap) {
        Boolean uiBehaviorEdit = true;

        List<SObject> parentResult = new List<SObject>();
        List<SObject> userResult = new List<SObject>();
        boolean checkParentVisibility = false;
        boolean checkUserVisibility = false;
        Map<String, String> parametersMap = new Map<String, String>();

        if (!String.isBlank(paramsMap.get('visibilityByParent'))) {
            parametersMap.put('sObjectApiName', paramsMap.get('parentRecord'));
            parametersMap.put('recordId', paramsMap.get('recordId'));
            parametersMap.put('filter', paramsMap.get('visibilityByParent'));
            parentResult = DynamicQueryService.getRecordWithFilter(parametersMap,AccessLevel.SYSTEM_MODE);
            checkParentVisibility = true;
        }

        if (!String.isBlank(paramsMap.get('visibilityByUser'))) {
            parametersMap.put('sObjectApiName', 'User');
            parametersMap.put('recordId', String.escapeSingleQuotes(UserInfo.getUserId()));
            parametersMap.put('filter', paramsMap.get('visibilityByUser'));
            userResult = DynamicQueryService.getRecordWithFilter(parametersMap,AccessLevel.SYSTEM_MODE);
            checkUserVisibility = true;
        }

        if(checkParentVisibility == true && !parentResult.isEmpty()){
            uiBehaviorEdit = false;
        }

        if(checkUserVisibility == true && !userResult.isEmpty()){
            uiBehaviorEdit = false;
        }

        return uiBehaviorEdit;
    }

    /**
     * @description Method to Section Behavior
     * @param paramsMap - contains filter criteria
     * @return uiBehavior
     */
    @AuraEnabled(cacheable=false)
    public static Boolean getContentBlockFilter(Map<String, String> paramsMap) {
        
        boolean showSection = true;
        List<SObject> childResult = new List<SObject>();
        boolean checkContentBlockVisibility = false;
        Map<String, String> parametersMap = new Map<String, String>();

        if (!String.isBlank(paramsMap.get('contentBlockFilter'))) {
            parametersMap.put('sObjectApiName', paramsMap.get('childRecord'));
            parametersMap.put('recordId', paramsMap.get('recordId'));
            parametersMap.put('filter', paramsMap.get('contentBlockFilter'));
            childResult = DynamicQueryService.getRecordWithFilter(parametersMap,AccessLevel.SYSTEM_MODE);
            checkContentBlockVisibility = true;
        }

        if(checkContentBlockVisibility == true && childResult.isEmpty()){
            showSection = false;
        }


        return showSection;
    }
}