/**
 * @description Mock DAO Class for Case Object
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                  |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------|
      | arsenio.jr.dayrit              | September 11, 2023    | DEPP-5652              | Created File                                    |
      | arsenio.jr.dayrit              | September 26, 2023    | DEPP-6720              | added new method getCasesBySuppliedPhone        |
      | neil.s.h.lesidan               | September 20, 2023    | DEPP-6478              | Added getCaseBySuppliedEmail                    |
      | roy.nino.s.regala              | Novmeber 03, 2023     | DEPP-7145              | Added Lead_Score_Reset__c as expected field     |
      | eccarius.munoz                 | May 16, 2024          | DEPP-8484              | added getOpenOutreachCasesByConfigAndContactIds |
 */
@isTest
public inherited sharing class CasesDAOMock extends DmlBaseMock implements ICasesDAO {

    public Map<Id, Case> caseMap;

    public CasesDAOMock() {
        super(new Map<Id, Case>(), Schema.Case.SObjectType);
        this.caseMap = (Map<Id, Case>) super.records;
    }

    public Schema.SObjectType getSObjectType() {
        return Case.SObjectType;
    }

    public List<Case> getCasesByContactIds(
        Set<Id> contactIds,
        AccessLevel accessLevel
    ) {
        List<Case> caseList = new List<Case>();

        for (Case record : caseMap.values()) {
            if (contactIds.contains(record.ContactId)) {
                caseList.add(record);
            }
        }

        return caseList;
    }

    public List<Case> getCasesByLeadIds(
        Set<Id> leadIds,
        AccessLevel accessLevel
    ) {
        List<Case> caseList = new List<Case>();

        for (Case record : caseMap.values()) {
            if (leadIds.contains(record.Lead__c)) {
                caseList.add(record);
            }
        }

        return caseList;
    }

    public List<Case> getCasesByContactOrLeadIds(
        Set<Id> contactOrLeadIds,
        AccessLevel accessLevel
    ) {
        List<Case> caseList = new List<Case>();
        String caseString = '';
        for (Case record : caseMap.values()) {
            if (
                contactOrLeadIds.contains(record.Lead__c) ||
                contactOrLeadIds.contains(record.ContactId)
            ) {
                Case tempCase = new Case();
                
                //deserialze json to add createddate
                caseString = '{"attributes":{"type":"Case","url":"/services/data/v56.0/sobjects/Case/'+record.Id+'"},' +
                '"Id":"'+record.Id+'","CreatedDate":"'+String.valueOf(System.today())+'"}';
                tempCase = (Case)JSON.deserialize(caseString,Case.class);

                tempCase.RecordTypeId = record.RecordTypeId;
                tempCase.Auto_Priority_Assignment__c = record.Auto_Priority_Assignment__c;
                tempCase.Priority = record.Priority;
                tempCase.Category__c = record.Category__c;
                tempCase.ContactId = record.ContactId;
                tempCase.Lead__c = record.Lead__c;
                tempCase.Lead_Score_Reset__c = record.Lead_Score_Reset__c;
                caseList.add(tempCase);
            }
        }

        return caseList;
    }

    public List<Case> getCasesBySuppliedPhone(
        Set<String> suppliedMobile,
        AccessLevel accessLevel
    ) {
        List<Case> caseList = new List<Case>();

        for (Case record : caseMap.values()) {
            if (
                suppliedMobile.contains(record.SuppliedPhone)  
            ) {
                caseList.add(record);
            }
        }

        return caseList;
    }

    public List<Case> getCaseBySuppliedEmail(
        String suppliedEmail,
        AccessLevel accessLevel
    ) {
        List<Case> caseList = new List<Case>();

        for (Case record : caseMap.values()) {
            if (
                suppliedEmail == record.SuppliedEmail
            ) {
                caseList.add(record);
            }
        }

        return caseList;
    }

    public List<Case> getCasesByIds(
        Set<Id> caseIds,
        AccessLevel accessLevel
    ) {
        List<Case> caseList = new List<Case>();
        String caseString = '';
        for (Case record : caseMap.values()) {
            if (
                caseIds.contains(record.Id)
            ) {
                Case tempCase = new Case();
                
                //deserialze json to add createddate
                caseString = '{"attributes":{"type":"Case","url":"/services/data/v56.0/sobjects/Case/'+record.Id+'"},' +
                '"Id":"'+record.Id+'","CreatedDate":"'+String.valueOf(System.today())+'"}';
                tempCase = (Case)JSON.deserialize(caseString,Case.class);

                tempCase.RecordTypeId = record.RecordTypeId;
                tempCase.Auto_Priority_Assignment__c = record.Auto_Priority_Assignment__c;
                tempCase.Priority = record.Priority;
                tempCase.Case_Type__c = record.Case_Type__c;

                caseList.add(tempCase);
            }
        }

        return caseList;
    }

    public List<Case> getCasesByIdsImported(
        Set<Id> caseIds,
        AccessLevel accessLevel
    ) {
        List<Case> caseList = new List<Case>();
        String caseString = '';
        for (Case record : caseMap.values()) {
            if (
                caseIds.contains(record.Id)
            ) {
                Case tempCase = new Case();

                tempCase.OwnerId = GroupsDAO.newInstance().getQueueByName(GroupsDAO.STUDENT_RETENTION_QUEUE);
                tempCase.RecordTypeId = CasesDAO.OUTREACH_RECTYPE_ID;

                caseList.add(tempCase);
            }
        }

        return caseList;
    }

    public Database.QueryLocator queryLocatorGetCasesByContactOrLeadIds(
        Set<Id> recordIds
    ){
        return null;
    }

    public List<Case> getOpenOutreachCasesByConfigAndContactIds(
        Set<Id> contactIds,
        Id configId,
        AccessLevel accessLevel
    ) {

        List<Case> caseList = new List<Case>();
        for (Case record : caseMap.values()) {
            if (
                contactIds.contains(record.ContactId) && 
                !record.IsClosed && 
                configId == record.Engagement_List_Configuration__c &&
                record.RecordTypeId == CasesDAO.OUTREACH_RECTYPE_ID
            ) {
                caseList.add(record);
            }
        }

        return caseList;
    }

    public List<Case> getCasesByQualtricsSurveyIds(
        Set<Id> qualtricsSurveyIds,
        AccessLevel accessLevel
    ) {
        List<Case> caseList = new List<Case>();
        for (Case record : caseMap.values()) {
            if (qualtricsSurveyIds.contains(record.Qualtrics_Survey__c)) {
                caseList.add(record);
            }
        }
        return caseList;
    }

    public List<Case> getCasesByEngagementListConfigurationIds(
        String configurationId,
        AccessLevel accessLevel
    ) {
        List<Case> caseList = new List<Case>();
        for (Case record : caseMap.values()) {
            if (record.Engagement_List_Configuration__c == configurationId) {
                caseList.add(record);
            }
        }

        return caseList;
    }
}