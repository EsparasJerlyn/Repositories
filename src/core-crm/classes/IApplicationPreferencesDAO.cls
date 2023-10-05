/**
 * @description Interface for ApplicationPreferencesDAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary                      |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------------|
 *    | eccarius.munoz                 | August 11, 2023       |DEPP-6252               | Created File                        |
 */
public interface IApplicationPreferencesDAO extends DmlInterface{
    
    List<Application_Preference__c> getApplicationPreferenceByAppSetIdsQTAC(
        Set<Id> applicationIDSet,
        AccessLevel accessLevel
    );
    List<Application_Preference__c> getApplicationPreferenceByAppSetIdsStudyLink(
        Set<Id> applicationIDSet,
        AccessLevel accessLevel
    );

    List<Application_Preference__c> getCurrentApplicationPreferenceById(
        Set<Id> applicationPreferenceIds,
        String accessLevel
    );
} 