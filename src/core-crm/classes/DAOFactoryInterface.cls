/**
 * @description interface for DAO factory
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | rhea.b.torres                  | April 25, 2023        | DEPP-5567              | Created file
 */
public interface DAOFactoryInterface {
    DmlInterface newInstance(SObjectType sObjectType);
}
