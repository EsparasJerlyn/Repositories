/**
 * @description Mock DAO Class for WebCart Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | Sep 19, 2023          | DEPP-6714              | Created file
 */
@isTest
public inherited sharing class WebCartsDAOMock extends DmlBaseMock implements IWebCartsDAO {
    public Map<Id, WebCart> webCartsMap;

    public Schema.SObjectType getSObjectType() {
        return WebCart.SObjectType;
    }

    public WebCartsDAOMock() {
        super(new Map<Id, WebCart>(), Schema.WebCart.SObjectType);
        this.webCartsMap = (Map<Id, WebCart>) super.records;
    }
}
