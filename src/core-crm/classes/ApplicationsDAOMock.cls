/**
 * @description Mock DAO Class for Application Object
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                      |
 *    |--------------------------------|-----------------------|------------------------|---------------------------------------------------------------------|
 *    | mark.j.mahilum                 | June 19, 2023         | DEPP-5846              | Created File                                                        |
 *    | mark.j.mahilum                 | July 03, 2023         | DEPP-5961              | Added method getApplicationsByLeadIds                               |
 *    | mark.j.mahilum                 | July 14, 2023         | DEPP-5799              | Added method getApplicationsByContactIds                            |
 *    | mark.j.mahilum                 | Aug 31, 2023          | DEPP-6455              | Added method getApplicationsActiveApplicants                        |
 *    | mark.j.mahilum                 | Oct 11, 2023          | DEPP-6852              | Added method getApplicationsByLeadOrContaIds                        |
 *    | sebastianne.k.trias            | March 28, 2024        | DEPP-8382              | Added method queryApplicationsByPastIntakeDateAndActiveApplicants   |
 */
@isTest
public inherited sharing class ApplicationsDAOMock extends DmlBaseMock implements IApplicationsDAO {
    
    public Map<Id, hed__Application__c> applicationMap;

    public ApplicationsDAOMock() {
        super(new Map<Id, hed__Application__c>(), Schema.hed__Application__c.SObjectType);
        this.applicationMap = (Map<Id, hed__Application__c>) super.records;
    }

    public Schema.SObjectType getSObjectType() {
        return hed__Application__c.SObjectType;
    }

    public List<hed__Application__c> getApplicationsBySetIds(
        Set<Id> applicationIds,
        AccessLevel accessLevel
    ) {
        List<hed__Application__c> applicationList = new List<hed__Application__c>();

        for (hed__Application__c record : applicationMap.values()) {
            if (applicationIds.contains(record.Id)) {
                applicationList.add(record);
            }
        }

        return applicationList;
    }

    public List<hed__Application__c> getApplicationsByLeadIds(
        Set<Id> leadIds,
        String accessLevel
    ) {
        List<hed__Application__c> applicationList = new List<hed__Application__c>();

        for (hed__Application__c record : applicationMap.values()) {
            if (leadIds.contains(record.Lead__c)) {
                applicationList.add(record);
            }
        }

        return applicationList;
    }

    public List<hed__Application__c> getApplicationsByContactIds(
        Set<Id> contactIds,
        String accessLevel
    ) {
        List<hed__Application__c> applicationList = new List<hed__Application__c>();

        for (hed__Application__c record : applicationMap.values()) {
            if (contactIds.contains(record.hed__Applicant__c)) {
                applicationList.add(record);
            }
        }

        return applicationList;
    }

    public List<hed__Application__c> getQtacApplicationsWithQtacApplicantId(
        List<String> qtacApplicantId,
        String accessLevel
    ) {
        List<hed__Application__c> applicationList = new List<hed__Application__c>();

        for (hed__Application__c record : applicationMap.values()) {
            if (qtacApplicantId.contains(record.hed__Applicant__c)) {
                applicationList.add(record);
            }
        }

        return applicationList;
    }

    public List<hed__Application__c> getApplicationsActiveApplicants(
        Set<Id> contactIds,
        String accessLevel
    ) {
        List<hed__Application__c> applicationList = new List<hed__Application__c>();

        for (hed__Application__c record : applicationMap.values()) {
            if (contactIds.contains(record.hed__Applicant__c)) {
                applicationList.add(record);
            }
        }

        return applicationList;
    }

    public List<hed__Application__c> getApplicationsByLeadOrContactIds(
        Set<String> recordIds,
        Set<String> cadenceNames,
        String accessLevel
    ) {
        List<hed__Application__c> applicationList = new List<hed__Application__c>();

        for (hed__Application__c record : applicationMap.values()) {
            if (recordIds.contains(record.hed__Applicant__c) || recordIds.contains(record.Lead__c)) {
                applicationList.add(record);
            }
        }

        return applicationList;
    }

    public List<hed__Application__c> getAppsWithLatestCalculatedIntakeDateByApplicantIds(
        Set<Id> recordIds,
        String accessLevel
    ) {
        List<hed__Application__c> applicationList = new List<hed__Application__c>();

        for (hed__Application__c record : applicationMap.values()) {
            if (recordIds.contains(record.hed__Applicant__c) && record.Calculated_Intake_Date__c != null) {
                applicationList.add(record);
            }
        }

        return applicationList;
    }

    public Database.QueryLocator queryApplicationsByPastIntakeDateAndActiveApplicants(
        String accessLevel
    ) {
        return null;
    }

}