/**
 * @description Interface for Buyer Group DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | arsenio.jr.dayrit              | January 02, 2024      |  ApexCRUDViolationFix  | Created file                 |
 */
public interface IBuyerGroupsDAO extends DmlInterface {

    List<BuyerGroup> getBuyerGroupsByProductRequestId(
        Set<Id> productRequestIds,
        AccessLevel accessLevel
    );  
}
