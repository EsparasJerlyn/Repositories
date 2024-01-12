/**
 * @description Mock DAO Class for WebStore Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | roy.nino.s.regala              | Sep 19, 2023          | DEPP-6714              | Created file                 |
 */
@isTest
public inherited sharing class WebStoresDAOMock extends DmlBaseMock implements IWebStoresDAO {
    public Map<Id, WebStore> webStoresMap;

    public Schema.SObjectType getSObjectType() {
        return WebStore.SObjectType;
    }

    public WebStoresDAOMock() {
        super(new Map<Id, WebStore>(), Schema.WebStore.SObjectType);
        this.webStoresMap = (Map<Id, WebStore>) super.records;
    }

    public WebStore getCCEWebStoreId() {
        for(WebStore ws : webStoresMap.values()) {
            if(ws.Name == 'CCE') {
                return ws;
            }
        }
        return null;
    }
}
