/**
 * @description Mock DAO Class for Pricebook Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | Sep 19, 2023          | DEPP-6714              | Created file
 */
@isTest
public inherited sharing class PricebooksDAOMock extends DmlBaseMock implements IPricebooksDAO {
    public Map<Id, Pricebook2> pricebooksMap;

    public Schema.SObjectType getSObjectType() {
        return Pricebook2.SObjectType;
    }

    public PricebooksDAOMock() {
        super(new Map<Id, Pricebook2>(), Schema.Pricebook2.SObjectType);
        this.pricebooksMap = (Map<Id, Pricebook2>) super.records;
    }
}
