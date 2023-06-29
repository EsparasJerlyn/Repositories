/**
 * @description Mock DAO Class for AppDefinition Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file
 */
@isTest
public inherited sharing class AppDefinitionsDAOMock extends DmlBaseMock implements IAppDefinitionsDAO {
    public Map<Id, AppDefinition> appDefinitionsMap;

    public Schema.SObjectType getSObjectType() {
        return AppDefinition.SObjectType;
    }

    public AppDefinitionsDAOMock() {
        super(new Map<Id, AppDefinition>(), Schema.AppDefinition.SObjectType);
        this.appDefinitionsMap = (Map<Id, AppDefinition>) super.records;
    }

    public List<AppDefinition> getAppDefinitionRecordsByDurableIdSet(Set<String> durableIdSet) {
        List<AppDefinition> appDefinitionList = new List<AppDefinition>();
        for (AppDefinition appDef : appDefinitionsMap.values()) {
            if (durableIdSet.contains(appDef.DurableId)) {
                appDefinitionList.add(appDef);
            }
        }
        return appDefinitionList;
    }
}
