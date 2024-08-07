/**
 * @description Interface for Application DAO framework
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                |
 *    |--------------------------------|-----------------------|------------------------|---------------------------------------------------------------|
 *    | mark.j.mahilum                 | June 19, 2023         | DEPP-5846              | Created File                                                  |
 *    | mark.j.mahilum                 | July 03, 2023         | DEPP-5961              | Added list getApplicationsByLeadIds                           |
 *    | mark.j.mahilum                 | July 14, 2023         | DEPP-5799              | Added list getApplicationsByContactIds                        |
 *    | mark.j.mahilum                 | Aug 31, 2023          | DEPP-6455              | Added new list getApplicationsActiveApplicants                |
 *    | sebastianne.k.trias            | March 28, 2024        | DEPP-8382              | Added queryApplicationsByPastIntakeDateAndActiveApplicants    |
 *    | mark.j.mahilum                 | April 30, 2024        | DEPP-7987              | Added queryLocatorGetApplicationsByBatchProcess               |
 */
public interface IApplicationsDAO extends DmlInterface{ 
    List<hed__Application__c> getApplicationsBySetIds(
        Set<Id> applicationIds,
        AccessLevel accessLevel
    );
    List<hed__Application__c> getApplicationsByLeadIds(
        Set<Id> leadIds,
        String accessLevel
    );
    List<hed__Application__c> getApplicationsByContactIds(
        Set<Id> contactIds,
        String accessLevel
    );
    List<hed__Application__c> getQtacApplicationsWithQtacApplicantId(
        List<String> qtacApplicantId,
        String accessLevel
    );
    List<hed__Application__c> getApplicationsActiveApplicants(
        Set<Id> contactIds,
        String accessLevel
    );
    List<hed__Application__c> getApplicationsByLeadOrContactIds(
        Set<String> recordId,
        Set<String> cadenceNames,
        String accessLevel
    ); 

    List<hed__Application__c> getAppsWithLatestCalculatedIntakeDateByApplicantIds(
        Set<Id> recordIds,
        String accessLevel
    );

    List<hed__Application__c> getApplicationsByLeadIdOrContactId(
        Set<String> recordId,
        String accessLevel
    ); 
    Database.QueryLocator queryApplicationsByPastIntakeDateAndActiveApplicants(
        String accessLevel
    );

    Database.QueryLocator queryLocatorGetApplicationsByBatchProcess(
        Set<String> batchProcessSet, 
        AccessLevel accessLevel
    );
    
    List<hed__Application__c> getApplicationsByBatchProcess(
        Set<String> batchProcessSet,
        AccessLevel accessLevel
    );
}
