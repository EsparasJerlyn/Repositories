/**
 * @description DAO Class for BuyerGroupPriceBook Object. Contains soql and constants related to the BuyerGroupPriceBook object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | Jan 05, 2024          | n/a                    | Created file
 */
public inherited sharing class BuyerGroupPriceBooksDAO extends DmlBase implements IBuyerGroupPriceBooksDAO{
	public Schema.SObjectType getSObjectType()
	{
		return BuyerGroupPriceBook.SObjectType;
	}

    public static IBuyerGroupPriceBooksDAO newInstance()
	{
		return (IBuyerGroupPriceBooksDAO) ImplementationSelector.DAO.newInstance(BuyerGroupPriceBook.SObjectType);
	}

	public List<BuyerGroupPriceBook> getBuyerGroupPriceBooksByPricebookId(
		Id pricebookId,
		AccessLevel accessLevel
	) {
		if(pricebookId != null && accessLevel != null) {
			// PMD bypass, variables are used in dynamic query.
			String productRequestSOADevName = ProductRequestsDAO.PR_SOA; //NOPMD
			String productRequestCBDevName = ProductRequestsDAO.PR_CORP_BUNDLE; //NOPMD
			return Database.query(
				'SELECT Id, BuyerGroupId, ' +
				'BuyerGroup.Product_Request__r.Product_Specification__r.Opportunity_Name__r.AccountId ' +
				'FROM BuyerGroupPriceBook ' +
				'WHERE Pricebook2Id = :pricebookId ' +
				'AND (BuyerGroup.Product_Request__r.RecordType.DeveloperName = :productRequestSOADevName ' +
				'OR BuyerGroup.Product_Request__r.RecordType.DeveloperName = :productRequestCBDevName) ' +
				'AND BuyerGroup.Product_Request__r.Product_Specification__r.Opportunity_Name__r.AccountId != null',
				accessLevel
			);
		} else { return new List<BuyerGroupPriceBook>(); }
	}

	public List<BuyerGroupPriceBook> getBuyerGroupPriceBooksByPricebookIds(
		Set<Id> pricebookIds,
		AccessLevel accessLevel
	) {
		if(!pricebookIds.isEmpty() && accessLevel != null) {
			return Database.query(
				'SELECT Id, BuyerGroup.Product_Request__c, Pricebook2Id ' +
				'FROM BuyerGroupPriceBook ' +
				'WHERE Pricebook2Id IN :pricebookIds ' +
				'AND BuyerGroup.Product_Request__c != null ' +
				'AND Pricebook2Id != null',
				accessLevel
			);
		} else { return new List<BuyerGroupPriceBook>(); }
	}
}