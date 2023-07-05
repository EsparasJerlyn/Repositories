/**
 * @description DAO Class for hed__Application__c Object. Contains soql and constants related to the Application object.
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
 *    |--------------------------------|-----------------------|------------------------|--------------------------------------------|
 *    | mark.j.mahilum                 | June 19, 2023         | DEPP-5846              | created file                               |
 */
public inherited sharing class ApplicationsDAO extends DmlBase implements IApplicationsDAO {
    public static final Id QTAC_RECTYPE_ID = Schema.SObjectType.hed__Application__c.getRecordTypeInfosByDeveloperName()
        .get('QTAC')
        .getRecordTypeId();
    public static final Id SAMS_RECTYPE_ID = Schema.SObjectType.hed__Application__c.getRecordTypeInfosByDeveloperName()
        .get('SAMS')
        .getRecordTypeId();
    public static final Id STUDYLINK_RECTYPE_ID = Schema.SObjectType.hed__Application__c.getRecordTypeInfosByDeveloperName()
        .get('StudyLink')
        .getRecordTypeId();    

    public static IApplicationsDAO newInstance() {
        return (IApplicationsDAO) ImplementationSelector.DAO.newInstance(hed__Application__c.SObjectType);
    }

    public Schema.SObjectType getSObjectType() {
        return hed__Application__c.SObjectType;
    }

    public List<hed__Application__c> getApplicationsBySetIds(Set<Id> applicationIds) {
        return [//NOPMD
            SELECT Id, Name
            FROM hed__Application__c
            WHERE Id IN :applicationIds
            WITH USER_MODE
        ];
    }
}