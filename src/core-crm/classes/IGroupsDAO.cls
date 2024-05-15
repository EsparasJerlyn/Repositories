/**
 * @description Interface for Lead DAO 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                   |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------------|
      | gabriel.p.ventayen             | May 9, 2023           | DEPP-8614              | Created file                                     |
 */
public interface IGroupsDAO extends DmlInterface {
    Id getQueueByName(String groupName); 
} 