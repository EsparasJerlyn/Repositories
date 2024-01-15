/**
 * @description Mock DAO Class for ProductLedger Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | Jan 05, 2024          | n/a                    | Created file
 */
@isTest
public inherited sharing class ProductLedgersDAOMock extends DmlBaseMock implements IProductLedgersDAO {

	public Map<Id, Product_Ledger__c> productLedgersMap;

    public Schema.SObjectType getSObjectType()
	{
		return Product_Ledger__c.SObjectType;
	}

	public ProductLedgersDAOMock() {
		super(new Map<Id, Product_Ledger__c>(), Schema.Product_Ledger__c.SObjectType);
		this.productLedgersMap = (Map<Id, Product_Ledger__c>) super.records;
	}
}