/**
 * @description Mock DAO Class for Lead Object.  
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                       |
      |--------------------------------|-----------------------|------------------------|------------------------------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file                                         |
      | mark.j.mahilum                 | June 26, 2023         | DEPP-5846              | Added new method                                     |
      | roy.nino.s.regala              | Aug 09, 2023          | DEPP-5677              | Added new method                                     |
      | mark.j.mahilum                 | Aug 23, 2023          | DEPP-6215              | Added new mock method getLeadsCalculatedCadenceByIds |
      | arsenio.jr.dayrit              | Sept 22,2023          | DEPP-6720              | added new mock method getLeadsByCaseMobile           |
      | neil.s.h.lesidan               | Sept 20, 2023         | DEPP-6478              | Added getLeadByEmailOrName                           |
      | alexander.cadalin              | November 9, 2023      | DEPP-7212              | Added excludeConverted to getLeadByEmailOrName
 */
@isTest
public inherited sharing class LeadsDAOMock extends DmlBaseMock implements ILeadsDAO { //NOPMD
    public Map<Id, Lead> leadsMap;

    public Schema.SObjectType getSObjectType() {
        return Lead.SObjectType;
    }

    public LeadsDAOMock() {
        super(new Map<Id, Lead>(), Schema.Lead.SObjectType);
        this.leadsMap = (Map<Id, Lead>) super.records;
    }

    public List<Lead> getExistingUnconvertedLeadsByEmail(
        Set<String> emailsToMatch,
        Set<Id> excludedLeadsRecordsSet,
        String accessLevel
    ) {
        List<Lead> leadList = new List<Lead>();

        for (Lead record : leadsMap.values()) {
            if (
                (!excludedLeadsRecordsSet.contains(record.Id) &&
                (emailsToMatch.contains(record.Email) ||
                emailsToMatch.contains(record.Work_Email__c)))
            ) {
                leadList.add(record);
            }
        }

        return leadList;
    }

    public List<Lead> getLeadsWithLimit(Integer recordsCount) {
        List<Lead> leadList = new List<Lead>();

        for (Lead record : leadsMap.values()) {
            leadList.add(record);

            if (leadList.size() == recordsCount) {
                break;
            }
        }

        return leadList;
    }

    public List<Lead> getExistingUnconvertedLeads(Set<String> emailsToMatch, String accessLevel) {
        List<Lead> leadList = new List<Lead>();

        for (Lead record : leadsMap.values()) {
            if (
                (emailsToMatch.contains(record.Email) ||
                emailsToMatch.contains(record.Work_Email__c))
            ) {
                leadList.add(record);
            }
        }

        return leadList;
    }

    public List<Lead> getLearnerLeadsByCalculatedCadences(Set<String> calculatedCadences) {
        List<Lead> leadList = new List<Lead>();

        for (Lead record : leadsMap.values()) {
            if (calculatedCadences.contains(record.Calculated_Cadence__c)) {
                leadList.add(record);
            }
        }

        return leadList;
    }
    
    public List<Lead> getLeadsCalculatedCadenceByIds(
        Set<String> recordIds,
        String accessLevel
    ) {
        List<Lead> leadList = new List<Lead>();
        
        for (Lead record : leadsMap.values()) {
            if (
                recordIds.contains(record.Id)
            ) {
                leadList.add(record);
            }
        }
        
        return leadList;
    }

    public List<Lead> getLeadsByCaseMobile(
        Set<String> caseMobile,
        AccessLevel accessLevel
    ) {
        List<Lead> leadList = new List<Lead>();
        
        for (Lead record : leadsMap.values()) {
            if (
                caseMobile.contains(record.MobilePhone)
            ) {
                leadList.add(record);
            }
        }
        
        return leadList;
    }

    public List<Lead> getLeadByEmailOrName(
        LeadsDAO.QueryParamWrapperEmailOrName queryParam,
        Boolean excludeConverted,
        AccessLevel accessLevel
    ) {

        String email = queryParam.email;
        List<Lead> leadList = new List<Lead>();

        for (Lead record : leadsMap.values()) {
            if (email != null && email != '' && email == record.Email) {
                if(excludeConverted && record.IsConverted == false) {
                    leadList.add(record);
                } else if(!excludeConverted) {
                    leadList.add(record);
                }
            }
        }

        return leadList;
    }

    public List<Lead> getLeadsByIdSet(
        Set<Id> recordIdSet,
        AccessLevel accessLevel
    ){

        List<Lead> leadList = new List<Lead>();

        for (Lead record : leadsMap.values()) {
            if (recordIdSet.contains(record.Id)) {
                leadList.add(record);
            }
        }

        return leadList;
    }

    public List<Lead> getLeadsByIdSetAndType(
        Set<Id> recordIdSet,
        String leadType,
        AccessLevel accessLevel
    ){

        List<Lead> leadList = new List<Lead>();

        for (Lead record : leadsMap.values()) {
            if (recordIdSet.contains(record.Id) && record.Lead_Type__c == leadType) {
                leadList.add(record);
            }
        }

        return leadList;
    }
    
    public List<Lead> getLeadMobilePhoneByRecordIds(
        Set<Id> recordIds,
        AccessLevel accessLevel
    ) {
        List<Lead> leadList = new List<Lead>();
        
        for (Lead record : leadsMap.values()) {
            if (
                recordIds.contains(record.Id)
            ) {
                leadList.add(record);
            }
        }
        
        return leadList;
    }

    public Database.QueryLocator queryLocatorGetLeadsByIds(
        Set<Id> recordIds,
        String leadType
    ){
        return null;
    }
    
    public List<Lead> getLearnerLeadsByEmailOrWorkEmail(
        Set<String> emails,
        AccessLevel accessLevel
    ) {
        List<Lead> leads = new List<Lead>();
        for(Lead ld : leadsMap.values()) {
            Boolean containsEmail = emails.contains(ld.Work_Email__c) || emails.contains(ld.Email);
            Boolean isLearner = ld.Lead_Type__c == 'Learner';
            if(containsEmail && isLearner) {
                leads.add(ld);
            }
        }
        return leads;
    }

    public List<Lead> getLearnerLeadsByEmailOrWorkEmail(
        Set<String> emails,
        Set<String> workEmails,
        AccessLevel accessLevel
    ) {
        List<Lead> leads = new List<Lead>();
        for(Lead ld : leadsMap.values()) {
            Boolean containsEmail = emails.contains(ld.Email) || workEmails.contains(ld.Email);
            Boolean containsWorkEmail = emails.contains(ld.Work_Email__c) || workEmails.contains(ld.Work_Email__c);
            Boolean isLearner = ld.Lead_Type__c == 'Learner';
            if((containsEmail || containsWorkEmail) && isLearner) {
                leads.add(ld);
            }
        }
        return leads;
    }

    public List<Lead> getUnconvertedLeadsByIdSet(
        Set<Id> recordIdSet,
        AccessLevel accessLevel
    ){
        List<Lead> leadList = new List<Lead>();
        for (Lead record : leadsMap.values()) {
            if (recordIdSet.contains(record.Id)) {
                leadList.add(record);
            }
        }
        return leadList;
    }
}