/**
 * @description DAO Class for Product Object. Contains soql and constants related to the Product object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file
      | kenneth.f.alsay                | March 27, 2024        | DEPP-8209              | Added getProductByDonationCauseId
      | kenneth.f.alsay                | April 4, 2024         | DEPP-8399              | Added getProductByDesignationId
      | marygrace.li                   | May 2, 2024           | DEPP-8399              | Deleted getProductByDonationCauseId
      | kenneth.f.alsay                | May 7, 2024           | DEPP-8203              | Removed Donation Cause references
      | sebastianne.k.trias            | May 22, 2024          | DEPP-8410              | Added getProductsOnPage      |
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
    
    public List<Product2> getProductByDesignationId(
        Set<Id> designationIds,
        AccessLevel accessLevel
    ){
        if(designationIds.isEmpty()){
            return new List<Product2>();
        }
        return Database.query(
            'SELECT Id, Name, Description__c, Title_Image_URL__c, Designation__c ' +
            'FROM Product2 ' +
            'WHERE Designation__c IN :designationIds ',
            accessLevel
        );
    }    

    public List<Product2> getProductsOnPage(
        Set<Id> productIdSet,
        Set<Id> priceBookIds,
        AccessLevel accessLevel
    ){
        String isActiveCondition = '';
        if(UserInfo.getUserType().equals('Guest')){
            isActiveCondition = ' And IsActive = true ';
        }
        return Database.query(
            'SELECT Id, Name, Description, StockKeepingUnit, Course__c, Course__r.ProductRequestID__c, ' +
            'Course__r.Minimum_Participants__c,Course__r.Maximum_Participants__c,Program_Plan__c, ' +
            'Program_Plan__r.Program_Delivery_Structure__c,Program_Plan__r.Minimum_Participants__c, ' +
            'Program_Plan__r.Maximum_Participants__c,Duration__c,Delivery__c,Minimum_Participants_Group__c, ' +
            'Maximum_Participants_Group__c,Payment_Options__c,Register_Interest_Available__c, ' +
            'Overview__c,Evolve_with_QUTeX__c,Who_Should_Participate__c,Core_Concepts__c, ' +
            'More_Details__c,Do_not_Show_Start_Date__c,Product_Category__c, ' +
            '(SELECT Id, Pricebook2.Name, UnitPrice, Early_Bird_No_of_Days__c FROM PricebookEntries WHERE IsActive = TRUE AND (Pricebook2.IsStandard = true OR Pricebook2Id IN :priceBookIds)), ' +
            'Program_Plan__r.Product_Request__c ' +
            'FROM Product2 ' +
            'WHERE Id IN :productIdSet ' + 
            isActiveCondition,
            accessLevel
        );
    }
}