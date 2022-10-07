/**
 * @description Add a custom tab for more flexible manipulation
 * @see ../lwc/mainNavigationMenuCtrl
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                 | Change Summary               |
      |--------------------------------|-----------------------|----------------------|------------------------------|
      | aljohn.motas@qut.edu.au        | January 14, 2022      | DEP1-1392            | Created file                 | 
      | marygrace.li@qut.edu.au        | June 1, 2022          | DEPP-2854            | Added getStudyStore          |
      | dodge.palattao@qut.edu.au      | June 4, 2022          | DEPP-2809            | Added getStudyProducts       | 
 */

public without sharing class MainNavigationMenuCtrl {
    
    @AuraEnabled(cacheable=true)
    public static list<Opportunity> getOpportunityContractType(Id userId){
        list<Opportunity> opportunities =new list<Opportunity>();
        list<User> users = [SELECT Id,Name,ContactId,AccountId FROM User WHERE Id=:userId];
		if(users.size()!=0){
            Id account_Id = users.get(0).AccountId;
            opportunities = [SELECT Id,Name,AccountId,Contract_Type__c FROM Opportunity WHERE AccountId=:account_Id];
        }
        return opportunities;
    }
    @AuraEnabled(cacheable=true)
    public static String getAccountName(String userId){
		List<AccountContactRelation> getAccount = [
			SELECT Id, AccountId, ContactId,Account.Name
			FROM AccountContactRelation 
			WHERE Account.RecordType.Name = 'Business Organization' 
			AND ContactId IN (
				SELECT ContactId 
				FROM User 
				WHERE Id = :userId)
		];
        if(!getAccount.isEmpty()){
            return getAccount[0].Account.Name;
        }else{
            return '';
        }
    }

    
    @AuraEnabled(cacheable=true)
    public static List<NavigationMenuItem> defaultMenu(){
	    String publishedState = 'Live';
        List<NavigationMenuItem> MenuItem = new List<NavigationMenuItem>();

		String networkId = Network.getNetworkId();
        List<NavigationLinkSet> linkSets  = [SELECT Id,MasterLabel FROM NavigationLinkSet WHERE NetworkId=:networkId];
        if(linkSets.size()!=0){
        Id linkSetId = linkSets.get(0).Id;  
        MenuItem= [SELECT toLabel(Label), Target, Type, DefaultListViewId, AccessRestriction,ParentId,Position,Status,TargetPrefs 
        FROM NavigationMenuItem WHERE NavigationLinkSetId=:linkSetId AND Status = :publishedState];
			}
        return MenuItem;

     }
    
    
    @AuraEnabled(cacheable=true)
    public static List<ProductCategory> getStoreFrontCategories(Id communityId){
		List<ProductCategory> ProductCategories =new List<ProductCategory>();
        String StoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
        List<WebStoreCatalog> Catalogues = [SELECT SalesStoreId,ProductCatalogId FROM WebStoreCatalog WHERE SalesStoreId=:StoreId];
        if(Catalogues.size()!=0){
            Id Catalog_Id = Catalogues.get(0).ProductCatalogId;
            ProductCategories = [SELECT Name, Id, SortOrder FROM ProductCategory WHERE CatalogId=:Catalog_Id AND IsNavigational = true ORDER By SortOrder ASC];
            }
        return ProductCategories;
    }
    @AuraEnabled(cacheable=true)
    public static List<ProductCategory> getStudyProducts(Id communityId){
        List<ProductCategory> ProductCategories =new List<ProductCategory>();
        String StoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
        List<WebStoreCatalog> Catalogues = [SELECT SalesStoreId,ProductCatalogId FROM WebStoreCatalog WHERE SalesStoreId=:StoreId];
        if(Catalogues.size()!=0){
            Id Catalog_Id = Catalogues.get(0).ProductCatalogId;
            ProductCategories = [SELECT Name,Id FROM ProductCategory WHERE CatalogId=:Catalog_Id AND Name = 'Products'];
            }
        return ProductCategories;
    }
}