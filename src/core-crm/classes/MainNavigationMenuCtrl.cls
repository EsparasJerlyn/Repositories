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
      | mary.grace.li                  | November 22, 2022     | DEPP-4693            | Modified for Selected account logic|
 */

public without sharing class MainNavigationMenuCtrl {
    
    @AuraEnabled(cacheable=true)
    public static list<Opportunity> getOpportunityContractType(Id userId){
        list<Opportunity> opportunities =new list<Opportunity>();
        list<User> users = [SELECT Id,Name,ContactId,AccountId FROM User WHERE Id=:userId];
		if(users.size()!=0){
            Id accountId = users.get(0).AccountId;
            opportunities = [SELECT Id,Name,AccountId,Contract_Type__c FROM Opportunity WHERE AccountId=:accountId];
        }
        return opportunities;
    }
    @AuraEnabled(cacheable=true)
    public static String getAccountName(String userId){
		List<AccountContactRelation> getAccount = [
			SELECT Id, AccountId, ContactId,Account.Name
			FROM AccountContactRelation 
			WHERE Account.RecordType.Name = 'Business Organization' 
            AND IsActive = true
			AND ContactId IN (
				SELECT ContactId 
				FROM User 
				WHERE Id = :userId)];
        if(!getAccount.isEmpty()){
            return getAccount[0].Account.Name;
        }else{
            return '';
        }
    }

    @AuraEnabled
    public static AccountWrapper getAllAccountName(String userId, String selectedAccountId){
        AccountWrapper accountWrapperData = new AccountWrapper();
        List<AccountWrapper> acctWrapperList = new List<AccountWrapper>();
       
        //Get default logged-in account
        AccountContactRelation getAccount = [
			SELECT Id, AccountId, ContactId,Contact.hed__Primary_Organization__c
			FROM AccountContactRelation 
			WHERE Account.RecordType.Name = 'Business Organization' 
			AND ContactId IN (
				SELECT ContactId 
				FROM User 
				WHERE Id = :userId) LIMIT 1 
		];

        //Get all accounts
		List<AccountContactRelation> getAccounts = [
                SELECT Id, AccountId, ContactId,Account.Name, Account.ParentId,Contact.hed__Primary_Organization__c
                    FROM AccountContactRelation 
                    WHERE Account.RecordType.Name = 'Business Organization' 
                    AND ContactId IN (
                        SELECT ContactId 
                        FROM User 
                    WHERE Id = :userId) ORDER BY Account.Name ASC
		];

        for (AccountContactRelation accountContactRelation : getAccounts){
            AccountWrapper accountWrapper = new AccountWrapper();
            accountWrapper.fullLabel = accountContactRelation.Account.Name;
            
            if(accountContactRelation.Account.Name.length() > 80){
                accountWrapper.label = accountContactRelation.Account.Name.SubString(0, 80);
            }else{
                accountWrapper.label = accountContactRelation.Account.Name;
            }

            accountWrapper.value = accountContactRelation.AccountId; 

            //checking to set account as primary
            if(String.isBlank(selectedAccountId)){
                if(accountContactRelation.AccountId == getAccount.Contact.hed__Primary_Organization__c){
                    accountWrapper.isPrimaryAccount = true;
                    accountWrapper.isSelected = false;
                }
            }
            //checking to set account as selected
            if(accountContactRelation.AccountId == String.valueOf(selectedAccountId)){
                accountWrapper.isSelected = true;
            }

            acctWrapperList.add(accountWrapper);
        }

        
        //Set values to wrapper
        accountWrapperData.accountNames = acctWrapperList;

		return accountWrapperData;

    }

    
    @AuraEnabled(cacheable=true)
    public static List<NavigationMenuItem> defaultMenu(){
	    String publishedState = 'Live';
        List<NavigationMenuItem> menuItem = new List<NavigationMenuItem>();

		String networkId = Network.getNetworkId();
        List<NavigationLinkSet> linkSets  = [SELECT Id,MasterLabel FROM NavigationLinkSet WHERE NetworkId=:networkId];
        if(linkSets.size()!=0){
        Id linkSetId = linkSets.get(0).Id;  
        menuItem= [SELECT toLabel(Label), Target, Type, DefaultListViewId, AccessRestriction,ParentId,Position,Status,TargetPrefs 
        FROM NavigationMenuItem WHERE NavigationLinkSetId=:linkSetId AND Status = :publishedState];
			}
        return menuItem;

     }
    
    
    @AuraEnabled(cacheable=true)
    public static List<ProductCategory> getStoreFrontCategories(Id communityId){
		List<ProductCategory> productCategories =new List<ProductCategory>();
        String storeId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);

        List<WebStoreCatalog> catalogues = [SELECT SalesStoreId,ProductCatalogId FROM WebStoreCatalog WHERE SalesStoreId=:storeId];
        if(catalogues.size()!=0){
            Id catalogId = catalogues.get(0).ProductCatalogId;
            productCategories = [SELECT Name, Id, SortOrder FROM ProductCategory WHERE CatalogId=:catalogId AND IsNavigational = true ORDER By SortOrder ASC];
            }
        return productCategories;
    }
    @AuraEnabled(cacheable=true)
    public static List<ProductCategory> getStudyProducts(Id communityId){
        List<ProductCategory> productCategories =new List<ProductCategory>();
        String storeId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
        List<WebStoreCatalog> catalogues = [SELECT SalesStoreId,ProductCatalogId FROM WebStoreCatalog WHERE SalesStoreId=:storeId];
        if(catalogues.size()!=0){
            Id catalogId = catalogues.get(0).ProductCatalogId;
            productCategories = [SELECT Name,Id FROM ProductCategory WHERE CatalogId=:catalogId AND Name = 'Products'];
            }
        return productCategories;
    }

    public class AccountWrapper{
        @AuraEnabled
        public String accountId{ get; set; }
        @AuraEnabled
        public String contactId{ get; set; }
        @AuraEnabled
        public Boolean isPrimaryAccount{ get; set; }
        @AuraEnabled
        public Boolean isSelected{ get; set; }
        @AuraEnabled
        public String accountName{ get; set; }
        @AuraEnabled
        public String accountParentId{ get; set; }
        @AuraEnabled
		public String label;
        @AuraEnabled
		public String fullLabel;
		@AuraEnabled
		public String value;
        @AuraEnabled
		public List<AccountWrapper> accountNames;
    }

    /**
	 * @description Wrapper that contains list of accounts
	 */
	public class AccountWrapperData{
		@AuraEnabled
		public List<AccountWrapper> accountNames;
	}
}