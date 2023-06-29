/**
 * @description Interface for AppDefinition DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | June 13, 2023         | DEPP-5391              | Created file
 */
public interface IAppDefinitionsDAO extends DmlInterface {
    List<AppDefinition> getAppDefinitionRecordsByDurableIdSet(Set<String> durableIdSet);
}
