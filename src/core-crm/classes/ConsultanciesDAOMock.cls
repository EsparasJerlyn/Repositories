/**
 * @description Mock DAO Class for Consultancy object
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file
 */
@isTest
public inherited sharing class ConsultanciesDAOMock extends DmlBaseMock implements IConsultanciesDAO {
    public Map<Id, Consultancy__c> consultancyMap;

    public ConsultanciesDAOMock() {
        super(new Map<Id, Consultancy__c>(), Schema.Consultancy__c.SObjectType);
        this.consultancyMap = (Map<Id, Consultancy__c>) super.records;
    }

    public Schema.SObjectType getSObjectType() {
        return Consultancy__c.SObjectType;
    }

    public List<Consultancy__c> getConsultanciesWithActionsBySetProductRequestIds(
        Set<Id> productRequestIds
    ) {
        List<Consultancy__c> consultancyList = new List<Consultancy__c>();

        consultancyList = TestDataFactory.createTestConsultancyRecords(
            2,
            productRequestIds.iterator().next()
        );
        //create consultancy mock data
        insertRecords(consultancyList, false, AccessLevel.USER_MODE);

        ActionsDAOMock actionsDAOClass = new ActionsDAOMock();
        List<Action__c> actionList = new List<Action__c>();
        Map<String, String> consultancyJSONMap = new Map<String, String>();

        //create actionlist data
        actionList = TestDataFactory.createTestActionRecords(
            1,
            ActionsDAO.ACTIVITY_RECORDTYPE_ID,
            consultancyList.iterator().next()?.Id
        );
        actionsDAOClass.insertRecords(actionList, false, AccessLevel.USER_MODE);

        //build json string map where consultancy id is key and string action record is value
        for (Action__c record : (List<Action__c>) actionsDAOClass.getRecords()) {
            if (!consultancyJSONMap.containsKey(record.Consultancy__c)) {
                consultancyJSONMap.put(record.Consultancy__c, '');
            }
            consultancyJSONMap.put(
                record.Consultancy__c,
                consultancyJSONMap.get(record.Consultancy__c) + JSON.serialize(record)
            );
        }
        //build mock consultancy records where some has related Actions__r records
        consultancyList = new List<Consultancy__c>();
        String consultancyString = '';

        for (Consultancy__c c : (List<Consultancy__c>) getRecords()) {
            consultancyString =
                '{"attributes":{"type":"Consultancy__c"},"Id":"' +
                c.Id +
                '","Name":"' +
                c.Name +
                '"' +
                ',"Definition_of_Problem__c":"' +
                c.Definition_of_Problem__c +
                '"' +
                ',"Product_Request__c":"' +
                c.Product_Request__c +
                '"';

            consultancyString += consultancyJSONMap.containsKey(c.Id)
                ? ',"Actions__r":{"totalSize":1,"done":true,"records":[' +
                  consultancyJSONMap.get(c.Id).removeEnd(',') +
                  ']}}'
                : '}';

            c = (Consultancy__c) JSON.deserialize(consultancyString, Consultancy__c.class);
            consultancyList.add(c);
        }

        return consultancyList;
    }

    public List<Consultancy__c> getConsultanciesBySetNames(Set<String> consultancyNames) {
        List<Consultancy__c> consultancyList = new List<Consultancy__c>();

        for (Consultancy__c record : consultancyMap.values()) {
            if (consultancyNames.contains(record.Name)) {
                consultancyList.add(record);
            }
        }

        return consultancyList;
    }
}
