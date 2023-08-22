/**
 * @description helper for ApplicationPreferenceTriggerHandler
 * @see ApplicationPreferenceTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                   |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------------|
      | julie.jane.alegre              | August 11, 2023       | DEPP-6252              | Created file                                     |
 */
public with sharing class ApplicationPreferenceTriggerHelper {

    /**
     * @description process records to be set as current preference
     * @param newItems - List of Application_Preference__c new records
     * @param oldItems - Map<Id, Application_Preference__c> old records map
     */
    public static void setCurrentPreference(List<Application_Preference__c> newItems, Map<Id, Application_Preference__c> oldItems) {
        //Gets and sets Application Ids 
        Set<Id> applicationIDSet = new Set<Id>();
        for(Application_Preference__c appPref : newItems){
            if(validateApplicationPreferenceRecord(appPref, oldItems)){
                applicationIDSet.add(appPref.Application__c);
            }
        }
        Map<Id, List<Application_Preference__c>> appPrefMap = setApplicationPreferenceMap(applicationIDSet);
        List<Application_Preference__c> applicationPrefListToUpdate = new List<Application_Preference__c>();
        for(Id appId : appPrefMap.keySet()){
            applicationPrefListToUpdate.addAll(appPrefMap.get(appId));
        }

        ApplicationPreferencesDAO.newInstance().updateRecords(applicationPrefListToUpdate, false, AccessLevel.USER_MODE);
        
        updateLinkedApplicationRecord(applicationPrefListToUpdate);
    }
    
    /**
     * @description validates if application preference record is for processing
     * @param Application_Preference__c appPref
     * @param Map<Id, Application_Preference__c> oldItems
     * @return boolean
     */
    private static Boolean validateApplicationPreferenceRecord(Application_Preference__c appPref, Map<Id, Application_Preference__c> oldItems){
        Boolean isForQTAC = appPref.Preference_Number__c != null && appPref.RecordTypeId == ApplicationPreferencesDAO.APPLICATION_PREFERENCE_QTAC_RECTYPE_ID;
        Boolean isForStudyLink = appPref.RecordTypeId == ApplicationPreferencesDAO.APPLICATION_PREF_STUDYLINK_RECTYPE_ID;
        Boolean isForInsert = oldItems == null;
        Boolean isForUpdate = oldItems!= null;
        if(appPref.Application__c != null && (
            (validateIfForStudyLink(isForStudyLink, isForInsert, isForUpdate)) || 
            (isForQTAC && (isForInsert || (isForUpdate && 
                (
                    oldItems.get(appPref.Id).Starting_Month__c != appPref.Starting_Month__c ||
                    oldItems.get(appPref.Id).Preference_Number__c != appPref.Preference_Number__c
                ))
            ))
        )){
            return true;
        }
        return false;
    }
    
    /**
     * @description validates if application preference record is for study link processing
     * @param Application_Preference__c appPref
     * @return boolean
     */
    private static Boolean validateIfForStudyLink(Boolean isForStudyLink, Boolean isForInsert, Boolean isForUpdate){
        if(isForStudyLink && (isForInsert || isForUpdate)){
            return true;
        }
        return false;
    }

    /**
     * @description sets the map to be used in updating list of application preference records
     * @param Set<Id> applicationIDSet
     * @return Map<Id, List<Application_Preference__c>> appPrefMap - map that contains list of app pref to update
     */
    private static Map<Id, List<Application_Preference__c>> setApplicationPreferenceMap(Set<Id> applicationIDSet){
        Map<Id, List<Application_Preference__c>> appPrefMap = new Map<Id, List<Application_Preference__c>>();
        List<Application_Preference__c> qtacPrefList = ApplicationPreferencesDAO.newInstance().getApplicationPreferenceByAppSetIdsQTAC(applicationIDSet, 'USER_MODE');
        if(qtacPrefList != null){
            appPrefMap.putAll(getMappedApplicationPreference(qtacPrefList));
        }

        List<Application_Preference__c> studyLinkPrefList = ApplicationPreferencesDAO.newInstance().getApplicationPreferenceByAppSetIdsStudyLink(applicationIDSet, 'USER_MODE');
        if(studyLinkPrefList != null){
            appPrefMap.putAll(getMappedApplicationPreference(studyLinkPrefList));
        }
        return appPrefMap;
    }
        
    /**
     * @description updates calculated intake date field from linked application
     * @param newItems - List of Application_Preference__c new records
     */
    private static void updateLinkedApplicationRecord(List<Application_Preference__c> newItems){
        
        Set<Id> appPrefSetIds = new Set<Id>();
        Map<Id, Application_Preference__c> applicationPreferenceMap = new Map<Id, Application_Preference__c>();
        for(Application_Preference__c appPref : newItems){
            if(appPref.Is_Current_Preference__c){
                applicationPreferenceMap.put(appPref.Application__c, appPref);
                appPrefSetIds.add(appPref.Id);
            }
        }

        List<Package_Component__c> packageComponentList = PackageComponentDAO.newInstance().getPackageComponentsByAppPrefIdSet(appPrefSetIds, 'USER_MODE');
        Map<Id, Package_Component__c> packageCompMap = new Map<Id, Package_Component__c>();
        for(Package_Component__c packageComp : packageComponentList){
            if(packageComp.Application_Preference__c != null && packageComp.Package_Component_No__c == 1){
                packageCompMap.put(packageComp.Application_Preference__c, packageComp);
            }
        }

        List<hed__Application__c> applicationListToUpdate = new List<hed__Application__c>();
        List<hed__Application__c> applications = ApplicationsDAO.newInstance().getApplicationsBySetIds(applicationPreferenceMap.keySet(), 'USER_MODE');
        for(hed__Application__c app : applications){
            Date calculatedDate = getCalculatedDate(app, applicationPreferenceMap, packageCompMap);
            app.Calculated_Intake_Date__c = calculatedDate;
            applicationListToUpdate.add(app);
        }

        ApplicationsDAO.newInstance().updateRecords(applicationListToUpdate, false, AccessLevel.USER_MODE);
    }

    /**
     * @description set the  
     * @param appRefList - List of Application_Preference__c 
     */
    private static Map<Id, List<Application_Preference__c>> getMappedApplicationPreference(List<Application_Preference__c> appRefList){
        
        Map<Id, List<Application_Preference__c>> appPrefMap = new Map<Id, List<Application_Preference__c>>();
        for(Application_Preference__c appPref: appRefList ){        
            if(!appPrefMap.containsKey(appPref.Application__c)){
                appPref.Is_Current_Preference__c = true;
                appPrefMap.put(appPref.Application__c, new List<Application_Preference__c>());
                appPrefMap.get(appPref.Application__c).add(appPref); 
            } else if(appPref.Is_Current_Preference__c == true && appPrefMap.containsKey(appPref.Application__c)){
                appPref.Is_Current_Preference__c = false;
                appPrefMap.get(appPref.Application__c).add(appPref); 
            }
        }
        return appPrefMap;
    }

    /**
     * @description retrieves calculated date based on application record type
     * @param app - hed__Application__c
     * @param applicationPreferenceMap - Map<Id, Application_Preference__c> 
     */
    private static Date getCalculatedDate(
        hed__Application__c app, 
        Map<Id, Application_Preference__c> applicationPreferenceMap,
        Map<Id, Package_Component__c> packageCompMap
    ){
        Date calculatedDate = null;
        Boolean isForQTAC = app.Intake_Year__c!=null && applicationPreferenceMap.get(app.Id).Starting_Month__c != null && app.RecordTypeId == ApplicationsDAO.QTAC_RECTYPE_ID;
        Boolean isForStudyLink = app.Intake_Year__c!=null && app.RecordTypeId == ApplicationsDAO.STUDYLINK_RECTYPE_ID;
        if(isForQTAC){
            String intakeYear = app.Intake_Year__c;
            Integer startingMonth = Integer.valueOf(applicationPreferenceMap.get(app.Id).Starting_Month__c);
            Integer lastDay = Date.daysInMonth(Integer.valueOf(intakeYear), startingMonth);
            String calculatedDateStr = lastDay + '/' + startingMonth + '/' + intakeYear;
            calculatedDate = Date.parse(calculatedDateStr);          
        }

        if(isForStudyLink && packageCompMap.containsKey(applicationPreferenceMap.get(app.Id).Id)){
            calculatedDate = packageCompMap.get(applicationPreferenceMap.get(app.Id).Id).Start_Date__c;
        }

        return calculatedDate;
    }

}
