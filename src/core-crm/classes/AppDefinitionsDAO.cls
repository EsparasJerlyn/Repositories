/**
 * @description DAO Class for AppDefinitionsDAO Object. Contains soql and constants related to the AppDefinition
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | June 13, 2023         | DEPP-5391              | Created file
 */
public inherited sharing class AppDefinitionsDAO extends DmlBase implements IAppDefinitionsDAO {
    public Schema.SObjectType getSObjectType() {
        return AppDefinition.SObjectType;
    }

    public static IAppDefinitionsDAO newInstance() {
        return (IAppDefinitionsDAO) ImplementationSelector.DAO.newInstance(
            AppDefinition.SObjectType
        );
    }

    public List<AppDefinition> getAppDefinitionRecordsByDurableIdSet(Set<String> durableIdSet) {
        return [
            SELECT DurableId, NavType
            FROM AppDefinition
            WHERE DurableId IN :durableIdSet
            WITH USER_MODE
        ];
    }
}
