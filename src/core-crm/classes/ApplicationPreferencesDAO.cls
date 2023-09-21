/**
 * @description DAO Class for Application_Preference__c Object. Contains soql and constants related to the Application_Preference__c object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary                      |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------------|
 *    | eccarius.munoz                 | August 11, 2023       |DEPP-6252               | Created File                        |
 */
public inherited sharing class ApplicationPreferencesDAO extends DmlBase implements IApplicationPreferencesDAO{
	public static final Id QTAC_RECTYPE_ID = Schema.SObjectType.Application_Preference__c.getRecordTypeInfosByDeveloperName().get('QTAC').getRecordTypeId();
    public static final Id STUDYLINK_RECTYPE_ID = Schema.SObjectType.Application_Preference__c.getRecordTypeInfosByDeveloperName().get('StudyLink').getRecordTypeId();
    
    public Schema.SObjectType getSObjectType(){
		return Application_Preference__c.SObjectType;
	}

    public static IApplicationPreferencesDAO newInstance(){
		return (IApplicationPreferencesDAO) ImplementationSelector.DAO.newInstance(Application_Preference__c.SObjectType);
	}

	public List<Application_Preference__c> getApplicationPreferenceByAppSetIdsQTAC(
        Set<Id> applicationIDSet,
		String accessLevel 
    ) {
        return Database.query(
            'SELECT Id, Application__c, Is_Current_Preference__c, RecordTypeId, Preference_Number__c, Starting_Month__c, Is_Active__c ' +
             'FROM Application_Preference__c ' +
             'WHERE Application__c IN : applicationIDSet ' +
             'AND Is_Active__c = TRUE ' +
			 'AND Preference_Number__c != null ' +
			 'AND RecordTypeId =: QTAC_RECTYPE_ID WITH ' +
             String.escapeSingleQuotes(accessLevel) +
			 ' ORDER BY Preference_Number__c ASC, LastModifiedDate DESC' 
              
        );
    }
	
    public List<Application_Preference__c> getApplicationPreferenceByAppSetIdsStudyLink(
        Set<Id> applicationIDSet,
		String accessLevel   
    ) {
        return Database.query(
            'SELECT Id, Application__c, Is_Current_Preference__c, RecordTypeId, Preference_Number__c, Starting_Month__c ' +
             'FROM Application_Preference__c ' +
             'WHERE Application__c IN : applicationIDSet ' +
			 'AND RecordTypeId =: STUDYLINK_RECTYPE_ID WITH ' +
             String.escapeSingleQuotes(accessLevel) +
			 ' ORDER BY LastModifiedDate DESC' 
        );
    }

    public static List<Application_Preference__c> getCurrentApplicationPreferenceById(
        Set<Id> applicationPreferenceIds,
		String accessLevel
    ) {
        return Database.query(
            'SELECT Id, Name, Application__c, Application__r.RecordTypeId, Is_Current_Preference__c,RecordTypeId, Preference_Number__c ' +
             'FROM Application_Preference__c ' +
             'WHERE Id IN : applicationPreferenceIds ' +
			 'AND RecordTypeId =: STUDYLINK_RECTYPE_ID WITH ' +
             String.escapeSingleQuotes(accessLevel)
        );
    }
	
}