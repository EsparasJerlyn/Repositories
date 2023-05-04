/**
 * @description Mock DAO Class for Action Object
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 24, 2023        | DEPP-5567              | Created File                 | 
 */
@isTest
public inherited sharing class ActionsDAOMock extends DmlBaseMock implements IActionsDAO {
    public Map<Id, Action__c> actionMap;

    public Schema.SObjectType getSObjectType() {
        return Action__c.SObjectType;
    }

    public ActionsDAOMock() {
        super(new Map<Id, Action__c>(), Schema.Action__c.SObjectType);
        this.actionMap = (Map<Id, Action__c>) super.records;
    }

    //create action mock data with related consultancy and product request
    public List<Action__c> getActionsByProductRequestAndRecordType(
        Set<Id> productRequestIds,
        Id recordTypeId
    ) {
        ConsultanciesDAOMock consultanciesDAO = new ConsultanciesDAOMock();
        List<Consultancy__c> consultancyList = new List<Consultancy__c>();
        Map<String, String> consultancyJSONMap = new Map<String, String>();

        consultancyList = TestDataFactory.createTestConsultancyRecords(
            1,
            productRequestIds.iterator().next()
        );
        //create consultancy mock data
        consultanciesDAO.insertRecords(consultancyList, false, AccessLevel.USER_MODE);

        //build json string for consultancy object
        for (Consultancy__c record : (List<Consultancy__c>) consultanciesDAO.getRecords()) {
            consultancyJSONMap.put(record.Id, JSON.serialize(record));
        }

        //create action mock data
        List<Action__c> actionList = new List<Action__c>();
        actionList = TestDataFactory.createTestActionRecords(
            5,
            consultancyJSONMap.keySet().iterator().next(),
            recordTypeId
        );
        insertRecords(actionList, false, AccessLevel.USER_MODE);

        //build action record with consultancy look up field
        actionList = new List<Action__c>();
        for (Action__c a : (List<Action__c>) getRecords()) {
            a = (Action__c) JSON.deserialize(
                '{"attributes":{"type":"Action__c"},"Id":"' +
                    a.Id +
                    '","Consultancy__c":"' +
                    a.Consultancy__c +
                    '"' +
                    ',"Activity_Name__c":"' +
                    a.Activity_Name__c +
                    '","Consultancy__r":' +
                    consultancyJSONMap.get(a.Consultancy__c) +
                    '}',
                Action__c.class
            );
            actionList.add(a);
        }

        return actionList;
    }
}
