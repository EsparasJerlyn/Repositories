/**
 * @description Mock DAO Class for Application Object
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------|
      | mark.j.mahilum                 | June 19, 2023         | DEPP-5846              | Created File                               |
      | mark.j.mahilum                 | July 03, 2023         | DEPP-5961              | Added method getApplicationsByLeadIds      |
      | mark.j.mahilum                 | July 14, 2023         | DEPP-5799              | Added method getApplicationsByContactIds   |
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
        String accessLevel
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

}