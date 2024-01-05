/**
 * @description Interface for BuyerGroupPriceBook DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | Jan 05, 2024          | n/a                    | Created file
 */
public interface IBuyerGroupPriceBooksDAO extends DmlInterface {
     List<BuyerGroupPriceBook> getBuyerGroupPriceBooksByPricebookId(
          Id pricebookId,
          AccessLevel accessLevel
     );

     List<BuyerGroupPriceBook> getBuyerGroupPriceBooksByPricebookIds(
          Set<Id> pricebookIds,
          AccessLevel accessLevel
     );
}
