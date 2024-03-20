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

	public List<Product2> getProductById(
        Set<Id> productIdSet,
        AccessLevel accessLevel
    ){
        if(productIdSet.isEmpty()){
            return new List<Product2>();
        }
        return Database.query(
            'SELECT Id, Name, Description, Overview__c, Evolve_with_QUTeX__c, Who_Should_Participate__c, Core_Concepts__c, More_Details__c, Available_on_Cart__c ' +
            'FROM Product2 ' +
            'WHERE Id IN :productIdSet ',
            accessLevel
        );
    }
}