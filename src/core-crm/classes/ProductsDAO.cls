/**
 * @description DAO Class for Product Object. Contains soql and constants related to the Product object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file
 */
public inherited sharing class ProductsDAO extends DmlBase implements IProductsDAO{

    public Schema.SObjectType getSObjectType()
	{
		return Product2.SObjectType;
	}

    public static IProductsDAO newInstance()
	{
		return (IProductsDAO) ImplementationSelector.DAO.newInstance(Product2.SObjectType);
	}
}