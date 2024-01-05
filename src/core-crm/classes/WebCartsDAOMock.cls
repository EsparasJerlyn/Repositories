/**
 * @description Mock DAO Class for WebCart Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | Sep 19, 2023          | DEPP-6714              | Created file
 *    | alexander.cadalin              | Jan 05 ,2024          | n/a                    | Added methods
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

    public WebCart getActiveWebCartByOwnerId(Id ownerId) {
        for(WebCart wc : webCartsMap.values()) {
            if(wc.Status == true && wc.OwnerId == ownerId) {
                return wc;
            }
        }
        return null;
    }
}
