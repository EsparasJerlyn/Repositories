/**
 * @description Mock DAO Class for BuyerGroupPriceBook Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | Jan 05, 2024          | n/a                    | Created file
 */
@isTest
public inherited sharing class BuyerGroupPriceBooksDAOMock extends DmlBaseMock implements IBuyerGroupPriceBooksDAO {

	public Map<Id, BuyerGroupPriceBook> buyerGroupPriceBooksMap;

    public Schema.SObjectType getSObjectType()
	{
		return BuyerGroupPriceBook.SObjectType;
	}

	public BuyerGroupPriceBooksDAOMock() {
		super(new Map<Id, BuyerGroupPriceBook>(), Schema.BuyerGroupPriceBook.SObjectType);
		this.buyerGroupPriceBooksMap = (Map<Id, BuyerGroupPriceBook>) super.records;
	}

	public List<BuyerGroupPriceBook> getBuyerGroupPriceBooksByPricebookId(
		Id pricebookId,
		AccessLevel accessLevel
	) {
		List<BuyerGroupPriceBook> bgPriceBooks = new List<BuyerGroupPriceBook>();
		for(BuyerGroupPriceBook bgPriceBook : buyerGroupPriceBooksMap.values()) {
			if(bgPriceBook.Pricebook2Id == pricebookId) {
				bgPriceBooks.add(bgPriceBook);
			}
		}
		return bgPriceBooks;
	}

	public List<BuyerGroupPriceBook> getBuyerGroupPriceBooksByPricebookIds(
		Set<Id> pricebookIds,
		AccessLevel accessLevel
	) {
		List<BuyerGroupPriceBook> bgPriceBooks = new List<BuyerGroupPriceBook>();
		for(BuyerGroupPriceBook bgPriceBook : buyerGroupPriceBooksMap.values()) {
			if(pricebookIds.contains(bgPriceBook.Pricebook2Id)) {
				bgPriceBooks.add(bgPriceBook);
			}
		}
		return bgPriceBooks;
	}
}