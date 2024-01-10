/**
 * @description DAO Class for ProductLedger Object. Contains soql and constants related to the ProductLedger object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | Jan 05, 2024          | n/a                    | Created file
 */
public inherited sharing class ProductLedgersDAO extends DmlBase implements IProductLedgersDAO{

    public Schema.SObjectType getSObjectType()
	{
		return Product_Ledger__c.SObjectType;
	}

    public static IProductLedgersDAO newInstance()
	{
		return (IProductLedgersDAO) ImplementationSelector.DAO.newInstance(Product_Ledger__c.SObjectType);
	}
}