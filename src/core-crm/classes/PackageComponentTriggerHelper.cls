/**
 * @description helper class for PackageComponentTriggerHelper
 * @see PackageComponentTriggerHelper
 *
 * @author Accenture-
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                   |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------------|
      | arsenio.jr.dayrit              | August 15, 2023       | DEPP-6370              | Created file                                     |
      | sebastianne.k.trias            | May 9, 2024           | DEPP-8382              | Changed logic in setting value of application    |
      |                                |                       |                        | calculated intake date field                     |
 */
public with sharing class PackageComponentTriggerHelper {
    private static Map<Id, Date> appMinStartDateMap = new Map<Id, Date>();
    /**
     * @description update the Application record from Package Component
     *
     * @param newItems  List of new Package Component records
     */
     public static void updateStudyLinkApplicationCalculatedDateOnPackageComponent(List<Package_Component__c> newItems,Map<Id,Package_Component__c> oldMap) {
        try{
            appMinStartDateMap.clear();
            Set<Id> newPackageComponentId = new Set<Id>();
            Set<Id> applicationPreferenceIds = PackageComponentService.getAllApplicationPreferenceIdInPackageComponent(newItems);
            Map<Id,hed__Application__c> updateApplicationMap = new Map<Id,hed__Application__c>();
            Map<Id,Application_Preference__c> appPrefRecords = checkStudyLinkApplicationPreference(applicationPreferenceIds);

            Set<Id> appPrefRecordsId = new Set<Id>();
            for(Id appPref : appPrefRecords.keySet()){
                appPrefRecordsId.add(appPref);
            }

            for(Package_Component__c newPackageComp : newItems){
                if( appPrefRecords.containsKey(newPackageComp.Application_Preference__c) && (oldMap == null || newPackageComp.Start_Date__c != oldMap.get(newPackageComp.Id).Start_Date__c)){
                    compareStartDate(appPrefRecords.get(newPackageComp.Application_Preference__c).Application__c, newPackageComp.Start_Date__c);
                    if( oldMap != null ){
                        newPackageComponentId.add(newPackageComp.Id);
                    }
                }
            }
            List<Package_Component__c> existingPackageComponentsList = PackageComponentDAO.newInstance().getPackageComponentsByAppPrefIdSet(appPrefRecordsId, AccessLevel.USER_MODE);

            for(Package_Component__c existingPackageComp : existingPackageComponentsList){
                if( existingPackageComp.Start_Date__c != null && !newPackageComponentId.contains(existingPackageComp.Id) ){
                    compareStartDate(appPrefRecords.get(existingPackageComp.Application_Preference__c).Application__c, existingPackageComp.Start_Date__c);
                }
            }
            for(Id appId : appMinStartDateMap.keySet()){
                updateApplicationMap.put(appId, 
                    new hed__Application__c(
                        id = appId,
                        Calculated_Intake_Date__c = appMinStartDateMap.get(appId)
                    )
                );
            }
            if(!updateApplicationMap.values().isEmpty()){
                ApplicationsDAO.newInstance().updateRecords(updateApplicationMap.values(), false, AccessLevel.SYSTEM_MODE);
            }
        } catch (Exception e) {
            Logger.error('Exception caught in method updateStudyLinkApplicationCalculatedDateOnPackageComponent in class PackageComponentTriggerHelper.')
              .setExceptionDetails(e);
          } finally {
            if(Logger.getBufferSize() > 0) {
              Logger.saveLog();
            }
          }
     }

      /**
     * @description: get existing application preference Id from Package Component
     *
     * @param Set<Id>  Application Preference Id to evaluate
     */
    public static Map<Id,Application_Preference__c> checkStudyLinkApplicationPreference(Set<Id> applicationPreferenceIds) {
        Map<Id,Application_Preference__c> appPreferenceMap = new Map<Id,Application_Preference__c>();

        List<Application_Preference__c> studyLinkAppPreference = ApplicationPreferencesDAO.newInstance().getCurrentApplicationPreferenceById(applicationPreferenceIds,'SYSTEM_MODE');
        for(Application_Preference__c appPreference : studyLinkAppPreference){
            if(appPreference.Is_Current_Preference__c == true && appPreference.Application__r.RecordTypeId == ApplicationsDAO.STUDYLINK_RECTYPE_ID && appPreference.Application__c != null){
                appPreferenceMap.put(appPreference.Id,appPreference);
            }
        }

        return appPreferenceMap;
    }

    /**
     * @description: returns date of the package components that has the most earliest start date
     * 
     * @param appId application id 
     * @param packageComponentStartDate start date value of package component
     */
    private static void compareStartDate(Id appId, Date packageComponentStartDate){
        if(!appMinStartDateMap.containsKey(appId)){
            appMinStartDateMap.put(appId, packageComponentStartDate);
        }
        else if(appMinStartDateMap.get(appId) > packageComponentStartDate){
            appMinStartDateMap.put(appId, packageComponentStartDate);
        }
    }
}