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
      | eccarius.munoz                 | August 23, 2023       | DEPP-6370              | Added handling for updating qtac apps            |
      | sebastianne.k.trias            | May 9, 2024           | DEPP-8382              | Changed logic in setting value of application    |
      |                                |                       |                        | calculated intake date field                     |
 */
public with sharing class ApplicationPreferenceTriggerHelper { //NOPMD

    private static List<Application_Preference__c> qtacApplicationPreferences;
    private static Map<Id, Date> appCalculatedDateMap = new Map<Id, Date>();

    /**
     * @description process records to be set as current preference
     * @param newItems - List of Application_Preference__c new records
     * @param oldItems - Map<Id, Application_Preference__c> old records map
     */
    public static void setCurrentPreference(List<Application_Preference__c> newItems, Map<Id, Application_Preference__c> oldItems) {
        appCalculatedDateMap.clear();
        //Gets and sets Application Ids 
        Set<Id> applicationIDSet = new Set<Id>();
        for(Application_Preference__c appPref : newItems){
            if(validateApplicationPreferenceRecord(appPref, oldItems)){
                applicationIDSet.add(appPref.Application__c);
            }
        }
        if(!applicationIDSet.isEmpty()){
            Map<Id, List<Application_Preference__c>> appPrefMap = setApplicationPreferenceMap(applicationIDSet);
            List<Application_Preference__c> applicationPrefListToUpdate = new List<Application_Preference__c>();
            for(Id appId : appPrefMap.keySet()){
                applicationPrefListToUpdate.addAll(appPrefMap.get(appId));
            }
            ApplicationPreferencesDAO.newInstance().updateRecords(applicationPrefListToUpdate, false, AccessLevel.USER_MODE);
            
            updateLinkedApplicationRecord(applicationPrefListToUpdate);
        }
    }
    
    /**
     * @description validates if application preference record is for processing
     * @param Application_Preference__c appPref
     * @param Map<Id, Application_Preference__c> oldItems
     * @return boolean
     */
    private static Boolean validateApplicationPreferenceRecord(Application_Preference__c appPref, Map<Id, Application_Preference__c> oldItems){
        Boolean isForQTAC = appPref.Preference_Number__c != null && appPref.RecordTypeId == ApplicationPreferencesDAO.QTAC_RECTYPE_ID;
        Boolean isForStudyLink = appPref.RecordTypeId == ApplicationPreferencesDAO.STUDYLINK_RECTYPE_ID;
        Boolean isForInsert = oldItems == null;
        Boolean isForUpdate = oldItems!= null;
        if(appPref.Application__c != null && (
            (validateIfForStudyLink(isForStudyLink, isForInsert, isForUpdate)) || 
            (isForQTAC && (isForInsert || (isForUpdate && 
                (
                    oldItems.get(appPref.Id).Starting_Month__c != appPref.Starting_Month__c ||
                    oldItems.get(appPref.Id).Preference_Number__c != appPref.Preference_Number__c ||
                    oldItems.get(appPref.Id).Application__c != appPref.Application__c
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
        List<Application_Preference__c> qtacPrefList = ApplicationPreferencesDAO.newInstance().getApplicationPreferenceByAppSetIdsQTAC(applicationIDSet, AccessLevel.USER_MODE);
        qtacApplicationPreferences = new List<Application_Preference__c>();
        if(!qtacPrefList.isEmpty()){
            appPrefMap.putAll(getMappedApplicationPreference(qtacPrefList));
            qtacApplicationPreferences = qtacPrefList;
        }

        List<Application_Preference__c> studyLinkPrefList = ApplicationPreferencesDAO.newInstance().getApplicationPreferenceByAppSetIdsStudyLink(applicationIDSet, AccessLevel.USER_MODE);
        if(!studyLinkPrefList.isEmpty()){
            appPrefMap.putAll(getMappedApplicationPreference(studyLinkPrefList));
        }
        return appPrefMap;
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
     * @description updates calculated intake date field from linked application
     * @param newItems - List of Application_Preference__c new records
     */
    private static void updateLinkedApplicationRecord(List<Application_Preference__c> newItems){
        Map<Id, hed__Application__c> appMapToUpdate = new Map<Id, hed__Application__c>();
        Set<Id> appPrefSetIds = new Set<Id>();
        Map<Id, Application_Preference__c> applicationPreferenceMap = new Map<Id, Application_Preference__c>();
        for(Application_Preference__c appPref : newItems){
            if(appPref.Is_Current_Preference__c){
                applicationPreferenceMap.put(appPref.Application__c, appPref);
                appPrefSetIds.add(appPref.Id);
            }
        }

        List<Package_Component__c> packageComponentList = PackageComponentDAO.newInstance().getPackageComponentsByAppPrefIdSet(appPrefSetIds, AccessLevel.USER_MODE);
        Map<Id, Package_Component__c> packageCompMap = new Map<Id, Package_Component__c>();
        for(Package_Component__c packageComp : packageComponentList){
            if(packageComp.Application_Preference__c != null){
                if(!appCalculatedDateMap.containsKey(packageComp.Application_Preference__c)){
                    appCalculatedDateMap.put(packageComp.Application_Preference__c, packageComp.Start_Date__c);
                }else if(appCalculatedDateMap.get(packageComp.Application_Preference__c) > packageComp.Start_Date__c){
                    appCalculatedDateMap.put(packageComp.Application_Preference__c, packageComp.Start_Date__c);
                }
                packageCompMap.put(packageComp.Application_Preference__c, packageComp);
            }
        }

        hed__Application__c tempApp;
        List<hed__Application__c> applications = ApplicationsDAO.newInstance().getApplicationsBySetIds(applicationPreferenceMap.keySet(), AccessLevel.USER_MODE);
        for(hed__Application__c app : applications){
            Date calculatedDate = getCalculatedDateForStudyLink(app, applicationPreferenceMap, packageCompMap);
            tempApp = new hed__Application__c(
                Id = app.Id,
                Calculated_Intake_Date__c = calculatedDate,
                Current_Preference__c = applicationPreferenceMap.get(app.Id).Id
            );
            appMapToUpdate.put(tempApp.Id, tempApp);
        }

        Map<Id, hed__Application__c> qtacAppMap = setQtacApplicationMap(applicationPreferenceMap);
        appMapToUpdate.putAll(qtacAppMap);

        ApplicationsDAO.newInstance().updateRecords(appMapToUpdate.values(), false, AccessLevel.USER_MODE);
    }

    /**
     * @description sets the map to be used in updating list of qtac application records
     * @return Map<Id, hed__Application__c> response - map that contains list of qtac apps to update
     */
    private static Map<Id, hed__Application__c> setQtacApplicationMap(Map<Id, Application_Preference__c> applicationPreferenceMap){
        Map<Id, hed__Application__c> response = new Map<Id, hed__Application__c>();
        Map<Id, Application_Preference__c> qtacApplicationPreferenceMap = new Map<Id, Application_Preference__c>();
        Set<Id> qtacAppPrefSetIds = new Set<Id>();
        for(Application_Preference__c appPref : qtacApplicationPreferences){
            if(appPref.Starting_Month__c != null){
                if(!qtacApplicationPreferenceMap.containsKey(appPref.Application__c)){
                    qtacApplicationPreferenceMap.put(appPref.Application__c, appPref);
                }else if(appPref.Starting_Month__c > qtacApplicationPreferenceMap.get(appPref.Application__c).Starting_Month__c){
                    qtacApplicationPreferenceMap.put(appPref.Application__c, appPref);
                }
                qtacAppPrefSetIds.add(appPref.Application__c);
            }
        }
        List<hed__Application__c> qtacApplications = ApplicationsDAO.newInstance().getApplicationsBySetIds(qtacAppPrefSetIds, AccessLevel.USER_MODE);
        hed__Application__c tempApp;
        for(hed__Application__c app : qtacApplications){
            Date calculatedDate = null;
            if(
                app.RecordTypeId == ApplicationsDAO.QTAC_RECTYPE_ID && 
                qtacApplicationPreferenceMap.get(app.Id).Starting_Month__c != null &&
                app.Intake_Year__c != null
            ){
                String intakeYear = app.Intake_Year__c;
                Integer startingMonth = Integer.valueOf(qtacApplicationPreferenceMap.get(app.Id).Starting_Month__c);
                Integer lastDay = Date.daysInMonth(Integer.valueOf(intakeYear), startingMonth);
                String calculatedDateStr = lastDay + '/' + startingMonth + '/' + intakeYear;
                calculatedDate = Date.parse(calculatedDateStr);          
            }
            tempApp = new hed__Application__c(
                Id = app.Id,
                Calculated_Intake_Date__c = calculatedDate,
                Current_Preference__c = applicationPreferenceMap.get(app.Id).Id
            );
            response.put(tempApp.Id, tempApp);
        }
        
        return response;
    }

    /**
     * @description retrieves calculated date based on application record type
     * @param app - hed__Application__c
     * @param applicationPreferenceMap - Map<Id, Application_Preference__c> 
     */
    private static Date getCalculatedDateForStudyLink(
        hed__Application__c app, 
        Map<Id, Application_Preference__c> applicationPreferenceMap,
        Map<Id, Package_Component__c> packageCompMap
    ){
        Date calculatedDate = null;

        if( app.RecordTypeId == ApplicationsDAO.STUDYLINK_RECTYPE_ID && packageCompMap.containsKey(applicationPreferenceMap.get(app.Id).Id) ){
            calculatedDate = appCalculatedDateMap.get(applicationPreferenceMap.get(app.Id).Id);
            // calculatedDate = packageCompMap.get(applicationPreferenceMap.get(app.Id).Id).Start_Date__c;
        }

        return calculatedDate;
    }

}